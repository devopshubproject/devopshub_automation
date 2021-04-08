PHASE 1
==========================================
Create a github repository connected to an Azure Devops pipeline which uses a service - Github Account Open account, Azure DevOps Pipeline
connection to an Azure subscription where:
The pipeline runs on an ubuntu environment
The pipeline environment installs ansible and terraform
The pipeline instantiates a VM (any size)
The VM is created with an attached disk
The VM has been installed with docker
The docker service is setup to start at boot with a specific container (e.g. tutum/hello-word)
The docker container has forwarded the port 80
The VM has a network security group with HTTP port 80 enabled
The request to the VM can be done through http://<azure-vm-ip-address>:80/