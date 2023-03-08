### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ b0224563-5d2a-4e46-9cf3-509a6c86a266
begin
	using Pkg
	Pkg.activate("Project.toml")
	Pkg.status()
end

# ╔═╡ a41ce9cd-915d-4ed8-b999-bc4603582be3
using CSV, FileIO, DataFrames, Dates

# ╔═╡ 41de3455-6039-4114-b98a-19266bf81a10
using Plots, StatsPlots, GLMakie, CairoMakie

# ╔═╡ 67559f09-e337-4fbb-b8f3-3b412ff7224e
using PlutoUI

# ╔═╡ 9c048d90-4a7a-42e8-b37c-89005b7f52c4
md"# Exploratory Data Analysis"

# ╔═╡ cd0488f3-cd0c-4b04-bb1a-edaff404cc83
md"## California, USA"

# ╔═╡ fc536a5f-99fa-409f-bf8f-84b9a93db409
md"### Libraries"

# ╔═╡ 434edfe1-444f-4ce3-8258-7c92b5c079a0
md"### Data"

# ╔═╡ d9a04ecb-6096-4573-b4c3-c4969d5882b3
region = "california"

# ╔═╡ 3d278ecc-dd20-46e3-a41a-fb622daedbb7
seismic_zone = CSV.read("./data/$region.csv", DataFrame)

# ╔═╡ d6962da6-5eda-4080-a6e2-271831b9667b
# Using describe function to get statistics of a dataset
describe(seismic_zone)

# ╔═╡ d66c8f29-bc34-46eb-8dda-5da0686862ac
md"#### Earthquakes by magnitude"

# ╔═╡ f651d956-4ee9-421a-83fa-88f8c82c1d09
Plots.histogram(seismic_zone[:,:Magnitude],
                bins = 40, xlabel = "Magnitude", label="Seismic Events")

# ╔═╡ 15ca1efc-2935-43b6-a9f6-7160244f6be3
md"#### Datetime exploration"

# ╔═╡ c7dee1f5-2088-417b-bb53-d34c48440294
function join_on_counted_no_mag_bounds(df,trim_year,magnitude_threshold)
	#######################################################
	# Get all counts for all years (no magnitude bounds)
	#######################################################

	# Trims the dataframe by year
	df_trimmed = df[(df.Datetime .> DateTime(trim_year,1,1,0,0,0)) .&
					(df.Magnitude .> magnitude_threshold),:]

	# Extracts just the year and puts it in the dataframe
	df_transformed = transform(df_trimmed, :Datetime => ByRow(year) => :Year)

	# Counts the number of occurences of each year resulting in number of events per year
	df_counted = combine(groupby(df_transformed, :Year), nrow => Symbol("count"));

	return df_counted
end
	

# ╔═╡ c6168a51-56fa-45fa-b3f8-a635de2abc98
function join_on_counted(df,trim_year,minmag,maxmag)
	#######################################################
	# Get all counts for all years and magnitude thresholds
	#######################################################
	
	# Trims the dataframe by year and magnitude threshold
	df_trimmed_mag = df[(df.Datetime .> DateTime(trim_year,1,1,0,0,0)) .& 
						  (df.Magnitude .>= minmag) .&
						  (df.Magnitude .< maxmag),:]
	
	# Extracts just the year and puts it in the dataframe
	df_transformed_mag = transform(df_trimmed_mag, :Datetime => ByRow(year) => :Year)

	# Counts the number of occurences of each year resulting in number of events per year per magnitude
	df_counted_mag = combine(groupby(df_transformed_mag, :Year), nrow => Symbol("count_mag_$minmag"));

	# return outerjoin(df_counted, df_counted_mag, on= :Year)
	return df_counted_mag
end

# ╔═╡ 5b62262d-e970-4c08-83c2-c0dc9d62174d
md"## Magnitude Visualization"

# ╔═╡ 660a684d-8fbd-4187-a131-d8eaced608a5
md"### Geographical position"

# ╔═╡ 669dedc1-b8c1-445b-b6bd-19811808332e
# Theme
seismic_theme = Theme(
    # fontsize = 24,
    Axis3 = (
        xlabelsize = 24,
        xlabeloffset = 40,
        xticklabelsize  = 16,

        ylabelsize = 24,
        ylabeloffset = 40,
        yticklabelsize  = 16,

        zlabelsize = 24,
        zlabeloffset = 40,
        zticklabelsize  = 16
        )
                    )

