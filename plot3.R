## Coursera: Exploratory Data Analysis: Week 1 Project: Plot3

## WARNING: This will clear all objects from memory, you can dedice to comment it if you don;t want this behaviour
##--------------------------------------------------
## Clean up session removing all variables
##rm(list = ls())
##gc()

if(!require("sqldf")){
    install.packages("sqldf")
    library("sqldf")
}

## create the directory where we will place the data. ProjectEPCPlot (Electric Power Consumption Plot)
## the directory will be created in the current work directory. I will then set the new work directory
## and save the previous one to recover it after finishing the work
dtaDirectory <- "ProjectEPCPlot"
oldWrkDir <- getwd()

newWrkDir <- paste(oldWrkDir,dtaDirectory,sep = "/")

# if new directory doesn't exist create it
if (!file.exists(newWrkDir)){
    dir.create(newWrkDir)
}
setwd(newWrkDir)

## URL where file is located
strUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"

## download binary file (ZIP file). 
## Destination name is "exdata_data_household_power_consumption.zip"
zipFile <- "exdata_data_household_power_consumption.zip"
if(!file.exists(zipFile)){
    res <- download.file(strUrl, zipFile, mode = "wb")
    if(res != 0){
        message("Error downloading zile")
        ## set work directory as it was before
        setwd(oldWrkDir)
        stop()
    }
}
## Files are now unzipped 
dtaSubDir <- paste(getwd(),"DataEPCPlot", sep = "/")

## unzip file
if(!file.exists(dtaSubDir)){
    unzip(zipFile, overwrite = TRUE, junkpaths = FALSE, exdir = newWrkDir)
}

## I am going to take the path of loading only the data we need instead of the complete data set
## To do this we will use the package sqldf, specifically the function read.csv.sql

## 1. Define the proper SQL Statement:
##    The statment will get the fields we need, making sure to convert the date from the string format d/m/yyyy into
##    a proper date format YYYY-MM-DD, changing any ? symbol into NA and filtering so we can only get 2/1/2007 and 2/2/2007
mysql <- "select  Date((Substr(Date, length(Date)-3, 4) || '-0' || Substr(Date, 3, 1) || '-0' || Substr(Date, 1, 1))
) Date, 
case when Time = '?' then 'NA' else Time end Time, case when Global_active_power  = '?' then 'NA' else Global_active_power  end Global_active_power  , 
case when Global_reactive_power = '?' then 'NA' else Global_reactive_power end Global_reactive_power, case when Voltage = '?' then 'NA' else  Voltage end Voltage, 
case when Global_intensity = '?' then 'NA' else  Global_intensity end Global_intensity, case when Sub_metering_1  = '?' then 'NA' else Sub_metering_1  end Sub_metering_1,
case when Sub_metering_2 = '?' then 'NA' else Sub_metering_2 end Sub_metering_2, case when Sub_metering_3 = '?' then 'NA' else Sub_metering_3 end Sub_metering_3 
from file where Date = '1/2/2007' or Date = '2/2/2007'"

## 2. Execute read.csv.sql function
plotdata <- read.csv.sql("household_power_consumption.txt", sql = mysql, sep=";")

## 3. Convert Date to date class and Time to datetime class
plotdata$Time <- paste(plotdata$Date,plotdata$Time, sep = ' ')
plotdata$Date <- as.Date(plotdata$Date)
plotdata$Time <- strptime(plotdata$Time, format="%Y-%m-%d %H:%M:%S")

## 4. Open PNG File create plot ans save it
png("plot3.png",width = 480, height = 480, units = "px", pointsize = 12)

plot(plotdata$Time, plotdata$Sub_metering_1, type="o", col="black", pch=NA, lty=1, xlab="", ylab="Energy sub metering")
points(plotdata$Time, plotdata$Sub_metering_2, col="red", pch=NA)
lines(plotdata$Time, plotdata$Sub_metering_2, col="red",lty=1)
points(plotdata$Time, plotdata$Sub_metering_3, col="blue", pch=NA)
lines(plotdata$Time, plotdata$Sub_metering_3, col="blue",lty=1)
legend("topright", pch=NA, col=c("black", "blue", "red"), legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lty=1)

dev.off()

## close all file connections

closeAllConnections()
## set work directory as it was before
setwd(oldWrkDir)