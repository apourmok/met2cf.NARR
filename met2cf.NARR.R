library(PEcAn.all)
library(ncdf4)
library(RPostgreSQL)

# Defaults
vlist <- c("pres.sfc", "dswrf", "dlwrf", "air.2m", "shum.2m", "prate" )
start_year <- 1979 
end_year <- 2012
outfile <- "/projectnb/cheas/gapmacro/NARR/NewNARR"

# site_lat <- 35.05904  #CWT
# site_lon <- -83.42732 #CWT
# siteid   <- 336       #CWT
# site_abriv <- "CWT"

# Mt Rainier, WA
 site_lat <- 46.8529  
 site_lon <- -121.7604 
 # x <- 140
 # y <- 136
 # siteid   <- ?      
 site_abriv <- "WA"

outfile <- "/projectnb/cheas/gapmacro/NARR/NewNARR"

system(paste("module load netcdf"))

# Get original Data
(for (v in vlist){
  for (year in seq(end_year,start_year,by=-1)){
    system(paste("wget -c -P ", outfile ," ftp://ftp.cdc.noaa.gov/Datasets/NARR/monolevel/",v,".", year,".nc",sep=""))
  }    
}
system(paste("cd ", outfile))
system(paste("/projectnb/cheas/gapmacro/NARR/NewNARR/nc_formatting.sh"))

# Find closest coordinates to site
close <- closest_xy(site_lat, site_lon)
x <- close$x
y <- close$y

# Subset to site and upload

dbparms <- list(driver="PostgreSQL" , user = "bety", dbname = "bety", password = "bety")
con     <- db.open(dbparms)

mimetype   <- 'CF Meteorology'
formatname <- 'application/x-netcdf'

for (year in seq(end_year,start_year,by=-1)){
  
  system(paste("ncks -d x,",x,",",x, " -d y,",y,",",y," ", year, ".nc ",year, "_sub.nc",sep=""))
  
  filename   <- paste(year, "_sub.nc",sep="")
  startdate  <- paste(year,'-01-01',sep="")
  enddate    <- paste(year,'-12-31',sep="")
  
  dbfile.input.insert(filename, siteid, startdate, enddate, mimetype, formatname, con=con) 
  
}
