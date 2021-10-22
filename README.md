# Udacity Project
In this project, Coded Packer template in the packer folder and a Terraform template in the terraform folder . The templates are customizable by changing the values and adding removing configuration as needed in the variable.tf file has the values that can used to change number of VMs and other properties.

 Screen shot of Policy and tagging provided in the [Policy Tagging](https://github.com/pikukesar/UdacityProjects/tree/main/Policy%20Tagging) folder

Screen shot of creating Az server principal and Packer build provided in the [Packer Screen Shots](https://github.com/pikukesar/UdacityProjects/tree/main/Packer%20Screen%20Shots) folder

Screen shots of Terraform Steps [Terraform Sreenshots](https://github.com/pikukesar/UdacityProjects/tree/main/Terraform%20Sreenshots) folder

## Dependencies

Create an Azure Account

Install the Azure command line interface

Install Packer

Install Terraform

Instructions

### Create Azure service principal
```bash
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }" 
```

### Build the image using packer [server.json](https://github.com/pikukesar/UdacityProjects/blob/main/Packer/server.json)

```bash
packer build server.json
```

## Terraform Template Incudes
[Terraform folder](https://github.com/pikukesar/UdacityProjects/tree/main/Terraform)

Create a terraform file main.tf and variable.tf

* Create a Resource Group

* Create a virtual network and a subnet on the virtual network

* Create a Network Security Group

* Create a Network Interface

* Create a Public IP

* Create a Load Balancer

* Create a virtual machine availability set

* Create virtual machines. Make sure you use the image you deployed using packer

* Create managed disks for your virtual machines

* Ensure declarative configuration is possible by using variable.tf file

* Deploy all Azure resources using terraform commands

Please make sure you download the Terraform folder and cd into it. then run the commands below

```bash
terraform init
terraform validate
terraform fmt
terraform plan -out solution.plan
terraform plan -no-color > solution.txt
terraform apply -auto-approve
```
terraform output : this file has been uploaded to the /Terraform/ folder

terraform screenshots : this file has been uploaded to the /Terraform Sreenshots/ [Terraform](https://github.com/pikukesar/UdacityProjects/tree/main/Terraform) folder

# Destroy Resources
```bash
terraform destroy -auto-approve
```
# Clean-Up
```bash
rm -rf .terraform*
rm -rf terraform.tfstate*
```
