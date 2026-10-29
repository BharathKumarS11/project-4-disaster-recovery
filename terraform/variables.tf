variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "project4-dr"
}

variable "cluster_version" {
  description = "EKS version supported by the selected region"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IPv4 address in CIDR notation, for example 203.0.113.10/32"
  type        = string
}

variable "node_instance_type" {
  type    = string
  default = "t3.small"
}