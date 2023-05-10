import numpy as np
import pandas as pd

def extract_features(cirs):
        '''
        Extracting manual defined features:
            mean excess delay tau_m
            max excess delay tau_max
            rms delay spread tau_rms
            total received power P
            number of multipath components N
            power of first path P_1
            arrival time of first path tau_1
        '''
        features = []
        T, S = cirs.shape

        for j in range(T):
            cir_t = [] # channel impulse response for a transmitter
            for i in range(S):
                c_tmp = cirs[j, i]
                
                m, n = c_tmp.shape
                if m < 2:
                    tau_m, tau_max, tau_rms, P, N, P_1, tau_1 = 0, 0, 0, 0, 0, 0, 0
                else:
                    tau_m = np.real(c_tmp[0]).mean()
                    tau_max = np.real(c_tmp)[0, -1]
                    P = np.linalg.norm(c_tmp[1])
                    P_1 = np.linalg.norm(c_tmp[1, 0])
                    tau_1 = np.real(c_tmp[0, 0])
                    N = n

                features.append(np.array([tau_m, tau_max, tau_1, P, P_1, N]))

        return np.reshape(np.array(features), (T, -1))


def dist_from_cat(cart1, cart2):
    """
    returns an array of distance from cart1 and cart2
    cart1: an array of cartisen coordinates
    cart2: an array of cartisen coordinates
    """
    return np.array([np.linalg.norm(i-j) for i, j in zip(cart1, cart2)])

def preprocess_cir(cirs, num=400):
    '''Preprocess CIR
    reshape to shape (num_tx, dim_fingerprints)
    Turn complex CIR to real fingperprint database: [Real, Image]
    '''
    cirs = np.reshape(cirs, (num, -1))
    r, i = np.real(cirs), np.imag(cirs)
    return np.concatenate([r, i], axis=1)

def loss(dist_arr):
    '''
    Overall localization loss
    '''
    return np.sum(dist_arr ** 2) / len(dist_arr)

def df_format(dists, col_name=None):
    result = pd.DataFrame()
    result['mean'] = np.mean(dists, axis=1)
    result['median'] = np.median(dists, axis=1)
    result['min'] = np.min(dists, axis=1)
    result['max'] = np.max(dists, axis=1)
    result['var'] = np.var(dists, axis=1)
    result['loss'] = [np.sum(i**2)/len(i) for i in dists]

    col = {}

    if isinstance(col_name, list):
        col_name = col_name #['CIR', 'CIR feature', 'CIR norm', 'CIR noisy', 'CFR norm', 'RSSI', 'kNN']
        for i in range(len(col_name)):
            col[i] = col_name[i]

        result.rename(index=col)
    return result
