variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS Profile"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name for the application"
  type        = string
  default     = "asklabs.ai"
}
