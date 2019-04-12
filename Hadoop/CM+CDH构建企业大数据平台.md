#                   CM+CDH构建企业大数据平台

## 1、如何构建企业大数据平台

（1）解决大规模数据存储问题

​	a、增加本机的磁盘空间

​	但是不可能一直增加，本机存储空间总会有一定的极限，加到一定程度就会超过限制。

​	b、增加机器数量，用共享目录的方式提供远程网络化存储。

​	这种方式是分布式的雏形，就是把同一文件切分之后放入到不同的机器中，空间不足了还可以继	续增加机器，突破本机存储空间的限制。存储数据的目的是想通过对大规模数据的多维分析挖掘	出数据背后对企业运营决策有价值的信息。

（2）如何对大规模数据进行分析？也就是如何解决大规模数据的计算的问题？

​	大规模数据存储通过分布式存储解决存储容量局限的问题

​	大规模数据计算重点考虑是计算速度的问题。就是怎么能够加快大规模数据的处理问题？

​	一台机器资源有限，计算大规模数据可能时间很长，那么怎么加快处理速度呢？整多台，一台不够多台来凑，每个任务处理一部分数据，多台机器的多个任务分别处理一部分数据，这样速度肯定会比之前快。

    总之，不管是大数据的存储还是计算，都是通过分布式系统来解决的，不再通过比较昂贵的小型机，因为小型机成本太高。那么分布式系统在哪运行呢，就需要构建分布式集群。所以说我们接下来的重点就是如何构建分布式集群。
## 2、什么叫构建Hadoop分布式集群？

构建分布式集群实际上就是在一组通过网络连接的物理计算机组成的集群上安装部署Hadoop相关的软件。

![1552544041020](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552544041020.png)

所以接下来我们的任务就是：

（1）首先准备物理集群

（2）实现物理集群的网络互联，就是通过网络把集群内所有机器连接起来

（3）在实现网络互联的集群上安装部署大数据相关的软件

基础环境

- 软件环境

| NO   | 软件名称         | 版本                                            |
| ---- | ---------------- | ----------------------------------------------- |
| 1    | 操作系统         | centos7 64位                                    |
| 2    | jdk              | jdk-8u181-linux-x64.tar.gz                      |
| 3    | cloudera manager | cloudera-manager-centos7-cm5.15.1_x86_64.tar.gz |
| 4    | cdh              | CDH-5.15.1-1.cdh5.15.1.p0.4-el7                 |
| 5    | 数据库           | mysql-5.7.18-1.el7.x86_64.rpm-bundle.tar        |
| 6    | jdbc             | mysql-connector-java-5.1.43.jar                 |

- 配置规划

| NO   | 机器名称 | IP        | 配置         | 用途                |
| ---- | -------- | --------- | ------------ | ------------------- |
| 1    | master   | 10.2.47.1 | 16C/32G/500G | master，cm，mysqldb |
| 2    | slave1   | 10.2.47.2 | 16C/32G/500G | slave               |
| 3    | slave2   | 10.2.47.3 | 16C/32G/500G | slave               |
| 4    | slave3   | 10.2.47.4 | 16C/32G/500G | slave               |
| 5    | slave4   | 10.2.47.5 | 16C/32G/500G | slave               |

## 3、集群规模的影响因素

（1）数据量（要考虑用多少台机器组成的集群能存储这么大的数据）

a、规划时间内的数据而不是现有的数据

这个数据量是公司一定规划时间内（比如两年）的数据量，不是现有的数据量，因为你不可能随着数据量的增加每月或每周都往集群里增加节点，这样每天绝大部分时间就都花在集群维护上了，虽然说我们的确可以随着数据量的动态变化通过动态的增减节点的个数来调整集群的存储和计算能力，但是最好还是要有一个1-2年左右的中长期规划。

b、多副本

因为Hadoop致力于构建在廉价的商用服务器上的，廉价的就更容易出现故障，出现故障就容易导致数据丢失，数据丢失是绝对不允许的。所以说怎么保证数据安全性呢？一份不够，存多份就得了呗，难道你们还能同时丢到，虽然说有可能，但是可能性是不是就小很多了。当然你也不可能买特别垃圾的服务器。我们需要在采购成本和维护成本之间做好权衡。

c、中间数据、临时数据和日志数据需要占用20-30%左右的空间

