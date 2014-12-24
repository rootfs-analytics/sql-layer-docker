# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
COREOS_CHANNEL = "alpha"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # rsync only works one way, which is less convenient for debugging scripts.
  # nfs is really slow, particular when writing.
  # On Windows:
  # For nfs: vagrant plugin install vagrant-winnfsd.
  # For rsync: install cwRsync and adjust cygdrive path prefix.
  sync_type = ENV['VAGRANT_SYNC_TYPE'] || 'rsync'

  # Build multiple Docker boxes to test cluster communication among
  # containers on different hosts.
  box_count = (ENV['DOCKER_BOX_COUNT'] || 1).to_i

  config.vm.box = "coreos-#{COREOS_CHANNEL}"
  config.vm.box_url = "http://#{COREOS_CHANNEL}.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

  config.vm.provider "virtualbox" do |vb|
    vb.check_guest_additions = false
    vb.functional_vboxsf = false
    vb.memory = 8192
    vb.cpus = 2
  end

  # Stay with insecure default for ease of connecting without
  # regenerting PPK for PuTTY. These are only test boxes.
  config.ssh.insert_key = false

  sync_opts = {}
  sync_opts.merge! type: sync_type unless sync_type == 'default'
  sync_opts.merge! rsync__exclude: ".git/" if sync_type == 'rsync'
  config.vm.synced_folder ".", "/home/core/sql-layer-docker", sync_opts

  box_count.times do |n|
    name = "core-docker#{'-' + (n + 1).to_s if n > 0}"
    config.vm.define name do |vm_config|
      vm_config.vm.hostname = name

      if n == 0
        # Docker server
        vm_config.vm.network "forwarded_port", guest: 2375, host: 2375, auto_correct: true
        # Container ports
        [*49080..49089].each do |port|
          vm_config.vm.network "forwarded_port", guest: port, host: port
        end
      end

      if sync_type == 'nfs' || box_count > 1
        vm_config.vm.network "private_network", ip: "192.168.50.#{10 + n}"
      end

      if box_count > 1
        # No way to access Vagrant::Environment.default_private_key_path here?
        vm_config.vm.provision "file", source: "~/.vagrant.d/insecure_private_key", destination: "~/.ssh/id_rsa"
        vm_config.vm.provision "shell", privileged: false, keep_color: true, inline: "chmod go-rx ~/.ssh/id_rsa"
      end

      script = "cd sql-layer-docker\n"
      if n == 0
        script += "./build-all.sh\n"
        if box_count > 1
          # The obvious thing would be to copy images.tar.gz back to
          # the sync'ed directory. But that takes 20 minutes over NFS.
          script += <<EOF
echo Saving FDB images
docker save -o /tmp/images.tar foundationdb/fdb-client foundationdb/fdb-server
gzip /tmp/images.tar
EOF
        end
      else
          script += <<EOF
echo Restoring FDB images
scp -o StrictHostKeyChecking=no 192.168.50.10:/tmp/images.tar.gz /tmp/
zcat /tmp/images.tar.gz | docker load
EOF
      end
      vm_config.vm.provision "shell", privileged: false, keep_color: true, inline: script

    end
  end
end
