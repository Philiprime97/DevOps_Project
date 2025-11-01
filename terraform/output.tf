output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "thanos_s3_bucket_name" {
  value = aws_s3_bucket.thanos_bucket.id
}
