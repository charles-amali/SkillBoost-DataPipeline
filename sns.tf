# resource "aws_sns_topic" "etl_failure_topic" {
#   name = "${var.project_name}-etl-failure-topic"
# }

# resource "aws_sns_topic_subscription" "email_sub" {
#   topic_arn = aws_sns_topic.etl_failure_topic.arn
#   protocol  = "email"
#   endpoint  = "charles.nkansah@amalitech.com" 
# }


resource "aws_sns_topic" "etl_failure_topic" {
  name = "${var.project_name}-etl-failure"
}

resource "aws_sns_topic" "etl_success_topic" {
  name = "${var.project_name}-etl-success"
}

resource "aws_sns_topic_subscription" "failure_email" {
  topic_arn = aws_sns_topic.etl_failure_topic.arn
  protocol  = "email"
  endpoint  = "charles.nkansah@amalitech.com"
}

resource "aws_sns_topic_subscription" "success_email" {
  topic_arn = aws_sns_topic.etl_success_topic.arn
  protocol  = "email"
  endpoint  = "charles.nkansah@amalitech.com"
}
