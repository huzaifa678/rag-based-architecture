resource "aws_s3_bucket" "ingestion_bucket" {
  bucket = "rag-ingestion-bucket-345433"
  force_destroy = true

  tags = {
    Project = "RAG-Pipeline"
  }
}

resource "aws_s3_bucket_notification" "s3_to_sqs" {
  bucket = aws_s3_bucket.ingestion_bucket.id

  queue {
    queue_arn = aws_sqs_queue.ingest_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_sqs_queue_policy.allow_s3_send
  ]
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ingestion_bucket.arn
}
