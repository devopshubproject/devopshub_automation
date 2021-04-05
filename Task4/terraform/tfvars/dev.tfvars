environment  = "dev"
location = "westeurope"
app_name = "automation"

##### LB Probe Values ###
lb_probe = {
    probe1  = ["Tcp", "80", ""]
    probe2 = ["Http", "8080", "/healthy"]
  }

##### LB Rule Values ###
lb_port = {
    rule1  = ["80", "Tcp", "80"]
    rule2 = ["8080", "Tcp", "8080"]
  }

##### Network Layer Values #####
vnet_rg_name = "ansible-poc-rg"
vnet_name = "ansible-poc-rg-vnet"
subnet_name = "default"
ipconf_name = "dev-automation-ipconfig"