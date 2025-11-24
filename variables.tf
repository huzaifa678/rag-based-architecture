variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "rag_documents"
}

variable "api_gateway_name" {
    description = "Name of the API Gateway"
    type        = string
    default     = "rag-query-api"
}

variable "integration_type" {
    description = "Type of API Gateway integration"
    type        = string
    default     = "AWS_PROXY"
}

variable "bucket_name" {
    description = "Name of the S3 bucket for ingestion"
    type        = string
    default     = "rag-ingestion-bucket-345433"
}

variable "function_name_ingestion" {
    description = "Name of the ingestion Lambda function"
    type        = string
    default     = "rag-ingest-lambda"
}

variable "function_name_query" {
  description = "name of the query Lambda function"
  type        = string
  default     = "rag-query-lambda"
} 

variable "bedrock_embed_model_id" {
    description = "Bedrock model ID for embeddings"
    type        = string
    default     = "amazon.titan-embed-text-v2:0"
}

variable "bedrock_text_model_id" {
    description = "Bedrock model ID for text generation"
    type        = string
}

variable "cross_region_profile_name" {
    description = "Name of the Bedrock cross-region inference profile"
    type        = string
    default     = "cross-region-profile-llama3"
}

variable "sqs_queue_name" {
    description = "Name of the SQS queue for ingestion"
    type        = string
    default     = "rag-ingest-queue"
}

variable "sqs_dlq_name" {
    description = "Name of the SQS dead-letter queue for ingestion"
    type        = string
    default     = "rag-ingest-dlq"
}