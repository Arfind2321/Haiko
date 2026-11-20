
from txtai import Embeddings
import sqlite3
import os

os.environ["HF_HUB_OFFLINE"] = "1"

# 1. Инициализируем поиск с готовой мультиязычной моделью
embeddings = Embeddings(
    path="./multilingual-e5-small",
    content=True,  # Обязательно для корректной работы upsert и обновлений
    instructions={"query": "query: ", "data": "passage: "}
)


docs = [
    {"text": "Текст первого документа", "ArticleId": '1'},
    {"text": "Текст второго документа", "ArticleId": '1'},
]

# 3. Индексируем и сохраняем в локальную папку
embeddings.index(docs)
embeddings.save("my_search_index")

# 4. Ищем по смыслу (даже без совпадения слов)
results = embeddings.search("надо лечится", limit=2)
print(results)


'''
embeddings = Embeddings()
embeddings.load("my_search_index")
embeddings.save("my_search_index")
#print(embeddings.search("SELECT text, ArticleId, id FROM txtai", limit=10000))

parts = embeddings.search("select id, text, PartId from txtai where ArticleId = '6'", limit=10000)
print(parts)
parts_ids = [int(part['id']) for part in parts]
#print(parts_ids)

answer = embeddings.search("assembler", limit=1)
print(answer)
#print(embeddings.search(f"select ArticleId from txtai where id = '{answer[0]['id']}'", limit=10000))
'''