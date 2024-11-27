library(foreign)
library(readstata13)

# 장애인설문용데이터
aa <- read.dta13("../data/koweps_da18_2023_beta1.dta")


# 가구용데이터
bb <- read.dta13("../data/koweps_h18_2023_beta1.dta")


# 가구용, 가구원용, 장애인설문용 머지데이터
cc <- read.dta13("../data/koweps_hpda18_2023_beta1.dta")


# 가구원용데이터
dd <- read.dta13("../data/koweps_p18_2023_beta1.dta")

