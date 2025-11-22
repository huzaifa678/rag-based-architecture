resource "aws_sqs_queue" "ingest_dlq" {
  name = var.sqs_dlq_name
}

resource "aws_sqs_queue" "ingest_queue" {
  name                        = var.sqs_queue_name
  visibility_timeout_seconds  = 900  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ingest_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "allow_s3_send" {
  queue_url = aws_sqs_queue.ingest_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.ingest_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.ingestion_bucket.arn
          }
        }
      }
    ]
  })
}
