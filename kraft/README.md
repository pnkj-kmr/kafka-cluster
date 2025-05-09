# Kafka KRaft cluster - High Availability

_kafka [2.13-4.0.0] with 3 linux machines | choose higher version if you like_

## kafka cluster - these setups help

1. kafka installation [skip if already installed]
2. hostname resolution [or we can skip this by IP address]
3. kafka configuration
4. kafka connection

### 1. kafka installation

---

_Here we are refering the linux machine to install kafka. To install [refer here](https://kafka.apache.org/downloads) or below command on terminal to install-_

```
cd /opt
wget https://dlcdn.apache.org/kafka/4.0.0/kafka_2.13-4.0.0.tgz
tar -zxvf kafka_2.13-4.0.0.tgz
mv kafka_2.13-4.0.0 /opt/kafka
```

_if linux machine has firewall service running, we need to enable ports by running below command_

```
firewall-cmd --permanent --add-port={9092,9093}/tcp
firewall-cmd --reload
```

_Install java in linux machine if not exists_

```
yum install -y jre java
java version
```

_now, let's run kafka as a service on linux, and verify the kafka service status_


##### Create kafka service

_[linux]: vi /etc/systemd/system/kafka.service_

```
[Unit]
Description=Apache Kafka Service
Documentation=http://kafka.apache.org/documentation.html

[Service]
Type=simple
#Environment="JAVA_HOME=$JAVA_HOME"
#Environment=KAFKA_HEAP_OPTS="-Xmx4G -Xms512M"
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


### 3. kafka configuration

---

_For kafka configuration, we need to modify below files as_

- server.properties
- client.properties

_modify or add the below parameters in conf file (parameter may exists in different location in file)_


_[linux]: vi /opt/kafka/config/client.properties_

[client.properties](client.properties)

_[linux]: vi /opt/kafka/config/server.properties_

[server.properties](server.properties)

```
node.id=1     # hostname1 -> 1 | hostname2 -> 2 | hostname3 -> 3
controller.quorum.voters=1@localhost:9093,2@localhost:9093,3@localhost:9093

...
```

_now, restart the service by running_

```
systemctl restart kafka.service
```

_how to setup the kafka with SCRAM configuration_

```
KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
./bin/kafka-storage.sh format --standalone -t $$KAFKA_CLUSTER_ID \
  -c infraon/server.properties \
  --add-scram 'SCRAM-SHA-512=[name="admin",password="admin@123"]'
```

### 4. kafka connection

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

helping commands [here](tmp_scripts.sh)
