from fastapi import FastAPI
from txtai import Embeddings

app = FastAPI()
embeddings = Embeddings(content=True)

@app.get("/")
async def read_item(search_request, limit):
    embeddings.load("my_search_index")

    ids = [part['ArticleId'] for part in embeddings.search(f"SELECT ArticleId, score FROM txtai WHERE score > 0.84 AND similar('{search_request}') LIMIT {limit}")]

    return {
        "IDs": ids
    }