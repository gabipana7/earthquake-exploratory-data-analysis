include("./src/gmt_maps.jl")


for region in ["Romania", "Italy", "Japan"]
    df = CSV.read("./data/$region.csv", DataFrame);
    for mag in [0.0, 2.0]
        scatter_2D(df, region, mag; z_control="Magnitude")
        scatter_2D(df, region, mag; z_control="Depth")

        scatter_semi_3D(df, region, mag; z_control="Magnitude")
        scatter_semi_3D(df, region, mag; z_control="Depth")
    end
end


region = "Japan"
df = CSV.read("./data/$region.csv", DataFrame);

df = df[(df.Datetime .> DateTime(2010,1,1,0,0,0)),:]

for mag in [0.0, 2.0]
    scatter_2D(df, region, mag; z_control="Magnitude")
    scatter_2D(df, region, mag; z_control="Depth")

    scatter_semi_3D(df, region, mag; z_control="Magnitude")
    scatter_semi_3D(df, region, mag; z_control="Depth")
end