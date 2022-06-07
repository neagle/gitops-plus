package greymatter

let Name = "observables_app"
let Port = 5000
let ObservalbesAppIngressName = "\(Name)_local"
let EgressToRedisName = "\(Name)_egress_to_redis"
let EgressToElasticSearchName = "\(Name)_egress_to_elasticsearch"
let EgressToElasticSearchPort = 9200

observables_app_config: [

  // HTTP ingress
  #domain & { domain_key: ObservalbesAppIngressName },
  #listener & {
    listener_key: ObservalbesAppIngressName
    _spire_self: Name
    _gm_observables_topic: Name
    _is_ingress: true
  },
  #cluster & { cluster_key: ObservalbesAppIngressName, _upstream_port: Port },
  #route & { route_key: ObservalbesAppIngressName },

  // egress->redis
  #domain & { domain_key: EgressToRedisName, port: defaults.ports.redis_ingress },
  #cluster & {
    cluster_key: EgressToRedisName
    name: defaults.redis_cluster_name
    _spire_self: Name
    _spire_other: defaults.redis_cluster_name
  },
  #route & { route_key: EgressToRedisName }, // unused route must exist for the cluster to be registered with sidecar
  #listener & {
    listener_key: EgressToRedisName
    ip: "127.0.0.1" // egress listeners are local-only
    port: defaults.ports.redis_ingress
    _tcp_upstream: defaults.redis_cluster_name
  },

  // egress->elasticsearch
  #domain & { domain_key: EgressToElasticSearchName, port: EgressToElasticSearchPort },
  #cluster & {
    cluster_key: EgressToElasticSearchName
    name: "elasticsearch"
    retuire_tls: true
    _upstream_host: "3c81f82d69c24552950876e4b5d01579.centralus.azure.elastic-cloud.com"
    _upstream_port: 9243
    _spire_self: Name
    _spire_other: defaults.redis_cluster_name
  },
  #route & { route_key: EgressToElasticSearchName }, // unused route must exist for the cluster to be registered with sidecar
  #listener & {
    listener_key: EgressToElasticSearchName
    ip: "127.0.0.1" // egress listeners are local-only
    port: EgressToElasticSearchPort
  },

  // shared proxy object
  #proxy & {
    proxy_key: Name
    domain_keys: [ObservalbesAppIngressName, EgressToRedisName, EgressToElasticSearchName]
    listener_keys: [ObservalbesAppIngressName, EgressToRedisName, EgressToElasticSearchName]
  },

  // Edge config for observables_app ingress
  #cluster & {
    cluster_key: Name
    _spire_other: Name
  },
  #route & {
    domain_key: "edge"
    route_key: Name
    route_match: {
      path: "/services/observables-app/"
    }
    redirects: [
      {
        from: "^/services/observables-app$"
        to: route_match.path
        redirect_type: "permanent"
      }
    ]
    prefix_rewrite: "/"
  }
]
