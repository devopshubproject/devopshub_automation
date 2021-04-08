
environment  = "dev"
location = "westeurope"
app_name = "automation"

##### OS Image Values ###
image_publisher = "Canonical"
image_offer     = "UbuntuServer"
image_sku = "18.04-LTS"
image_version = "latest"
count = "2"

##### Disk Values #####
data_disk_size         = "100"
data_disk_type = "Standard_LRS"

##### Network Layer Values #####
vnet_rg_name = "ansible-poc-rg"
vnet_name = "ansible-poc-rg-vnet"
subnet_name = "default"
ipconf_name = "dev-automation-ipconfig"

##### Login Values #####
username = "devopshub"

#######################################
# NSG Rules for inbound values
#######################################
rule_name = [
  "remote_ssh",                           #0
  "expose_container"                      #1
]

rule_description = [
  "Allow ssh to the vm",                          #0
  "Expose the container application outside"      #1
]

rule_portrange = [
  "22",                                          #0
  "80"                                           #1
]

########################################
# NSG Rules for outbound values
#######################################
outbound_rule_name = ["allow_to_world"]
outbound_rule_description = ["Allow connection to world"]
outbound_rule_portrange = "*"

##### VM Values ######
vm_size = "Standard_E64s_v3"
