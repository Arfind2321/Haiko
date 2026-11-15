import difflib
from gensim.models import Word2Vec, KeyedVectors
import pymorphy3

def filter(word_vectors):
    morph = pymorphy3.MorphAnalyzer()

    # Указываем теги: NOUN (существительное), ADJF (полное прил.), ADJS (краткое прил.)
    target_pos = {'NOUN', 'ADJF', 'ADJS'}

    filtered_words = []
    for word in word_vectors.index_to_key:
        # Берем наиболее вероятный разбор слова (индекс 0)
        parsed = morph.parse(word)[0]
        
        if parsed.tag.POS in target_pos:
            filtered_words.append(word)

    filtered_vectors = [word_vectors[word] for word in filtered_words]

    # Создаем новый словарь KeyedVectors
    filtered_wv = KeyedVectors(vector_size=word_vectors.vector_size)
    filtered_wv.add_vectors(filtered_words, filtered_vectors)
    return filtered_wv


class Searcher:
    def __init__(self, word_vectors):
        self.word_vectors = word_vectors
        self.words = word_vectors.index_to_key

    def search_simmilar(self, target):
        self.result = difflib.get_close_matches(target, self.words, n=1, cutoff=0.6)

        if self.result != []:
            return self.word_vectors.most_similar(self.result, topn=2)


if __name__ == "__main__":
    word_vectors = Word2Vec.load('taiga_word2vec.model').wv
    dict_wv = filter(word_vectors)

    searcher = Searcher(dict_wv)
    print(searcher.search_simmilar(target="програмирование"))