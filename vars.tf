variable "k8s_version" {
  type    = string
  default = "1.32"
}

variable "env" {
  type    = string
  default = "test-task"
}

variable "eks_instance_type" {
  type    = string
  default = "t4g.small"
}

variable "node_group_min_size" {
  type    = number
  default = 1
}

variable "node_group_max_size" {
  type    = number
  default = 2
}

variable "node_group_desired_size" {
  type    = number
  default = 1
}
