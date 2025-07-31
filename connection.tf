
resource "aws_glue_connection" "rds_connection" {
  name = "rds-skillboost-conn"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://${aws_db_instance.mock_rds.address}:5432/skillboostdb"
    USERNAME            = "skillboostadmin"
    PASSWORD            = "skillboostpass"
  }

  physical_connection_requirements {
    availability_zone      = "eu-west-1c"
    security_group_id_list = [aws_security_group.allow_glue.id]
    subnet_id              = "subnet-023ef9a340a1083e6"
  }
}


resource "aws_glue_connection" "redshift_connection" {
  name = "redshift-conn"

  connection_properties = {
    JDBC_CONNECTION_URL   = local.redshift_url
    USERNAME              = var.redshift_username
    PASSWORD              = var.redshift_password
  }

  physical_connection_requirements {
    availability_zone      = "eu-west-1b"
    security_group_id_list = [aws_security_group.allow_glue.id]
    subnet_id              = "subnet-0d825740a4d575238"
  }
}



