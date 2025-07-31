variable "project_name" {
  default = "skillboost"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "redshift_db" {
  default = "skillboost_analytics"
}

variable "redshift_username" {
  default = "admin"
}

variable "redshift_password" {
  default = "SkillboostRedshift123!"
}

variable "rds_host" {
  default = "your-rds-endpoint.rds.amazonaws.com"
}

variable "rds_username" {
  default = "skillboostadmin"
}

variable "rds_password" {
  default = "skillboostpass"
}

variable "rds_database" {
  default = "skillboostdb"
}
