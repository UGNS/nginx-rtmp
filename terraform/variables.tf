variable "domain" {
  description = "Domain to use for RTMP server hostname"
  type        = string
  default     = "example.com"
}

variable "hostname" {
  description = "Hostname of RTMP server to prepend to domain"
  type        = string
  default     = "rtmp"
}