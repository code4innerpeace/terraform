import boto3
import os

def lambda_handler(event, context):
    """
        This lambda send SNS notification when there is an error.
    """
    client = boto3.client('sns')
    topic_arn = os.environ['topic_arn']
    try:
        message = "Error had been raised while launching quarantine instance."
        subject = "Error :- Launching Quarantine Instance."
        client.publish(
                TopicArn=topic_arn,
                Message=message,
                Subject=subject
                )
        return message
    except:
        print("Error encountered while sending SNS notification.")
        raise
