

# start command
#bin/kafka-server-start.sh config/server.properties

# create topic
#bin/kafka-topics.sh --create --topic test --bootstrap-server localhost:9092
#bin/kafka-topics.sh --describe --topic test --bootstrap-server localhost:9092
./bin/kafka-topics.sh --create --topic test \
    --bootstrap-server localhost:9092 --command-config infraon/client.properties

# push data to topic
./bin/kafka-console-producer.sh --topic test --bootstrap-server localhost:9092 \
    --producer.config infraon/client.properties

# consume from data topic
./bin/kafka-console-consumer.sh --topic test --from-beginning \
    --bootstrap-server localhost:9092 --consumer.config infraon/client.properties

#remove kafka environment
#rm -rf /tmp/kafka-logs /tmp/kraft-combined-logs



