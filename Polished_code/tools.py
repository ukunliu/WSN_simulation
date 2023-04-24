import math
import numpy as np
from geopy.distance import geodesic
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
import seaborn as sns


def distance_tr(TX, RX):
    """
    returns an array of euclidean distances between every node in tx and rx
    TX: an array of tx coordinates
    RX: an array of rx coordinates
    """
    new_dist = []
    for t in TX:
        new_dist.append(np.array([
            geodesic(t, r).m for r in RX
        ]))
    return np.array(new_dist)

def read_mat(dir, location='london'): 
    """
    read data from .mat file
    returns meta data, cir profile, distance between tx and rx, coordination of tx and rx
    dir     : directory of .mat file
    location: the cell key for reaching data in .mat file
    """
    import scipy.io
    meta_data = scipy.io.loadmat(dir)
    cir_profile = meta_data[f'{location}_cell']['cir'][0][0]

    TX = meta_data[f'{location}_cell'][0][0]['tx'].T # coordination of agents (lat, lon)
    RX = meta_data[f'{location}_cell'][0][0]['rx'].T
    return meta_data, cir_profile, distance_tr(TX, RX), TX, RX

def dist_from_geo(geo1, geo2):
    """
    returns an array of distance from geo1 and geo2
    geo1: an array of geo-locations
    geo2: an array of geo-locations
    """
    return np.array([geodesic(i, j).m for i, j in zip(geo1, geo2)])

def plot_agent(Y, ax=plt, ind=None, label=None, c=None):
    """
    plot scatters of nodes
    """
    if not ind:
        ind = np.arange(len(Y))

    try:
        ax.scatter(Y[ind, 0], Y[ind, 1], label=label, c=c)
    except:
        ax.scatter(Y[0], Y[1], label=label, c=c)

def compare_pred(y_true, y_pred, ax=None):
    """
    plot scatters of predicted nodes and groud truth for comparison
    """
    if not ax:
        ax = plt
    plot_agent(y_true, ax=ax, label='Ground truth', c='k')
    plot_agent(y_pred, ax=ax, label='Prediction', c='r')
    ax.plot([y_true[:, 0], y_pred[:, 0]], [y_true[:, 1], y_pred[:, 1]], 'r--')

def cdf_plot(data, ax=plt, label=None, c=None):
    """
    Plot cdf of euclidean distance estimation errors
    """
    n = len(data)
    x = np.arange(n) / (n-1)
    y = np.sort(data)
    # ax.set_xlabel('Distance error (m)')
    # ax.set_y('CDF')
    ax.plot(y, x, '--',label=label, linewidth=2, color=c)


def outlier_index(data):
    """
    Find index of outliers (beyond 1.5 quantiles) in a group of data
    """
    q3, q1 = np.percentile(data, [75, 25])
    high_bar = q3 + 1.5 * (q3 - q1)
    low_bar = q1 - 1.5 * (q3 - q1)
    return (data > high_bar) | (data < low_bar)

