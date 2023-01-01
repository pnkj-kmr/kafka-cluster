# Kafka cluster with Zookeeper - High Availability

_kafka [2.13-3.0.1] with 3 linux machines | choose higher version if you like_

## kafka cluster - these setups help

1. kafka installation [skip if already installed]
2. hostname resolution [or we can skip this by IP address]
3. zookeeper configuration
4. kafka configuration
5. kafka connection

![KafkaCluster](./scripts/kafka.png)

### 1. kafka installation

---

_Here we are refering the linux machine to install kafka. To install [refer here](https://kafka.apache.org/downloads/) or below command on terminal to install-_

```
cd /opt
wget https://archive.apache.org/dist/kafka/3.0.1/kafka_2.13-3.0.1.tgz
tar -zxvf kafka_2.13-3.0.1.tgz
mv kafka_2.13-3.0.1 /opt/kafka
```

_if linux machine has firewall service running, we need to enable ports by running below command_

```
firewall-cmd --permanent --add-port={2181,9092}/tcp
firewall-cmd --reload
```

_Install java in linux machine if not exists_

```
yum install -y jre java
```

_we need to setup the JAVA_HOME environment variable, if not there, by finding java_
`echo $(dirname $(dirname $(readlink -f $(which java))))`

_[linux]: vi /etc/environment_

```
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.352.b08-2.el8_7.x86_64/jre
```

_now, let's run kafka as a service on linux, and verify the kafka and zookeeper service status_

##### Create zookeeper service

_[linux]: vi /etc/systemd/system/zookeeper.service_

```
[Unit]
Description=Apache Zookeeper Service
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
#Environment="JAVA_HOME=$JAVA_HOME"
WorkingDirectory=/opt/kafka
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
```

##### Create kafka service

_[linux]: vi /etc/systemd/system/kafka.service_

```
[Unit]
Description=Apache Kafka Service
Documentation=http://kafka.apache.org/documentation.html
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
#Environment="JAVA_HOME=$JAVA_HOME"
WorkingDirectory=/opt/kafka
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
#ExecStartPre=/bin/sleep 30

[Install]
WantedBy=multi-user.target
```

_**REPEAT** the step in Each & Every machine_

### 2. hostname resolution

---

_We are setting up kafka cluster with 3 linux machines, here we are the ips and their hostnames as, modify as per your structure_

_Now, let's add hosts as known host for the machine, login to hostname1 machine and run the below command_

```
cat >> /etc/hosts <<EOF
192.168.1.101 hostname1
192.168.1.102 hostname2
192.168.1.103 hostname3
EOF

cat /etc/hosts
```

_**REPEAT** for machine hostname2 - modify the hostname carefully with same machine hostname_

_**REPEAT** hostname3_

### 3. zookeeper configuration

---

_For zookeeper configuration, we need to modify the zookeeper.properties file as_

_modify or add the below parameters in conf file (parameter may exists in different location in file)_

_[linux]: vi /opt/kafka/config/zookeeper.properties_

```
dataDir=/opt/kafka/zoo_data     # CREATE DIR IF NOT EXISTS
tickTime=2000
initLimit=10
syncLimit=5
server.1=hostname1:2888:3888
server.2=hostname2:2888:3888
server.3=hostname3:2888:3888
```

_Add the zookeeper id as, by creating a myid file in zookeeper dir [**hostname1 --> 1** refered from above]_

_[linux]: vi /opt/kafka/zoo_data/myid_

```
1
```

_now, restart the service by running_

```
systemctl restart zookeeper.service
```

_**REPEAT** the step 3 in Each & Every machine carefully_

### 4. kafka configuration

---

_For kafka configuration, we need to modify below files as_

- producer.properties
- consumer.properties
- server.properties

_modify or add the below parameters in conf file (parameter may exists in different location in file)_

_[linux]: vi /opt/kafka/config/producer.properties_

```
bootstrap.servers=hostname1:9092,hostname2:9092,hostname3:9092
```

_[linux]: vi /opt/kafka/config/consumer.properties_

```
bootstrap.servers=hostname1:9092,hostname2:9092,hostname3:9092
```

_[linux]: vi /opt/kafka/config/server.properties_

```
broker.id=1     # hostname1 -> 1 | hostname2 -> 2 | hostname3 -> 3
listeners=PLAINTEXT://:9092
advertised.listeners=PLAINTEXT://hostname1:9092
log.dirs=/opt/kafka/logs            # CREATE DIR IF NOT EXISTS
num.partitions=3
auto.create.topics.enable=true
offsets.topic.replication.factor=3
default.replication.factor=3
log.retention.hours=1000
zookeeper.connect=hostname1:2181,hostname2:2181,hostname3:2181
```

_now, restart the service by running_

```
systemctl restart kafka.service
```

### 5. kafka connection

---

_Kafka connection helps to connect with kafka brokers_

_How we connect with single kafka server while producing or consuming the data_

```
hostname1:9092
```

_Same, we need to connect with kafka cluster like_

```
hostname1:9092,hostname2:9092,hostname3:9092
```

_completed :)_

### ADDITIONAL

---

#### A. How to create a topic in kafka cluster

_Login to one of you cluster machine and run the below command_

```
/opt/kafka/bin/kafka-topics.sh --create --topic demo --bootstrap-server hostname1:9092,hostname2:9092,hostname3:9092
```

#### B. How to describe a topic in kafka cluster

```
/opt/kafka//bin/kafka-topics.sh --describe --topic demo --bootstrap-server hostname1:9092,hostname2:9092,hostname3:9092
```

#### C. How to list all topics in kafka cluster

```
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server hostname1:9092,hostname2:9092,hostname3:9092
```

#### D. How to produce data to topic in kafka cluster

```
/opt/kafka/bin/kafka-console-producer.sh --topic demo --bootstrap-server hostname1:9092,hostname2:9092,hostname3:9092
```

#### E. How to consume data from topic in kafka cluster

```
/opt/kafka/bin/kafka-console-consumer.sh --topic demo --from-beginning ---bootstrap-server hostname1:9092,hostname2:9092,hostname3:9092
```
