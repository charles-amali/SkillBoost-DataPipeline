
resource "aws_s3_object" "glue_script" {
  bucket = "skillboost"
  key    = "scripts/extract_rds_to_redshift.py"
  source = "${path.module}/scripts/extract_rds_to_redshift.py"
  etag   = filemd5("${path.module}/scripts/extract_rds_to_redshift.py")
}


resource "aws_glue_job" "rds_to_redshift" {
  name     = "rds-to-redshift-ingest"
  role_arn = aws_iam_role.glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_object.glue_script.bucket}/${aws_s3_object.glue_script.key}"
    # script_location = "s3://skillboost/scripts/extract_rds_to_redshift.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language" : "python"
    "--TempDir"      : "s3://skillboost/temp/"
    "--JOB_NAME"     : "rds-to-redshift-ingest"
    "--rds_database" : var.rds_database
    "--rds_username" : var.rds_username
    "--rds_password" : var.rds_password
    "--rds_url"      : local.rds_url
    "--redshift_db"  : var.redshift_db
    "--redshift_username" : var.redshift_username
    "--redshift_password" : var.redshift_password
    "--redshift_url" : local.redshift_url

  }

  glue_version = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  connections = [
    aws_glue_connection.rds_connection.name,
    aws_glue_connection.redshift_connection.name
  ]
}
resource "aws_security_group" "allow_glue" {
  name        = "allow_glue"
  description = "Allow Glue job access"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-glue"
  }
}

resource "aws_security_group_rule" "allow_glue_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.allow_glue.id
  source_security_group_id = aws_security_group.allow_glue.id
  description              = "Allow all internal traffic for Glue"
}

