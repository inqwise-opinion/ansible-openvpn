# -*- mode: ruby -*-
# vi: set ft=ruby :

# vagrant plugin install vagrant-aws 
# vagrant up --provider=aws
# vagrant destroy -f && vagrant up --provider=aws --debug



# Vagrant.configure("2") do |config|
#   config.vm.provision "shell", inline: <<-SHELL
#       yum -y erase python3
#       #yum -y install curl gcc libffi-devel openssl-devel
#       amazon-linux-extras install python3.8
#       pip3.8 install -r /vagrant/requirements.txt --upgrade ansible
#     SHELL
AWS_REGION = "il-central-1"
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: <<-SHELL
    set -euxo pipefail
    cd /vagrant
    yum -y erase python3 && amazon-linux-extras install python3.8  
    echo $PWD
    export VAULT_PASSWORD=#{`op read "op://Security/ansible-vault inqwise-stg/password"`.strip!}
    echo "$VAULT_PASSWORD" > secret
    bash main.sh -e "discord_message_owner_name=#{Etc.getpwuid(Process.uid).name}" -r #{AWS_REGION}
    rm secret
  SHELL

  # config.vm.provision "ansible_local" do |ansible|
  #   ansible.playbook = "main.yml"
  #   #ansible.raw_arguments = ["--skip-tags", "openvpn"]
  #   ansible.install = false
  #   ansible.galaxy_roles_path = "/vagrant/ansible-galaxy/roles"
  #   ansible.galaxy_role_file = "requirements.yml"

  # end
  
  config.vm.provider :aws do |aws, override|
  	override.vm.box = "dummy"
    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "~/.ssh/id_rsa"
    aws.access_key_id             = `op read "op://Private/aws inqwise-stg/Security/Access key ID"`.strip!
    aws.secret_access_key         = `op read "op://Private/aws inqwise-stg/Security/Secret access key"`.strip!
    #aws.session_token             = ENV["VAGRANT_AWS_SESSION_TOKEN"]
    #aws.aws_dir = ENV['HOME'] + "/.aws/"
    aws.keypair_name = Etc.getpwuid(Process.uid).name
    override.vm.allowed_synced_folder_types = [:rsync]
    override.vm.synced_folder ".", "/vagrant", type: :rsync, rsync__exclude: ['.git/','ansible-galaxy/'], disabled: false
    override.vm.synced_folder '../ansible-galaxy', '/vagrant/ansible-galaxy', type: :rsync, rsync__exclude: '.git/', disabled: false
    
    aws.region = AWS_REGION
    aws.security_groups = ["sg-0e11a618872a5a387","sg-0cbd632d37524e9fe"]

    aws.ami = "ami-0eba4e5c3163a4f8c"
    aws.instance_type = "t3.micro"
    aws.subnet_id = "subnet-0f46c97c53ea11e2e"
    aws.associate_public_ip = true
    aws.iam_instance_profile_name = "bootstrap-role"
    aws.tags = {
      Name: "openvpn-test-#{Etc.getpwuid(Process.uid).name}"
    }
  end
end
