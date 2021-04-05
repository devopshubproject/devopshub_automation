###### General ######

variable "environment" {
  type        = "string"
  description = "The environment name"
}
variable "location" {
  type        = "string"
  description = "The Location for Infra centre"
  default     = "westeurope"
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

#### LB Rule Details ####
variable "lb_port" {
  description = "Protocols to be used for lb rules"
  type        = map(any)
  default     = {}
}

#### LB Probe Details ####
variable "lb_probe_unhealthy_threshold" {
  description = "Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy"
  type        = number
  default     = 2
}
variable "lb_probe_interval" {
  description = "Interval in seconds the load balancer health probe rule does a check"
  type        = number
  default     = 5
}
variable "lb_probe" {
  description = "(Optional) Protocols to be used for lb health probes. Format as [protocol, port, request_path]"
  type        = map(any)
  default     = {}
}

#### LB Details ####
#variable "frontend_private_ip_address" {
#  description = "(Optional) Private ip address to assign to frontend. Use it with type = private"
#  type        = string
#  default     = ""
#}
#variable "frontend_private_ip_address_allocation" {
#  description = "(Optional) Frontend ip allocation type (Static or Dynamic)"
#  type        = string
#  default     = "Dynamic"
#}

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