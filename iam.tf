
resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ✅ S3 Read/Write for temp & scripts
resource "aws_iam_policy" "glue_s3_access" {
  name = "${var.project_name}-glue-s3-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::skillboost/scripts/*",
          "arn:aws:s3:::skillboost/redshift-dir/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::skillboost"
      }
    ]
  })
}

# ✅ Redshift: Only allow connection & COPY/UNLOAD
resource "aws_iam_policy" "glue_redshift_access" {
  name = "${var.project_name}-glue-redshift-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "redshift:GetClusterCredentials",
          "redshift-data:ExecuteStatement",
          "redshift-data:GetStatementResult"
        ],
        Resource = "*"
      }
    ]
  })
}

# ✅ RDS: Allow JDBC connection (via Secrets Manager if used)
resource "aws_iam_policy" "glue_rds_access" {
  name = "${var.project_name}-glue-rds-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters"
        ],
        Resource = "*"
      }
    ]
  })
}

# ✅ Attach all policies to Glue role
resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "glue_redshift_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_redshift_access.arn
}

resource "aws_iam_role_policy_attachment" "glue_rds_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_rds_access.arn
}

# Keep AWSGlueServiceRole for Glue internals
resource "aws_iam_role_policy_attachment" "glue_service_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


resource "aws_iam_role" "stepfn_role" {
  name = "${var.project_name}-stepfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "states.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# resource "aws_iam_role_policy_attachment" "stepfn_redshift_access" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
#   role       = aws_iam_role.stepfn_role.name
# }

resource "aws_iam_policy" "stepfn_redshift_access" {
  name = "${var.project_name}-stepfn-redshift-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "redshift-data:ExecuteStatement",
        "redshift-data:GetStatementResult",
        "redshift:GetClusterCredentials"
      ],
      Resource = "*"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "stepfn_redshift_attach" {
  role       = aws_iam_role.stepfn_role.name
  policy_arn = aws_iam_policy.stepfn_redshift_access.arn
}

# resource "aws_iam_role_policy_attachment" "stepfn_glue_access" {
#   policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
#   role       = aws_iam_role.stepfn_role.name
# }

resource "aws_iam_policy" "stepfn_glue_access" {
  name = "${var.project_name}-stepfn-glue-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:GetJob",
          "glue:ListJobs"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "stepfn_glue_attach" {
  role       = aws_iam_role.stepfn_role.name
  policy_arn = aws_iam_policy.stepfn_glue_access.arn
}


resource "aws_iam_role" "redshift_data_api_role" {
  name = "${var.project_name}-redshift-dataapi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "redshift.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_redshift_data_api_permissions" {
  role       = aws_iam_role.redshift_data_api_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftDataFullAccess"
}


resource "aws_iam_policy" "glue_ec2_access" {
  name = "${var.project_name}-glue-ec2-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_ec2_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_ec2_access.arn
}

resource "aws_iam_policy" "glue_cloudwatch_logs" {
  name = "${var.project_name}-glue-cloudwatch-logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_cloudwatch_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_cloudwatch_logs.arn
}

resource "aws_iam_policy" "stepfn_sns_publish" {
  name = "${var.project_name}-stepfn-sns-publish"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.etl_failure_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stepfn_sns_publish_attach" {
  role       = aws_iam_role.stepfn_role.name
  policy_arn = aws_iam_policy.stepfn_sns_publish.arn
}



resource "aws_iam_role" "lambda_redshift_role" {
  name = "${var.project_name}-lambda-redshift-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_policy" "lambda_redshift_policy" {
  name = "${var.project_name}-lambda-redshift-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue", 
          "redshift:DescribeClusters",
          "redshift:GetClusterCredentials"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "redshift-data:ExecuteStatement",
          "redshift-data:GetStatementResult",
          "redshift-data:DescribeStatement"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.etl_failure_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_redshift_attach" {
  role       = aws_iam_role.lambda_redshift_role.name
  policy_arn = aws_iam_policy.lambda_redshift_policy.arn
}
