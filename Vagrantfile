# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
COREOS_CHANNEL = "alpha"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "coreos-#{COREOS_CHANNEL}"
  config.vm.box_url = "http://#{COREOS_CHANNEL}.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

  config.vm.hostname = "core-docker"

  # Docker server
  config.vm.network "forwarded_port", guest: 2375, host: 2375, auto_correct: true
  # Container ports
  [*49080..49089].each do |port|
    config.vm.network "forwarded_port", guest: port, host: port
  end

  # Best we can do for folder sharing.
  # On Windows, install cwRsync and adjust cygdrive path prefix.
  config.vm.synced_folder ".", "/home/core/sql-layer-docker", type: "rsync",
    rsync__exclude: ".git/"

  config.vm.provider "virtualbox" do |vb|
    vb.check_guest_additions = false
    vb.functional_vboxsf = false
    vb.memory = 8192
    vb.cpus = 2
  end

  config.vm.provision "shell", privileged: false, keep_color: true, inline: <<EOF
cd sql-layer-docker
./build-all.sh
EOF

end
