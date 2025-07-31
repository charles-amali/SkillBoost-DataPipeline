resource "aws_redshift_cluster" "skillboost_cluster" {
  cluster_identifier = "${var.project_name}-redshift"
  node_type          = "ra3.xlplus"
  number_of_nodes    = 1
  database_name      = var.redshift_db
  master_username    = "admin"
  master_password    = "SkillboostRedshift123!"
  publicly_accessible = true
  skip_final_snapshot = true
  availability_zone_relocation_enabled = true
  encrypted                            = true
  vpc_security_group_ids = [aws_security_group.allow_redshift.id]

}

resource "aws_redshiftdata_statement" "create_schemas" {
  cluster_identifier = aws_redshift_cluster.skillboost_cluster.id
  database           = var.redshift_db
  db_user            = "admin"

  sql = <<EOT
CREATE SCHEMA IF NOT EXISTS raw_schema;
CREATE SCHEMA IF NOT EXISTS curated;
CREATE SCHEMA IF NOT EXISTS presentation;
EOT
}


resource "aws_redshift_cluster_iam_roles" "attach_role" {
  cluster_identifier = aws_redshift_cluster.skillboost_cluster.cluster_identifier
  iam_role_arns      = [aws_iam_role.redshift_data_api_role.arn]
}


resource "aws_security_group" "allow_redshift" {
  name        = "allow_redshift"
  description = "Allow Redshift access"
  vpc_id      = data.aws_vpc.selected.id

  # Allow your IP to connect to Redshift (for testing/debugging)
  # ingress {
  #   from_port   = 5439
  #   to_port     = 5439
  #   protocol    = "tcp"
  #   cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]

  # }

  # Glue workers talking to each other (self-ingress rule)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

#   ingress {
#   from_port   = 5439
#   to_port     = 5439
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
# }

  tags = {
    Name = "redshift-access"
  }
}

resource "aws_security_group_rule" "allow_glue_to_redshift" {
  type                     = "ingress"
  from_port                = 5439
  to_port                  = 5439
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_redshift.id
  source_security_group_id = aws_security_group.allow_glue.id  # This is the Glue SG
  description              = "Allow Glue to access Redshift"
}

resource "aws_security_group_rule" "allow_redshift_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_redshift.id
  source_security_group_id = aws_security_group.allow_redshift.id
  description              = "Allow internal Glue traffic to Redshift"
}


# GRANT EXECUTE ON PROCEDURE curated.sp_transform_raw_to_curated TO admin;
# GRANT EXECUTE ON PROCEDURE presentation.sp_generate_kpis TO admin;




# resource "aws_redshiftdata_statement" "create_raw_schema" {
#   cluster_identifier = aws_redshift_cluster.skillboost_cluster.id
#   database           = var.redshift_db
#   db_user            = "admin"
#   sql                = "CREATE SCHEMA IF NOT EXISTS raw_schema;"
# }

# resource "aws_redshiftdata_statement" "create_curated_schema" {
#   cluster_identifier = aws_redshift_cluster.skillboost_cluster.id
#   database           = var.redshift_db
#   db_user            = "admin"
#   sql                = "CREATE SCHEMA IF NOT EXISTS curated;"
# }

# resource "aws_redshiftdata_statement" "create_presentation_schema" {
#   cluster_identifier = aws_redshift_cluster.skillboost_cluster.id
#   database           = var.redshift_db
#   db_user            = "admin"
#   sql                = "CREATE SCHEMA IF NOT EXISTS presentation;"
# }