class Extractor(object):
    '''
    Class for feature extraction, based on cir profiles
    '''
    def __init__(self, cir_profile, RX=None):
        
        self.cir_profile = cir_profile

        self.time_range = []
        self.theta_lst = []
        self.amp_lst = []
        self.sigma_lst = []
        self.var_profile = []
        self.RX = RX

    def statistical_input(self):
        """
        calculating features for statistical learning
        """
        self.ray_len = []
        self.delay_set = []

        T, S = self.cir_profile.shape

        for chs in self.cir_profile:
            self.theta_lst.append([np.abs(ch[0, :]) for ch in chs])
            self.amp_lst.append([ch[1, :] for ch in chs])
            self.sigma_lst.append([1e-7 * np.mean(np.abs(ch[1, :]))**2 / np.abs(ch[1, :])**2 for  ch in chs])

            for ch in chs:
                self.ray_len.append(len(ch[0,:]))
                self.delay_set.extend(ch[0, :])
                self.time_range.append(max(ch[0, :]))

        self.max_reflection = max(self.ray_len)
        self.mag = - math.floor(math.log(np.mean(self.delay_set), 10))
        self.theta_mtx = np.reshape(np.array(self.theta_lst, dtype='object'), newshape=(S,-1)).T
        self.sigma_mtx = np.reshape(np.array(self.sigma_lst, dtype='object'), newshape=(S,-1)).T
        return self.theta_mtx, self.sigma_mtx

    def _data_statistics(self):
        """
        Calculates stats of cir profile: 
            the length of ray traces
            the time delays
            the max number of ray traces
            the magnitude of time delays
        """
        self.ray_len = []
        self.delay_set = []

        for chs in self.cir_profile:
            for ch in chs:
                self.ray_len.append(len(ch[0,:]))
                self.delay_set.extend(ch[0, :])

        self.max_reflection = max(self.ray_len)
        self.mag = - math.floor(math.log(np.mean(self.delay_set), 10))


    def formatting_X(self, max_len=10):
        '''
        Extract time and magnitude feature
        with reflection of ray-traces within max_len
        consisting padding 0 and flattening process
        '''
        self._data_statistics()
        x_pre = []
        self.T, self.S = self.cir_profile.shape

        for j in range(self.T):
            cir_t = [] # channel impulse response for a transmitter
            for i in range(self.S):
                c_tmp = self.cir_profile[j, i].copy()
                c_tmp[0, :] = c_tmp[0, :] * 10 ** self.mag # normalize the delay seconds
                
                m, n = c_tmp.shape
                if m < 2:
                    cir_shaped = np.zeros(shape=(2, max_len))
                else:
                    if n > max_len:
                        c_tmp[1, :] = abs(c_tmp[1, :])
                        cir_shaped = c_tmp[:, 0:max_len].flatten()

                    else:                    
                        cir_shaped = np.pad(c_tmp, \
                            ((0,2-m), (0, max_len-n)), \
                                constant_values=0).flatten() # padding 0 to shape of (2, max_len)
                # print(cir_shaped.shape, (m,n), cir_shaped)
                cir_t.append(np.array(cir_shaped, dtype='float').flatten())

            x_pre.append(np.array(cir_t).flatten())

        self.X = np.array(x_pre)

        return self.X

    def amplitute_feature(self, max_len=None):
        """
        Extract only amplitute feature from channel impulse response (absolute value)
        Padding 0 to max_len
        """
        self._data_statistics()
        
        if not max_len:
            max_len = self.max_reflection

        x_pre = []
        self.T, self.S = self.cir_profile.shape

        for j in range(self.T):                             # loop over transmitters
            cir_t = []                                      # channel impulse response for each transmitter
            for i in range(self.S):                         # loop over stations
                c_tmp = self.cir_profile[j, i].copy()       # a cir sample from one tx to one rx
                m, n = c_tmp.shape
                if m < 2:
                    c_amp = [0] * max_len
                else:
                    if n > max_len:
                        c_amp = abs(c_tmp[1, 0: max_len])
                    else:
                        c_amp = abs(np.pad(c_tmp[1, :], (0, max_len-n), constant_values=0))                    
                cir_t.extend(c_amp)

            x_pre.append(np.array(cir_t))

        self.X = np.array(x_pre)

        return self.X

    def coord_feature(self):
        # self.amplitute_feature()
        coord = np.repeat(self.RX.flatten()[:, None], self.T, axis=1).T

        return np.concatenate((self.X, coord), axis=1)


class PipesFitting(object):
    '''
    Class for training with multiple pipes
    '''
    def __init__(self, X, Y, RX) -> None:
        '''
        Initialize data, split into train and test
        '''
        self.X, self.Y, self.RX = X, Y, RX

        self.grid_num = int(np.sqrt(self.X.shape[0]))
        self.x_train, self.x_test, self.y_train, self.y_test = train_test_split(self.X, self.Y, train_size=.75)
        self.grid_lat, self.grid_lon = round(geodesic(self.Y[1, :], self.Y[1 + self.grid_num, :]).m, 2), \
            round(geodesic(self.Y[1, :], self.Y[2, :]).m, 2)


    def add_pipes(self, pipes, model_ls):
        self.pipes = pipes
        self.model_ls = model_ls

    def fit(self):
        self.y_test_pred_all = []
        self.y_train_pred_all = []
        self.dist_all = []
        self.model_all = []

        for pipe in self.pipes:
            pipe.fit(self.x_train, self.y_train)
            y_pred = pipe.predict(self.x_test)
            
            self.y_train_pred_all.append(pipe.predict(self.x_train))
            self.y_test_pred_all.append(y_pred)

            self.model_all.append(pipe)

            self.dist_all.append(self.dist_from_geo(self.y_test, y_pred))

        self.d_error = np.mean(self.dist_all, axis=1)
        self.d_medians = np.around(np.median(self.dist_all, axis=1), 2)

    def dist_from_geo(self, geo1, geo2):
        return np.array([geodesic(i, j).m for i, j in zip(geo1, geo2)])

