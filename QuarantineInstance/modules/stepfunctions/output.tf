output "lambda_role_policy_name" {
  value = "${aws_iam_policy.lambda_role_policy.name}"
}

output "lambda_role_policy_arn" {
  value = "${aws_iam_policy.lambda_role_policy.arn}"
}

output "lambda_get_instance_id_name" {
  value = "${aws_lambda_function.get_instance_id.function_name}"
}

output "lambda_create_ami_name" {
  value = "${aws_lambda_function.create_ami.function_name}"
}

output "lambda_get_ami_status_name" {
  value = "${aws_lambda_function.get_ami_status.function_name}"
}

output "lambda_launch_quarantine_instance_name" {
  value = "${aws_lambda_function.launch_quarantine_instance.function_name}"
}

output "lambda_ami_creation_failure" {
  value = "${aws_lambda_function.ami_creation_failure.function_name}"
}

output "launch_instance_notification" {
  value = "${aws_lambda_function.launch_instance_notification.function_name}"
}

output "lambda_error_notification" {
  value = "${aws_lambda_function.error_notification.function_name}"
}

output "state_machine_name_id" {
  value = "${aws_sfn_state_machine.quarantine_instance_state_machine.id}"
}

output "quarantine_instance_topic_arn" {
  value = "${aws_sns_topic.quarantine_instance_updates.arn}"
}
