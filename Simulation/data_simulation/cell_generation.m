%%
% map coordinations
coord_sahara = [24.2920, 24.3006, 7.0237, 7.0484];

coord_london = [51.5108, 51.519788107578044, -0.0988, -0.08439578091555248];

coord_big_london = [51.4707, 51.5454, -0.0988, 0.0057]; % 8.3km x 7.2km

coord_paris = [48.8296, 48.83859227831143, 2.3132, 2.3268200662724703]; 

coord_toulouse = [43.6048, 43.6138005261109, 1.4393, 1.4516859475885562];

%%
base_dir = '..\maps\';
pr = 'paris.osm';
ld = 'london.osm';
tl = 'toulouse.osm';

ld_dir = strcat(base_dir, ld);
pr_dir =  strcat(base_dir, pr);
tl_dir = strcat(base_dir, tl);

big_ld_dir = 'C:\Users\11740\Desktop\export.osm';

%%
% london_square_20_cell = generate_simulation_data(coord_london, 100, 10, ld_dir); % 20 by 20 grids for tx, 5 by 5 grid for rx
% london_square_50_cell = generate_simulation_data(coord_london, 50, 10);
% london_square_10_cell = generate_simulation_data(coord_london, 10, 10);
% london_square_5_cell = generate_simulation_data(coord_london, 5, 10);
london_square_100_cell = generate_simulation_data(coord_london, 100, 10, ld_dir);

%% Generate data in London but diffent tx locations with same rx and same area (creating observation set)
london_square_20_observation_cell = generate_simulation_data(coord_london, 20, 10, ld_dir);

%%
london_square_big_cell = generate_simulation_data(coord_big_london, 50, 20, big_ld_dir);
%%
paris_square_20_cell = generate_simulation_data(coord_paris, 20, 10, pr_dir);
toulouse_square_20_cell = generate_simulation_data(coord_toulouse, 20, 10, tl_dir);

%%
[m, t, r, rays] = generate_test(coord_london, 20, 20, 10);

%%
rtchan = comm.RayTracingChannel(rays{1},t(1),rx(1));
rtchan.MinimizePropagationDelay = 0;
showProfile(rtchan);

%%
rssi_london = generate_rssi(coord_london, 100, 10, ld_dir);


%% get elevation
ld_tx_ele = get_elevation(coord_london, 20, ld_dir);
%% 
ld_rx_ele = get_elevation(coord_london, 5, ld_dir);