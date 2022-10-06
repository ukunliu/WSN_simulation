import math
import numpy as np
from geopy.distance import geodesic
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
import seaborn as sns



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

def dist_from_geo(geo1, geo2):
    return np.array([geodesic(i, j).m for i, j in zip(geo1, geo2)])

def plot_agent(Y, ax=None, ind=None, label=None, c=None):
    if not ind:
        ind = np.arange(len(Y))

    if not ax:
        ax = plt

    try:
        ax.scatter(Y[ind, 0], Y[ind, 1], label=label, c=c)
    except:
        ax.scatter(Y[0], Y[1], label=label, c=c)

def compare_pred(y_true, y_pred, ax=None):
    if not ax:
        ax = plt
    plot_agent(y_true, ax=ax, label='Ground truth', c='k')
    plot_agent(y_pred, ax=ax, label='Prediction', c='r')
    ax.plot([y_true[:, 0], y_pred[:, 0]], [y_true[:, 1], y_pred[:, 1]], 'r--')


def outlier_index(data):
    q3, q1 = np.percentile(data, [75, 25])
    high_bar = q3 + 1.5 * (q3 - q1)
    low_bar = q1 - 1.5 * (q3 - q1)
    return (data > high_bar) | (data < low_bar)

class Extractor(object):
    def __init__(self, cir_profile):
        
        self.cir_profile = cir_profile

        self.time_range = []
        self.theta_lst = []
        self.amp_lst = []
        self.sigma_lst = []
        self.var_profile = []

    def clean_input(self):
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

    def formatting_X(self):
        self.ray_len = []
        self.delay_set = []

        T, S = self.cir_profile.shape

        for chs in self.cir_profile:
            for ch in chs:
                self.ray_len.append(len(ch[0,:]))
                self.delay_set.extend(ch[0, :])

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

class PipesFitting(object):
    def __init__(self, X, Y, RX) -> None:
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
    def __init__(self, pipes, location) -> None:
        self.pipes = pipes
        self.location = location

    def boxplot_pipes(self):
        box_plot = sns.boxplot(data=self.pipes.dist_all)
        plt.xticks(np.arange(len(self.pipes.model_ls)), self.pipes.model_ls)
        plt.ylabel('Error on test set (m)')

        for xtick in box_plot.get_xticks():
            box_plot.text(xtick, self.pipes.d_medians[xtick],self.pipes.d_medians[xtick], 
                    horizontalalignment='center',size='x-small',color='w',weight='semibold', c='k')

            box_plot.text(xtick, self.pipes.d_error[xtick],self.pipes.d_error[xtick], 
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

    def outlier_index(self, data):
        q3, q1 = np.percentile(data, [75, 25])
        high_bar = q3 + 1.5 * (q3 - q1)
        low_bar = q1 - 1.5 * (q3 - q1)
        return (data > high_bar) | (data < low_bar)