# ╔═╡ b7e3e98d-27de-4e1d-b0e4-e1b6c8e7f5e4
function seismic_scatter_2D(region, trim_year, magnitude_threshold, with_image, img=nothing)
	
	CairoMakie.activate!()
	
	mapcoords= Dict("minLat"=>minimum(region.Latitude),
		            "maxLat"=>maximum(region.Latitude),
		            "minLon"=>minimum(region.Longitude),
		            "maxLon"=>maximum(region.Longitude),
					)
	
	region = region[(region.Datetime .> DateTime(trim_year,1,1,0,0,0)) .&
					(region.Magnitude .> magnitude_threshold),:]

	fig = Figure( resolution=(1080, 720))
	ax = Axis(fig[1,1];    
	    title = L"\text{Seismic Events in region}", titlesize = 40,
	    xlabel = "Longitude", ylabel = "Latitude",
	)

	markerSizes = [1.7^x for x in region.Magnitude];

	limits!(mapcoords["minLon"], mapcoords["maxLon"], mapcoords["minLat"], mapcoords["maxLat"])
	
	if with_image == true
		CairoMakie.image!( 
				range(mapcoords["minLon"],mapcoords["maxLon"],step=0.01),
				range(mapcoords["minLat"],mapcoords["maxLat"],step=0.01),
			    rotr90(img*0.55);
				)
	end

	sc = CairoMakie.scatter!(ax, region.Longitude, region.Latitude,
	    markersize= markerSizes,
		markeralpha = region.Depth,
	    color= region.Magnitude,
	    colormap= (Reverse(:devon), 1),
	    strokewidth= 0.5,
	    shading= false
	)

	Colorbar(fig[1, 2], sc, label="Magnitudes", height=Relative(0.7))

	# save("california_mag_$magnitude_threshold.png", fig)
	fig
end

# ╔═╡ fefbd7ea-45c6-4f7d-bbcf-5b11a3886261
function seismic_scatter_3D(region, trim_year, magnitude_threshold, with_image, img=nothing)
	GLMakie.activate!()
	set_theme!(seismic_theme)
	
	mapcoords= Dict("minLat"=>minimum(region.Latitude),
		            "maxLat"=>maximum(region.Latitude),
		            "minLon"=>minimum(region.Longitude),
		            "maxLon"=>maximum(region.Longitude),
		            "minDepth"=>minimum(region.Depth),
		            "maxDepth"=>maximum(region.Depth),
					)
	
	region = region[(region.Datetime .> DateTime(trim_year,1,1,0,0,0)) .&
					(region.Magnitude .> magnitude_threshold),:]

	mapcoords["maxDepth"]=maximum(region.Depth)

	fig = Figure( resolution=(1080, 720))

	lscene = LScene(fig[1, 1])
	# surface!(lscene, ...)
	
	cam = cameracontrols(lscene.scene)
	cam.lookat[] = [0, 0, 200]
	cam.eyeposition[] = [3000, 200, 2000]
	update_cam!(lscene.scene, cam)

	# parent = Scene(backgroundcolor=:white)
	# cam3d!(parent)

	# camc = cameracontrols(parent)
	# update_cam!(parent, camc, Vec3f(0, 0, 0), Vec3f(4.0, 0, 0))
	
	# cam = Makie.camera(scene)
	
	ax = Axis3(fig[1,1];    
	    title = L"\text{Seismic Events in region}", titlesize = 40,
	    xlabel = "Longitude", ylabel = "Latitude", zlabel = "Depth",
	    perspectiveness=0.5,
		aspect=(1, 1, 1)
	)
	
	markerSizes = [1.7^x for x in region.Magnitude];
	
	sc = GLMakie.scatter!(ax, region.Longitude, region.Latitude, -region.Depth;
		markersize= markerSizes,
		color= region.Magnitude,
		colormap= (Reverse(:devon), 0.99),
		strokewidth= 0.5,
		shading= false,
	)

	Colorbar(fig[1, 2], sc, label="Magnitudes", height=Relative(0.7))
	if with_image == true
		image!(ax , 
				mapcoords["minLon"] .. mapcoords["maxLon"],
				mapcoords["minLat"] .. mapcoords["maxLat"],

				# range(mapcoords["minLon"],mapcoords["maxLon"],step=0.01),
				# range(mapcoords["minLat"],mapcoords["maxLat"],step=0.01),
			    rotr90(img*0.7); 
			    transformation=(:xy,10)# -mapcoords["maxDepth"]),
				)
	end

	# save("california_mag_$magnitude_threshold.png", fig)
	fig
