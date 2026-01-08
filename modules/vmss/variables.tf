variable "project_name" {}
variable "environment" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}
variable "admin_username" {}

variable "instance_count" {
  type    = number
  default = 2
}


variable "backend_pool_id" {
  type = string
}