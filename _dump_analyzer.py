import numpy as np
import os

start_range = 1
end_range = 100
os.system('mkdir -p dist_histograms_per_steps')
os.system('mkdir -p dist_histograms_average')
lhs_list = []
rhs_list = []
for i in np.arange(start_range, end_range):
    print('handle {}'.format(i))
    _type = 'gru'
    _raw_data = np.load('./raw_data_dump_{}_dir/input_{}.npy'.format(_type, i), allow_pickle=True)
    _flat_data = _raw_data[0].flatten()
    exps = np.log2(np.abs(_flat_data.detach().cpu()))
    hist = np.histogram(exps, bins=109, range=(-100.,9.0))
    newhist = [hist[0], hist[1].astype(int)]
    lhs_list.append(hist[0])
    import pandas
    pandas.DataFrame(newhist).to_csv('./dist_histograms_per_steps/dist_hist_{}_{}.csv'.format(_type, i))
    print('finish {}'.format(i))


avdata = np.sum(lhs_list, axis=0)
outdata = [np.arange(-100, 10), avdata]
pandas.DataFrame(newhist).to_csv('./dist_histograms_average/dist_hist_{}_average.csv'.format(_type))

os.system('tar -cvf dist_hist_per_step.tar dist_histograms_per_steps/')
os.system('tar -cvf dist_hist_average.tar dist_histograms_average/')
os.system('rm -rf dist_histograms_average')
os.system('rm -rf dist_histograms_per_steps')

