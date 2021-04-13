## SWMPr package for importing and organizing data for NERR site data
## Code compiled by Jill Arriola- October 2020
## Updated 2021-04-13 to include removal of NA's
## Based on article by Marcus Beck - 2016
## SWMPr package can be found at github.com/fawda123/SWMPr

## Loading SWMPr package
install.packages('SWMPr')
library('SWMPr')

####################################################################################
## Importing data set from local source (zip file of data requested from CDMO)
## import_local('file path', 'station ID')
## Station ID e.g. apaebmet; apaebmet2016; apacpnut2007
swmp1 <- import_local("C:/Users/Jill/My Documents/Raw NERRS data/761095.zip", 'sapdcwq')
#attributes(swmp1) ## Check what you just pulled in

swmp2 <- import_local("C:/Users/Jill/My Documents/Raw NERRS data/761095.zip", 'sapmlmet')
#attributes(swmp2)

#swmp3 <- import_local("C:/Users/Jill Arriola/OneDrive - The Pennsylvania State University/Documents/R codes and data/Raw data/Weeks/323175.zip", 'wkbwbmet')
####################################################################################
## Cleaning and Organizing Datasets
## See article for all functions. Only some functions are listed here.

## QAQC code filter 
## Removes obviously bad values, i.e. negative wind speed, and erroneous data
## qaqc(data, qaqc_keep)
## QAQC values range from -5 to 5. Values with - are missing or rejected data points. O means passed initial QAQC.
#qaqcchk(swmp1) ## View the number of observations in each QAQC code
#qaqcchk(swmp2)

## Removes flag columns and replaces removed data points with NA
## Be aware that overnight PAR values are often flagged and therefore may be replaced with NA when should be 0
swmp1zero <- qaqc(swmp1, qaqc_keep = 0) 
#attributes(swmp1zero)
swmp2zero <- qaqc(swmp2, qaqc_keep = 0)
#attributes(swmp2zero)
#swmp3zero <- qaqc(swmp3, qaqc_keep = 0)

## Selecting subsets of data
## subset(dat, subset = c('starting date and time', 'ending date and time'), select = c('param1', 'param2', etc))
swmp1zerosub <- subset(swmp1zero, subset = c('2007-01-01 0:00', '2018-12-31 23:45'), select = c('datetimestamp', 'temp', 'depth', 'do_mgl', 'sal'))
swmp2zerosub <- subset(swmp2zero, subset = c('2007-01-01 0:00', '2018-12-31 23:45'), select = c('datetimestamp', 'atemp', 'bp', 'wspd', 'totpar', 'wdir'))
#swmp3zerosub <- subset(swmp3zero, subset = c('2007-01-01 0:00', '2018-12-31 23:45'), select = c('datetimestamp', 'atemp', 'bp', 'wspd', 'totpar'))

## Combine multiple datasets into one
## comb(swmp1, swmp2, swmp3, timestep = minute interval (i.e. 120), method = 'union' or 'intersect')
## For example:
## swmp1 = apacpnut2012
## swmp2 = apacpwq2012
## swmp3 = apaebmet2012
swmpdataset <- comb(swmp1zerosub, swmp2zerosub, method = 'union')

#Change NA's in totpar to zero
#swmpdataset$totpar[is.na(swmpdataset$totpar)] <- 0
#Remove rows with NA values
#swmpdataset <- na.omit(swmpdataset)

write.csv(swmpdataset, file = 'C:/Users/Jill/My Documents/sap_dc_data.csv')
#write.csv(swmp3zerosub, file = 'C:/Users/Jill Arriola/Documents/wkbwbmet.csv')
                    
#####################################################################################
## Data Analysis Tools

## Decomposition of additive time series breaks down and plots observations, trends (monthly or daily), seasonal, and anomalies.
## Set subset of data first to reduce amount of data analyzed
## decomp(data, param = 'parameter', frequnecy = 'daily' or 'monthly') *see help for more options
dc_swmpdataset <- decomp(swmpdataset, param = 'do_mgl', frequency = 'daily')
plot(dc_swmpdataset)

## Decomposition of monthly measurements, such as nutrients
## Set subset of data first to reduce amount of data analyzed
## decomp_cj(data, param = 'parameter') *see help for more options
dccj_swmpnut <- decomp_cj(swmp1, param = 'chla_n')
plot(dccj_swmpnut)

## Plot time series which includes plots of monthly distributions, monthly histograms, monthly means by year, and deviations.
## plot_summary(data, param = 'parameter', years = c(start, end)) *default years is all
plot_summary(swmp1zero, param = 'do_mgl')

## Plot multiple parameters for one time series into one plot
## overplot(data, select = c('param1', 'param2', etc), subset = c('start date and time', 'end date and time'))
## *includes plotting arguements including ylab, lwd, type, etc.
overplot(swmp1zero, select = c('do_mgl', 'sal', 'temp'), subset = c('2012-05-01 0:00', '2012-06-30 23:45'), lwd = 2)

# decompose the chlorophyll time series
decomp_cj(swmp1zero, param = 'chla_n')

# plot a wind rose 
plot_wind(swmp2zerosub)

######################################################################################
## Maps 

## Create a map of the NERR site and field stations
## YOU MUST HAVE AN API KEY SET UP WITH GOOGLE TO USE - IT IS NOT FREE
## See ?register_google
## map_reserve('nerr_site_id', zoom, text_sz, text_col, map_type = 'terrain', 'satellite', 'roadmap', or 'hybrid')




