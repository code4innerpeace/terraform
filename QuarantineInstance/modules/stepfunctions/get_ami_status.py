import boto3

def lambda_handler(event, context):
    """
        This lambda tries to get status of AMI created in earlier step.
    """
    try:
        ec2 = boto3.resource('ec2')
        ami_id = event['ami_id']
        print('AMI ID :  {ami_id}'.format(ami_id=ami_id))
        image = ec2.Image(ami_id)
        ami_status = image.state
        print('AMI STATUS : {ami_status}'.format(ami_status=ami_status))
        return ami_status
    except KeyError:
        print("'ami_id' key doesn't exist in 'event' object.")
        raise
    except:
        print("Error encountered while getting AMI status.")
        raise
