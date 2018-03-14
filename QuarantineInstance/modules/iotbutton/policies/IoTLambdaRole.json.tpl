{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:Describe*",
                "ssm:Get*",
                "ssm:List*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                  "sns:Publish"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:ListStateMachines",
                "states:ListActivities",
                "states:DescribeStateMachine",
                "states:DescribeStateMachineForExecution",
                "states:ListExecutions",
                "states:DescribeExecution",
                "states:GetExecutionHistory",
                "states:DescribeActivity",
                "states:StartExecution"
            ],
            "Resource": "*"
        }
    ]
}
