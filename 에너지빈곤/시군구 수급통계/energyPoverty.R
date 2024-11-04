library(dplyr)
library(readxl)
library(tidyr)
library(stringr)
library(ggplot2)

SGG_EB_column_names <- c("sector",
                         "TotalofPetroleum", 
                         "EnergyUse", "Gasoline", "Kerosene", "DieselOil", "B-A", "B-B", "B-C", "JA-1", "AVI-G", "LPG", "Propane", "Butane", 
                         "Non-EnergyUse", "Naphtha", "Solvent", "Asphalt", "Lubricant", "Paraffin-Wax", "PetroleumCoke", "OtherProducts", 
                         "Gas", "Electricity", "Heat", "RenewablesOthers", "Total",
                         "year")

SGG_EB_wanted_energyType <- c("TotalofPetroleum", "Gas", "Electricity", "Heat", "RenewablesOthers")


year <- 2022

fileName <- paste0('./2022_시군구_에너지수급통계', ".xlsx")
test <- readxl::read_excel(fileName,
                           #sheet = SGG_EB_sheet_names[i],
                           sheet = '경기가평군',
                           col_names = F,
                           range = "A24:AA26") %>%
  mutate(year = year)

colnames(test) <- SGG_EB_column_names
mutate(year = year)



## Import Function
import_SGG_EB <- function (year) {
  
  fileName <- paste0('[RawData]HistoricalEnergy/SGG_demandsupply_', year, ".xlsx")
  readxl::read_excel(fileName,
                     sheet = SGG_EB_sheet_names[i],
                     col_names = F,
                     range = "A22:AA26") %>%
    mutate(year = year)
  
}