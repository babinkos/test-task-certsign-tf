#!/bin/bash
trap 'EXCODE=$?; [ "$EXCODE" -eq "0" ] && (echo "***********************************"; \
	echo "all commands ran without errors") || (echo "***********************************"; \
	echo "Last command failed with exit code $EXCODE."; echo "***********************************"; \
	set +ex )' EXIT
set -ex
echo "usage  : <script> [version]"
echo "example: <script> 0.14.0"

if [ -z $1 ] ; then
  CURRR_VER=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
else
  CURRR_VER=$1
fi
echo "latest version is $CURRR_VER"
which terraform && INSTALLED_VER=$(terraform --version) || INSTALLED_VER="none"
if [ "$INSTALLED_VER" == "Terraform v${CURRR_VER}" ] ; then
	echo "already installed version $INSTALLED_VER, exiting"
	exit
fi
if [ -f "/usr/local/bin/terraform.${CURRR_VER}" ] ; then
	echo "/usr/local/bin/terraform.${CURRR_VER} exists, exiting"
	exit
fi
sudo echo ; zcat <( curl -q -f -L "https://releases.hashicorp.com/terraform/${CURRR_VER}/terraform_${CURRR_VER}_linux_amd64.zip" ) | sudo tee /usr/local/bin/terraform.${CURRR_VER} > /dev/null
sudo chmod +x /usr/local/bin/terraform.${CURRR_VER}
[ -L "/usr/local/bin/terraform" ] && sudo unlink /usr/local/bin/terraform
sudo ln -s /usr/local/bin/terraform.${CURRR_VER} /usr/local/bin/terraform
set +ex
terraform --version
