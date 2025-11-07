variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image vulnerability scanning"
  type        = bool
  default     = true
}

variable "keep_last_n_images" {
  description = "Number of images to retain (0 = keep all)"
  type        = number
  default     = 10
}