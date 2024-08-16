import bisect
import itertools
import random
import re

import nltk
from konlpy.tag import Mecab 
mecab=Mecab()

def generate_sentence(cfdist, word):
    sentence = []

    while word!='.':
        sentence.append(word)

        choices, weights = zip(*cfdist[word].items())
        cumdist = list(itertools.accumulate(weights))
        x = random.random() * cumdist[-1]
        word = choices[bisect.bisect(cumdist, x)]

    regEx = re.compile('^J|^E|^X|^S')
    res = ''
    for i in sentence:
        tp = mecab.pos(i[0])
        tag = tp[0][1]
        if regEx.match(tag)==None:
            res += ' '+i

        else:
            res += i       

    return res


def calc_cfd(doc):
    words = [w for w, t in Mecab().pos(doc)]
    ngrams = nltk.ngrams(words, n=2)
    #condition_pairs = (((w0, w1), w2) for w0, w1, w2 in ngrams)
    return nltk.ConditionalFreqDist(ngrams)

doc = open('corpus/4294967295.txt', 'rt', encoding='UTF8').read()

if __name__=='__main__':
    initstr = random.choice([w for w, t in Mecab().pos(doc)])
    cfd = calc_cfd(doc)

    print(generate_sentence(cfd, initstr))