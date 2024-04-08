#!/usr/bin/env bash
set -euxo pipefail
echo "Start user data"
REGION=$(ec2-metadata --availability-zone | sed -n 's/.*placement: \([a-zA-Z-]*[0-9]\).*/\1/p');
curl https://bootstrap.pypa.io/get-pip.py | python3
aws s3 cp s3://bootstrap-opinion-stg/playbooks/ansible-opinion/ /tmp/ansible-openvpn --recursive --region $REGION && cd /tmp/ansible-openvpn && bash main.sh -r $REGION
echo "End user data"



#old
#!/usr/bin/env bash
#set -euxo pipefail
#echo "Start user data"
#yum -y erase python3 && amazon-linux-extras install python3.8 && yum -y install openssl-devel
#aws s3 cp s3://opinion-stg-bootstrap/playbooks/ansible-openvpn/ /tmp/ansible-openvpn --recursive --region il-central-1 && cd /tmp/ansible-openvpn && bash main.sh
#echo "End user data"