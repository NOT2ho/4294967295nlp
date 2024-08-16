import optuna
import sys
sys.path.append('.')
sys.path.append('..')
sys.path.append('../../')


from RNN.models.train import train

def objective(trial):
    params = {
        "batch_size": trial.suggest_int("batch_size", 20,50),
        "lr": trial.suggest_float("lr", 0.001, 0.5, log=True),
        "hidden_size": trial.suggest_int("hidden_size", 10,100),
        "max_epoch": trial.suggest_int("max_epoch", 2, 50)
    }

    return train(**params)

#batch_size = 10, wordvec_size = 100, hidden_size = 100 , time_size = 5 , lr = 0.0000205, max_epoch = 1, max_grad = 0.1
study = optuna.create_study(direction='minimize')
study.optimize(objective, n_trials=500)
print('Best hyperparameters:', study.best_params)
print('Best ppl:', study.best_value)