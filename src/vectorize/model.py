import os
from gensim.models import Word2Vec

# Определяем количество ядер вашего процессора (на MacBook обычно 8-12)
num_workers = os.cpu_count() or 4

model = Word2Vec(
    corpus_file="clean_taiga.txt",  # Читаем напрямую с диска в многопоточном режиме
    vector_size=300,
    window=5,
    min_count=5,
    workers=num_workers,
    sg=1,
    epochs=5  # Теперь можно безопасно поставить 5 эпох, это пройдет очень быстро
)

model.save("taiga_word2vec.model")

# Проверка качества эмбеддингов
print(model.wv.most_similar("python", topn=5))
