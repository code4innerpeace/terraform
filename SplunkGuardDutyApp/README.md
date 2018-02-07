# Splunk GuardDuty App

### Overview ###

This terraform code builds the AWS infrastructure required for SplunkGuardDutyApp.

The lambda code(SplunkGuardDutyApp.zip) which sends events to Splunk is downloaded from [SplunkGuardDutyApp](https://splunkbase.splunk.com/app/3790/).

#### Terraform Variables ####

SPLUNK_HEC_URL :- URL where events are sent to Splunk.

SPLUNK_HEC_TOKEN :- Splunk HEC Token which can fetched from Splunk console.

```
variable "SPLUNK_HEC_URL" {
  default = "<SPLUNK HEC URL>"
}

variable "SPLUNK_HEC_TOKEN" {
  default = "<SPLUNK HEC TOKEN>"
}
```

#### Additional Changes ####

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
