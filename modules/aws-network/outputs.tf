output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs, one per availability zone."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs, one per availability zone."
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs. One when single_nat_gateway is true, otherwise one per AZ."
  value       = aws_nat_gateway.this[*].id
}

output "flow_log_group_name" {
  description = "CloudWatch log group receiving VPC flow logs, or null when disabled."
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow[0].name : null
}
