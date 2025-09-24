output "database_public_ip" {
  description = "Public IP of the database instance"
  value       = aws_instance.database.public_ip
}

output "database_private_ip" {
  description = "Private IP of the database instance"
  value       = aws_instance.database.private_ip
}

output "api_public_ip" {
  description = "Public IP of the API instance"
  value       = aws_instance.api.public_ip
}

output "api_private_ip" {
  description = "Private IP of the API instance"
  value       = aws_instance.api.private_ip
}

output "thread_public_ip" {
  description = "Public IP of the Thread instance"
  value       = aws_instance.thread.public_ip
}

output "sender_public_ip" {
  description = "Public IP of the Sender instance"
  value       = aws_instance.sender.public_ip
}

output "api_url" {
  description = "URL to access the API"
  value       = "http://${aws_instance.api.public_ip}:3000"
}

output "thread_url" {
  description = "URL to access the Thread interface"
  value       = "http://${aws_instance.thread.public_ip}:80"
}

output "sender_url" {
  description = "URL to access the Sender interface"
  value       = "http://${aws_instance.sender.public_ip}:8080"
}

output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    database = "ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@${aws_instance.database.public_ip}"
    api      = "ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@${aws_instance.api.public_ip}"
    thread   = "ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@${aws_instance.thread.public_ip}"
    sender   = "ssh -i ~/.ssh/marinelangrez-forum-keypair.pem ubuntu@${aws_instance.sender.public_ip}"
  }
}