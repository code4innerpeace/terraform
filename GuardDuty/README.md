# AWS GuardDuty

###  This project enables GuardDuty on 'master' and 'member' account.

#### Setup ####

Make sure AWS 'member' profile 'dev' is created. The profile 'dev' will be used for 'member' account in Terraform.
For example below is sample AWS configuration in 'AWS Credentials' file.

```
[default]
aws_access_key_id = <AWS ACCESS KEY>
aws_secret_access_key = <AWS SECRET KEY>
[dev]
aws_access_key_id = <AWS ACCESS KEY>
aws_secret_access_key = <AWS SECRET KEY>

```

#### Terraform Variables ####
aws_member_account_email_id :- This is the e-mail id used by 'member' account.
