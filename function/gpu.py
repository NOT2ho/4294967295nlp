import sys
sys.path.append('C:\4294967295nlp\.venv\Lib\site-packages')

def to_cpu(x):
    import numpy as np
    if type(x) == np.ndarray:
        return x
    return np.asnumpy(x)


def to_gpu(x):
    import cupy
    if type(x) == cupy.ndarray:
        print(x)
        return x
    return cupy.asarray(x)