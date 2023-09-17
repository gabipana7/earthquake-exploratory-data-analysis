using CSV, DataFrames, Dates

#######################################
# STEP 1
# Read each file, line by line 
#######################################
function parse_data_files(filepaths)
    identifier = []
    datetime = []
    latitude_deg, latitude_min, latitude_err=  [],[],[]
    longitude_deg, longitude_min, longitude_err =  [],[],[]
    depth, depth_err = [],[]
    magnitude1 = []
    magnitude1_type = []

    # 5:end -> 1983 - 2020
    for path in filepaths[5:end]
        open(path) do io
            # skip the first line
            # line = readline(io)
            while true
                # start reading the lines
                line = readline(io)
                # detect the end of the line
                line == "" && break
                # push to the vectors, the characters based on the position in the text file
                # push!(date,  strip(line[1:10]))
                push!(identifier,  strip(line[1:1]))

                # DATETIME PROCESSING 
                year = strip(line[2:5])
                month = strip(line[6:7])
                day = strip(line[8:9])
                hour = strip(line[10:11])
                minute = strip(line[12:13])
                second = strip(line[14:17])
                push!(datetime,  year * "/" * month * "/" * day * " " * hour * ":" * minute * ":" * string(parse(Float64,second)/100))

                # Latitude
                push!(latitude_deg, strip(line[22:24]))
                push!(latitude_min, strip(line[25:28]))
                push!(latitude_err, strip(line[29:32]))
                
                # Longitude
                push!(longitude_deg, strip(line[33:36]))
                push!(longitude_min, strip(line[37:40]))
                push!(longitude_err, strip(line[41:44]))

                # Depth
                push!(depth, strip(line[45:49]))
                push!(depth_err, strip(line[50:52]))

                # Magnitude
                push!(magnitude1, strip(line[53:54]))
                push!(magnitude1_type, strip(line[55:55]))
                # push!(magnitude2, parse(Float64, strip(line[56:57])))
                # push!(magnitude2_type, strip(line[57:58]))
            end
        end
    end 

    df = DataFrame(Identifier=identifier,
                    Datetime=datetime, 
                    Latitude_degree=latitude_deg, Latitude_minute=latitude_min, Latitude_error=latitude_err,
                    Longitude_degree=longitude_deg, Longitude_minute=longitude_min, Longitude_error=longitude_err,
                    Depth=depth, Depth_error=depth_err,
                    Magnitude=magnitude1, Magnitude_Type=magnitude1_type)



    ####################################################
    # STEP 1.2
    # Some preprocessing -> keep Japan, eliminate emptys 
    ####################################################

    # Get Only Japan data 
    df = df[df.Identifier .== "J",:]

    # Eliminate empty strings data
    df = df[all.(!=(""), eachrow(df)), :]

    return(df)
end


####################################################
# STEP 2
# Processing -> manage long, lat, dep and mag
####################################################

# Parser for strings to turn into float and process
function parse_float(value)
    try
        float_value = parse(Float64, value)
        return(float_value)
    catch e
        return(missing)
    end
end


function process_df(jma)
    latitude = []
    latitude_err = []
    longitude = []
    longitude_err = []
    depth = []
    depth_err = []
    magnitude =[]

    for i in eachindex(jma.Identifier)
        # Latitude processing
        lat_deg = parse_float(jma.Latitude_degree[i])
        # Minutes are in the form XXXX, but represent actually XX.XX
        # Divide XXXX by 100
        lat_min = parse_float(jma.Latitude_minute[i]) / 6000
        # Latitude error 
        lat_err = parse_float(jma.Latitude_error[i]) / 6000

        push!(latitude, round((lat_deg + lat_min), digits=4))
        push!(latitude_err, round(lat_err, digits=4))


        # Longitude processing
        lon_deg = parse_float(jma.Longitude_degree[i])
        lon_min = parse_float(jma.Longitude_minute[i]) / 6000
        # longitude error 
        lon_err = parse_float(jma.Longitude_error[i]) / 6000

        push!(longitude, round((lon_deg + lon_min), digits=4))
        push!(longitude_err, round(lon_err, digits=4))

        # Depth processing
        dep = parse_float(jma.Depth[i]) / 100
        push!(depth, dep)
        # depth error
        dep_err = parse_float(jma.Depth_error[i]) / 100
        push!(depth_err, dep_err)

        # Magnitude
        mag = parse_float(jma.Magnitude[i]) / 10
        push!(magnitude, mag)
    end

    # do not forget about datetime
    datetime = []
    dateformat = dateformat"yyyy/mm/dd HH:MM:SS.ss"
    datetime = DateTime.(jma.Datetime, dateformat);

    df_new = DataFrame(Datetime=datetime, 
                    Latitude=latitude, Latitude_err=latitude_err, 
                    Longitude=longitude, Longitude_err=longitude_err, 
                    Depth=depth, Depth_err=depth_err,
                    Magnitude=magnitude, Magnitude_Type=jma.Magnitude_Type)


    # Drop missing in new, processed dataframe
    dropmissing!(df_new)

    # Positive magnitude
    df_new = df_new[df_new.Magnitude .> 0.0,:]

    return(df_new)
end


####################################################DEMO####################################################
#######################################
# STEP 1
# Read each file, line by line 
#######################################
unzip_destination_path = "./jma_data"
filepaths = readdir(unzip_destination_path,join=true)
jma_preprocessed = parse_data_files(filepaths)


####################################################
# STEP 2
# Processing -> manage long, lat, dep and mag
####################################################
jma = process_df(jma_preprocessed)


# Make directory if it does not exist
mkpath("./catalogs/")

# Write CSV with data
CSV.write("./catalogs/jma.csv", jma)


# Extra
# remove unzipped files after loading and processing
rm("jma_data", recursive=true)
