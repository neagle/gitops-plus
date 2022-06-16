package services

config: {
	spire: bool | *false @tag(spire,type=bool) // enable Spire-based mTLS
}

mesh: {
	metadata: {
		name: string | *"greymatter-mesh"
	}
	spec: {
		zone: string | *"default-zone"
		images: {
			proxy: string | *"docker.greymatter.io/release/gm-proxy:1.7.0"
		}
	}
}

defaults: {
	redis_cluster_name:        "redis"
	egress_elasticsearch_host: ""

	ports: {
		default_ingress: 10808
		redis_ingress:   10910

		observables_app_port:      5000
		egress_elasticsearch_port: 443
	}
}
