import boto3
import os

def lambda_handler(event, context):
    """
        This lambda send SNS notification about instance launch.
    """
    client = boto3.client('sns')
    topic_arn = os.environ['topic_arn']
    try:
        quarantine_instance_id = event['quarantine_instance_id']
        message = "Quarantine Instance : {quarantine_instance_id} has been launched.".format(quarantine_instance_id=quarantine_instance_id)
        subject = "Quarantine Instance had been launched."
        client.publish(
                TopicArn=topic_arn,
                Message=message,
                Subject=subject
                )
        return message
    except KeyError as ke:
        print("Key not found : {ke}".format(ke=ke))
        raise
    except:
        print("Error encountered while sending SNS notification about instance launch.")
        raise