end

# ╔═╡ ef09da5b-ee77-40c4-bc51-c0e38d5599cd
begin
	map = @bind with_map PlutoUI.CheckBox(true)
	mag = @bind magnitude_threshold PlutoUI.Slider(0.0:7.0, 2.0, true)
	trim = @bind trim_year PlutoUI.Slider(1950:2022, 1977, true)
	

	md"Interactive variables: \
	Check if you want to plot with projection of map: $(map) \
	Adjust slider to set magnitude threshold: $(mag) \
	Adjust slider to set trim year: $(trim)"

end

# ╔═╡ 2262a1d3-3b73-4379-97fd-842ba5378224
seismic_zone_counted = join_on_counted_no_mag_bounds(seismic_zone,trim_year,0)

# ╔═╡ 3410c384-2928-4503-ac0d-db8b0ddc65cd
begin
	bar(seismic_zone_counted.Year, seismic_zone_counted.count, 
		orientation=:vertical, 
		title="Event counts per year",
		label="events")
	StatsPlots.plot!(size=(800,600))
end

# ╔═╡ 92e99cad-6648-4863-803d-8f3fecfe5fd2
seismic_zone_counted

# ╔═╡ 1aa3b0a6-3dcc-42b5-9e2f-df78d65c6493
begin
	mags=[]
	for minmag=0:7
		push!(mags,seismic_zone_counted[!,Symbol("count_mag_$minmag")])
	end

	ticklabels = string.(collect(minimum(seismic_zone_counted.Year):maximum(seismic_zone_counted.Year)))

	groupedbar([ mags[8] mags[7] mags[6] mags[5] mags[4] mags[3] mags[2] mags[1] ],
		        bar_position = :stack,
		        bar_width=0.7,
		        xticks=(1:46, ticklabels),
				xrotation=90,
				title="Events within magnitude ranges",
		        label=["7<magnitude" "6<magnitude<7" "5<magnitude<6" "4<magnitude<5" "3<magnitude<4" "2<magnitude<3" "1<magnitude<2" "magnitude<1"])

	StatsPlots.plot!(size=(800,600))
end

# ╔═╡ 0eca36b9-9c29-495a-bc39-be2007105c1d
begin
	groupedbar([ mags[8] mags[7] mags[6] mags[5] mags[4] mags[3]],
			        bar_position = :stack,
			        bar_width=0.7,
			        xticks=(1:46, ticklabels),
					xrotation=90,
					title="Events within magnitude ranges without microearthquakes",
			        label=["7<magnitude" "6<magnitude<7" "5<magnitude<6" "4<magnitude<5" "3<magnitude<4" "2<magnitude<3" ]
					)
	
	StatsPlots.plot!(size=(800,600))
end

# ╔═╡ 332ef6d0-7425-4692-8755-a3f783e3792c
begin
	groupedbar([ mags[8] mags[7] mags[6]],
			        bar_position = :stack,
			        bar_width=0.7,
			        xticks=(1:46, ticklabels),
					xrotation=90,
					title="Large events within magnitude ranges",
			        label=["7<magnitude" "6<magnitude<7" "5<magnitude<6"]
					)
	
	StatsPlots.plot!(size=(800,600))
end

# ╔═╡ 55d71e28-039e-4c46-8a49-dcce6ea0a754
begin
	# Test to check if all quakes have been properly placed in magnitude bracket 
	events=0
	for minmag=0:7
		events+= sum(seismic_zone_counted[!,Symbol("count_mag_$minmag")])
	end
	events == sum(seismic_zone_counted[!,:count])
end

