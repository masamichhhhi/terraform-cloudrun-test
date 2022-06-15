variable "project" {
  description = "A name of a GCP project"
  type        = string
  default     = null
}

variable "location" {
  description = "A name of a GCP location"
  type        = string
  default     = "asia-northeast1"
}

variable "container_image" {
  description = "docker cointainer image"
  type        = string
  default     = ""
}

variable "service_account_name" {
  description = "Email address of the IAM service account"
  type        = string
  default     = ""
}