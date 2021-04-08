###### General ######

variable "environment" {
  type        = "string"
  description = "The environment name"
}

variable "location" {
  type        = "string"
  description = "The Location for Infra centre"
  default     = "northeurope"
}

#### Tags ####

variable "owner" {
  type        = string
  description = "The name of the infra provisioner or owner"
  default     = "Prem"
}
variable "company" {
  type        = string
  description = "The cost_center name for this porject"
  default     = "DevOpsHub"
}
variable "app_name" {
  type        = string
  description = "Application name of the project"
  default     = "automation"
}

#### VM Details ####
varialbe "count" {
  type        = string
  description = "No. of vm resource"
}
variable "vm_size" {
  type        = string
  description = "The Size for vm resource"
}
variable "disable_password_authentication" {
  type        = string
  description = "disable_password_authentication"
  default     = "true"
}
variable "image_publisher" {
  type        = string
  description = "Publisher Name for the OS image"
}
variable "image_offer" {
  type        = string
  description = "Image offer name for the selected OS image"
}
variable "image_sku" {
  type        = string
  description = "sku name for the selected OS Image"
}
variable "image_version" {
  type        = string
  description = "Selected OS image version"
}

#### Disk Details ####
variable "data_disk_type" {
  type        = string
  description = "data disk type"
}
variable "data_disk_size" {
  type        = string
  description = "size for the secondary disk"
}
#### Network rule Details ####
variable "rule_name" {
  type = list(string)
  description = "Names of the rules"
}
variable "rule_description" {
  type = list(string)
  description = "Short description for the rule"
}
variable "rule_portrange" {
  type = list(number)
  description = "Define the port need to be opened"
}
variable "outbound_rule_name" {
  type = list(string)
  description = "Names of the outbound rules"
}
variable "outbound_rule_description" {
  type = list(string)
  description = "Short description for the outbound rule"
}
variable "outbound_rule_portrange" {
  #type = list(number)
  description = "Define the port need to be opened for outbound"
}

#### Network layer Details ####
variable "vnet_name" {
  type = "string"
  description = "The core network environment vnet name"
}
variable "vnet_rg_name" {
  type = "string"
  description = "The core network vnet resource group name"
}
variable "subnet_name" {
  type = "string"
  description = "The core network subnet resource name"
}
variable "ipconf_name" {
  type = "string"
  description = "The nic name for the e resource"
}

#### Network layer Details ####
variable "username" {
  type = "string"
  description = "Admin user name"
}