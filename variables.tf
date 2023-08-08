variable "vpc_id" {
  type        = string
  description = "The VPC to associate the load balancer security groups, and target group with."
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to attach to the load balancer."
  default     = []
}

variable "certificate_arn" {
  description = "The certificate to use with the SSL listener"
  type        = string
  default     = ""
}

variable "http_port" {
  type        = number
  description = "Port on which the load balancer is listening"
  default     = 80
}

variable "https_port" {
  type        = number
  description = "SSL Port on which the load balancer is listening"
  default     = 443
}

variable "health_check_path" {
  type        = string
  description = "Destination for the health check request"
  default     = "/swagger/index.html"
}

variable "dns_zone_id" {
  description = "The ID of the Route53 hosted zone to create an alias record.  The Route53 hosted zone must be accessible via the dns_zone_role_arn"
  type        = string
  default     = ""
}

variable "dns_record_name" {
  description = "he DNS name to use to create an alias record.  The Route53 hosted zone must be accessible via the dns_zone_role_arn"
  type        = string
  default     = ""
}

variable "dns_zone_role_arn" {
  type        = string
  description = "The AWS assume role"
  default     = ""
}

variable "sns_alarm_topic_arn" {
  type        = string
  description = "The SNS Topic ARN to use for Cloudwatch Alarms"
  default     = ""
}

variable "alarm_unheathly_threshold" {
  type        = number
  description = "Number of unheathy hosts that should cause an alarm if the actual is greater than or equal for 60 seconds"
  default     = 1
}

variable "access_logs_enabled" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable access_logs"
}

variable "access_logs_s3_bucket_id" {
  type        = string
  default     = null
  description = "An external S3 Bucket name to store access logs in. If specified, no logging bucket will be created."
}

variable "alb_access_logs_s3_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error"
}

variable "lifecycle_configuration_rules" {
  type = list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload_days = number

    # `filter_and` is the `and` configuration block inside the `filter` configuration.
    # This is the only place you should specify a prefix.
    filter_and = any
    expiration = any
    transition = list(any)

    noncurrent_version_expiration = any
    noncurrent_version_transition = list(any)
  }))
  default     = []
  description = <<-EOT
    A list of S3 bucket v2 lifecycle rules, as specified in [terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)"
    These rules are not affected by the deprecated `lifecycle_rule_enabled` flag.
    **NOTE:** Unless you also set `lifecycle_rule_enabled = false` you will also get the default deprecated rules set on your bucket.
    EOT
}

variable "access_logs_prefix" {
  type        = string
  default     = ""
  description = "The S3 log bucket prefix"
}