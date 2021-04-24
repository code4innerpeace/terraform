output "iot_button_lambda_arn" {
  value = module.iotbutton.iot_button_lambda_arn
}

output "state_function_arn" {
  value = module.stepfunctions.state_machine_name_id
}

output "topic_arn" {
  value = module.stepfunctions.quarantine_instance_topic_arn
}
