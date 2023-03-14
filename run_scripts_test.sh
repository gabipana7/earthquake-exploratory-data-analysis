echo `date`
julia --project src/gmt_maps_test.jl vrancea &
julia --project src/gmt_maps_test.jl romania &
wait
echo `date`
