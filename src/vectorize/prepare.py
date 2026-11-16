import re
from datasets import load_dataset
from tqdm import tqdm

def prepare_corpus(output_file="clean_taiga.txt", limit=None):
    dataset = load_dataset("cointegrated/taiga_stripped_rest", split="Lenta", streaming=True)
    
    if limit:
        dataset = dataset.take(limit)

    with open(output_file, "w", encoding="utf-8") as f:
        # tqdm покажет прогресс обработки документов в реальном времени
        for sample in tqdm(dataset, desc="Подготовка текстов"):
            sentences = re.split(r'[.!?]+', sample["text"])
            for sentence in sentences:
                tokens = re.findall(r'[а-яё]+', sentence.lower())
                if len(tokens) > 2:
                    # Записываем токены через пробел (требование corpus_file)
                    f.write(" ".join(tokens) + "\n")

if __name__ == "__main__":
    # Укажите limit=None для скачивания всего датасета целиком (займет около 3-5 ГБ на диске)
    prepare_corpus(output_file="clean_taiga.txt", limit=50000)