class VisualizeResult():
    '''
    Class for visulation position estimation results of pipes
    '''
    def __init__(self, pipes, location) -> None:
        self.pipes = pipes
        self.location = location

    def boxplot_pipes(self):
        box_plot = sns.boxplot(data=self.pipes.dist_all)
        plt.xticks(np.arange(len(self.pipes.model_ls)), self.pipes.model_ls)
        plt.ylabel('Error on test set (m)')

        for xtick in box_plot.get_xticks():
            # box_plot.text(xtick, self.pipes.d_medians[xtick], round(self.pipes.d_medians[xtick], 2), 
            #         horizontalalignment='center',size='x-small',color='w',weight='semibold', c='k')

            box_plot.text(xtick, self.pipes.d_error[xtick], round(self.pipes.d_error[xtick], 2), 
                    horizontalalignment='center',size='x-small',color='w',weight='semibold', c='k')
        plt.title(f'{self.location}, Grid size {self.pipes.grid_lat, self.pipes.grid_lon}')
        
    def scatter_pipes(self):
        pipes = self.pipes
        n_row = len(pipes.model_ls)
        fig, axs = plt.subplots(n_row, 2, figsize=(n_row * 7, n_row * 5))
        # axs = axs.flatten()
        for ind, model in enumerate(pipes.model_ls):
            # y_tmp = model_all[ind].predict(x_train)
            y_train_pred = pipes.y_train_pred_all[ind]
            compare_pred(pipes.y_train, y_train_pred, axs[ind, 0])
            axs[ind, 0].set_title(f'{model}')
            axs[ind, 0].legend(ncol=2, bbox_to_anchor=(.75, -.15))


            y_test_pred = pipes.y_test_pred_all[ind]
            compare_pred(pipes.y_test, y_test_pred, axs[ind, 1])
            axs[ind, 1].set_title(f'Localization for {self.location}, Grid size {pipes.grid_lat, pipes.grid_lon}')
            plot_agent(pipes.RX, axs[ind, 1], label='Anchor')
            axs[ind, 1].legend(ncol=2, bbox_to_anchor=(.75, -.15))

    def scatter_pipe(self, ind):
        pipes = self.pipes
        y_train_pred = pipes.y_train_pred_all[ind]           
        y_test_pred = pipes.y_test_pred_all[ind]

        compare_pred(pipes.y_train, y_train_pred)
        plt.title(f'{pipes.model_ls[ind]}')
        plt.legend(ncol=2, bbox_to_anchor=(.75, -.15))
        
        plt.figure()
        compare_pred(pipes.y_test, y_test_pred)
        plt.title(f'Localization for {self.location}, Grid size {pipes.grid_lat, pipes.grid_lon}')
        plt.legend(ncol=2, bbox_to_anchor=(.75, -.15))

    def scatter_outliers(self):
        pipes = self.pipes
        for ind, model in enumerate(pipes.model_ls):
            ol = pipes.y_test[self.outlier_index(pipes.dist_all[ind])]
            plt.figure()
            plot_agent(ol)
            plot_agent(pipes.RX)
            plt.title(f'Outliers in {model}')

    def cdf_plot(self, ax=plt):
        pipes = self.pipes
        model_ls = pipes.model_ls

        x = np.arange(len(pipes.dist_all[0])) / (len(pipes.dist_all[0]) - 1)

        for ind, model in enumerate(pipes.model_ls):
            score = np.sort(pipes.dist_all[ind])
            ax.plot(score, x, '--', label=f'{model}')

        ax.ylabel('CDF')
        ax.xlabel('Euclidean Distance error (m)')
        ax.legend(loc='best')

    def outlier_index(self, data):
        q3, q1 = np.percentile(data, [75, 25])
        high_bar = q3 + 1.5 * (q3 - q1)
        low_bar = q1 - 1.5 * (q3 - q1)
        return (data > high_bar) | (data < low_bar)


def sinc_filter(cirs, t, W, snr=20):
    '''Adding sinc filtering to cirs'''
    T, S = cirs.shape
    cir_full_noise = []
    # cir_pure = []
    cir_sinc = []
    x_pre = []
    for j in range(T):
        cir_t = [] # channel impulse response for a transmitter
        for i in range(S):
            status, _ = cirs[j, i].shape
            if status == 1: # if no cir observed
                x_n = np.zeros_like(t)
                y = x_n
                # nan_idx.append([j, i]) # index of no-signal tx
            else:
                tau, amp = cirs[j, i].copy()
                tau_noise = np.random.normal(np.real(tau), .05 * np.real(tau))
                ans = np.repeat(t[:, None], len(tau), axis=1) - tau_noise
                y = np.sinc(W * ans) @ amp
                # c_tmp_noise = noise_gen(y, snr)
                n = len(y)
                noise = np.random.randn(n, 2).view(np.complex128)
                signal_power = np.sum(y * y) / n
                signal_db = 10 * np.log10(signal_power)
                noise_power = np.sum(noise * noise) / n
                noise_var = signal_power / (10 ** (snr/10))
                # noise_var = 10 ** ((signal_db - snr) / 10)
                # # print(noise_var)
                noise_gaussian = np.sqrt(noise_var / noise_power) * noise
                # noise_gaussian = np.random.normal(0, np.sqrt(noise_var), n).view(np.complex128)
                x_n = y + np.squeeze(noise_gaussian)

            cir_full_noise.append(x_n)
            cir_sinc.append(y)
            # cir_pure.append(cirs[j, i])

    return cir_full_noise, cir_sinc


def optimal_search(RX, dist_pred):
    """find x through distance and rx coordinates"""
    from scipy.optimize import minimize, Bounds

    def dist2coord(x, coords, dists):

        d = np.array([geodesic(x, coord).m for coord in coords])

        return np.linalg.norm([d-dists])**2

    x_pred = []

    bounds = Bounds([0, -90], [90, 90])

    for p in dist_pred:
        res = minimize(
        dist2coord,
        RX[0],
        args=(RX, p),
        method='L-BFGS-B',
        options={
            'ftol':1e-5,         # Tolerance
            'maxiter': 1e+7      # Maximum iterations
        },
        bounds=bounds
    )   

        x_pred.append(res.x)

    return np.array(x_pred)