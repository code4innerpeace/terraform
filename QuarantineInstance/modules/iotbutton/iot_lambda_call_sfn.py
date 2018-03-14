import boto3
import os
import datetime

def send_notification(message, subject):
    client = boto3.client('sns')
    topic_arn = os.environ['topic_arn']
    try:
        client.publish(
                TopicArn=topic_arn,
                Message=message,
                Subject=subject
                )
        return message
    except:
        print("Error encountered while sending SNS notification.")
        raise

def lambda_handler(event, context):
    """
        This lambda send SNS notification when there is an error.
    """

    try:
        client = boto3.client('stepfunctions')
        date_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        stateMachineArn=os.environ['sfn_arn']
        name = 'QuarantineSFNExecution_' + date_time
        response = client.start_execution(
            stateMachineArn=stateMachineArn,
            name=name,
            input='{}'
        )

        subject = "IoTButton : {execution_arn} status."
        message = "{sfn} step function {execution_arn} has started successfully at {startDate}.".format(sfn=stateMachineArn,execution_arn=response['executionArn'],startDate=response['startDate'])
        send_notification(message=message, subject=subject)
        print(response)
    except:
        print("Error calling statemachine.")
        subject = "ERROR : IoTButton : {execution_arn} status."
        message = "{sfn} step function {execution_arn} has failed.".format(sfn=stateMachineArn,execution_arn=response['executionArn'])
        send_notification(message=message, subject=subject)
        raise
