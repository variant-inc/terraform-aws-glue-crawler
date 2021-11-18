variable "name" {
  description = "Name of glue crawler."
  type        = string
}

variable "database_name" {
  description = "Name of the Database where results from crawler will be stored"
  type        = string
}

variable "role" {
  description = "ARN of existing role used for Glue crawler. If not specified new one is created"
  type        = string
  default     = ""
}

variable "s3_target" {
  description = "All parameters for S3 target"
  type        = list(any)
  default     = []
}

variable "classifiers" {
  description = "List of custom clasifiers."
  type        = list(string)
  default     = null
}

variable "configuration" {
  description = "JSON of configuration information."
  type        = any
  default     = {}
}

variable "schedule" {
  description = "Cron expression for scheduled crawls. Example: \"cron(45 13 * * ? *)\""
  type        = string
  default     = "cron(45 13 * * ? *)"
}

variable "schema_change_policy" {
  description = "Policy for the crawler's update and deletion behavior."
  type = object({
    delete_behavior = string
    update_behavior = string
  })
  default = {
    "delete_behavior" = null
    "update_behavior" = null
  }
}

variable "lineage_configuration" {
  description = "Specifies data lineage configuration settings for the crawler."
  type        = bool
  default     = false
}

variable "recrawl_behavior" {
  description = "Specifies whether to crawl the entire dataset again or to crawl only folders that were added since the last crawler run."
  type        = string
  default     = null
}