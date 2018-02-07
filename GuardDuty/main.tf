provider "aws" {
  region = "${var.aws_region}"
}

provider "aws.dev" {
  region = "${var.aws_region}"
  profile = "dev"
}

terraform {
  backend "s3" {
    region     = "us-east-1"
    bucket     = "<S3 BUCKET NAME TO STORE TERRAFORM STATE>"
    key        = "tf.tfstate"
    encrypt    = true
  }
}

resource "aws_guardduty_detector" "guardduty_master" {
  enable = true
}

resource "aws_guardduty_detector" "guardduty_member" {
  provider = "aws.dev"
  enable = true
}

resource "aws_guardduty_member" "member" {
  account_id  = "${aws_guardduty_detector.guardduty_member.account_id}"
  detector_id = "${aws_guardduty_detector.guardduty_master.id}"
  email       = "${var.aws_member_account_email_id}"
}
