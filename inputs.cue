package greymatter

defaults: {
  image_pull_secret_name: string | *"gm-docker-secret"
  image_pull_policy: "Always"
  xds_host: "controlensemble.greymatter.svc.cluster.local"
  redis_cluster_name: "redis"
  redis_host: "redis.greymatter.svc.cluster.local"
  spire_selinux_context: string | *"s0:c30,c5"

  proxy: string | *"docker.greymatter.io/release/gm-proxy:1.7.0"

  ports: {
    default_ingress: 10808
    redis_ingress: 10910
  }

  images: {
    observables_app: string | *"docker.greymatter.io/internal/observables-app:latest" @tag(observables_app_image)
  }

}