因为数据不只是需要分析处理的业务数据。

（2）每台机器的性能配置

假设有100T的数据，每台机器2T硬盘，至少需要50台，每台机器4T硬盘，至少需要25台，所以说机器性能配置的不同也会影响集群规模的大小。后边我们会单独讲机器选型及配置选择。

（3）平台的功能性和非功能性需求

平台实现基本的功能之外还需要实现非功能需求：

a、性能需求：

比如对100G—1T左右的数据进行简单的查询分析，能够在2分-10分钟之内完成，复杂作业（比如多表连接）能够在20-1小时内完成，业务数据的增量导入和数据清洗在1小时之内完成。

b、可靠性需求：

比如系统每月宕机次数不能超过1次。

c、可用性需求：

系统每次宕机的时间不能超过两小时，还有就是系统内任何一台计算机每月不可用的时间不能超过总时间的2%。

d、容错性需求：

 机器宕机、服务停止硬件损坏的情况下数据不会出现丢失，不同情况下的恢复时间也有要求，比如宕机或服务器停止，恢复时间10分钟之内，如果NameNode硬件损坏，2小时之内恢复。

所以接下来的任务就是：

a、先确定选择什么样的机器，也就是机器选型，当然包括机器的配置资源了

b、再确定集群的规模，也就是集群包含多少台机器

**注意：在机器选型时并不是每台机器的配置必须都是一样的，因为不管是Hadoop中的HDFS还是YARN都是分布式系统，采用的是主从的架构，建议主节点的配置要高于从节点，从节点的配置建议一样，不同组件的安装部署配置可以不同。具体根据不同的业务场景进行不同的配置选择。**

## 4、Cloudera Manager是啥？主要是干啥的？

（1） 简单来说，Cloudera Manager是一个拥有集群自动化安装、中心化管理、集群监控、报警功能的一个工具（软件）,使得安装集群从几天的时间缩短在几个小时内，运维人员从数十人降低到几人以内，极大的提高集群管理的效率。

**cloudera manager有四大功能：**
　　（1）管理：对集群进行管理，如添加、删除节点等操作。
　　（2）监控：监控集群的健康情况，对设置的各种指标和系统运行情况进行全面监控。
　　（3）诊断：对集群出现的问题进行诊断，对出现的问题给出建议解决方案。
　　（4）集成：对hadoop的多组件进行整合。

（2）、Cloudera Manager架构原理

**cloudera manager的核心**是管理服务器，该服务器承载管理控制台的Web服务器和应用程序逻辑，并负责安装软件，配置，启动和停止服务，以及管理上的服务运行群集。

![1552542866874](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552542866874.png)

**Cloudera Manager Server由以下几个部分组成：**

　　Agent：安装在每台主机上。该代理负责启动和停止的过程，拆包配置，触发装置和监控主机。
　　Management Service：由一组执行各种监控，警报和报告功能角色的服务。
　　Database：存储配置和监视信息。通常情况下，多个逻辑数据库在一个或多个数据库服务器上运行。例如，Cloudera的管理服务器和监控角色使用不同的逻辑数据库。
　　Cloudera Repository：软件由Cloudera 管理分布存储库。
　　Clients：是用于与服务器进行交互的接口：

　　Admin Console ：基于Web的用户界面与管理员管理集群和Cloudera管理。
      API ：与开发人员创建自定义的Cloudera Manager应用程序的API。

## 5、CM和CDH有什么关系？

简单的说就是通过CM统一的图形化界面快速自动的安装部署CDH相关的服务组件。

（1）、CM（Cloudera Manage）是Cloudera公司研发的一款可以让企业对大数据平台的管理和维护变得更简单更直观的管理工具。

CM可以实现以下功能：

a、自动化安装软件，不用我们先单独的下载解压，然后修改配置文件等等复杂的操作，只需要按照提示点击对应的按钮即可。

b、可以查看整个集群或各个节点的实时运行状态。对集群进行监控和报警。这个是不是更直观，否则你还要单独部署监控组件，比如Ganglia。

c、可以通过图形化界面修改集群的配置文件  

 这些是最直观的功能，当然还有其他高级功能，比如滚动升级、自定义图表、自定义报警监控、安全机制等等，目前CM支持的版本如下：

![1552546960566](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552546960566.png)

（2）、CDH就是Cloudera's Distribution including Apache Hadoop的缩写，即CDH是包含Apache Hadoop的Cloudera的发行版。

