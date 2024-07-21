# -*- mode: ruby -*-
# vi: set ft=ruby :

# vagrant plugin install vagrant-aws 
# vagrant up --provider=aws
# vagrant destroy -f && vagrant up --provider=aws --debug

TOPIC_NAME = "errors"
ACCOUNT_ID = "992382682634"
AWS_REGION = "il-central-1"
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: <<-SHELL
    set -euxo pipefail
    cd /vagrant
    yum -y erase python3 && amazon-linux-extras install python3.8  
    echo $PWD
    export VAULT_PASSWORD=#{`op read "op://Security/ansible-vault inqwise-stg/password"`.strip!}
    echo "$VAULT_PASSWORD" > vault_password
    curl -s https://raw.githubusercontent.com/inqwise/ansible-automation-toolkit/master/main_amzn2.sh | bash -s -- -r #{AWS_REGION} -e "playbook_name=openvpn-test discord_message_owner_name=#{Etc.getpwuid(Process.uid).name}"
    rm vault_password
  SHELL

  config.vm.provider :aws do |aws, override|
  	override.vm.box = "dummy"
    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "~/.ssh/id_rsa"
    aws.access_key_id             = `op read "op://Employee/aws inqwise-stg/Security/Access key ID"`.strip!
    aws.secret_access_key         = `op read "op://Employee/aws inqwise-stg/Security/Secret access key"`.strip!
    aws.keypair_name = Etc.getpwuid(Process.uid).name
    override.vm.allowed_synced_folder_types = [:rsync]
    override.vm.synced_folder ".", "/vagrant", type: :rsync, rsync__exclude: ['.git/','ansible-galaxy/'], disabled: false
    collection_path = ENV['COMMON_COLLECTION_PATH'] || '~/git/ansible-common-collection'
    override.vm.synced_folder collection_path, '/vagrant/ansible-galaxy', type: :rsync, rsync__exclude: '.git/', disabled: false      

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
