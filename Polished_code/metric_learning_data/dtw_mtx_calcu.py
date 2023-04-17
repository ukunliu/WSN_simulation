
import numpy as np
from dtaidistance import dtw
from dtaidistance import dtw_visualisation as dtwvis

total = np.load('./data/total.npy')
n = len(total)

dtw_mtx = np.zeros((n, n))

for i, t1 in enumerate(total):
    for j, t2 in enumerate(total):
        d, _ = dtw.warping_paths(t1, t2, window=25)
        dtw_mtx[i, j] = d

np.save('./data/dtw_mtx', dtw_mtx)