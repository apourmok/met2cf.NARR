vars=("pres.sfc" "dswrf" "dlwrf" "air.2m" "shum.2m" "prate" "uwnd.10m" "vwnd.10m")
svars=("pres" "dswrf" "dlwrf" "air" "shum" "prate" "uwnd" "vwnd")
nvars=("air_pressure" "surface_downwelling_shortwave_flux" "surface_downwelling_longwave_flux" "air_temperature" "specific_humidity" "precipitation_flux" "eastward_wind" "northward_wind" )

cd /projectnb/cheas/gapmacro/NARR/RawNARR2

sep="."
suffix=".nc"

n=${#nvars[*]} #Number of variable names


######################
# Rename Variables

for i in {1979..2012}
do   
    year="$i"

    for (( k=0; k<=$(( $n -1 )); k++ )) # For each variable name
        do    
        
            file=${vars[$k]}$sep$year$suffix

            if [ -f $file ]
                then
                cp $file ${nvars[$k]}$sep$year$suffix
                ncrename -v ${svars[$k]},${nvars[$k]} ${nvars[$k]}$sep$year$suffix
            fi
        done
done

######################
# Merge files by year

for i in {1979..2012}
    do   
        year="$i"
        
        j=0

        for (( k=0; k<=$(( $n -1 )); k++ )) # For each variable name
            do    
                file=${nvars[$k]}$sep$year$suffix
                if [ -f $file ]
                    then

                    let j++

                    if [ $j == 1 ]
                        then
                        cp $file $year$suffix 

                        ncks -O --fl_fmt=netcdf4 $year$suffix $year$suffix  # netCDF4
                        ncpdq -O -U $year$suffix $year$suffix

                    else 

                        ncks -O --fl_fmt=netcdf4 $file $file  # netCDF4
                        ncpdq -O -U $file $file

                        
                        ncks -A $file $year$suffix

                    fi
                fi
                rm $file
        done
done