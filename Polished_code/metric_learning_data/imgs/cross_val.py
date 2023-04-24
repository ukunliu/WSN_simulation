
import numpy as np
from tools import *
import scipy
import lightgbm as lgb
from sklearn.model_selection import train_test_split, GridSearchCV, cross_validate, cross_val_score
from sklearn.multioutput import MultiOutputRegressor
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
import joblib

# read data
cirs_obs = np.load('./data/cirs_observation_ld_exact.npy')
TX_ld = np.load('./data/TX_ld.npy')
RX_ld = np.load('./data/RX_ld.npy')
rssi_ld = scipy.io.loadmat('./data/rssi_london.mat')['rssi_london']
rssi_ld = np.nan_to_num(rssi_ld, neginf=1)

cirs_all = np.concatenate([np.real(cirs_obs), np.imag(cirs_obs)], axis=1)

# cirs_train, cirs_val, rssi_train, rssi_val, y_train, y_val = train_test_split(cirs_all, rssi_ld, TX_ld)

lgb_pipe = Pipeline([('scale', StandardScaler()), \
                    ('lgb', MultiOutputRegressor(lgb.LGBMRegressor(subsample=1, 
                                                                    colsample_bytree=1, 
                                                                    reg_lambda=0,
                                                                    n_estimators=500,
                                                                    max_depth=2000)))])

lgb_pipe_rssi = Pipeline([('scale', StandardScaler()), \
                    ('lgb', MultiOutputRegressor(lgb.LGBMRegressor(subsample=1, 
                                                                    colsample_bytree=1, 
                                                                    reg_lambda=0,
                                                                    n_estimators=500,
                                                                    max_depth=2000)))])

# fitting (no cross validation)
pipes_ld = PipesFitting(cirs_all, TX_ld, RX_ld)
pipes_ld.add_pipes([lgb_pipe], ['LGBM'])
pipes_ld.fit()

pipes_rssi = PipesFitting(rssi_ld, TX_ld, RX_ld)
pipes_rssi.add_pipes([lgb_pipe_rssi], ['LGBM'])
pipes_rssi.fit()

# save model (PipeFitting class)
joblib.dump(pipes_ld, 'data/model_lgbm_cir.joblib')
joblib.dump(pipes_rssi, 'data/model_lgbm_rssi.joblib')


# cross validate score
score_cir = cross_val_score(pipes_ld.model_all[0], cirs_all, TX_ld, cv=5, scoring='neg_mean_squared_error', n_jobs=-1)
score_rssi = cross_val_score(pipes_rssi.model_all[0], rssi_ld, TX_ld, cv=5, scoring='neg_mean_squared_error', n_jobs=-1)
print(score_cir, score_rssi)
np.save('score_cir.npy', score_cir)
np.save('score_rssi.npy', score_rssi)

# plot cdf and store it
# cdf_plot(pipes_ld.dist_all[0], label='trained with cir')
# cdf_plot(pipes_rssi.dist_all[0], label='trained with rssi')
# plt.legend()
# plt.xlabel('distance error(m)')
# plt.savefig('data/cir_vs_rssi_3.pdf')