# ╔═╡ 3a122a51-8d5a-4d3f-aec1-8647f2d12a7b
for minmag=0:7
	maxmag=minmag+1
	seismic_zone_counted_mag = join_on_counted(seismic_zone,trim_year,minmag,maxmag)

	leftjoin!(seismic_zone_counted, seismic_zone_counted_mag, on=:Year,makeunique=true)
	seismic_zone_counted[!,Symbol("count_mag_$minmag")] = replace(seismic_zone_counted[!,Symbol("count_mag_$minmag")], missing => 0)
end

# ╔═╡ 48830065-7283-4617-812b-f1c12c2f58ef
md"#### 2D scatter"

# ╔═╡ edf2a421-b514-4802-a1a0-641f9d2fe645
cali = load("./maps/california.png"); nothing

# ╔═╡ 886b94f6-e12f-4d3a-a043-63a0503458e8
seismic_scatter_2D(seismic_zone, trim_year, magnitude_threshold, with_map, cali)

# ╔═╡ 31e2cb67-c945-4146-a9d2-296f23562d41
md"#### 3D scatter"

# ╔═╡ 75db2fcd-22cf-4f42-8cfc-e07a70798c2d
seismic_scatter_3D(seismic_zone, trim_year, magnitude_threshold, with_map, cali)

# ╔═╡ 8a94eb20-18e0-429b-a42e-d203328d14ce


# ╔═╡ Cell order:
# ╟─9c048d90-4a7a-42e8-b37c-89005b7f52c4
# ╟─cd0488f3-cd0c-4b04-bb1a-edaff404cc83
# ╟─fc536a5f-99fa-409f-bf8f-84b9a93db409
# ╠═b0224563-5d2a-4e46-9cf3-509a6c86a266
# ╠═a41ce9cd-915d-4ed8-b999-bc4603582be3
# ╠═41de3455-6039-4114-b98a-19266bf81a10
# ╠═67559f09-e337-4fbb-b8f3-3b412ff7224e
# ╟─434edfe1-444f-4ce3-8258-7c92b5c079a0
# ╠═d9a04ecb-6096-4573-b4c3-c4969d5882b3
# ╠═3d278ecc-dd20-46e3-a41a-fb622daedbb7
# ╠═d6962da6-5eda-4080-a6e2-271831b9667b
# ╟─d66c8f29-bc34-46eb-8dda-5da0686862ac
# ╠═f651d956-4ee9-421a-83fa-88f8c82c1d09
# ╟─15ca1efc-2935-43b6-a9f6-7160244f6be3
# ╠═c7dee1f5-2088-417b-bb53-d34c48440294
# ╠═c6168a51-56fa-45fa-b3f8-a635de2abc98
# ╠═2262a1d3-3b73-4379-97fd-842ba5378224
# ╠═3410c384-2928-4503-ac0d-db8b0ddc65cd
# ╟─5b62262d-e970-4c08-83c2-c0dc9d62174d
# ╠═3a122a51-8d5a-4d3f-aec1-8647f2d12a7b
# ╠═92e99cad-6648-4863-803d-8f3fecfe5fd2
# ╠═1aa3b0a6-3dcc-42b5-9e2f-df78d65c6493
# ╠═55d71e28-039e-4c46-8a49-dcce6ea0a754
# ╠═0eca36b9-9c29-495a-bc39-be2007105c1d
# ╠═332ef6d0-7425-4692-8755-a3f783e3792c
# ╟─660a684d-8fbd-4187-a131-d8eaced608a5
# ╠═669dedc1-b8c1-445b-b6bd-19811808332e
# ╠═b7e3e98d-27de-4e1d-b0e4-e1b6c8e7f5e4
# ╠═fefbd7ea-45c6-4f7d-bbcf-5b11a3886261
# ╟─ef09da5b-ee77-40c4-bc51-c0e38d5599cd
# ╟─48830065-7283-4617-812b-f1c12c2f58ef
# ╠═edf2a421-b514-4802-a1a0-641f9d2fe645
# ╠═886b94f6-e12f-4d3a-a043-63a0503458e8
# ╟─31e2cb67-c945-4146-a9d2-296f23562d41
# ╠═75db2fcd-22cf-4f42-8cfc-e07a70798c2d
# ╠═8a94eb20-18e0-429b-a42e-d203328d14ce
