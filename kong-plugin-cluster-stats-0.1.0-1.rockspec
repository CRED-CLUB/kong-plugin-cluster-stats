package = "kong-plugin-cluster-stats" 
version = "0.1.0-1"
-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.
supported_platforms = {"linux", "macosx"}

source = {
  url = "https://bitbucket.org/dreamplug-backend/kong-plugin-cluster-stats",
  tag = "0.1.0"
}

description = {
  summary = "Plugin to get cluster stats e.g number of nodes",
  homepage = "http://getkong.org",
  license = "Apache 2.0"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.cluster-stats.handler"] = "kong/plugins/cluster-stats/handler.lua",
    ["kong.plugins.cluster-stats.schema"] = "kong/plugins/cluster-stats/schema.lua",
    ["kong.plugins.cluster-stats.daos"] = "kong/plugins/cluster-stats/daos.lua",
    ["kong.plugins.cluster-stats.api"] = "kong/plugins/cluster-stats/api.lua",
    ["kong.plugins.cluster-stats.config"] = "kong/plugins/cluster-stats/config.lua",
    ["kong.plugins.cluster-stats.repo"] = "kong/plugins/cluster-stats/repo.lua",
    ["kong.plugins.cluster-stats.worker"] = "kong/plugins/cluster-stats/worker.lua",
    ["kong.plugins.cluster-stats.migrations.init"] = "kong/plugins/cluster-stats/migrations/init.lua",
    ["kong.plugins.cluster-stats.migrations.000_base_cluster_stats"] = "kong/plugins/cluster-stats/migrations/000_base_cluster_stats.lua",
  }
}
