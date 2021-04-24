data "template_file" "lambda_policy_template_file" {
  template = file("modules/stepfunctions/policies/LambdaRole.json.tpl")
}

data "template_file" "step_function_policy_template_file" {
  template = file("modules/stepfunctions/policies/StepFunctionsRole.json.tpl")
}

resource "aws_iam_policy" "lambda_role_policy" {
  description = "${var.project_name} Lambda Role Policy"
  name_prefix = "${var.project_name}_lambda_role"
  policy      = data.template_file.lambda_policy_template_file.rendered
}

resource "aws_iam_policy" "step_functions_role_policy" {
  description = "${var.project_name} step functions Policy"
  name_prefix = "${var.project_name}_step_functions_role"
  policy      = data.template_file.step_function_policy_template_file.rendered
}

resource "aws_iam_role" "lambda_role" {
  name_prefix        = "${var.project_name}_lambda_role"
  assume_role_policy = <<EOF
{
          "Version": "2012-10-17",
          "Statement": [
                {
                    "Sid": "",
                    "Effect": "Allow",
                    "Principal": {
                      "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
          ]
    }
  EOF
  description        = "Lambda Role assumed by ${var.project_name}."
}

resource "aws_iam_role" "step_functions_role" {
  name_prefix        = "${var.project_name}_sf_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "states.us-east-1.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  description        = "Step functions Role assumed by ${var.project_name}."
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "step_functions_role_policy_attachment" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_role_policy.arn
}


resource "aws_lambda_function" "get_instance_id" {
  filename         = "modules/stepfunctions/python_code.zip"
  function_name    = "${var.project_name}_get_instance_id"
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_instance_id.lambda_handler"
  source_code_hash = filebase64("modules/stepfunctions/python_code.zip")
  runtime          = "python3.6"
  timeout          = 20

  environment {
    variables = {
      ssm_parameter_store = "${var.ssm_parameter_store}"
    }
  }
}

resource "aws_lambda_function" "create_ami" {
  filename         = "modules/stepfunctions/python_code.zip"
  function_name    = "${var.project_name}_create_ami"
  role             = aws_iam_role.lambda_role.arn
  handler          = "create_ami.lambda_handler"
  source_code_hash = filebase64("modules/stepfunctions/python_code.zip")
  runtime          = "python3.6"
  timeout          = 20
}

resource "aws_lambda_function" "get_ami_status" {
  filename         = "modules/stepfunctions/python_code.zip"
  function_name    = "${var.project_name}_get_ami_status"
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_ami_status.lambda_handler"
  source_code_hash = filebase64("modules/stepfunctions/python_code.zip")
  runtime          = "python3.6"
  timeout          = 20
}

resource "aws_lambda_function" "launch_quarantine_instance" {
  filename         = "modules/stepfunctions/python_code.zip"
  function_name    = "${var.project_name}_launch_quarantine_instance"
  role             = aws_iam_role.lambda_role.arn
  handler          = "launch_quarantine_instance.lambda_handler"
  source_code_hash = filebase64("modules/stepfunctions/python_code.zip")
  runtime          = "python3.6"
  timeout          = 20

  environment {
    variables = {
      ssh_key_name       = "${var.ssh_key_name}"
      subnet_id          = "${var.subnet_id}"
      security_group_ids = "${var.security_group_ids}"
    }
  }
}

resource "aws_lambda_function" "ami_creation_failure" {
  filename         = "modules/stepfunctions/python_code.zip"
  function_name    = "${var.project_name}_ami_creation_failure"
  role             = aws_iam_role.lambda_role.arn
  handler          = "ami_creation_failure.lambda_handler"
  source_code_hash = filebase64("modules/stepfunctions/python_code.zip")
  runtime          = "python3.6"
  timeout          = 20

  environment {
    variables = {
      topic_arn = "${aws_sns_topic.quarantine_instance_updates.arn}"
    }
  }
}

resource "aws_lambda_function" "launch_instance_notification" {
  filename         = "modules/stepfunctions/python_code.zip"
  function_name    = "${var.project_name}_launch_instance_notification"
  role             = aws_iam_role.lambda_role.arn
  handler          = "launch_instance_notification.lambda_handler"
  source_code_hash = filebase64("modules/stepfunctions/python_code.zip")
  runtime          = "python3.6"
  timeout          = 20

  environment {
    variables = {
      topic_arn = "${aws_sns_topic.quarantine_instance_updates.arn}"
    }
  }
}

resource "aws_lambda_function" "error_notification" {
  filename         = "modules/stepfunctions/python_code.zip"
  function_name    = "${var.project_name}_error_notification"
  role             = aws_iam_role.lambda_role.arn
  handler          = "error_notification.lambda_handler"
  source_code_hash = filebase64("modules/stepfunctions/python_code.zip")
  runtime          = "python3.6"
  timeout          = 20

  environment {
    variables = {
      topic_arn = "${aws_sns_topic.quarantine_instance_updates.arn}"
    }
  }
}

resource "aws_sfn_state_machine" "quarantine_instance_state_machine" {
  name     = "${var.project_name}_state_machine"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = <<EOF
{
  	"Comment": "${var.project_name} state machine",
  	"StartAt": "GetInstanceId",
  	"States": {
  		"GetInstanceId": {
  			"Type": "Task",
  			"Resource": "${aws_lambda_function.get_instance_id.arn}",
  			"ResultPath": "$.instance_id",
  			"Next": "CreateAMI",
        "Catch": [
              {
                "ErrorEquals": [ "States.ALL" ],
                "Next": "ErrorSNS"
              }
        ]
  		},
  		"CreateAMI": {
  			"Type": "Task",
  			"Resource": "${aws_lambda_function.create_ami.arn}",
  			"ResultPath": "$.ami_id",
  			"Next": "WaitForAMICreation",
        "Catch": [
              {
                "ErrorEquals": [ "States.ALL" ],
                "Next": "ErrorSNS"
              }
        ]
  		},
  		"WaitForAMICreation": {
  			"Type": "Wait",
  			"Seconds": 120,
  			"Next": "GetAMIStatus"

  		},
  		"GetAMIStatus": {
  			"Type": "Task",
  			"Resource": "${aws_lambda_function.get_ami_status.arn}",
  			"ResultPath": "$.ami_status",
  			"Next": "CheckAMIStatus",
        "Catch": [
              {
                "ErrorEquals": [ "States.ALL" ],
                "Next": "ErrorSNS"
              }
        ]
  		},
  		"CheckAMIStatus": {
  			"Type": "Choice",
  			"Choices": [

  				{
  					"Variable": "$.ami_status",
  					"StringEquals": "available",
  					"Next": "LaunchQuarantineInstance"
  				},
  				{
  					"Variable": "$.ami_status",
  					"StringEquals": "failed",
  					"Next": "AMICreationFailedSNS"
  				},
  				{
  					"Variable": "$.ami_status",
  					"StringEquals": "pending",
  					"Next": "WaitForAMICreation"
  				}
  			]

  		},
  		"LaunchQuarantineInstance": {
  			"Type": "Task",
  			"Resource": "${aws_lambda_function.launch_quarantine_instance.arn}",
  			"ResultPath": "$.quarantine_instance_id",
  			"Next": "QuarantineInstanceLaunchSNS",
        "Catch": [
              {
                "ErrorEquals": [ "States.ALL" ],
                "Next": "ErrorSNS"
              }
        ]
  		},
  		"AMICreationFailedSNS": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.ami_creation_failure.arn}",
  			"ResultPath": "$.message",
  			"End": true
  		},
      "QuarantineInstanceLaunchSNS": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.launch_instance_notification.arn}",
        "ResultPath": "$.message",
  			"End": true
  		},
      "ErrorSNS": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.error_notification.arn}",
  			"ResultPath": "$.message",
  			"End": true
  		}
  	}
  }
EOF
}

resource "null_resource" "quarantine_instance_ssh_key" {
  provisioner "local-exec" {
    command     = "aws ec2 create-key-pair --key-name ${var.ssh_key_name} | jq -r .KeyMaterial > ~/.ssh/${var.ssh_key_name}.pem; chmod 400 ~/.ssh/${var.ssh_key_name}.pem"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "aws_sns_topic" "quarantine_instance_updates" {
  name_prefix = "${var.project_name}_instance_updates"
}
