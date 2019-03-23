#                                                  HBase

## 1、HBase介绍

（1）HBase的原型是Google的Bigtable论文，受到该论文的启发，目前作为Hadoop的子项目来维护，用于支持非结构化和半结构化的松散数据存储。

（2）HBase的角色

**Client**：Client包含了访问HBase的接口，另外Client还维护了对应的cache来加速HBase的访问，比如cache的.META.元数据的信息。

**Zookeeper:**

​	HBase通过Zookeeper来做master的高可用、RegionServer的监控、元数据的入口以及集群配置的维护工作，具体工作如下：

​	通过Zookeeper来保证集群中只有一个master在运行，如果master异常，会通过竞争机制产生新的master。

​	通过Zookeeper来监控RegionServer的状态，当RegionServer有异常的时候，通过回调函数的形式通知Master、RegionServer上下线的信息。

​	通过Zookeeper存储元数据的统一入口地址。（记录-ROOT-表的位置信息）

**HMaster**：

master节点的主要职责如下：

为RegionServer分配Region；

维护集群的负载均衡；

维护集群的元数据信息（-root-表）

发现失效的Region，并将失效的Region分配到正常的RegionServer上，

当RegionServer失效的时候，协调对应的Hlog拆分。

**HRegionServer**：

HRegionServer直接对接用户的读写请求，是真正干活的节点，它的功能概括如下：

管理master为其分配的Region

处理来自客户端的读写请求

负责和底层的HDFS进行交互，存储数据到HDFS

负责Region变大以后的拆分

负责StoreFile的合并工作。

**HDFS**：

HDFS为HBase提供最终的底层数据存储服务，同时为HBase提供高可用（Hlog存储在HDFS）的支持，具体功能概括如下：

提供元数据和表数据的底层分布存储服务

数据多副本，保证高可靠和高可用

## 2、HBase架构

![1552880341714](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552880341714.png)

​	HBase是基于HDFS构建上来存储的框架，所以它的底层是HDFS，核心是DataNode，DataNode是实际存储数据的地方，DataNode是一个Java进程，用于管理Linux文件夹。HBase集群中仍然通过Zookeeper来调度和管理HMaster和HRegionserver，Zookeeper通过选举，保证什么时候，集群中都只有一个活跃的HMaster，HMaster和HRegionServer在启动的时候，都会向Zookeeper注册，存储HRegion的寻址入口，实时监控HRegionServer的上下线信息，并实时通知给HMaster。	

​	HRegionServer也是一个Java进程，可以理解为存储HRegion的服务器，一个HRegionServer会维护多个HRegion，但一个HRegionServer上只有一个HLog，HLog相当于MySql中的mysqlbin文件，用于记录操作日志，一张表对应一个或多个HRegion，因为一张表本来对应一个HRegion，当表非常大的时候，他会进行切分，形成不同的HRegion，否则维护起来非常困难。一个列族对应一个或多个Store，一个Store对应一个列族，列族不会单独进行切分，都是随着Region的切分而切分。一个Store里面会有一个MemStore，Store里面的数据会先写到MemStore里面，当达到一定的数据量时再把数据刷写到StoreFile里，HFile是StoreFile在磁盘上的存储格式，StoreFile通过HDFS Client调用把数据存储到DataNode即Linux本地文件系统上，Client是触发读写请求的。

## 3、HBase读写数据过程

![1552638745786](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552638745786.png)

首先需要知道HBase的三层结构，在HBase的三层结构中，先是-ROOT-表，然后是.META.表，最后是用户数据表。-ROOT-表保存在Zookeeper中，里面保存了.META.表的地址信息，即保存着.META.表存储在哪个HRegionServer上，.META.表存储在HRegionServer上，里面保存着用户数据表的Region位置信息。

**读数据过程**

![1552641548340](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552641548340.png)

![1552645764969](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552645764969.png)

（1）HRegionserver保存着meta表以及表数据，要访问数据，首先要去Zookeeper，从Zookeeper中获取meta表所在的位置信息，即找到这个meta表保存在哪个HRegionServer上；

（2）接着Client通过刚才获取到的HRegionServer的IP来访问meta表，从而获得meta表中存储的元数据信息，meta表中保存了表具体存放在哪个Region上；

（3）Client通过元数据中存储的信息，访问对应的HRegion，然后扫描Memstore和Storefile来查询数据（先MemStore，再StoreFile）

（4）最后HRegionserver把查询到的数据响应给Client

**写数据过程**

（1）Client先访问Zookeeper，找到Meta表，并获取Meta表信息

