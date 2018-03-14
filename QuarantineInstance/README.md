# Quarantine Instance Automation

### Overview ###

Generally, if our instance is being used for abusive or illegal purposes, we get abuse notice e-mail from 'abuse@amazonaws.com.'. In response to notice from Amazon, we shutdown the rogue instance, create an AMI and launch the instance in separate VPC and perform forensic analysis. This terraform code automates this process of creating quarantine instance for forensic analysis.

### Versions ###

Terraform v0.11.2

Note :- The code had been tested on this version.

#### Pre Requisites ####

Before we execute terraform code, we need provide SSM parameter store where we have stored the instance id.
You can use AWS CLI or console to create SSM parameter store and store instance id for which we received
abuse notification from AWS.

Below is AWS CLI command to create SSM parameter store and store instance id.

aws ssm put-parameter --name quarantine_instance_id --value <Instnace Id> --type String

#### Changes to Terraform Code ####

1)
Update S3 Bucket Name, where you want to store Terraform State. This block is optional, it can be ignored.

```
terraform {
  backend "s3" {
    region     = "us-east-1"
    bucket     = "<S3 BUCKET NAME TO STORE TERRAFORM STATE>"
    key        = "tf.tfstate"
    encrypt    = true
  }
}
```

2) Updated 'aws_region', 'project_name', 'ssm_parameter_store'.

* Please make sure 'project_name' is not lengthy, because terraform resources uses 'name_prefix' due to which sometimes we might get AWS name constraint exception.

#### Post Installation ####

Subscribe your e-mail id to the topic(Topic Arn is displayed as output) created by the code. All updates regarding instance creation will be sent to the topic created by terraform code.

#### Destroying Environment ####

1) terraform destroy
2) Remove SSH key from EC2 console key pair and ~/.ssh/<ssh key>.pem.
3) Deregister the AMI.

#### Issues ####

1) Terraform isn't aware of instance which is created by the lambda function, due to which terraform is not able to destroy security group and VPC. So manually terminate the instance after which terraform should be able to delete these resources too.
