import boto3
import os

def lambda_handler(event, context):
    """
        This lambda fetches instance id from SSM parameter store defined in vars.tf file.
    """
    try:
        client = boto3.client('ssm')
        ssm_parameter_store = os.environ['ssm_parameter_store']
        response = client.get_parameter(Name=ssm_parameter_store)
        instance_id = response['Parameter']['Value']
        print("Instance Id : " + instance_id)
        return instance_id
    except KeyError:
        print("SSM parameter store {ssm_parameter_store} doesn't exist.".format(ssm_parameter_store=ssm_parameter_store))
        raise
    except:
        print("Error encountered while getting instance id.")
        raise
