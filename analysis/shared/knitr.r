options(knitr.project_name = "Zeitgeist")

figure_path <- function(filename="") {
  file.path(getOption("knitr.figure_dir"), filename)
}

# Default xtable output
options(xtable.type = 'html')

# Output HTML table (requires xtable package)
html_table <- function(df, digits=2, row.names=FALSE, col.names=TRUE) {
  if(class(df)[1] != "xtable") df <- xtable(df)
  digits(df) <- digits
  print(df, include.rownames=row.names, include.colnames=col.names)
}

# Format number with commas
pn <- function(i, ...) {
  prettyNum(i, big.mark=",", ...)
}

# Wrap output and code
options(width=100)

# Force knitr to stop evaluation when an error is encountered
knitr::opts_chunk$set(error=FALSE)

# Show code blocks by default
knitr::opts_chunk$set(echo=TRUE)

# No comment character in front of R output
knitr::opts_chunk$set(comment=NA)

# Don't reformat R code
knitr::opts_chunk$set(tidy=FALSE)

# Set up figure defaults 
knitr::opts_chunk$set(fig.width=7, fig.height=5, fig.path=figure_path())

# Create output directory if it doesn't exist
if(!file.exists(getOption("knitr.figure_dir"))) dir.create(getOption("knitr.figure_dir"))

source("shared/caching.r")
source("shared/parallel.r")
