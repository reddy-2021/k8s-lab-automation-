variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "key_name" {
  default = "k8s-key"
}

variable "worker_count" {
  description = "Number of worker nodes"
  default     = 2
}