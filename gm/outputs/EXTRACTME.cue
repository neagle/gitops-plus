package greymatter

mesh_configs: observables_app_config +
             catalog_entries

// for CLI convenience,
// e.g. `cue eval -c ./gm/outputs --out text -e mesh_configs_yaml`
mesh_configs_yaml: mesh_configs
