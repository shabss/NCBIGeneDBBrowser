
library(data.table)

#Steps:
#1. Downloaded from ftp.ncbi.nlm.nih.gov using the following command
#   wget -r ftp://ftp.ncbi.nlm.nih.gov/gene/ --ftp-user=anonymous --ftp-password=<email address>
#2. Set data.base.laptop variable (below) to point to root where the files are downloaded
#3. setwd() to this files base folder and run prepare.gene.subset() function
#   This will create subset data in <download-root>/gene/DATA.subset
#4. Manually copy/move the subset directory to this .R files location 
#   So path should be <this .R location>/gene/DATA.subset
#5. Run runApp(), deployApp(), or load.gene.subset() function

data.base.laptop <- "c:/projects/edu/devdataprod/data/ftp.ncbi.nlm.nih.gov"
data.base.server <- "."
data.base <- data.base.laptop

gene.base.orig <- "gene/DATA"
gene.base.subset <- "gene/DATA.subset"
gene.base <- gene.base.orig

gene.pattern <- "*.gz"


get.header <- function(file) {
    
    #Each file has a header of form:
    ##Format: <list of column names seperated by space> (<extra comments>)
    #Strip "#Format: " and "((<extra comments>)" out. 
    #Then create a character vector of column names and return it
    
    #The subset files have proper header; first line is column names seperated by tabs
    #the following code works for that case also
    
    ln <- readLines(file, n = 1)
    ln <- sub("#Format: ", "", ln)
    ln <- sub(" *\\(.*\\)$", "", ln)
    ln <- sub("^\\s*", "", ln)
    ln <- sub("\\s*$", "", ln)
    hdr <- strsplit(ln, split=" +|\t+")[[1]]
    print(paste("ncols=", length(hdr), ":", paste(hdr, collapse=',')))
    hdr
}

get.genedata <- function(file, skip = 0, count = -1) {
    path <- paste(data.base, gene.base, file, sep="/")
    hdr <- get.header(path)
    sep <- "\t"

    if (skip == 0) {
        #skip first line, which is header. We are processing header
        #seperately. See get.header(path) above
        skip <- 1
    }
    
    if (sum(grepl("gene_pm", file)) > 0) {
        #special processing for gene/DATA.subset/misc/gene_pm_200701_9606_10090.gz
        #- has header on first line, like others, however it is seperated by spaces instead of tabs
        #- 2nd line is a seperator between header and data. So skip that also
        #- do the above only when generating subset data. We write correctly in subset data
        
        sep <- ""
        if ((skip <= 1) & (gene.base != gene.base.subset)) {
            skip <- skip + 1
        }
    }

    genedata <- read.table(path, header=FALSE, skip = skip, nrows=count,
                           sep=sep, na.strings="-", quote="\"",
                           comment.char="", col.names=hdr)
}

get.genedbs <- function() {
    #Recursivley find *.gz files within the folder; each *.gz file has a gene database
    #return the relative path names of *.gz files found
    
    path <- paste(data.base, gene.base, sep="/")
    dbs <- list.files(path, pattern = gene.pattern, recursive=TRUE)
}

prepare.gene.subset <- function() {
    #Extract first 100 records (aka subset)  from each of the gene database
    #store it in alternate folder location for later use
    #ignore .ags files since those are not currenlty supported
    
    dbs <- get.genedbs()
    for (db in dbs) {
        fn <- paste(data.base, gene.base.subset, db, sep="/")
        print(paste("Creating", fn, sep=" "))
        
        if (sum(grepl("\\.ags", db)) > 0) {
            print(paste("ASN.1 file format not supported (", db, ")", sep=""))
            next
        }
        
        genedata <- get.genedata(db, 0, 100)
        if (!file.exists(dirname(fn))) {
            dir.create(dirname(fn), recursive=TRUE)
        }
        gzf <- gzfile(fn, "w")
        write.table(genedata, gzf, sep="\t", na="-", 
                    col.names=names(genedata), row.names=FALSE,
                    quote=FALSE)
        close(gzf)
    }
}

load.gene.subset <- function() {
    #Load gene subset data from alternate path
    
    data.base <<- data.base.server
    gene.base <<- gene.base.subset

    dbs <- get.genedbs()
    
    list.db <- c()
    list.genedata <- list()
    
    for (db in dbs) {
        print(paste(gene.base, db, sep="/"))
        genedata <- get.genedata(db)
        
        list.db <- c(list.db, db)
        list.genedata <- rbind(list.genedata, genedata=list(genedata))
    }
    
    data.frame(db=list.db, genedata=list.genedata)
}


