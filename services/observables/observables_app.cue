package services

import (
	greymatter "greymatter.io/api"
)

let Name = "observables" // Name needs to match the greymatter.io/cluster value in the Kubernetes deployment
let ObservablesAppIngressName = "\(Name)_local"
let EgressToRedisName = "\(Name)_egress_to_redis"
let EgressToElasticSearchName = "\(Name)_egress_to_elasticsearch"

ObservablesApp: {
	name:   Name
	config: observables_app_config
}

observables_app_config: [

	// HTTP ingress
	#domain & {domain_key: ObservablesAppIngressName},
	#listener & {
		listener_key:          ObservablesAppIngressName
		_spire_self:           Name
		_gm_observables_topic: Name
		_is_ingress:           true
	},
	#cluster & {cluster_key: ObservablesAppIngressName, _upstream_port: defaults.ports.observables_app_port},
	#route & {route_key:     ObservablesAppIngressName},

	// egress->redis
	#domain & {domain_key: EgressToRedisName, port: defaults.ports.redis_ingress},
	#cluster & {
		cluster_key:  EgressToRedisName
		name:         defaults.redis_cluster_name
		_spire_self:  Name
		_spire_other: defaults.redis_cluster_name
	},
	// unused route must exist for the cluster to be registered with sidecar
	#route & {route_key: EgressToRedisName},
	#listener & {
		listener_key:  EgressToRedisName
		ip:            "127.0.0.1" // egress listeners are local-only
		port:          defaults.ports.redis_ingress
		_tcp_upstream: defaults.redis_cluster_name
	},

	// egress->elasticsearch
	#domain & {
		domain_key: EgressToElasticSearchName
		port:       9200 // don't change this, the app expects this port
		custom_headers: [
			{
				key:   "Host"
				value: defaults.egress_elasticsearch_host
			},
		]
	},
	#cluster & {
		cluster_key:    EgressToElasticSearchName
		name:           "elasticsearch"
		require_tls:    true
		_upstream_host: defaults.egress_elasticsearch_host
		_upstream_port: defaults.ports.egress_elasticsearch_port
		_spire_self:    Name
		_spire_other:   defaults.redis_cluster_name
	},
	// unused route must exist for the cluster to be registered with sidecar
	#route & {route_key: EgressToElasticSearchName},
	#listener & {
		listener_key: EgressToElasticSearchName
		ip:           "127.0.0.1" // egress listeners are local-only
		port:         9200        // don't change this, the app expects this port
	},

	// shared proxy object
	#proxy & {
		proxy_key: Name
		domain_keys: [ObservablesAppIngressName, EgressToRedisName, EgressToElasticSearchName]
		listener_keys: [ObservablesAppIngressName, EgressToRedisName, EgressToElasticSearchName]
	},

	// Config for greymatter.io edge ingress.
	#cluster & {
		cluster_key:  Name
		_spire_other: Name
	},
	#route & {
		domain_key: "edge"
		route_key:  Name
		route_match: {
			path: "/services/observables/"
		}
		redirects: [
			{
				from:          "^/services/observables$"
				to:            route_match.path
				redirect_type: "permanent"
			},
		]
		prefix_rewrite: "/"
	},

	// Config for edge ingress to support mesh-segmentation.
	// #cluster & {
	//  cluster_key:  "\(Name)_edge_plus"
	//  _spire_other: "\(Name)_edge_plus"
	// },
	#route & {
		domain_key: "edge-plus"
		route_key:  Name
		route_match: {
			path: "/services/observables/"
		}
		redirects: [
			{
				from:          "^/services/observables$"
				to:            route_match.path
				redirect_type: "permanent"
			},
		]
		prefix_rewrite: "/"
	},

	// Grey Matter Catalog service entry.
	greymatter.#CatalogService & {
		name:                      "Observables App"
		mesh_id:                   mesh.metadata.name
		service_id:                "observables"
		version:                   "0.0.1"
		description:               "A standalone dashboard visualizaing data collected from Grey Matter Observability."
		api_endpoint:              "/services/observables"
		business_impact:           "critical"
		enable_instance_metrics:   true
		enable_historical_metrics: true
	},
]
