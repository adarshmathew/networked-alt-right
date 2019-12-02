library(tidyverse)
library(sparklyr)

c_spark <- spark_connect(master = "local")

xx_rep <- read_rds("data/The_Donald-2016-11-08-2019-11-08.gz")
View(xx_rep)

colnames(xx_rep)
nrow(xx_rep)
