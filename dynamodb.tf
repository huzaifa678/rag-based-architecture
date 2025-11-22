resource "aws_dynamodb_table" "documents" {
  name         = var.dynamodb_table_name
  billing_mode = var.billing_mode
  hash_key     = "document_id"
  range_key    = "chunk_id"

  attribute {
    name = "document_id"
    type = "S"
  }

  attribute {
    name = "chunk_id"
    type = "S"
  }
}
