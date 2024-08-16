# coding: utf-8
import sys
sys.path.append('.')
sys.path.append('..')
sys.path.append('../../')
from trainer import RnnlmTrainer
from function.eval_perplexity import eval_perplexity
from rnnlm import Rnnlm
from function.optimizer import *
from preprocess.preprocess import preprocess
from konlpy.tag import Mecab 


# 하이퍼파라미터 설정
batch_size = 10
wordvec_size = 400
hidden_size = 400  # RNN의 은닉 상태 벡터의 원소 수
time_size = 5  # RNN을 펼치는 크기
lr = 0.00002
max_epoch = 2
max_grad = 0.1



# 학습 데이터 읽기

data = open('corpus/pure_4294967295.txt', 'rt', encoding='UTF8').read()
words = ' '.join([w for w, t in Mecab().pos(data)])

corpus, word_to_id, id_to_word = preprocess(words)
#corpus_test, _, _ = 
vocab_size = len(word_to_id)

xs = corpus[:-1]
ts = corpus[1:]

# 모델 생성
model = Rnnlm(vocab_size, wordvec_size, hidden_size)
optimizer = Adam(lr)
trainer = RnnlmTrainer(model, optimizer)

# 기울기 클리핑을 적용하여 학습
trainer.fit(xs, ts, max_epoch, batch_size, time_size, max_grad,
            eval_interval=20)
trainer.plot(ylim=(0, 200000))

# 테스트 데이터로 평가
'''model.reset_state()
ppl_test = eval_perplexity(model, corpus_test)
print('테스트 퍼플렉서티: ', ppl_test)
'''
# 매개변수 저장
model.save_params()