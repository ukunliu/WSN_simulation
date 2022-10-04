import math
import numpy as np

def read_mat(location='london'): 
    import scipy.io
    meta_data = scipy.io.loadmat(f'./dataset/{location}_cell.mat')
    cir_profile = meta_data[f'{location}_cell']['cir'][0][0]
    dist = meta_data[f'{location}_cell']['dist'][0][0]

    Y = meta_data[f'{location}_cell'][0][0]['tx'].T # coordination of agents (lat, lon)
    RX = meta_data[f'{location}_cell'][0][0]['rx'].T
    p_a_arr = Y
    p_i_arr = RX
    return meta_data, cir_profile, dist, Y, RX, p_a_arr, p_i_arr

class Extractor(object):
    def __init__(self, cir_profile):
        
        self.cir_profile = cir_profile
        self.ray_len = []
        self.delay_set = []
        self.time_range = []
        self.theta_lst = []
        self.amp_lst = []
        self.sigma_lst = []
        self.var_profile = []

    def clean_input(self):
        T, S = self.cir_profile.shape


        for chs in self.cir_profile:
            self.theta_lst.append([np.abs(ch[0, :]) for ch in chs])
            self.amp_lst.append([ch[1, :] for ch in chs])
            self.sigma_lst.append([1e-7 * np.mean(np.abs(ch[1, :]))**2 / np.abs(ch[1, :])**2 for  ch in chs])
            # var_profile.extend(1e-1 / np.abs(ch[1, :])**2 for  ch in chs)

            for ch in chs:
                self.ray_len.append(len(ch[0,:]))
                self.delay_set.extend(ch[0, :])
                self.time_range.append(max(ch[0, :]))

        max_reflection = max(self.ray_len)
        mag = - math.floor(math.log(np.mean(self.delay_set), 10))
        self.theta_mtx = np.reshape(np.array(self.theta_lst, dtype='object'), newshape=(4,-1)).T
        self.sigma_mtx = np.reshape(np.array(self.sigma_lst, dtype='object'), newshape=(4,-1)).T
        return self.theta_mtx, self.sigma_mtx

    def formatting_X(self):
        T, S = self.cir_profile.shape
        self.max_reflection = max(self.ray_len)
        self.mag = - math.floor(math.log(np.mean(self.delay_set), 10))
        x_pre = []
        for j in range(T):
            cir_t = [] # channel impulse response for a transmitter
            for i in range(S):
                c_tmp = self.cir_profile[j, i].copy()
                c_tmp[0, :] = c_tmp[0, :] * 10 ** self.mag # normalize the delay seconds
                
                m, n = c_tmp.shape
                if m == 2:
                    c_tmp[1, :] = abs(c_tmp[1, :])
                    
                cir_shaped = np.pad(c_tmp, \
                    ((0,2-m), (0, self.max_reflection-n)), \
                        constant_values=0).flatten() # padding 0 to shape of (2, max_len)
                cir_t.append(np.array(cir_shaped, dtype='float'))
                # cir_t.append(np.array(cir_shaped[0: 2], dtype='float'))

            x_pre.append(np.array(cir_t).flatten())

        self.X = np.array(x_pre)

        return self.X