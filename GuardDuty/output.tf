output "master_guardduty_account_id" {
  value = "${aws_guardduty_detector.guardduty_master.account_id}"
}

output "member_guardduty_account_id" {
  value = "${aws_guardduty_detector.guardduty_member.account_id}"
}
