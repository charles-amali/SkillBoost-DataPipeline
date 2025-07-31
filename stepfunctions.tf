
resource "aws_sfn_state_machine" "etl_orchestration" {
  name     = "${var.project_name}-etl-pipeline"
  role_arn = aws_iam_role.stepfn_role.arn

  definition = jsonencode({
    StartAt = "RunGlueJob",
    States = {
      RunGlueJob = {
        Type = "Task",
        Resource = "arn:aws:states:::glue:startJobRun.sync",
        Parameters = {
          JobName = aws_glue_job.rds_to_redshift.name
        },
        Next = "TransformProcedure",
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next        = "NotifyFailure"
        }]
      },

      TransformProcedure = {
        Type = "Task",
        Resource = "arn:aws:lambda:eu-west-1:842676015206:function:skillboost-redshift-sql-runner"
        Parameters = {
          procedure = "transform_raw_to_curated"
        },
        Next = "BuildProcedure",
        Retry = [{
          ErrorEquals = ["States.ALL"],
          IntervalSeconds = 10,
          MaxAttempts     = 3,
          BackoffRate     = 2.0
        }],
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next        = "NotifyFailure"
        }]
      },

      BuildProcedure = {
        Type = "Task",
        Resource = "arn:aws:lambda:eu-west-1:842676015206:function:skillboost-redshift-sql-runner"
        Parameters = {
          procedure = "build_star_schema"
        },
        Next = "NotifySuccess",
        Retry = [{
          ErrorEquals = ["States.ALL"],
          IntervalSeconds = 10,
          MaxAttempts     = 3,
          BackoffRate     = 2.0
        }],
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next        = "NotifyFailure"
        }]
      },

      NotifySuccess = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = aws_sns_topic.etl_success_topic.arn,
          Message  = "ETL pipeline completed successfully.",
          Subject  = "ETL Success"
        },
        End = true
      },

      NotifyFailure = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = aws_sns_topic.etl_failure_topic.arn,
          Message  = "ETL pipeline failed at some stage. Please check logs and take action.",
          Subject  = "ETL Pipeline Failure Alert"
        },
        Next = "FailState"
      },

      FailState = {
        Type  = "Fail",
        Error = "ETLJobFailed",
        Cause = "An error occurred during the ETL pipeline execution"
      }
    }
  })
}
