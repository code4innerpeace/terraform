output "vpc_id" {
  value = aws_vpc.quarantine_instances_vpc.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "public_subnet_rt_id" {
  value = aws_route_table.public_subnet_rt.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "private_subnet_rt_id" {
  value = aws_route_table.private_subnet_rt.id
}

output "quarantine_instances_sg" {
  value = aws_security_group.quarantine_instances_sg.id
}
