variable "name" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag_mutability" {
  description = "Whether tag mutability is MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scan on push"
  type        = bool
  default     = true
}

variable "keep_last_n_images" {
  description = "How many tagged images to keep"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Common tags applied to all ECR resources"
  type        = map(string)
  default     = {}
}