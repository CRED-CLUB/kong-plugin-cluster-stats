# 📊 kong-plugin-cluster-stats

## Overview

`kong-plugin-cluster-stats` exposes different stats for a kong cluster. 

Currently it supports getting,
- Number of kong nodes in the cluster

> This plugin is inspired from the discussion here: https://github.com/Kong/kong/issues/3172

## Installation and Loading of the plugin

Follow [standard procedure](https://docs.konghq.com/gateway-oss/2.0.x/plugin-development/distribution/) to install and load the plugin.

## Enabling the plugin

This plugin can be enabled as a global plugin. Enabling the plugin exposes the REST API for querying. 

Please note that the plugin starts updating heartbeat records in the database even without enabling. This is because the heartbeat events are scheduled in the background in the `init_worker` nginx phase. More details on how the plugin works can be found [here](#how-does-it-work).

## Accessing the plugin API

The plugin exposes cluster stats with the following API and returns the number of active kong nodes.
```
curl -X GET http://localhost:8001/cluster-stats
{"num_nodes":2}
```

## How does it work?

The plugin, when loaded schedules a job, which only runs on the nginx master process, to periodically update an entry in the `cluster_stats_heartbeat` table in the database. The table has the following fields.
1. `node_id`: The unique kong node id
2. `created_at`: The timestamp at which this node was bootstrapped
3. `updated_at`: The timestamp of last heartbeat

The API, when queried, returns the most recently updated nodes from this table and returns its count. The plugin also schedules a clean up job which removes stale entries from the database.

### Configuration

Since the heartbeat and the cleanup jobs are scheduled in the `init_worker` phase, the configuration is static and cannot be changed dynamically. The `config.lua` file contains the following configurations.
1. `HEARTBEAT_SEND_INTERVAL_IN_SECS`: The interval at which heartbeat entries are updated by the nodes in the database. **Default = 1s**
2. `HEARTBEAT_CLEANUP_INTERVAL_IN_SECS`: The interval at which stale heartbeat entries are cleaned up from the database. **Default = 60s**
3. `HEARTBEAT_FETCH_NOT_OLDER_THAN_IN_SEC`: The maximum duration to look back while fetching heartbeat records while querying the active number of nodes. **Default = 3s**
4. `HEARTBEAT_CLEANUP_OLDER_THAN_IN_SEC`: The heartbeat entries older than this duration are cleaned up. **Default = 60s** 
