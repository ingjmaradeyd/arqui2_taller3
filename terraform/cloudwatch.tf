resource "aws_cloudwatch_dashboard" "dynamodb" {
  dashboard_name = "SITP-DynamoDB-Performance"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "DynamoDB - Consumed Read Capacity"
          region = var.aws_region

          metrics = [
            [
              "AWS/DynamoDB",
              "ConsumedReadCapacityUnits",
              "TableName",
              aws_dynamodb_table.usuarios.name
            ]
          ]

          period = 60
          stat   = "Sum"
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "DynamoDB - Consumed Write Capacity"
          region = var.aws_region

          metrics = [
            [
              "AWS/DynamoDB",
              "ConsumedWriteCapacityUnits",
              "TableName",
              aws_dynamodb_table.usuarios.name
            ]
          ]

          period = 60
          stat   = "Sum"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "DynamoDB - Successful Request Latency"
          region = var.aws_region

          metrics = [
            [
              "AWS/DynamoDB",
              "SuccessfulRequestLatency",
              "TableName",
              aws_dynamodb_table.usuarios.name,
              "Operation",
              "GetItem"
            ]
          ]

          period = 60
          stat   = "Average"
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "DynamoDB - Throttled Requests"
          region = var.aws_region

          metrics = [
            [
              "AWS/DynamoDB",
              "ThrottledRequests",
              "TableName",
              aws_dynamodb_table.usuarios.name
            ]
          ]

          period = 60
          stat   = "Sum"
        }
      }
    ]
  })
}
