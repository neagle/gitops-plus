package greymatter

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
  ports: {
    default_ingress: 10808
    redis_ingress: 10910
  }
}