CDH有什么好处呢？

a、基于Apache协议，100%开源

b、基于稳定版本Apache Hadoop，并修复了大量的Bug，比Apache Hadoop的兼容性、安全性、稳定性更强

c、充分考虑了各个大数据组件之间的版本兼容性，版本管理更清晰（比如CDH5）

d、版本更新快，通常每2-3个月都会有一次更新

e、集群管理维护更简单方便，提供了部署、安装、配置、监控、诊断等工具（CM），大大提高了集群部署及维护的效率

（3）、CM和CDH的区别

通过CM统一的图形化界面快速自动的安装部署CDH相关的服务组件，所以说CM是一个web工具，CDH是一个软件栈，它包含很多软件，这些软件怎么安装呢，我们可以先安装CM，然后通过CM图形化界面自动的安装CDH里包含的各种软件。就这么简单。

（4）为什么要使用 CDH？
	社区版本的 Hadoop 具备很多的优点，例如：完全的开源免费，活跃的社区，文档资料齐全。但由于 Hadoop 的生态圈过于复杂，包括 Hive、 HBase、 Sqoop、 Flume、 Spark、 Hue、 Oozie 等，需要考虑
版本和组件的兼容性；同时集群部署、安装、配置较为复杂，需要手工调整配置文件后，对每台服务器的分发配置分发操作，较为容易出错；同时缺少配套的运行监控和运维工具，需要结合 ganglia、 nagois等实现运行监控，运维成本较高。而 Cloudera 的 CDH 版本为目前最成型的发行版本， 拥有最多的部署案例。 通过 CDH 提供更为稳定商用的 Hadoop 版本； 提供强大的部署、管理和监控工具，通过统一的可视化管理后台，实现集群的动态监控， 大大提高了集群部署的效率；同时 CDH Express 版本完全免费，不涉及昂贵的商业授权费用。 

![1552547635153](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1552547635153.png)

## 6、环境准备

（1）关闭防火墙：防火墙是对服务器进行一种保护，但有时候会妨碍集群间的相互通讯，所以要关闭防火墙。关闭防火墙有两种方式：临时关闭和永久关闭，永久关闭需要重启Linux操作系统，否则配置不会生效。

（2）禁用SELINUX： SELINUX全称为Security Enhanced Linux (安全强化 Linux)，是对系统安全级别更细粒度的设置。由于SELinux配置设置太严格，可能会与CM需要的功能相冲突，所以这里我们选择直接关掉。

（3）修改主机名

（4）设置ssh免密码登陆

​	SSH是一个可以在应用程序中提供安全通信的一个协议，通过SSH可以安全地进行网络数据传输，它的主要原理就是利用非对称加密体系，对所有待传输的数据进行加密，保证数据在传输时不被恶意破坏、泄露或者篡改。但是**Hadoop使用ssh主要不是用来进行数据传输的，Hadoop主要是在启动和停止的时候需要主节点通过SSH协议将从节点上面的进程启动或停止**。也就是说如果不配置SSH免密码登录对hadoop的正常使用也没有任何影响，只是在启动和停止Hadoop的时候需要输入每个从节点的用户名的密码就可以了，但是我们可以想象一下，当集群规模比较大的时候，比如成百上千台，如果每次都要输入每个连接节点的密码，那肯定是比较麻烦的，这种方法肯定是不可取的，所以我们要进行SSH免密码登录的配置，而且目前远程管理环境中最常使用的也是SSH（Secure Shell）。

（5）设置时间同步

​	 因为Hadoop 对集群中各个机器的时间同步要求比较高， 要求各个机器的系统时间不能相差太多， 不然会造成很多问题。比如，最常见的连接超时问题。所以需要配置集群中各个机器和互联网的时间服务器进行时间同步， 但是在实际生产环境中， 集群中大部分服务器是不能连接外网的， 这时候可以在内网搭建一个自己的时间服务器（ NTP 服务器），然后让集群的各个机器与这个时间服务器定时的进行时间同步。

（6）安装jdk

（7）安装Mysql

​	CentOS7 默认安装 MariaDB（MySQL 的开源分支），为确保数据库的稳定性，依据采用 MySQL 官方社区版本。 

## 6、CM安装部署

首先我们需要安装CM，在安装之前我们先来简单了解一下CM Server的安装方式和架构原理。

