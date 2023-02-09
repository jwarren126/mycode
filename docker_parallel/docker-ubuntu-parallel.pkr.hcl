/* Alta3 Research | rzfeeser@alta3.com
   Packer - Example template using HCL to build an Ubuntu Docker image
            and including variables to dynamically control builds */


/* Packer Block - Contains Packer settings, including Packer version
                  as well as the required plugins. Anyone can write a plugin (GoLang)
                  Alta3 Research has an introduction to GoLang course (5 days) */
packer {
  required_plugins {
    // The Docker Builder (plugin) - built, maintained, and distributed by HashiCorp
    docker = {
      version = ">= 0.0.7"
      // only necessary when requiring a plugin outside the HashiCorp domain
      source = "github.com/hashicorp/docker"
    }
  }
}


/* Variable Block - The following block declares the variable named
                    "docker_image". This variable includes a default
                    value. */
variable "docker_image" {
  type    = string
  default = "ubuntu:xenial"
}


/* Source Block - Configures the builder plugin, which is invoked by the Build Block. In the following example,
                  the Builder TYPE is "docker", and the Builder NAME is "ubuntu". */
// source "TYPE" "NAME"
source "docker" "ubuntu" {
  image  = var.docker_image // updated to use a variable
  commit = true
}

/* Parallel Builds - For a parallel build, we need a SECOND source and to update build sources */

source "docker" "ubuntu-bionic" {
  image  = "ubuntu:bionic"
  commit = true
}

source "docker" "ubuntu-xenial" {
  image  = "ubuntu:xenial"
  commit = true
}

/* Build Block - This is what to do with the Docker container after it launches. In more detailed examples, we can use the Provision Block and Post-Process Block to add additional provisioning steps. */
build {
  name = "learn-packer"
  sources = [
    "source.docker.ubuntu",        // matches source "docker" "ubuntu" {}
    "source.docker.ubuntu-bionic", // added for parallel build 
    "source.docker.ubuntu-xenial", // tertiary build
  ]

  // Provisioner - Uses the "shell" provisioner to set the env var "ALTA"
  // and then write that, and a string, into the file example.txt
  provisioner "shell" {
    environment_vars = [
      "ALTA=hello world",
    ]
    inline = [
      "echo Adding file to Docker Container",
      "echo \"The env var ALTA is set to $ALTA\" > example.txt",
    ]
  }
  // recall of a variable declared in a template uses {}
  provisioner "shell" {
    inline = ["echo The base image in use is ${var.docker_image}"]
  }
}

