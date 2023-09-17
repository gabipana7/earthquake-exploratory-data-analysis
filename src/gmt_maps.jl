using CSV, FileIO, DataFrames, Dates
using GMT


function scatter_2D(df, region, magnitude_threshold; z_control="Magnitude")
    # path for resulting maps
    mkpath("./results/$region/")

    # read data
    df = CSV.read("./data/$region.csv", DataFrame);

    # temporary path to store gmt generation files
    mkpath("./tmp/$region/")
    cd("./tmp/$region/")

    df = df[df.Magnitude .>= magnitude_threshold,:];

    # Get region's coordinates
    min_lon = minimum(df.Longitude)
    max_lon = maximum(df.Longitude)
    min_lat = minimum(df.Latitude)
    max_lat = maximum(df.Latitude);

    # Create the map coordinates
    map_coords = (min_lon,max_lon,min_lat,max_lat)
    
    # Colormap for the region topography
    C_map = makecpt(cmap=:geo, range=(-8000,8000), continuous=true);
    # Relief map of the region
    relief_map = grdcut("@earth_relief_30s", region=map_coords);

    
    # control marker size based on magnitude
    marker_size = [2^x/100 for x in df.Magnitude];

    # control marker color either by Magnitude or by Depth
    C_markers = makecpt(cmap=:seis, range=(minimum(df[!, z_control]),maximum(df[!, z_control])),continuous=true, inverse=true);
    zcolor_control = df[!, z_control]

    basemap(region=map_coords,frame=(axes=:WSne), proj=:merc)

    grdview!(relief_map, proj=:merc, axis=:none, surftype=(image=2000,), 
            cmap=C_map, zsize=1.5, alpha=30)

    plot!(df.Longitude, df.Latitude, 
            markersize=marker_size, marker=:cc, markerline=:faint,
            cmap=C_markers, zcolor=zcolor_control, alpha=60)

    colorbar!(pos=(outside=:MR, offset=(1.0,0)), shade=0.4, xaxis=(annot=:auto,), frame=(xlabel=z_control,),par=(MAP_LABEL_OFFSET=0.8,), 
                savefig="../../gmt/$region/$(region)_2D_mag_$(magnitude_threshold)_$(z_control).pdf")

end


function scatter_semi_3D(df, region, magnitude_threshold; z_control="Magnitude", perspective=(145,40))
    # path for resulting maps
    mkpath("./results/$region/")

    # read data
    df = CSV.read("./data/$region.csv", DataFrame);

    # temporary path to store gmt generation files
    mkpath("./tmp/$region/")
    cd("./tmp/$region/")

    df = df[df.Magnitude .>= magnitude_threshold,:];

    # Get region's coordinates
    min_lon = minimum(df.Longitude)
    max_lon = maximum(df.Longitude)
    min_lat = minimum(df.Latitude)
    max_lat = maximum(df.Latitude);

    # Create the map coordinates
    map_coords = (min_lon,max_lon,min_lat,max_lat)
    
    # Colormap for the region topography
    C_map = makecpt(cmap=:geo, range=(-8000,8000), continuous=true);
    # Relief map of the region
    relief_map = grdcut("@earth_relief_30s", region=map_coords);

    
    # control marker size based on magnitude
    marker_size = [2^x/100 for x in df.Magnitude];

    # control marker color either by Magnitude or by Depth
    C_markers = makecpt(cmap=:seis, range=(minimum(df[!, z_control]),maximum(df[!, z_control])),continuous=true, inverse=true);
    zcolor_control = df[!, z_control]


    basemap(region=map_coords,frame=(axes=:SE), proj=:merc, view=perspective)

    grdview!(relief_map, proj=:merc, axis=:none, surftype=(image=2000,), 
            cmap=C_map, zsize=1.5, alpha=30 , view=perspective)

    plot!(df.Longitude, df.Latitude, 
            markersize=marker_size, marker=:cc, markerline=:faint,
            cmap=C_markers, zcolor=zcolor_control, alpha=60, view=perspective)

    colorbar!(pos=(outside=:MR, offset=(1.6,0)), shade=0.4, xaxis=(annot=:auto,), frame=(xlabel=z_control,),par=(MAP_LABEL_OFFSET=0.8,), 
                view=perspective, savefig="../../gmt/$region/$(region)_semi3D_mag_$(magnitude_threshold)_$(z_control).png")

end

# user input
# print("What's the region ? \n\n") 
# region = readline()

# CLI input
region = ARGS[1]



# create maps
for mag in [0.0, 2.0]
    scatter_2D(df, region, mag; z_control="Magnitude")
    scatter_2D(df, region, mag; z_control="Depth")

    scatter_semi_3D(df, region, mag; z_control="Magnitude")
    scatter_semi_3D(df, region, mag; z_control="Depth")
end

