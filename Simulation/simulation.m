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

%% transmitter coordination
clear tx_set
for i = 1:n
    for j = 1:n 
        a(i, j)=1;

        tx_set(i, j) = txsite("Latitude",Y(i, j),"Longitude", X(i, j), ...
            "AntennaHeight",1.5, ...
            "TransmitterFrequency", 1e9);    
    end
end

%% receiver coordination

for i = 1: n_rx/2
    for j = 1: n_rx/2
        a(i, j) = 1;
        rx_set(i, j) = rxsite("Latitude",Y_rx(i, j),"Longitude", X_rx(i, j), "AntennaHeight",30);
        Y_rx(i, j), X_rx(i, j)
    end
end



%%
[nt, nr] = size(rays)
for i = 1:nt
    for j = 1:nr
        ch_cell{i, j} = 0;
        [a, b] = size(rays{i, j});
        if b ~= 0
              tmp = comm.RayTracingChannel(rays{i, j}, tx_set(i), rx_set(j));
              tmp.ChannelFiltering = 0;
              ch_cell{i, j} = tmp();
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
