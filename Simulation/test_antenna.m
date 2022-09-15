tx = txsite("Latitude",42.3001,"Longitude",-71.3504);
rx = rxsite("Latitude",42.3021,"Longitude",-71.3764);

show(tx)
show(rx)

%% distance and angles
dm = distance(tx,rx)
[az,el] = angle(tx,rx)

%%
ss = sigstrength(rx,tx)
margin = abs(rx.ReceiverSensitivity - ss)
link(rx,tx)
coverage(tx,"SignalStrengths",-100:5:-60) 
%%
sinr([tx,rx])

%% 

dire = 'D:\Telecom_2eme_anne\Geolocation_simulation\src\simulation\simulation géoloc\data_sim_NY.xlsx'
a = xlsread(dire);
crd = a(:, 4:5);

%%
% tx_set = zeros(50)
for i = 1:50
    tx_set(i) = txsite("Latitude",crd(i, 2),"Longitude",crd(i, 1), "AntennaHeight",1.5, "TransmitterFrequency", 1e9);    
end
  
%%

rx_new = rxsite("Latitude",crd(1, 2),"Longitude",crd(1, 1), "AntennaHeight",20)

pm = propagationModel('raytracing', ...
    'Method','sbr', ...
    'MaxNumReflections',3);

%%
rays = raytrace(tx_set, rx_new, pm);

%%
rtchan = comm.RayTracingChannel(rays{1},tx_set(1),rx_new)



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

[X_rx, Y_rx] = meshgrid( X(n/n_rx:n/n_rx * 2:end), Y(n/n_rx: n/n_rx*2 : end));
%%
clear tx_set
for i = 1:n
    for j = 1:n 
        a(i, j)=1;
        tx_set(i, j) = txsite("Latitude",Y(i, j),"Longitude", X(i, j), "AntennaHeight",1.5, "TransmitterFrequency", 1e9);    
    end
end

%%
for i = 1: n_rx/2
    for j = 1: n_rx/2
        rx_set(i, j) = rxsite("Latitude",Y_rx(i, j),"Longitude", X_rx(i, j), "AntennaHeight",30);
    end
end

%%
