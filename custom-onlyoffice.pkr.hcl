packer {
  required_plugins {
    docker = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "onlyofficede" {
  image  = "onlyoffice/documentserver-de:7.0.1"
  commit = true
}

build {
  name    = "onlyoffice"
  sources = ["source.docker.onlyofficede"]

  provisioner "shell" {
    inline = [
      "sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf"
    ]
  }

  post-processors {

    post-processor "docker-tag" {
      repository = "085935842926.dkr.ecr.us-east-1.amazonaws.com/onlyoffice"
      tags       = ["latest"]
    }

    post-processor "docker-push" {
      ecr_login    = true
      aws_profile  = "default"
      login_server = "https://085935842926.dkr.ecr.us-east-1.amazonaws.com/onlyoffice"
    }

  }


}
