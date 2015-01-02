# check available files
files<- list.files("./data/", "*.Rdata")
datasets<- gsub(".Rdata", "", files)

# load all datasets (*.Rdata files)
for(f in files) 
  load(paste0("./data/", f))

# remove all days with no entries
for(d in datasets)
  assign(d, subset(get(d), !is.na(ip_id)))