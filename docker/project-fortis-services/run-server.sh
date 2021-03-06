#!/usr/bin/env sh

cassandra_exec() {
  /opt/cassandra/bin/cqlsh \
    --request-timeout=3600 \
    --username="$CASSANDRA_USERNAME" \
    --password="$CASSANDRA_PASSWORD" \
    "$CASSANDRA_CONTACT_POINTS"
}

# wait for cassandra to start
while ! cassandra_exec; do
  echo "Cassandra not yet available, waiting..."
  sleep 10s
done
echo "...done, Cassandra is now available"

# set up cassandra schema
if [ -n "$FORTIS_CASSANDRA_SCHEMA_URL" ]; then
  echo "Got Fortis schema definition at $FORTIS_CASSANDRA_SCHEMA_URL, ingesting..."
  wget -qO- "$FORTIS_CASSANDRA_SCHEMA_URL" | cassandra_exec
  echo "...done, Fortis schema definition is now ingested"
fi

# set up cassandra seed data
if [ -n "$FORTIS_CASSANDRA_SEED_DATA_URL" ]; then
  echo "Got Fortis sample data at $FORTIS_CASSANDRA_SEED_DATA_URL, ingesting..."
  wget -qO- "$FORTIS_CASSANDRA_SEED_DATA_URL" | cassandra_exec
  echo "...done, Fortis sample data is now ingested"
fi

# start node server
PORT="80" npm start
