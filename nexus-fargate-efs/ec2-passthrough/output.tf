output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.test-ec2-instance.public_ip
}