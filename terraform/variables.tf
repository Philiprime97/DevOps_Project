variable "region" {
  default = "eu-north-1"
}

variable "jenkins_key_name" {
  description = "Key pair name for Jenkins EC2"
  default     = "jenkins"
}

variable "app_key_name" {
  description = "Key pair name for App EC2"
  default     = "app"
}

variable "jenkins_instance_type" {
  default = "t3.micro"
}

variable "app_instance_type" {
  default = "t3.micro"
}

variable "thanos_s3_bucket" {
  default = "my-thanos-bucket-david-30092025"
}

