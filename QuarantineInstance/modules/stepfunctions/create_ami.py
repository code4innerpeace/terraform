import boto3
import datetime

def lambda_handler(event, context):
    # TODO implement
    """
        This lambda tries to create AMI from instance id provided.
    """
    try:
        client = boto3.client('ec2')
        instance_id = event['instance_id']
        date_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        name = "Quarantine_Image_{date_time}_{instance_id}".format(date_time=date_time,instance_id=instance_id)
        response = client.create_image(InstanceId=instance_id, Name=name)
        return response['ImageId']
    except KeyError:
        print("'instance_id' key doesn't exist in 'event' object.")
        raise
    except:
        print("Error encountered while creating AMI image.")
        raise
