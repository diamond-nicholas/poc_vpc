output "instance_public_ip" {
  value = aws_instance.ec2_block.public_ip
}

output "private_key_path" {
  value = local_file.private_key.filename
}