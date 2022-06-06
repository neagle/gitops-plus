// All Catalog Service entries

package greymatter

import (
  // "greymatter.io/operator/greymatter-cue/greymatter"
	"strings"
)

// TODO catalog entries could go into each of the other gm/outputs/ files, to keep things near other Grey Matter config

#CatalogService: {
	mesh_id:                   string
	service_id:                string
	name:                      string
	api_endpoint?:             string
	api_spec_endpoint?:        string
	description?:              string
	enable_instance_metrics:   bool
	enable_historical_metrics: bool
	
	// missing fields from official cue repo
	business_impact: string // FYI the Go currently uses this field to determine whether this is a catalog service entry
	version?: string
}

// TODO these should get their own defaults treatment in gm/intermediates.cue

catalog_entries: [
	#CatalogService & {
		name:            "Grey Matter Edge"
		mesh_id: mesh.metadata.name
		service_id: "edge"
		version:         strings.Split(mesh.spec.images.proxy, ":")[1]
		description:     "Handles north/south traffic flowing through the mesh."
		api_endpoint:    "/"
		business_impact: "critical"
		enable_instance_metrics: true
		enable_historical_metrics: false
	}
]