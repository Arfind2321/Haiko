
from txtai import Embeddings
import sqlite3

'''
# 1. Инициализируем поиск с готовой мультиязычной моделью
embeddings = Embeddings(
    path="intfloat/multilingual-e5-small", content=True
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
print(embeddings.search("SELECT text, ArticleId, id FROM txtai", limit=10000))

parts = embeddings.search("select id, text, PartId from txtai where ArticleId = '1'", limit=10000)
print(parts)
parts_ids = [int(part['id']) for part in parts]
#print(parts_ids)

answer = embeddings.search("grpc", limit=1)

print(embeddings.search(f"select ArticleId from txtai where id = '{answer[0]['id']}'", limit=10000))