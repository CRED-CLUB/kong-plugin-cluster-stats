# kong-plugin-cluster-stats

`kong-plugin-cluster-stats` plugin exposes different stats for a kong cluster.
Currently it supports getting

- Number of kong nodes in the cluster

## Installation and Loading the plugin

Follow [standard procedure](https://docs.konghq.com/gateway-oss/2.0.x/plugin-development/distribution/) to install and load the plugin.

## Enabling the plugin

This plugin can be enabled as a global plugin. Please note that the plugin starts updating heartbeat records in the database even without enabling. This is because the heartbeat events are scheduled in the background in the `init_worker` nginx phase. Enabling the pluging just exposed the REST API for querying.

## Accessing the plugin API

The plugin exposes cluster stats with the following API and returns the number of kong nodes active.
```
curl -X GET http://localhost:8001/cluster-stats
{"num_nodes":2}
```

## Internals of the plugin
### How it works?

The plugin when loaded schedules a job, which only runs on the nginx master process, to periodically update an entry in the `cluster_stats_heartbeat` table in the database. The table has the following fields.

1. `node_id`: The unique kong node id
2. `created_at`: The timestamp at which this node was bootstrapped
3. `updated_at`: The timestamp of last heartbeat

The API, when queried, returns the most recently updated nodes from this table and returns its count.

The plugin also schedules a clean up job which removes stale entries from the database.

### Configuration

Since, the heartbeat and the cleanup jobs are scheduled in the `init_worker` phase, the configuration is static and cannot be changed dynamically. The `config.lua` file contains the following configurations.

1. `heartbeat_send_interval_in_secs`: The interval at which heartbeat entries are updated in the db. **Default = 1s**
2. `heartbeat_cleanup_interval_in_secs`: The interval at which stale heartbeat entries are cleaned up from the db. **Default = 60s**
3. `heartbeat_fetch_not_older_than_in_secs`: The maximum duration to look back while fetching heartbeat records. **Default = 3s**
4. `heartbeat_cleanup_older_than_in_secs`: The heartbeat entries not updated last in this duration are cleaned up. **Default = 60s** 
