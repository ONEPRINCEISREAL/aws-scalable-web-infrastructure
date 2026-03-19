output "vpc_id" {
    value = aws_vpc.main.id
    description = "This is the vpc id"
}

output "public_subnet_ids" {
    value = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
    description = "This is Public subnet ids" 
}

output "private_subnet_ids" {
    value = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
    description = "This is private subnet ids"
}

