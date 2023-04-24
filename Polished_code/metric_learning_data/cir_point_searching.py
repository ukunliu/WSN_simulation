
import numpy as np
from tools import *
import scipy
import lightgbm as lgb
from sklearn.model_selection import train_test_split, GridSearchCV, cross_validate
from sklearn.multioutput import MultiOutputRegressor
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline


# read data
cirs_obs = np.load('./data/cirs_observation_ld_exact.npy')
TX_ld = np.load('./data/TX_ld.npy')
RX_ld = np.load('./data/RX_ld.npy')
rssi_ld = scipy.io.loadmat('./data/rssi_london.mat')['rssi_london']
rssi_ld = np.nan_to_num(rssi_ld, neginf=1)

cfr = np.load('./data/cfr.npy')
# parameter grids
lgb_grid = {
    'lgb__estimator__n_estimators': [100, 200, 500, 1000, 2000],
    'lgb__estimator__max_depth': [100, 200, 300, 400, 500, 1000]
}


lgb_pipe = GridSearchCV(
                Pipeline([('scale', StandardScaler()), \
                    ('lgb', MultiOutputRegressor(lgb.LGBMRegressor(subsample=1, 
                                                                    colsample_bytree=1, 
                                                                    reg_lambda=0)))]),
                lgb_grid)

lgb_pipe_rssi = GridSearchCV(
                Pipeline([('scale', StandardScaler()), \
                    ('lgb', MultiOutputRegressor(lgb.LGBMRegressor(subsample=1, 
                                                                    colsample_bytree=1, 
                                                                    reg_lambda=0)))]),
                lgb_grid_rssi)


# fitting (no cross validation)
pipes_ld = PipesFitting(cirs_all, TX_ld, RX_ld)
pipes_ld.add_pipes([lgb_pipe], ['LGBM'])
pipes_ld.fit()

pipes_rssi = PipesFitting(rssi_ld, TX_ld, RX_ld)
pipes_rssi.add_pipes([lgb_pipe_rssi], ['LGBM'])
pipes_rssi.fit()

# # cross validate score
# score_cir = cross_val_score(pipes_ld.model_all[0], cirs_all, TX_ld, cv=5, scoring='f1_macro')
# score_rssi = cross_val_score(pipes_ld_rssi.model_all[0], rssi_ld, TX_ld, cv=5, scoring='f1_macro')

# plot cdf and store it
cdf_plot(pipes_ld.dist_all[0], label='trained with cir')
cdf_plot(pipes_rssi.dist_all[0], label='trained with rssi')
plt.legend()
plt.xlabel('distance error(m)')
plt.savefig('cir_vs_rssi.pdf')