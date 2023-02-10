// Per an issue on GitHub, the container needs a random name, or sometimes Ansible will stall or fail
variable "ansible_host" {
  default = "defaults"
}

// per the documentation, the connection type should be set to docker (not ssh)
variable "ansible_connection" {
  default = "docker"
}

// a resource we wish to create
source "docker" "example" {
  image  = "centos:7"
  commit = true
  // changes are things that used to live in a Dockerfile
  // the rest of the change operations are handeled by Ansible
  changes = ["EXPOSE 9876",
  "CMD [\"/dockergo\"]"]
  run_command = ["-d", "-i", "-t", "--name", var.ansible_host, "{{.Image}}", "/bin/bash"]
}

build {
  sources = [
    "source.docker.example"
  ]

  // run ansible from the environment we are currently in
  provisioner "ansible" {
    groups        = ["webserver"]
    user          = "root"
    playbook_file = "./playbook.yml"
    extra_arguments = [
      "--extra-vars",
      "ansible_host=${var.ansible_host} ansible_connection=${var.ansible_connection}"
    ]
  }
}

