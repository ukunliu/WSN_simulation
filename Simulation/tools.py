def read_mat(location='london'): 
    import scipy.io
    meta_data = scipy.io.loadmat(f'{location}_cell.mat')
    cir_profile = meta_data[f'{location}_cell']['cir'][0][0]
    dist = meta_data[f'{location}_cell']['dist'][0][0]

    Y = meta_data[f'{location}_cell'][0][0]['tx'].T # coordination of agents (lat, lon)
    RX = meta_data[f'{location}_cell'][0][0]['rx'].T
    p_a_arr = Y
    p_i_arr = RX
    return meta_data, cir_profile, dist, Y, RX, p_a_arr, p_i_arr