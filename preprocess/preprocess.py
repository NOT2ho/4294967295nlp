import numpy as np

def preprocess(t):
    t = t.replace('.', ' .')
    ws = t.split(' ')
    word_to_id = {}
    id_to_word= {}
    for w in ws:
        if w not in word_to_id:
            new_id = len(word_to_id)
            word_to_id[w] = new_id
            id_to_word[new_id] = w

    corpus = np.array([word_to_id[w] for w in ws])

    return corpus, word_to_id, id_to_word