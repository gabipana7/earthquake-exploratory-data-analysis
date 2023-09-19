include("./src/gmt_map.jl")


# region = "Romania"
# df = CSV.read("./data/$region.csv", DataFrame);
# mag = 2.0
# scatter_2D(df, region, mag; z_control="Magnitude")

for region in ["California"]
    df = CSV.read("./data/$region.csv", DataFrame);
    for mag in [0.0, 2.0]
        for z_control in ["Magnitude", "Depth"]
            scatter_2D(df, region, mag; z_control, format="png")
            scatter_semi_3D(df, region, mag; z_control, perspective=(145,40), format="png")
        end
    end
end


region = "Japan"
df = CSV.read("./data/$region.csv", DataFrame);

df = df[(df.Datetime .> DateTime(2010,1,1,0,0,0)),:]

for mag in [0.0, 2.0]
    for z_control in ["Magnitude", "Depth"]
        scatter_2D(df, region, mag; z_control, format="png")
        scatter_semi_3D(df, region, mag; z_control, perspective=(145,40), format="png")
    end
end