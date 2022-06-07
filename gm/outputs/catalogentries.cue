package greymatter

import (
  greymatter "greymatter.io/api"
)

catalog_entries: [
	greymatter.#CatalogService & {
		name:                     "Observables App"
		mesh_id:                   mesh.metadata.name
		service_id:                "observables_app"
		version:                   "0.0.1"
		description:               "A standalone dashboard visualizaing data collected from Grey Matter Observability."
		api_endpoint:              "/"
		business_impact:           "critical"
		enable_instance_metrics:   true
		enable_historical_metrics: true
	}
]