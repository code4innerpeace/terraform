import boto3
import os

def lambda_handler(event, context):
    """
        This lambda send SNS notification about AMI creation failure.
    """
    client = boto3.client('sns')
    topic_arn = os.environ['topic_arn']
    try:
        ami_id = event['ami_id']
        message = "AMI {ami_id} creation failed.".format(ami_id=ami_id)
        subject = "AMI Creation failed."
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
        print("Error encountered during sending SNS notification.")
        raise
