
resource "aws_lambda_function" "redshift_lambda" {
  filename         = "scripts/lambda/redshift_sql_runner.zip"
  function_name    = "${var.project_name}-redshift-sql-runner"
  role             = aws_iam_role.lambda_redshift_role.arn
  handler          = "redshift_sql_runner.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60

  environment {
    variables = {
      REDSHIFT_CLUSTER = aws_redshift_cluster.skillboost_cluster.cluster_identifier
      REDSHIFT_DATABASE    = var.redshift_db
      REDSHIFT_DB_USER     = var.redshift_username
    }
  }
}