（2）确定当前将要写入的数据对应的RegionServer服务器和Region

（3）Client向RegionServer服务器发起写数据请求，然后RegionServer收到请求并响应。

（4）Client先把数据写入到HLog中，以防止数据丢失

（5）然后将数据写入到MemStore中

（6）如果Hlog和MemStore均写入成功，则这条数据写入成功，此时向Client返回写入成功的信息。在此过程中，如果MemStore达到阈值（默认是64M），会把Memstore中的数据flush到StoreFile中，将内存中的数据删除，同时删除HLog中的历史数据。

（7）当StoreFile越来越多，会触发Compact合并操作，把过多的StoreFile合并成一个大的StoreFile。当StoreFile越来越大的时候，Region也会越来越大，达到阈值后，会触发Split操作，将Region一分为二。

**Flush触发条件**

（1）RegionServer级别：整个内存MemStore达到RegionServer的40%

（2）任一MemStore中的数据达到一个小时的时候

（3）HRegion里面所有内存超过128M时

## 4、HBase基本命令

（1）查看当前数据库中有哪些表list 

（2）创建表create '表名','列族'  创建表的时候需要指定表名和列族 eg： create 'student','info'

​	创建多个列族  create '表名',{NAME=>'列族名'，NAME=>'列族名'}

（3）插入数据 put '表名','行键','列族：列限定符','插入值'   eg: put student, '1001','info:name','Thomas'

（4）扫描查看表数据 

​	查看整个表数据，scan '表名'  eg: sacn 'student'  

​	查看特定行键区域内的数据  scan '表名',{STARTROW => '1001',STOPROW => '1001'}，可以省略STARTROW 	或STOPROW ，左闭右开

（5）查看表结构 disable '表名'  eg: disable 'student'	

（6）更新指定字段数据 put '表名','行键','列族:列限定符','值'    eg: put 'student','1001','info:name','Nick'

（7）查看“指定列”或“指定列族：列的数据”

​	get '表名','行键'       eg: get 'student','1001'

​	get '表名','行键','列族:列限定符'    eg: get 'student','1001','info:name'

（8）删除数据

​	删除某rowkey的全部数据  deleteall '表名','行键'        eg: deleteall 'student','1001'

​	删除某rowkey的某一列数据： delete '表名',‘行键’,'列族:列限定符'   eg: delete 'student','1001',info:sex'

（9）禁用表disable ‘表名’      启用表enable '表名'

（10）清空表（本质是先删除一个表，再创建一个空表），清空表的操作顺序为disable，然后再truncating

​	  truncate '表名'

![1552896299587](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552896299587.png)

（11）删除表，删除表的操作顺序为先disable，再drop

​	disable '表名'  drop '表名'

（12）删除一行中一个单元格的值

​	delete ‘表名’,'行键','列族：列限定符'

（13）变更表信息

​	将Student表中，info列族的数据存放三个版本 alter 'Student',{NAME => 'info',VERSIONS => 3}

​	为当前表增加列族  alter '表名'，NAME=>'列族名',VERSIONS=>2

​	删除列族 alter '表名','delete'=>'列族名'

（14）显示服务器状态      status ‘主机名’     eg: status ‘hadoop-master’

（15）显示当前用户   whoami

（16）统计指定表的记录数 count '表名'

（17）检查表是不是存在 exist '表名'

（18）检查表是否启用或禁用  is_enable '表名'

## 5、节点的管理

（1）服役（commissioning）

当启动 regionserver 时， regionserver 会向 HMaster 注册并开始接收本地数据，开始的时候，
新加入的节点不会有任何数据，平衡器开启的情况下，将会有新的 region 移动到开启的
RegionServer 上。如果启动和停止进程是使用 ssh 和 HBase 脚本，那么会将新添加的节点的
主机名加入到 conf/regionservers 文件中。 

（2）退役（decommissioning）

顾名思义，就是从当前 HBase 集群中删除某个 RegionServer，

## 6、HBase的优化

（1）预分区

每一个Region维护着startRow和stopRowKey，如果加入的数据符合某个Region维护的rowkey范围，则该数据交给这个Region维护，那么依照这个原则，我们可以将数据索要投放的分区提前大致规划好，以提高HBase性能。

a、手动设置预分区

create ‘表名’，‘列族’，‘列限定符’，SPLITS=>['1000','2000','3000','4000']

eg: create 'fenqu','info','partition1',SPLITS=>['1000','2000','3000','4000']

![1552966323330](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552966323330.png)

b、生成16进制序列预分区

