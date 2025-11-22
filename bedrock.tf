resource "aws_bedrock_inference_profile" "cross_region_profile" {
  name        = var.cross_region_profile_name
  description = "A custom cross-region inference profile for my application"

  model_source {
    copy_from = var.bedrock_text_model_id
  }
}

output "bedrock_inference_profile_arn" {
  value = aws_bedrock_inference_profile.cross_region_profile.arn
}