##################################################
# Outputs
##################################################
output "azurerm_lb_id" {
  description = "the id for the azurerm_lb resource"
  value       = "${azurerm_lb.lb.id}"
}

output "azurerm_lb_probe_ids" {
  description = "the ids for the azurerm_lb_probe resources"
  value       = azurerm_lb_probe.probw.*.id
}

output "azurerm_lb_nat_rule_ids" {
  description = "the ids for the azurerm_lb_nat_rule resources"
  value       = azurerm_lb_nat_rule.lbrule.*.id
}