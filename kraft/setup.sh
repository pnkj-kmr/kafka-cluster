
# init for kafka setup
KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
# ./bin/kafka-storage.sh format --standalone -t $KAFKA_CLUSTER_ID -c infraon/server.properties
./bin/kafka-storage.sh format --standalone -t $$KAFKA_CLUSTER_ID \
  -c infraon/server.properties \
  --add-scram 'SCRAM-SHA-512=[name="admin",password="admin@123"]'


### create a new user into kafka acl
### SCRAM User creation

# # user (producer)
# ./bin/kafka-configs.sh --bootstrap-server localhost:9092 \
#   --alter --add-config 'SCRAM-SHA-512=[password='infraon@123']' \
#   --command-config infraon/admin.properties \
#   --entity-type users --entity-name infraon-producer

# infraon - generic user for any third party use case
./bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --alter --add-config 'SCRAM-SHA-512=[password='infraon@123']' \
  --command-config infraon/admin.properties \
  --entity-type users --entity-name infraon

### for test the configuration
# view
./bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --describe --entity-type users --entity-name infraon \
  --command-config client.properties
# add
./bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --alter --add-config 'SCRAM-SHA-512=[iterations=8192,password=infraon@123]' \
  --entity-type users --entity-name infraon \
  --command-config client.properties
# delete
./bin/kafka-configs.sh --bootstrap-server localhost:9092 \
  --alter --delete-config 'SCRAM-SHA-512' \
  --entity-type users --entity-name infraon \
  --command-config client.properties


# ### server.properties
# authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
# super.users=User:admin
# # Optional: to require all actions to pass ACL checks
# allow.everyone.if.no.acl.found=false

### Allow read from all topics
# bin/kafka-acls.sh --bootstrap-server localhost:9092 \
#   --add --allow-principal User:readonly_user \
#   --operation Read --topic '*'

### Allow describe (metadata fetch)
# bin/kafka-acls.sh --bootstrap-server localhost:9092 \
#   --add --allow-principal User:readonly_user \
#   --operation Describe --topic '*'

### Allow consume from all consumer groups
# bin/kafka-acls.sh --bootstrap-server localhost:9092 \
#   --add --allow-principal User:readonly_user \
#   --operation Read --group '*'

### grant a write operation
# bin/kafka-acls.sh --add --allow-principal User:readonly_user --operation Write ...

