locals {
  rds_url = "jdbc:postgresql://${aws_db_instance.mock_rds.address}:5432/${var.rds_database}"
  redshift_url = "jdbc:redshift://${aws_redshift_cluster.skillboost_cluster.endpoint}/${var.redshift_db}"
}

