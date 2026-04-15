variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "worker_count" {
  default = 2
}

variable "key_name" {
  default = "k8s-key"
}
