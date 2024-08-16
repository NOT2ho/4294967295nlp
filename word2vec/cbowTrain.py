# coding: utf-8
import sys
from konlpy.tag import Mecab 
sys.path.append('.')
sys.path.append('..')
sys.path.append('../../')
import numpy as np
from config import config
from preprocess.preprocess import preprocess

# GPU에서 실행하려면 아래 주석을 해제하세요(CuPy 필요).
# ===============================================
# config.GPU = True
# ===============================================
import pickle
from trainer import Trainer
from function.optimizer import Adam
from cbow import CBOW
from word2vec.skip_gram import SkipGram
from function.gpu import to_cpu, to_gpu
from function.create_contexts_target import create_contexts_target


# 하이퍼파라미터 설정
window_size = 5
hidden_size = 100
batch_size = 100
max_epoch = 10

# 데이터 읽기
data = open('corpus/4294967295.txt', 'rt', encoding='UTF8').read()
words = ' '.join([w for w, t in Mecab().pos(data)])

corpus, word_to_id, id_to_word = preprocess(words)
vocab_size = len(word_to_id)

contexts, target = create_contexts_target(corpus, window_size)
if config.GPU:
    contexts, target = to_gpu(contexts), to_gpu(target)

# 모델 등 생성
model = CBOW(vocab_size, hidden_size, window_size, corpus)
# model = SkipGram(vocab_size, hidden_size, window_size, corpus)
optimizer = Adam()
trainer = Trainer(model, optimizer)

# 학습 시작
trainer.fit(contexts, target, max_epoch, batch_size)
trainer.plot()

# 나중에 사용할 수 있도록 필요한 데이터 저장
word_vecs = model.word_vecs
if config.GPU:
    word_vecs = to_cpu(word_vecs)
params = {}
params['word_vecs'] = word_vecs.astype(np.float16)
params['word_to_id'] = word_to_id
params['id_to_word'] = id_to_word
pkl_file = 'cbow_params.pkl'  # or 'skipgram_params.pkl'
with open(pkl_file, 'wb') as f:
    pickle.dump(params, f, -1)