（1）、CM的安装方式

 Cloudera Manager的安装主要是针对 CM Server和CM Agent。其他诸如 Service Monitor、Host Monitor 等这些服务是在安装 CDH 的时候一并安装的。

CM的安装方式主要有三种：

a、通过 Cloudera 公司提供的 bin 文件来安装

这种方式只能用来安装 CM Server，节点机器上的 Agent 只能再另外通过CM Server 的 Web 界面安装等其他方式来安装。 采用 bin 文件的安装方式本质上也是用 yum 来安装的，主要是会安装 CM Server、JDK、Deamons Tools、PostgreSQL，并且会自动帮忙配置好，这还是比较方便的，这一点从 CM 的 yum 源就能看出来。

b、通过 yum 来安装

这种方式对比第一种来说其实就是将其中的bin文件安装步骤拆分出来，并且可以弃用默认提供的 PostgreSQL ，然后自己选择一个数据库，如果选择的是 MySQL，还需要再提供额外的 JDBC 库、JDK 等。

 c、通过 tar 文件来离线安装

其实就是将一个已有的 tar 包解压缩，修改下配置，然后起服务。对比上面两种方式的优点是： 完全离线 一切自己定制，包括 JDK、数据库、文件路径，由于 yum 方式安装最终的程序是放在 ROOT 分区下的，日志也是打在 ROOT 分区下，所以有将 ROOT 分区打满的危险

通过前边的分析，为了简单方便，**CM Server的安装我们选择通过Cloudera 公司提供的 bin 文件来安装**。为了提高安装的速度及可靠性，我们可以通过配置一个本地 yum 源来实现，各个节点机器上的 Agent 的安装通过CM Server 的 Web 界面的方式来安装。 所以说接下来我们的任务就是先配置本地yum源，然后安装CM Server,最后通过CM Server 的 Web 界面来实现CDH核心组件的安装。最终完成用CM+CDH的方式构建企业级大数据平台。 后面分别介绍 CM Server 及 CM Agent 安装的具体方法.

## 7、构建本地yum源？

（1）什么叫构建本地yum源？

    构建本地yum源又叫部署本地库，实际上就是安装一个镜像服务器：镜像服务器(Mirror server)与主服务器的服务内容都是一样的，只是放在不同的地方，分担主机的负载。简单来说就是和照镜子似的，能看，但不是原版的。在网上内容完全相同而且同步更新的两个或多个服务器，除主服务器外，其余的都被称为镜像服务器。为了提高安装的速度和可靠性
