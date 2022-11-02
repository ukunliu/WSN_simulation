%%
coord = [51.5108, 51.519788107578044, -0.0988, -0.08439578091555248];

lat_s = coord(1);
lat_e = coord(2);
lon_s = coord(3);
lon_e = coord(4);

%%

tx = txsite("Latitude",lat_s,"Longitude", lon_s);

rx = rxsite("Latitude", lat_s * 1.00001, "Longitude", lon_s * 1.00002);

pm = propagationModel("raytracing", ...
    "Method","sbr", ...
    "MaxNumReflections",3, ...
    "BuildingsMaterial", 'glass', ...
    "SurfaceMaterial", "concrete");

rays = raytrace(tx, rx, pm);

trace = comm.RayTracingChannel(rays{1}, tx, rx);
trace.MinimizePropagationDelay = 0;

%%


