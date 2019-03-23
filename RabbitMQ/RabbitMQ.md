# RabbitMQ



## 快速创建

```
docker run -d --hostname rabbitmq --name rabbitmq -e  RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=keeponai7 -p  15672:15672 -p 5672:5672 --restart=on-failure:3 rabbitmq:latest
```

 15672：控制台端口号

 5672：应用访问端口号



## 开启web管理界面

通过`docker exec -it rabbitmq bash`进入到rabbitmq容器环境里面，执行

```
rabbitmq-plugins enable rabbitmq_management
```

可特别指定选项 --offline

或者直接使用开启管理界面的版本`rabbitmq:management`



## 创建ExChange

Exchange可以理解为路由，队列Queue可以绑定到对应的Exchange以接受消息。



## 创建队列Queue

关于控制队列大小的两个参数，

`Max length`(`x-max-length`) 用来控制队列中消息的数量。
 如果超出数量，则先到达的消息将会被删除掉。

`Max length bytes`(`x-max-length-bytes`) 用来控制队列中消息总的大小。
 如果超过总大小，则最先到达的消息将会被删除，直到总大小不超过`x-max-length-byte`为止。



测试组发现，golang编程里面操作MQ，会自动连通所指定的队列和路由，哪怕MQ里面没有创建对应的队列和路由。



## Shovel插件

Shovel也是RabbitMQ的一个插件，这个插件的功能就是将源节点的消息发布到目标节点，这个过程中Shovel就是一个客户端，它负责连接源节点，读取某个队列的消息，然后将消息写入到目标节点的exchange中。shovel可以在rabbitmq.config中配置，也可以通过web控制台进行配置。

启用shovel插件命令 ，执行:

```
rabbitmq-plugins enable rabbitmq_shovel
rabbitmq-plugins enable rabbitmq_shovel_management
```

查看已经安装的插件

```
rabbitmq-plugins list
```

启用后在控制台Admin页面就多了两个tab ：Shovel Status和Shovel Management。

shovel 插件的使用存在 static 和 dynamic 两种形式。

### 配置

注意**前提条件：**

源RabbitMQ实例打开了shovel插件。

目的RabbitMQ实例打开了shovel插件。

源实例与目的实例能够网络互通。



然后在管理界面中，找到Shovel Management就可以进行配置了，在源实例或目的实例中进行配置均可。

![](Shovel配置.jpg)

Source中，使用的是本机，因此URI为amqp://

Destination中，URI填写格式为amqp://user:password@ip:port，端口为5672则可以省略填写”:port“。写入位置可以直接选择Queue，则Exchange使用的是默认的“AMQP default”

由于没有创建vhost，就不需要在URI后面接/vhost-name了。