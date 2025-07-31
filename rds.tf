resource "aws_db_instance" "mock_rds" {
  identifier              = "skillboost-mock-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.micro"
  db_name                 = var.rds_database
  username                = var.rds_username
  password                = var.rds_password
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.allow_postgres.id]
}

  data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_vpc" "selected" {
  default = true
}

resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow PostgreSQL access"
  vpc_id     = data.aws_vpc.selected.id


  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]

  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
  Name        = "skillboost-mock-db"
  Environment = "dev"
}
}

resource "aws_security_group_rule" "allow_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_postgres.id
  source_security_group_id = aws_security_group.allow_postgres.id
  description       = "Allow self-ingress for Glue internal communication"
}

resource "aws_security_group_rule" "allow_glue_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_postgres.id
  source_security_group_id = aws_security_group.allow_glue.id
  description              = "Allow Glue to access RDS"
}