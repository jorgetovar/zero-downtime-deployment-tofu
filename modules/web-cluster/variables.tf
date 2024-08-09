variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}
variable "ami" {
  description = "The AMI to run in the cluster"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
  default     = 2
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
