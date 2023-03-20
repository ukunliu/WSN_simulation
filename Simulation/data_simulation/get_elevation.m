function ele_matrix = get_elevation(coord, n, dir)
%Generate dataset (CIR response) based on simulation setup

lat_s = coord(1);
lat_e = coord(2);
lon_s = coord(3);
lon_e = coord(4);
% n = 20;
% n_rx = 4;
% n_tx = n - n_rx;

% Creat 2D mesh within map
x = linspace(lon_s, lon_e, n);
y = linspace(lat_s, lat_e, n);
[X, Y] = meshgrid(x, y);

% [X_rx, Y_rx] = meshgrid( X(1, n/n_rx:n/n_rx * 2:n), Y(n/n_rx: n/n_rx*2 : n, 1));

% Open 3D building model
viewer = siteviewer('Building', dir)

% Elevation for each node
for i = 1:n
    for j = 1:n 
        a(i, j)=1;

        ele_set(i, j) = txsite("Latitude",Y(i, j),"Longitude", X(i, j));    
    end
end

ele = elevation(ele_set);
ele_matrix = reshape(ele, n, n);

%%%%%%%%%%%%%%%%
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
show(tx_set)