create ‘fenqu’,'info','partition2',{NUMREGIONS=> 15,SPLITALGO => 'HexStringSplit'}

![1552966747638](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552966747638.png)

![1552966775164](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552966775164.png)

c、按照文件中设置的规则预分区

d、使用JavaAPI创建预分区

（2）Rowkey设计

一条数据的唯一标识就是rowkey，那么这条数据存储于哪个分区，取决于rowkey处于哪个一个预分区的区间内，设计rowkey的主要目的，就是让数据均匀的分布于所有的Region中，在一定程度上防止数据倾斜。

a、生成随机数、hash、散列值

b、字符串反转

c、字符串拼接

（3）内存优化

HBase操作过程中需要大量的内存开销，毕竟Table是可以缓存再内存中的，一般会分配整个可用内存的70%给HBase的Java堆。但是不建议分配非常大的堆内存，因为GC（Garbage Collection，垃圾收集，垃圾回收）过程持续太久会导致Regionserver处于长期不可用状态，一般16-48G就可以了，如果因为框架占用内存过高导致系统内存不足，框架一样会被系统服务拖死。

（4）基础优化

a、允许在HDFS的文件中追加内容

开启HDFS追加同步，可以优秀的配合HBase的数据同步和持久化，默认值为true。

b、优化DataNode允许的最大文件打开数

HBase一般都会同一时间操作大量的文件，根据集群的数量和规模以及数据动作，设置为4096或者更高，默认值为：4096

c、优化延迟高的数据操作的等待时间

如果对于某一次数据操作来讲，延迟非常高，Socket需要等待更长的时间，建议把该值设置为更大的值（默认60000毫秒），以确保Socket不会被timeout掉

d、优化数据的写入效率

mapreduce.map.output.compress
mapreduce.map.output.compress.codec

开启这两个数据可以大大提高文件的写入效率，减少写入时间。

## 7、Hive和HBase的区别

\1. 两者分别是什么？  

 Apache Hive是一个构建在Hadoop基础设施之上的数据仓库。通过Hive可以使用HQL语言查询存放在HDFS上的数据。HQL是一种类SQL语言，这种语言最终被转化为Map/Reduce. 虽然Hive提供了SQL查询功能，但是Hive不能够进行交互查询--因为它只能够在Haoop上批量的执行Hadoop。

​    Apache HBase是一种Key/Value系统，它运行在HDFS之上。和Hive不一样，Hbase的能够在它的数据库上实时运行，而不是运行MapReduce任务。Hive被分区为表格，表格又被进一步分割为列簇。列簇必须使用schema定义，列簇将某一类型列集合起来（列不要求schema定义）。例如，“message”列簇可能包含：“to”, ”from” “date”, “subject”, 和”body”. 每一个 key/value对在Hbase中被定义为一个cell，每一个key由row-key，列簇、列和时间戳。在Hbase中，行是key/value映射的集合，这个映射通过row-key来唯一标识。Hbase利用Hadoop的基础设施，可以利用通用的设备进行水平的扩展。

\2. 两者的特点

  Hive帮助熟悉SQL的人运行MapReduce任务。因为它是JDBC兼容的，同时，它也能够和现存的SQL工具整合在一起。运行Hive查询会花费很长时间，因为它会默认遍历表中所有的数据。虽然有这样的缺点，一次遍历的数据量可以通过Hive的分区机制来控制。分区允许在数据集上运行过滤查询，这些数据集存储在不同的文件夹内，查询的时候只遍历指定文件夹（分区）中的数据。这种机制可以用来，例如，只处理在某一个时间范围内的文件，只要这些文件名中包括了时间格式。

​    HBase通过存储key/value来工作。它支持四种主要的操作：增加或者更新行，查看一个范围内的cell，获取指定的行，删除指定的行、列或者是列的版本。版本信息用来获取历史数据（每一行的历史数据可以被删除，然后通过Hbase compactions就可以释放出空间）。虽然HBase包括表格，但是schema仅仅被表格和列簇所要求，列不需要schema。Hbase的表格包括增加/计数功能。

\3. 限制

  Hive目前不支持更新操作。另外，由于hive在hadoop上运行批量操作，它需要花费很长的时间，通常是几分钟到几个小时才可以获取到查询的结果。Hive必须提供预先定义好的schema将文件和目录映射到列，并且Hive与ACID不兼容。

​    HBase查询是通过特定的语言来编写的，这种语言需要重新学习。类SQL的功能可以通过Apache Phonenix实现，但这是以必须提供schema为代价的。另外，Hbase也并不是兼容所有的ACID特性，虽然它支持某些特性。最后但不是最重要的--为了运行Hbase，Zookeeper是必须的，zookeeper是一个用来进行分布式协调的服务，这些服务包括配置服务，维护元信息和命名空间服务。

