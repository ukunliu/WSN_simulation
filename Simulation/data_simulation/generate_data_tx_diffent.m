function meta = generate_simulation_data(coord, n, n_rx, dir)
%Generate dataset (CIR response) based on simulation setup
%locations of transmitters here is not uniformly distributed but randomly

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

grid_x = (lon_s - lon_e) / n;
grid_y = (lat_s - lat_e) / n;


% adding offset to each node
x_offset = rand(n, n) * grid_x;
y_offset = rand(n, n) * grid_y;

[X_rx, Y_rx] = meshgrid( X(1, n/n_rx:n/n_rx * 2:n), Y(n/n_rx: n/n_rx*2 : n, 1));

% Open 3D building model
viewer = siteviewer('Building', dir)

% Elevation for each node
for i = 1:n
    for j = 1:n 
        a(i, j)=1;

        ele_set(i, j) = txsite("Latitude",Y(i, j) + y_offset(i, j),"Longitude", X(i, j) + x_offset(i, j));    
    end
end

ele = elevation(ele_set);
ele_matrix = reshape(ele, n, n);

ele_matrix = zeros(n, n);

% set up transmitters
tx_height = 1.5;
freq = 1e9;
tx_power = 5;
for i = 1:n
    for j = 1:n 
        a(i, j)=1;
        tx_set(i, j) = txsite("Latitude",Y(i, j) + y_offset(i, j),"Longitude", X(i, j)  + x_offset(i, j), ...
            "AntennaHeight", tx_height + ele_matrix(i, j), ...
            "TransmitterFrequency", freq, ...
            "TransmitterPower", tx_power);    
    end
end

% set up receviers
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

% propagation model
pm = propagationModel("raytracing", ...
    "Method","sbr", ...
    "MaxNumReflections",2, ...
    "BuildingsMaterial", 'glass', ...
    "SurfaceMaterial", "concrete");

% pm.MaxRelativePathLoss = 50;

% simulate rays between each tx and rx 
rays = raytrace(tx_set, rx_set, pm);

% collect cir profile from simulation rays
[nt, nr] = size(rays);
for i = 1:nt
    for j = 1:nr
        resp_cell{i, j} = 0;
        sigstrength_cell{i, j} = 0;
        [a, b] = size(rays{i, j});
        if b ~= 0
              tmp = comm.RayTracingChannel(rays{i, j}, tx_set(i), rx_set(j));
              tmp.MinimizePropagationDelay = 0;
%               tmp.ChannelFiltering = 0;
              [delay, gain] = my_feature(tmp);
              resp_cell{i, j} = [double(delay); gain];

              sig = sigstrength(rx_set(j), tx_set(i), pm);
              sigstrength_cell{i, j} = sig;
        end
    end
end

% merge data into meta cell
meta.cir = resp_cell;
meta.tx = [tx_set.Latitude; tx_set.Longitude];
meta.rx = [rx_set.Latitude; rx_set.Longitude];
meta.dist = distance(rx_set, tx_set);
meta.sigstrength = sigstrength_cell;
end