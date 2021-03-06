library(dataone)

# Initialize a client to interact with DataONE
cli <- D1Client()

# search for data packages, listing both data and metadata relevant, and only request versions that are not obsolete
# for this PISCO search, it allows us to discover the identifier for the package resource map, used below
results <- d1SolrQuery(cli, list(q="id:*pisco_intertidal.50.6 -obsoletedBy:*",fl="identifier,title,author,documents,resourceMap"))
sr <- xmlParse(results)
sr

# A function that downloads the data for a pid and assumes its parseable into a data.frame
getDataFrame <- function(pkg, pid) {
    obj1 <- getMember(pkg, pid)
    d1 <- asDataFrame(obj1)
    return(d1)
}

# Retrieve the PISCO point count data package, and list its identifiers
pkg <- getPackage(cli, "resourceMap_pisco_intertidal.50.6")
getIdentifiers(pkg)

# Create data frames for each of the data objects
d1 <- getDataFrame(pkg, "doi:10.6085/AA/pisco_intertidal.32.8")
d2 <- getDataFrame(pkg, "doi:10.6085/AA/pisco_intertidal.45.2")
d3 <- getDataFrame(pkg, "doi:10.6085/AA/pisco_intertidal.31.8")
d4 <- getDataFrame(pkg, "doi:10.6085/AA/pisco_intertidal.33.3")

# Download the metadata as well
obj5 <- getMember(pkg, "doi:10.6085/AA/pisco_intertidal.50.6")
getFormatId(obj5)
metadata <- xmlParse(getData(obj5))
metadata

#obj <- eml_read("doi:10.6085/AA/pisco_intertidal.50.6")

# Aggregate the species counts by site, year, plot, and species
# Note: it's not clear the PISCO concept of transect will correspond to our use of 'plot'
# Check the methods docs to verify: http://cbsurveys.ucsc.edu/sampling/images/dataprotocols.pdf
library(data.table)
d2_t = data.table(d2)
d2_t$dummy <- 1
pisco_point_counts <- d2_t[,list(cnt = sum(dummy)), by = c('site_code,year,transect,class_code')]
setnames(pisco_point_counts, c("site", "year", "plot", "species", "abundance"))
pisco_point_counts$abundancemetric <- "count"
