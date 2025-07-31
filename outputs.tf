# output "step_function_name" {
#   value = aws_sfn_state_machine.etl_orchestration.name
# }
output "rds_url" {
  value = local.rds_url
}
output "redshift_endpoint" {
  value = local.redshift_url
}
