# Happy enough with the default state file here
# Order is based on the usual lifecycle


# Some tasks need my IP as a CIDR block for bastion ssh access, so I will export
export TF_VAR_bastion_ssh_access_cidr_block=$(shell dig +short myip.opendns.com @resolver1.opendns.com)/32


check:
	@terraform validate
	@terraform fmt


plan:
	@echo $$TF_VAR_bastion_ssh_access_cidr_block
	@terraform plan


apply:
	@terraform apply


show:
	@terraform show


# Graph task assumes you have graphviz and you are using a workstation, see http://www.graphviz.org/Home.php
graph_file_path := $(shell mktemp).png
graph:
	@terraform graph | dot -Tpng > $(graph_file_path)
	@xdg-open $(graph_file_path)


destroy:
	@terraform destroy
