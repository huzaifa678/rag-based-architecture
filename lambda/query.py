import boto3
import json
import os
import math
from decimal import Decimal

bedrock = boto3.client("bedrock-runtime")
dynamodb = boto3.resource("dynamodb").Table(os.getenv("DDB_TABLE"))

def cosine_sim(a, b):
    dot = sum(x * y for x, y in zip(a, b))
    mag_a = math.sqrt(sum(x * x for x in a))
    mag_b = math.sqrt(sum(x * x for x in b))
    return dot / (mag_a * mag_b)

def get_relevant_context(query_embedding, top_k=3):
    """Fetch all documents from DynamoDB and find top_k similar chunks."""
    docs = dynamodb.scan()["Items"]
    scored = []
    for doc in docs:
        emb = [float(x) for x in doc["embedding"]]
        sim = cosine_sim(query_embedding, emb)
        scored.append({"text": doc["text"], "score": sim})
    scored.sort(key=lambda x: x["score"], reverse=True)
    return [d["text"] for d in scored[:top_k]]

def lambda_handler(event, context):
    body = json.loads(event.get("body", "{}"))
    query = body.get("query", "")
    if not query:
        return {"statusCode": 400, "body": json.dumps({"error": "Missing query"})}

    embed_resp = bedrock.invoke_model(
        modelId=os.getenv("BEDROCK_EMBED_MODELID"), 
        contentType="application/json",
        body=json.dumps({"inputText": query})
    )
    query_vec = json.loads(embed_resp["body"].read())["embedding"]

    context_chunks = get_relevant_context(query_vec)
    context_text = "\n\n".join(context_chunks)
    
    if not context_text:
        context_text = "You may answer the question based on your own knowledge."

    prompt = f"""
You are a knowledgeable assistant. Use the following context to answer the user's question.

Context:
{context_text}

Question:
{query}

Answer:
"""

    llm_resp = bedrock.invoke_model(
        modelId=os.getenv("BEDROCK_TEXT_MODELID"), 
        contentType="application/json",
        accept="application/json",
        body=json.dumps({
            "prompt": prompt,
        })
    )

    raw_body = llm_resp["body"].read().decode("utf-8").strip()

    try:
        response_json = json.loads(raw_body)
        answer = response_json.get("generation", raw_body)
    except json.JSONDecodeError:
        answer = raw_body

    return {
        "statusCode": 200,
        "body": json.dumps({
            "answer": answer,
            "used_contexts": context_chunks
        })
    }
