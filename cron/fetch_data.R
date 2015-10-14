#------------------------------------------------------------------------
# SETTINGS
library(data.table)
library(R.utils)
library(plyr)

#------------------------------------------------------------------------
# DOWNLOAD DL LOG FILES
# source: http://cran-logs.rstudio.com

# Here's an easy way to get all the URLs in R
start <- as.Date('2012-10-01')
today <- as.Date(format(Sys.time(), "%Y-%m-%d"))

all_days <- seq(start, today, by = 'day')

# If you only want to download the files you don't have, try:
missing_days <- setdiff(all_days, as.Date(tools::file_path_sans_ext(dir(path = paste0(getwd(),"/data/raw/")), TRUE)))
missing_days <- format(as.POSIXct.Date(missing_days), "%Y-%m-%d")

year <- as.POSIXlt(missing_days)$year + 1900
urls <- paste0('http://cran-logs.rstudio.com/', year, '/', missing_days, '.csv.gz')

# You can then use download.file to download into a directory.
if(length(missing_days)>2) {
  yesterday<- length(missing_days)-2
  for(i in 1:yesterday) {
    tryCatch(
      expr = download.file(url = urls[i], 
                           destfile = paste0(getwd(),"/data/raw/", missing_days[i],'.csv.gz')),
      error = function(e){
        print(e)
      })
  }
} else {
  print("Log files are up-to-date!")
}

rm(list=ls())


#------------------------------------------------------------------------
# FETCH DATA FOR ALL PACKAGES
packages<- c("Luminescence", "shiny", "dplyr", "googleVis", "data.table", "RLumShiny")

files_to_remove<- list.files(paste0(getwd(),"/data/raw/"), pattern = "*.csv$", full.names = TRUE)
file.remove(files_to_remove)

for(p in packages) {
  stat_files_existing<- list.files(paste0(getwd(),"/data/"), pattern = "*.Rdata")
  stat_file<- paste0("stats_", as.character(p),".Rdata")
  
  if(stat_file %in% stat_files_existing) {
    load(paste0(getwd(), "/data/", stat_file))
  } else {
    assign(paste0("stats_", as.character(p)), data.frame())
  }
  
  files_all<- list.files(paste0(getwd(),"/data/raw/"))
  dates<- gsub(".csv.gz","",files_all)
  
  tmp<- get(paste0("stats_", as.character(p)))
  
  last_date<- na.omit(tmp$date)[length(na.omit(tmp$date))]
  if(!is.null(last_date)) {
    missing_dates<- c(match(last_date, dates)+1, length(dates))
    if (any(is.na(missing_dates))) {
      next
    }
    
    missing_files<- files_all[missing_dates[1]:missing_dates[2]]
  } else {
    last_date<- gsub(".csv.gz","",files_all[1])
    missing_files<- files_all
  }
  
  if(!is.null(last_date) && last_date != dates[length(dates)]) {
    
    data<- data.frame(date=NA,time=NA,size=NA,r_version=NA,r_arch=NA,
                      r_os=NA,package=NA,version=NA,
                      country=NA,ip_id=NA)
    
    pb<- txtProgressBar(min = 0,  max = length(missing_files), initial = 0, char = "=",
                        width = NA, title, label, style = 3, file = "")
    
    for(i in 1:length(missing_files)) {
      # fread in {data.table}
      f<- missing_files[i]
      gunzip(paste0(getwd(),"/data/raw/",f), temporary = F, skip = T, remove = F)
      f2<- paste0(getwd(),"/data/raw/", gsub(".gz", "", x = missing_files[i]))
      dt<- tryCatch({
        fread(f2, sep = ",", header = TRUE, stringsAsFactors = FALSE, 
              colClasses=c("character","character","integer","character","character",
                           "character","character","character","character","integer"))
      }, error = function(e) {
        message(e)
      })
      
      if (inherits(dt, "try-error") || is.null(dt)) {
        try(file.remove(f2))
        closeAllConnections()
        setTxtProgressBar(pb, i)
        next
      }
        
      # new_data<- filter(dt, p == as.character(p)) # filter() in {dplyr}
      new_data<- subset(dt, package == p)
      
      if(nrow(new_data)==0) {
        new_data<- data.frame(date = gsub(".csv.gz", "", x = missing_files[i]),
                              time = NA ,size = NA, r_version = NA, r_arch = NA,
                              r_os = NA, package = NA, version = NA,
                              country = NA, ip_id = NA)
      }
      data<- rbind(data, new_data)
      file.remove(f2)
      closeAllConnections()
      setTxtProgressBar(pb, i)
    }#EndOf::for loop
    
    assign(paste0("stats_", as.character(p)),
           rbind(get(paste0("stats_", as.character(p))), data))
    
    save(list = paste0("stats_", as.character(p)), file = paste0(getwd(), "/data/stats_", as.character(p), ".Rdata"))
    
    close(pb)
  } else {
    print(paste0("stats_", as.character(p) ," is up-to-date!"))
  }
}

rm(list=ls())