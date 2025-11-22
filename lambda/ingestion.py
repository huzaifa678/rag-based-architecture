import io
import boto3, os, json, csv
from PyPDF2 import PdfReader
from decimal import Decimal

bedrock = boto3.client("bedrock-runtime", region_name="us-east-1")
dynamodb = boto3.resource("dynamodb").Table(os.getenv("DDB_TABLE"))
s3 = boto3.client("s3")

def lambda_handler(event, context):
    for record in event["Records"]:
        body = json.loads(record["body"])
        
        if "Records" not in body or "s3" not in body["Records"][0]:
            print("Skipping non-S3 message:", body)
            continue
        
        s3_record = body["Records"][0]["s3"]
        bucket = s3_record["bucket"]["name"]
        key = s3_record["object"]["key"]
        obj = s3.get_object(Bucket=bucket, Key=key)
        content = obj["Body"].read()

        if key.endswith(".pdf"):
            reader = PdfReader(io.BytesIO(content))
            text = " ".join([p.extract_text() for p in reader.pages])
        elif key.endswith(".csv"):
            text = content.decode("utf-8")
        else:
            continue

        chunks = [text[i:i+500] for i in range(0, len(text), 500)]
        for idx, chunk in enumerate(chunks):
            resp = bedrock.invoke_model(
                modelId=os.getenv("BEDROCK_EMBED_MODELID"),
                contentType="application/json",
                body=json.dumps({"inputText": chunk}),
            )
            embedding = json.loads(resp["body"].read())["embedding"]
            dynamodb.put_item(Item={
                "document_id": key,
                "chunk_id": str(idx),
                "text": chunk,
                "embedding": [Decimal(str(x)) for x in embedding]
            })
