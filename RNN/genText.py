# coding: utf-8
import random
import re
from konlpy.tag import Mecab 
import sys
mecab=Mecab()
sys.path.append('.')
sys.path.append('..')
sys.path.append('../../')
from rnnlmGen import RnnlmGen
from preprocess.preprocess import preprocess

data = open('corpus/4294967295.txt', 'rt', encoding='UTF8').read()
words = ' '.join([w for w, t in Mecab().pos(data)])

corpus, word_to_id, id_to_word = preprocess(words)
vocab_size = len(word_to_id)
corpus_size = len(corpus)


model = RnnlmGen()
model.load_params('trained_4294967295.pkl')

start_word = random.choice([w for w, t in Mecab().pos(data)])
start_id = word_to_id[start_word]
skip_words = ['는']
skip_ids = [word_to_id[w] for w in skip_words]

word_ids = model.generate(start_id, skip_ids)
# txt = ' '.join([id_to_word[i] for i in word_ids])
#txt = txt.replace('', '')
regEx = re.compile('^J|^E|^X|^S')
res = ''
for i in [id_to_word[i] for i in word_ids]:
    tp = mecab.pos(i[0])
    tag = tp[0][1]
    if regEx.match(tag)==None:
        res += ' '+i

    else:
        res += i       

print(res)