---------------------
（2）如何构建本地yum源？

       1、检查并安装Apache
    
           默认情况下是没有安装http服务的
    
           我们先来检查一下有没有可用的安装包
    
           我们输入yum list
    
           httpd(d代表demo,代表常驻后台运行的)
    
           如果没有安装，那我们就使用命令安装一下
    
           sudo yum install httpd
    
           下载完http服务就有/var/www/html目录
    
       2、启动HTTP服务:
    
           sudo service httpd start/stop/status
    
       3、在http://archive.cloudera.com/cm5/repo-as-tarball/5.8.0/下载cm的tar包
    
       4、提前创建一个目录cm-5.8.0
    
       5、把下载到本地的cm的yum源安装包上传到/var/www/html/cm-5.8.0目录下，然后解压即可。
    
       6、启动httpd服务之后在地址栏输入http://192.168.74.134/cm-5.3.6/
    
           就可以看到目录下的文件，但是现在还没有repodata(repodata本地YUM仓库)
    
       7、创建本地yum源
    
           我们使用下面的命令先来安装创建本地源的工具
    
           sudo yum install yum-utils createrepo
    
           然后执行sudo createrepo /var/www/html/cm-5.8.0命令生成repodata
    
           然后再在地址栏输入http://192.168.74.134/cm-5.8.0/就可以看到repodata目录了
    
       8、修改本地源地址 cd /etc/yum.repos.d/
    
       9、备份repo文件 cd /etc/yum.repos.d sudo mkdir back-repos sudo mv ./*.repo back-repos/
    
           下边尤其要注意：
    
       10、创建自己的repo文件
    
           输入命令：sudo touch myrepo.repo
    
           然后vi myrepo.repo
    
           添加如下内容：
    
           [myrepo]
    
           name=myrepo
    
           baseurl=http://主机名/cm-5.4.6
    
           enabled = 1
    
           gpgcheck = 0
    
           gpgcheck=0
    
           表示对从这个源下载的rpm包不进行校验；
    
           enabled=1 表示启用这个源。
    
       11、然后在其他两个节点上可以删除/etc/yum.repos.d目录下边的文件，然后把主节点的myrepo.repo文件scp到其他两个节点即可。（因为主节点是作为服务器，其他两个节点知道主节点资源地址即可）
    
           scp myrepo.repo root@node-cm02.djt.com:/etc/yum.repos.d
    
           注意：scp是远程复制文件用的，您需要安装openssh（所以要提前安装，修改yum 源之后就无法更改了） 问题：如果本节点安装了openssh-clients还是出现scp命令不存在，可能原因是你远程连接的那个节点没有安装openssh-clients软件
---------------------
## 8、安装Cloudera Manager Server

 （1）、下载CM的bin文件到本地:

     http://archive.cloudera.com/cm5/installer/5.4.6/cloudera-manager-installer.bin

  （2）、把该文件上传到/root/softwares目录下（没有该目录可以提前创建）

（3）、赋予该bin文件可执行权限：

    sudo chmod 777 cloudera-manager-installer.bin

  （4）、赋予该bin文件djt用户和用户组权限

    sudo chown djt:djt cloudera-manager-installer.bin

  （5）、执行该bin文件

    ./cloudera-manager-installer.bin --skip_repo_package=1

  （6）、然后输入主机名：7180即可看到web界面

  然后输入用户和密码都是admin

这样cms就安装成功了

注意：机器启动CMS服务自动启动

---------------------
## 9、下载CDH的parcels包并配置到Cloudera Manager主服务器上

 CM安装成功之后，接下来我们就可以通过CM安装CDH的方式构建企业大数据平台。所以首先需要把CDH的parcels包下载到CM主服务器上。

那么Parcels包是什么？从哪下载呢？怎么安装配置到CM主服务器上？首先要搞明白这几个问题。

（1）、Parcels包是什么？

  	Parcels实际上就是软件包，类似于package包，只是package包是以.rpm格式结尾的，数量通常较多，下载的时候比较麻烦，而parcels软件包是以.parcel结尾的，相当于压缩包格式的，parcels软件包一个系统版本对应一个包，下载的时候更方便。 **Cloudera 也建议使用 parcel 来代替软件包进行安装**，因为 parcel 可以使服务二进制文件的部署和升级自动化，让 Cloudera Manager 轻松地管理群集上的软件。如果选择不使用 parcel，当有软件更新可用时，将需要您手动升级群集中所有主机上的包，并会阻止您使用 Cloudera Manager 的滚动升级功能.

（2）、Parcels包从哪下载呢？

   Parcels包下载地址： http://archive.cloudera.com/cdh5/parcels/ 在该地址目录下找到对应版本（比如5.8.0）然后下载下图中的两个文件。注意：要和自己的linux操作系统的软件版本一致。

![1551929968211](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551929968211.png)

（3）、Parcels包怎么安装配置到CM主服务器上？

将下载到本地的两个文件上传到主服务器(比如node-a.cm01-djt.com节点)的parcel源目录下（该目录由Cloudera Manager Server指定，默认是/opt/cloudera/parcel-repo）， 注： /opt目录主要存放一些可选的程序。

![1551930000039](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930000039.png)

（4）、修改文件名

    修改文件名称，改为后缀名为.sha的文本文件，否则会导致找不到对应的CDH版本。mv CDH-5.8.0-1.cdh5.8.0.p0.42-el6.parcel.sha1 CDH-5.8.0-1.cdh5.8.0.p0.42-el6.parcel.sha

（5）、重启一下cms服务

    修改完之后还要重启一下cms服务： 在/var/log/目录下执行： service cloudera-scm-server restart即可。 （因为/opt/cloudera/parcel-repo目录是cm自动创建的，所以要重启服务，相当于刷新了该目录，这样他才知道他下边有新的东西。）
     OK，等待几分钟之后，如果安装配置成功之后，我们将能够在如下页面看到5.8.0的版本。

![1551929721491](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551929721491.png)

        这也表示特定版本的CDH已经安装部署成功，接下来我们就可以正式的使用CM来安装配置CDH了。

---------------------
## 10、安装Cloudera Manager Agent

1、登录CM页面之后首先会看到如下界面：即选择要安装哪种类型Cloudera Express,CM的汉化做的比较好，大家直接按照汉语标注即可判断3者之间的区别，目前我们选择免费版，因为既不用花钱，又可以满足目前学习的需求。所以我们就可以点击”免费”，然后点击”继续”。

![1551930116736](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930116736.png)

    2、进入如下界面，我们将看到我们可以选择安装的服务名称，暂时不用做任何的选择，直接点击“继续”即可。

![1551930155879](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930155879.png)

    3、	进入如下界面，按照填写主机名的模式提示把要安装CDH的节点的主机名填写到如下会话框中然后点击“搜索”。

![1551930178588](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930178588.png)

    4、点击搜索之后，出现3台主机对应的信息之后就表明3台主机已经准备就绪，接下来就可以在这3台主机上安装cdh相关的组件。如果前边的操作没有问题，我们都能看到如下搜索结果，然后点击“继续”即可。

![1551930204115](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930204115.png)

    5、	进入如下界面，然后选择“使用Parcel”，然后选择CDH的版本，即CDH5.8.0。

![1551930229165](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930229165.png)

    然后选择“自定义存储库”，存储库的地址即为/etc/yum.repos.d/myrepo.repo文件中的baseurl指定的值。这样就可以通过本地yum进行相关的下载。然后点击“继续”。

![1551930248303](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930248303.png)

![1551930288420](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930288420.png)

    6、进入如下界面之后，进行JDK的安装，然后点击“继续”。

![1551930311183](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930311183.png)

    7、进入如下界面，启用单用户模式，然后点击“继续”。

![1551930327042](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930327042.png)

    8、	进入如下界面，进行SSH登录凭据配置，比如输入root用户名和密码，然后点击“继续”即可。

![1551930341319](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930341319.png)

    9、进入如下界面之后，即开始相关服务的安装，只要不报错，就一直等着，直到出现下图所示，即表示安装成功，然后点击“继续”。

![1551930356735](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930356735.png)

    10、进入如下界面之后，即开始安装选定的Parcel包。只要不报错，就一直等着，直到出现下图所示，这样在对应节点的/opt/cloudera/parcels/目录下就有了相应的CDH包。然后点击“继续”。

![1551930371871](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930371871.png)

    11、进入如下界面之后，将进行主机的安全性检查，正常情况下我们会发现有如下两个问题。

![1551930391824](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930391824.png)

    可以不用处理，也可以按照建议进行如下处理。即在3台主机上分别执行如下命令即可分别解决这两个问题。本质就是修改对应文件的两个值。
    
    echo 10 > /proc/sys/vm/swappiness
    
    echo never > /sys/kernel/mm/transparent_hugepage/defrag
    
    以上两个命令在各个节点执行完成之后，点击重新检查，正常情况下，我们将发现前边的两个警告已经消除，然后点击”继续”即可。

![1551930410781](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930410781.png)

    11、进入如下界面之后，然后可选择要一键安装CDH服务组合或自定义安装包含的任何组件。如果每个节点的内存够大，比如超过10GB，那么就可以选择一键安装CDH的相关服务组合，如果内存比较小，建议还是一个一个组件进行自定义安装。

![1551930427788](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930427788.png)

    12、当然也可以直接点击左上角的Cloudera MANAGER进入主页面进行相关软件的安装。如下图所示。

![1551930443046](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551930443046.png)

    OK，到此为止，CM和CDH就安装部署成功，接下来就可以通过图形化界面进行相关服务组件的安装。

## 11、数据收集方式

（1）设备配网方式

目前所有产品均采用WiFi与路由器完成连接，然后通过手机与云端进行数据交互，拓扑结构如下：

![1551840795668](C:\Users\331122.INTERNET\AppData\Roaming\Typora\typora-user-images\1551840795668.png)

WiFi配网就是用来解决智能设备的联网需求的，进一步来说是通过某种方式把AP（Wireless Access Point无线访问接入点）的名称（SSID）和密码（PWD）告知设备中的WiFi模块，之后智能设备根据收到的SSID和密码连接指定AP。

SoftAP配网：智能设备的WiFi模式切换到AP模式，手机作为STA（Station）连接智能设备的AP，之后双方建立一个Socket连接交互数据（之前双方约定好端口）