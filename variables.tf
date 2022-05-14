# !! EKS Cluster Information

variable "EKS_cluster_name" {
  description = "Name of the EKS cluster created via eksctl"
  type    = "string"
  default = "atg-useast2"
}

variable "route53_zone" {
  type    = "string"
}

# !! MISP Database !!
variable "MISP_database_name" {
  type    = "string"
  default = "misp"
}
variable "MISP_database_user" {
  type    = "string"
  default = "misp"
}
variable "MISP_database_root_psswd" {
  type    = "string"
}
variable "MISP_database_size" {
  description = "Default size for the MISP MySQL Database"
  type = "number"
  default = 20
}


variable "MISP_ADMIN_EMAIL" {
  type    = "string"
}

variable "MISP_ADMIN_PASSPHRASE" {
  type    = "string"
}

variable "POSTFIX_RELAY_HOST" {
  type    = "string"
}

variable "TIMEZONE" {
  type    = "string"
}

variable "DATA_DIR" {
  type    = "string"
}

variable "aws_region" {
  type    = "string"
}

variable "authorized_ips" {
  type = string
}


