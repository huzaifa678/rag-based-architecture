data "archive_file" "ingest_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/ingestion.py"
  output_path = "${path.module}/build/ingest.zip"
}

data "archive_file" "query_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/query.py"
  output_path = "${path.module}/build/query.zip"
}

data "archive_file" "python_lib_zip" {
  type        = "zip"
  source_dir = "${path.module}/python_layer"
  output_path = "${path.module}/build/python_lib.zip"
}

resource "aws_lambda_layer_version" "python_dependencies" {
  layer_name          = "python-dependencies"
  filename            = data.archive_file.python_lib_zip.output_path
  compatible_runtimes = ["python3.11"]
  description         = "Python dependencies for query Lambda"
}

resource "aws_lambda_function" "ingest_lambda" {
  function_name = var.function_name_ingestion
  filename      = data.archive_file.ingest_zip.output_path
  handler       = "ingestion.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 60
  memory_size   = 1024

  environment {
    variables = {
      DDB_TABLE       = aws_dynamodb_table.documents.name
      BEDROCK_EMBED_MODELID = var.bedrock_embed_model_id
      BUCKET_NAME     = aws_s3_bucket.ingestion_bucket.bucket
    }
  }

  layers = [
    aws_lambda_layer_version.python_dependencies.arn
  ]
}

resource "aws_lambda_event_source_mapping" "sqs_ingest" {
  event_source_arn  = aws_sqs_queue.ingest_queue.arn
  function_name     = aws_lambda_function.ingest_lambda.arn
  batch_size        = 1  
  enabled           = true
}


resource "aws_lambda_function" "query_lambda" {
  function_name = var.function_name_query
  filename      = data.archive_file.query_zip.output_path
  handler       = "query.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      DDB_TABLE       = aws_dynamodb_table.documents.name
      BEDROCK_EMBED_MODELID = var.bedrock_embed_model_id
      BEDROCK_TEXT_MODELID   = aws_bedrock_inference_profile.cross_region_profile.arn
    }
  }

  layers = [
    aws_lambda_layer_version.python_dependencies.arn
  ]
}

