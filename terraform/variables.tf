variable "vpc_name" {
  description = "VPC name to deploy into"
  type        = string
}

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

variable "ttv_hostname" {
  description = "(optional) TwitchTV ingest server hostname [Default: live.twitch.tv]"
  type        = string
  default     = "live.twitch.tv"
}

variable "ttv_streamkey" {
  description = "TwitchTV stream key"
  type        = string
}

variable "yt_streamkey" {
  description = "YouTube stream key"
  type        = string
}

variable "task_memory" {
  description = "ECS Service Task Memory"
  type        = number
  default     = 1024
}

variable "task_cpu" {
  description = "ECS Service Task CPU"
  type        = number
  default     = 512
}