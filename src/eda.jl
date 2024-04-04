using CSV, DataFrames, Dates
using CairoMakie
using StatsPlots


function load_data(region, catalog)
    df = CSV.read("./catalogs/$catalog.csv", DataFrame);
    println(first(df,5), describe(df))

    mkpath("./data")
    mkpath("./eda_results/$region/")

    return df
end

# EVENTS EDA
function events_histogram(df, region)
 
    set_theme!(Theme(fonts=(; regular="CMU Serif")))
    fig = Figure(size = (700, 500), font= "CMU Serif",) ## probably you need to install this font in your system

    ax = Axis(fig[1, 1], xlabel = L"M", ylabel = L"N", ylabelsize = 26,
    xlabelsize = 22, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
    xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10)

    hist!(ax, df[:,:Magnitude], bins = 40, label = "number of events")

    axislegend(ax, position = :rt, backgroundcolor = (:grey90, 0.25), labelsize=18);

    save("./eda_results/$region/$(region)_histogram_events_magnitudes.png",fig, px_per_unit=5)
    return fig
end


# TIMESPAN EDA
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

function explore_timespan(df, region, trim_year, explore_trim_year; magnitude_threshold=0.0)
    df_counted = join_on_counted_no_mag_bounds(df,trim_year,magnitude_threshold)
    set_theme!(Theme(fonts=(; regular="CMU Serif")))
    fig = Figure(size = (700, 500), font= "CMU Serif",) ## probably you need to install this font in your system


    ax1 = Axis(fig[1, 1], xlabel = L"\mathrm{Year}", ylabel = L"N", ylabelsize = 26,
    xlabelsize = 22, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
    xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10)

    ########################################## TRUNCATED
    ax2 = Axis(fig, bbox = BBox(140,410,226,460), xgridvisible = false, ygridvisible = false, xtickalign = 1,
    xticksize = 4, ytickalign = 1, yticksize = 4, xticklabelsize=16, yticklabelsize=16, backgroundcolor=:white)

    barplot!(ax1, df_counted.Year, df_counted.count)

    barplot!(ax2, df_counted.Year[end-(2023-explore_trim_year):end], df_counted.count[end-(2023-explore_trim_year):end], label="Starting $(explore_trim_year)")
    hideydecorations!(ax2)

    axislegend(ax2, position = :lt, backgroundcolor = (:grey90, 0.25), labelsize=10);

    save("./eda_results/$region/$(region)_events_per_year.png",fig, px_per_unit=5)
    fig

    trim_year = explore_trim_year
    df_trimmed = df[(df.Datetime .> DateTime(trim_year,1,1,0,0,0)),:]

    return df_trimmed 
end

# MAGNITUDE TYPE EXPLORATION
function magtype_boxplot(df, region; mag_type_descriptions)


    StatsPlots.boxplot(df.Magnitude_Type, df.Magnitude, xlabel="Magnitude Type", ylabel="Magnitude")
    StatsPlots.savefig("./eda_results/$region/$(region)_magnitude_type_boxplot.png")

    df_mag_type_count = combine(groupby(df, :Magnitude_Type, sort=true), nrow)
    mag_type_year_range =[]
    for i in df_mag_type_count.Magnitude_Type
        df3 = df[(df.Magnitude_Type .== i),:]
        push!(mag_type_year_range, string(year(minimum(df3.Datetime))) * "-" * string(year(maximum(df3.Datetime))))
    end

    insertcols!(df_mag_type_count, 3, :Year_range => mag_type_year_range)
    if mag_type_descriptions
        insertcols!(df_mag_type_count, 4, :Description => mag_type_descriptions)
        return df_mag_type_count
    else
        return df_mag_type_count
    end

end


# QUALITY EXPLORATION
function quality_boxplot(df, region)

    StatsPlots.boxplot(df.Quality, df.Magnitude, xlabel="Quality", ylabel="Magnitude")
    StatsPlots.savefig("./eda_results/$region/$(region)_quality_boxplot.png")

    df_quality_count = combine(groupby(df, :Quality, sort=true), nrow)

    return df_quality_count
end