variable "project_name" {}
variable "environment" {}
variable "resource_group_name" {}
variable "zone_name" {}
variable "records" {
  type = map(string)
}
variable "vnet_ids" {
  type = list(string)
}
