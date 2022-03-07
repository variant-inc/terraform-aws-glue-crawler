# Terraform Glue Crawler module

- [Terraform Glue Crawler module](#terraform-glue-crawler-module)
  - [Input Variables](#input-variables)
  - [Variable definitions](#variable-definitions)
    - [name](#name)
    - [tags](#tags)
    - [database_name](#database_name)
    - [create_role](#create_role)
    - [policy](#policy)
    - [managed_policies](#managed_policies)
    - [role](#role)
    - [s3_target](#s3_target)
    - [classifiers](#classifiers)
    - [configuration](#configuration)
    - [schedule](#schedule)
    - [schema_change_policy](#schema_change_policy)
    - [lineage_configuration](#lineage_configuration)
    - [recrawl_behavior](#recrawl_behavior)
  - [Examples](#examples)
    - [`main.tf`](#maintf)
    - [`terraform.tfvars.json`](#terraformtfvarsjson)
    - [`provider.tf`](#providertf)
    - [`variables.tf`](#variablestf)
    - [`outputs.tf`](#outputstf)

## Input Variables
| Name     | Type    | Default   | Example     | Notes   |
| ---------- | --------- | ------------| --------------- | --------- |
| name | string |  | "test-crawler" |  |
| tags | map(string) | {} | {"environment": "prod"} | |
| database_name | string |  | "test-crawler-db" |  |
| create_role | bool | true | false |  |
| policy | list(any) | [] | `see below` |  |
| managed_policies | list(string) | [] | `see below` |  |
| role | string | "" | "arn:aws:iam::648462982672:role/service-role/AWSGlueServiceRole-test-role" |  |
| s3_target | list(any) | [] | `see below` |  |
| classifiers | list(string) | null | ["test-clasifier"] |  |
| configuration | any | {} | `see below` | <https://docs.aws.amazon.com/glue/latest/dg/crawler-configuration.html> |
| schedule | string | `"cron(45 13 * * ? *)"` | `"cron(45 13 * * ? *)"` |  |
| schema_change_policy | object | `see below` | `see below` |  |
| lineage_configuration | bool | false | "DISABLE" |  |
| recrawl_behavior | string | null | `see below` |  |

## Variable definitions

### name
Sets name for Glue Crawler.
```json
"name": "<crawler name>"
```

### tags
Tags for created bucket.
```json
"tags": {<map of tag keys and values>}
```

Default:
```json
"tags": {}
```


### database_name
Database where results should be stored.
```json
"database_name": "<database name>"
```

### create_role
Specifies if IAM role for the Glue Crawler will be created in module or externally.
`true` - created with module
`false` - created externally
```json
"create_role": <true or false>
```

Default:
```json
"create_role": true
```

### policy
Additional inline policy statements for Glue Crawler role.
Effective only if `create_role` is set to `true`.
```json
"policy": [<list of inline policies>]
```

Default:
```json
"policy": []
```

### managed_policies
Additional managed policies which should be attached to auto-created role.
Effective only if `create_role` is set to `true`.
```json
"managed_policies": [<list of managed policies>]
```

Default:
```json
"managed_policies": []
```

### role
ARN of externally created role. Use in case of `create_role` is set to `false`.
```json
"role": "<role ARN>"
```

Default:
```json
"role": ""
```

### s3_target
List that specifys all parameters needed for each S3 target path.
```json
"s3_target": [
  {
    "path": "<S3 path to the target>",
    "connection_name": "<name of a connection which allows crawler to access data in S3 within a VPC>",
    "exclusions": ["<list of glob patterns used to exclude from the crawl>"],
    "sample_size": <number of files used for sample size>,
    "event_queue_arn": "<ARN of the SQS queue to receive S3 notifications from>",
    "dlq_event_queue_arn": "<ARN of the dead-letter SQS queue>"
  }
]
```

Default:
```json
"s3_target": [
  {
    "path": null,
    "connection_name": null,
    "exclusions": ["archive**", "staging**", "raw**"],
    "sample_size": null,
    "event_queue_arn": null,
    "dlq_event_queue_arn": null
  }
]
```

### classifiers
List of custom clasifiers that are going to be used for this Crawler.
```json
"classifiers": ["<list of clasifiers>"]
```

Default:
```json
"classifiers": null
```

### configuration
JSON configuration for Glue Crawler.
Anything defined in variable merges with defaults and overrides only that config property, not others.
More info on each option <https://docs.aws.amazon.com/glue/latest/dg/crawler-configuration.html>
```json
"configuration": {
  "Version" : 1.0,
  "CrawlerOutput" : {
  "Partitions" : {
    "AddOrUpdateBehavior" : "<corresponding to the Update all new and existing partitions with metadata from the table option>"
  },
  "Tables" : {
    "AddOrUpdateBehavior" : "<corresponds to the Add new columns only option>"
  }
  },
  "Grouping" : {
  "TableGroupingPolicy" : "<corresponds to the Create a single schema for each S3 path>",
  "TableLevelConfiguration" : <numeber which corresponds to Table level crawler option>
  }
}
```

Default:
```json
"configuration": {
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
}
```

### schedule
Cron expression for scheduled crawls.
<https://docs.aws.amazon.com/glue/latest/dg/monitor-data-warehouse-schedule.html>
```json
"schedule": "<cron(Minutes Hours Day-of-month Month Day-of-week Year)>"
```

Default:
```json
"schedule": "cron(45 13 * * ? *)"
```

### schema_change_policy
Policy controlling schema changes. By default overriden with settings in configuration block but can be changed if needed.
```json
"schema_change_policy": {
  "delete_behavior": "<The deletion behavior when the crawler finds a deleted object. Valid values: LOG, DELETE_FROM_DATABASE, or DEPRECATE_IN_DATABASE. Defaults to DEPRECATE_IN_DATABASE>",
  "update_behavior": "<The update behavior when the crawler finds a changed schema. Valid values: LOG or UPDATE_IN_DATABASE. Defaults to UPDATE_IN_DATABASE.>"
}
```

Default:
```json
"schema_change_policy": {
  "delete_behavior": null,
  "update_behavior": null
}
```

### lineage_configuration
Specifies whether data lineage is enabled for the crawler.
```json
"lineage_configuration": <true or false>
```

Default:
```json
"lineage_configuration": false
```

### recrawl_behavior
Specifies whether to crawl the entire dataset again or to crawl only folders that were added since the last crawler run.
```json
"recrawl_behavior": "<CRAWL_EVERYTHING or CRAWL_NEW_FOLDERS_ONLY. Default value is CRAWL_EVERYTHING>"
```

Default:
```json
"recrawl_behavior": null
```

## Examples
### `main.tf`
```terraform
module "aws_crawler" {
  source = "github.com/variant-inc/terraform-aws-glue-crawler?ref=v1"

  name          = var.name
  tags          = var.tags
  database_name = var.database_name

  create_role      = var.create_role
  policy           = var.policy
  managed_policies = var.managed_policies
  role             = var.role

  s3_target   = var.s3_target
  classifiers = var.classifiers

  configuration         = var.configuration
  schedule              = var.schedule
  schema_change_policy  = var.schema_change_policy
  lineage_configuration = var.lineage_configuration
  recrawl_behavior      = var.recrawl_behavior
}
```

### `terraform.tfvars.json`
```json
{
  "name": "test-crawler-1",
  "tags": {
    "environment": "prod"
  },
  "managed_policies": [
    "arn:aws:iam::319244236588:policy/example-managed-policy"
  ],
  "database_name": "test-crawler-db",
  "role": "arn:aws:iam::319244236588:role/service-role/AWSGlueServiceRole-test-crawler-1",
  "s3_target": [
    {
      "path": "s3://test-luka-290183/year=2021/",
      "exclusions": [
        "archive**",
        "staging**",
        "raw**"
      ]
    }
  ],
  "classifiers": null,
  "configuration": {
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
      "TableLevelConfiguration" : 3
    }
  },
  "schedule": "cron(25 15 * * ? *)",
  "schema_change_policy": {
    "delete_behavior": "DEPRECATE_IN_DATABASE",
    "update_behavior": "UPDATE_IN_DATABASE"
  },
  "lineage_configuration": false,
  "recrawl_behavior": "CRAWL_EVERYTHING"
}
```

Basic
```json
{
  "name": "test-crawler-1",
  "database_name": "test-crawler-db",
  "s3_target": [
    {
      "path": "s3://test-luka-290183/year=2021/"
    }
  ]
}
```

### `provider.tf`
```terraform
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      team : "DataOps",
      purpose : "glue_crawler_test",
      owner : "Luka"
    }
  }
}
```

### `variables.tf`
copy ones from module

### `outputs.tf`
```terraform
output "crawler_name" {
  value       = module.aws_crawler.crawler_name
  description = "Name of the Glue Crawler"
}
```