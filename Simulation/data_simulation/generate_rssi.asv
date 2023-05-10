function rssi = generate_rssi(coord, n, n_rx, dir)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
lat_s = coord(1);
lat_e = coord(2);
lon_s = coord(3);
lon_e = coord(4);
% n = 20;
% n_rx = 4;
% n_tx = n - n_rx;

x = linspace(lon_s, lon_e, n);
y = linspace(lat_s, lat_e, n);
[X, Y] = meshgrid(x, y);

[X_rx, Y_rx] = meshgrid( X(1, n/n_rx:n/n_rx * 2:n), Y(n/n_rx: n/n_rx*2 : n, 1));

viewer = siteviewer('Building', dir);
% elevation calculation for transmitter

for i = 1:n
    for j = 1:n 
        a(i, j)=1;

        ele_set(i, j) = txsite("Latitude",Y(i, j),"Longitude", X(i, j));    
    end
end

ele = elevation(ele_set);
ele_matrix = reshape(ele, n, n);

% transmitter coordination

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

% receiver coordination

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

%
pm = propagationModel("raytracing", ...
    "Method","sbr", ...
    "MaxNumReflections",2, ...
    "BuildingsMaterial", 'glass', ...
    "SurfaceMaterial", "concrete");

% rays = raytrace(tx_set, rx_set, pm);
% 
% %
% [nt, nr] = size(rays);
nt = n * n;
nr = n_rx ^2 / 4;
rssi = zeros(nt, nr);

for i = 1:nt
    i
    for j = 1:nr
        rssi(i, j) = sigstrength(rx_set(j), tx_set(i), pm);
        
    end
end

end