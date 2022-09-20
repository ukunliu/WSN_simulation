%%

sv = siteviewer("Buildings","D:\Telecom_2eme_anne\Geolocation_simulation\Simulation\london.osm");
% latitude: 51.5108-51.5194; longitude:-0.0988 - -0.0741
lat_s = 51.5108;
lat_e = 51.5194;
lon_s = -0.0988;
lon_e = -0.0741;
n = 20;
n_rx = 4;
n_tx = n - n_rx;

x = linspace(lon_s, lon_e, n);
y = linspace(lat_s, lat_e, n);
[X, Y] = meshgrid(x, y);

[X_rx, Y_rx] = meshgrid( X(1, n/n_rx:n/n_rx * 2:n), Y(n/n_rx: n/n_rx*2 : n, 1));

%% elevation calculation for transmitter
for i = 1:n
    for j = 1:n 
        a(i, j)=1;

        ele_set(i, j) = txsite("Latitude",Y(i, j),"Longitude", X(i, j));    
    end
end

ele = elevation(ele_set);
ele_matrix = reshape(ele, n, n);
%% transmitter coordination
clear tx_set

tx_height = 1.5;
freq = 1e9;
tx_power = 5;
for i = 1:n
    for j = 1:n 
        a(i, j)=1;

        tx_set(i, j) = txsite("Latitude",Y(i, j),"Longitude", X(i, j), ...
            "AntennaHeight", tx_height + ele_matrix(i, j), ...
            "TransmitterFrequency", freq, ...
            "TransmitterPower", tx_power);    
    end
end

%% receiver coordination

for i = 1: n_rx/2
    for j = 1: n_rx/2
        a(i, j) = 1;
        ele_rx(i, j) = rxsite("Latitude",Y_rx(i, j),"Longitude", X_rx(i, j));

    end
end

ele_rx_set = reshape(elevation(ele_rx), n_rx/2, n_rx/2);
for i = 1: n_rx/2
    for j = 1: n_rx/2
        a(i, j) = 1;
        rx_set(i, j) = rxsite("Latitude",Y_rx(i, j),"Longitude", X_rx(i, j), ...
            "AntennaHeight",30 + ele_rx_set(i, j));
        Y_rx(i, j), X_rx(i, j);
    end
end

%%
pm = propagationModel("raytracing", ...
    "Method","sbr", ...
    "MaxNumReflections",3, ...
    "BuildingsMaterial", 'glass', ...
    "SurfaceMaterial", "concrete");

rays = raytrace(tx_set, rx_set, pm);

%% visualization of rays - Testing
% raytrace(tx_set, rx_new)
t = tx_set(7)
r = rx_set(1)

rays = raytrace(t, r)

rc = comm.RayTracingChannel(rays{1}, t, r)
rc.ChannelFiltering = 0
cir = rc()

%%
ray_sample = raytrace(tx_set(1,1), rx_set(1,1))
chan_sample = comm.RayTracingChannel(ray_sample{1}, tx_set(1, 1), rx_set(1, 1))
%%
M = 16;       % Modulation order
numTx = rc.info.NumTransmitElements

x = qammod(randi([0,M-1],1e3,numTx),M);

y = rc(x)

showProfile(rc)
%%
[nt, nr] = size(rays);
for i = 1:nt
    for j = 1:nr
        resp_cell{i, j} = 0;
        [a, b] = size(rays{i, j});
        if b ~= 0
              tmp = comm.RayTracingChannel(rays{i, j}, tx_set(i), rx_set(j));
%               tmp.ChannelFiltering = 0;
              [delay, gain] = my_feature(tmp);
              resp_cell{i, j} = [delay; gain];
        end
    end
end


%% simulation with x and y
raw_input = ones(1,100).'

for i = 1:nt
    for j = 1:nr
        rep_cell{i, j} = 0;
        [a, b] = size(rays{i, j});
        if b ~= 0
              tmp = comm.RayTracingChannel(rays{i, j}, tx_set(i), rx_set(j));
%               tmp.ChannelFiltering = 0;
              rep_cell{i, j} = tmp(raw_input);
        end
    end
end

%% calculate distance between transmitters and base stations
dist = distance(tx_set, rx_set).'


%%
rtchan = comm.RayTracingChannel(rays, tx_set, rx_set);

%%
ray_sample = raytrace(tx_set(1,1), rx_set(1,1))
chan_sample = comm.RayTracingChannel(ray_sample, tx_set(1, 1), rx_set(1, 1))

%%

%%