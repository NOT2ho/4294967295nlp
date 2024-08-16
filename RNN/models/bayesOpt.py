import sys
sys.path.append('.')
sys.path.append('..')
sys.path.append('../../')
sys.path.append('../../../')

from bayes_opt import BayesianOptimization
from bayes_opt.logger import JSONLogger
from bayes_opt.event import Events
from RNN.models.train import train

pbounds = {'lr': (1e-6, 3e-6)}
#batch_size = 10, wordvec_size = 400, hidden_size = 400 , time_size = 5 , lr = 0.0000205, max_epoch = 3, max_grad = 0.1
optimizer = BayesianOptimization(
    f=train,
    pbounds=pbounds,
    random_state=1,
)

logger = JSONLogger(path="./logs.log")
optimizer.subscribe(Events.OPTIMIZATION_STEP, logger)

optimizer.maximize(
    init_points=2,
    n_iter=3,
)

