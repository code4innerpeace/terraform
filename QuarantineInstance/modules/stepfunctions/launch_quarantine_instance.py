import boto3
import os

def lambda_handler(event, context):
    """
        This lambda launches quarantine instance.
    """
    try:
        client = boto3.client('ec2')
        ami_id = event['ami_id']
        key_name = os.environ['ssh_key_name']
        subnet_id = os.environ['subnet_id']
        security_group_ids = os.environ['security_group_ids'].split(",")
        response = client.run_instances(
            ImageId=ami_id,
            MaxCount=1,
            MinCount=1,
            KeyName=key_name,
            SubnetId=subnet_id,
            SecurityGroupIds=security_group_ids)
        instance_id = response['Instances'][0]['InstanceId']
        print("Instance ID : {instance_id}".format(instance_id=instance_id))
        return instance_id
    except KeyError:
        print("Key Error, key couldn't be found either in 'event' or 'environment' variables")
        raise
    except:
        print("Error encountered while launching quarantine instance.")
        raise
