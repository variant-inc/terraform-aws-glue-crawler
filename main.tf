locals {
  paths_arns = [for i in var.s3_target : format("arn:aws:s3:::%s*", trimprefix(i.path, "s3://"))]
}

data "aws_caller_identity" "current" {}

resource "aws_glue_crawler" "crawler" {
  name          = var.name
  database_name = var.database_name
  #fixed role name: role = length(var.role) == 0 ? format("arn:aws:iam::%s:role/service-role/%s", data.aws_caller_identity.current.account_id, format("AWSGlueServiceRole-%s", var.name)) : var.role
  role = length(var.role) == 0 ? aws_iam_role.crawler_role[0].arn : var.role

  dynamic "s3_target" {
    for_each = var.s3_target

    content {
      path            = lookup(s3_target.value, "path", null)
      connection_name = lookup(s3_target.value, "connection_name", null)
      exclusions = lookup(s3_target.value, "exclusions", [
        "archive**",
        "staging**",
        "raw**"
      ])
      sample_size         = lookup(s3_target.value, "sample_size", null)
      event_queue_arn     = lookup(s3_target.value, "event_queue_arn", null)
      dlq_event_queue_arn = lookup(s3_target.value, "dlq_event_queue_arn", null)
    }
  }

  schedule    = var.schedule
  classifiers = var.classifiers
  configuration = jsonencode(merge({
    "Version" : 1.0,
    "CrawlerOutput" : {
      "Partitions" : {
        "AddOrUpdateBehavior" : "InheritFromTable"
      },
      "Tables" : {
        "AddOrUpdateBehavior" : "MergeNewColumns"
      }
    },
    "Grouping" : {
      "TableGroupingPolicy" : "CombineCompatibleSchemas",
      "TableLevelConfiguration" : 2
    }
    },
    var.configuration
  ))

  schema_change_policy {
    delete_behavior = lookup(var.schema_change_policy, "delete_behavior", null)
    update_behavior = lookup(var.schema_change_policy, "update_behavior", null)
  }
  lineage_configuration {
    crawler_lineage_settings = var.lineage_configuration ? "ENABLE" : "DISABLE"
  }
  recrawl_policy {
    recrawl_behavior = var.recrawl_behavior
  }
}

resource "aws_iam_role" "crawler_role" {
  count = length(var.role) == 0 ? 1 : 0
  name  = format("AWSGlueServiceRole-%s", var.name)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"]

  inline_policy {
    name = "replication-policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : local.paths_arns
        }
      ]
    })
  }
}
