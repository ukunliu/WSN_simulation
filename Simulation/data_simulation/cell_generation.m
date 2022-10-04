%%
% To validate the cell generated
coord_london = [51.5108, 51.5194, -0.0988, -0.0741];
coord_sahara = [24.2920, 24.3006, 7.0237, 7.0484];

coord_london = [51.5108, 51.519788107578044, -0.0988, -0.08439578091555248]

%%
london_square_cell = generate_simulation_data(coord_london, 20, 10);

%%
[m, t, r, rays] = generate_test(coord_london, 20, 20, 10);

%%
rtchan = comm.RayTracingChannel(rays{1},t(1),rx(1));
rtchan.MinimizePropagationDelay = 0;
showProfile(rtchan);