\4. 应用场景

​    Hive适合用来对一段时间内的数据进行分析查询，例如，用来计算趋势或者网站的日志。Hive不应该用来进行实时的查询。因为它需要很长时间才可以返回结果。

​    Hbase非常适合用来进行大数据的实时查询。Facebook用Hbase进行消息和实时的分析。它也可以用来统计Facebook的连接数。

\5. 总结

​    Hive和Hbase是两种基于Hadoop的不同技术--Hive是一种类SQL的引擎，并且运行MapReduce任务，Hbase是一种在Hadoop之上的NoSQL 的Key/vale数据库。当然，这两种工具是可以同时使用的。就像用Google来搜索，用FaceBook进行社交一样，Hive可以用来进行统计查询，HBase可以用来进行实时查询，数据也可以从Hive写到Hbase，设置再从Hbase写回Hive。

## 8、描述Hbase的rowKey的设计原则.

rowkey的三大设计原则：长度、散列、唯一性

**Rowkey长度原则**

Rowkey 是一个二进制码流，Rowkey 的长度被很多开发者建议说设计在10~100 个字节，

不过建议是越短越好，不要超过16 个字节。

原因如下：

（1）数据的持久化文件HFile 中是按照KeyValue 存储的，如果Rowkey 过长比如100 个

字节，1000 万列数据光Rowkey 就要占用100*1000 万=10 亿个字节，将近1G 数据，这会极

大影响HFile 的存储效率；

（2）MemStore 将缓存部分数据到内存，如果Rowkey 字段过长内存的有效利用率会降

低，系统将无法缓存更多的数据，这会降低检索效率。因此Rowkey 的字节长度越短越好。

（3）目前操作系统是都是64 位系统，内存8 字节对齐。控制在16 个字节，8 字节的

整数倍利用操作系统的最佳特性。

**Rowkey散列原则**

如果Rowkey 是按时间戳的方式递增，不要将时间放在二进制码的前面，建议将Rowkey

的高位作为散列字段，由程序循环生成，低位放时间字段，这样将提高数据均衡分布在每个

Regionserver 实现负载均衡的几率。如果没有散列字段，首字段直接是时间信息将产生所有

新数据都在一个 RegionServer 上堆积的热点现象，这样在做数据检索的时候负载将会集中

在个别RegionServer，降低查询效率。

**Rowkey唯一原则**

必须在设计上保证其唯一性。

## 8、描述Hbase中scan和get的功能以及实现的异同.


HBase的查询实现只提供两种方式：

1、按指定RowKey 获取唯一一条记录，get方法（org.apache.hadoop.hbase.client.Get）

Get 的方法处理分两种 : 设置了ClosestRowBefore 和没有设置的rowlock .主要是用来保证行的事务性，即每个get 是以一个row 来标记的.一个row中可以有很多family 和column.

2、按指定的条件获取一批记录，scan方法(org.apache.Hadoop.hbase.client.Scan）实现条件查询功能使用的就是scan 方式.

1)scan 可以通过setCaching 与setBatch 方法提高速度(以空间换时间)；

2)scan 可以通过setStartRow 与setEndRow 来限定范围([start，end)start 是闭区间，

end 是开区间)。范围越小，性能越高。

3)、scan 可以通过setFilter 方法添加过滤器，这也是分页、多条件查询的基础。

## 9、请描述如何解决Hbase中region太小和region太大带来的冲突.

Region过大会发生多次storeFile的compaction，将数据读一遍并重写一遍到hdfs 上，占用io，region过小会造成多次split，region 会下线，影响访问服务，调整hbase.hregion.max.filesize 为256m.

## 10、简述 HBASE中compact

在hbase中每当有memstore数据flush到磁盘之后，就形成一个storefile，当storeFile的数量达到一定程度后，就需要将 storefile 文件来进行 compaction 操作。

Compact 的作用：

1>.合并文件

2>.清除过期，多余版本的数据

3>.提高读写数据的效率

HBase 中实现了两种 compaction 的方式：minor and major. 这两种 compaction 方式的区别是：

1、Minor 操作只用来做部分文件的合并操作以及包括 minVersion=0 并且设置 ttl 的过

期版本清理，不做任何删除数据、多版本数据的清理工作。

2、Major 操作是对 Region 下的HStore下的所有StoreFile执行合并操作，最终的结果是整理合并出一个文件。







