library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)

thous <- 10^(3) 
mil <- 10^(6)

## 전국태양광발전소전기사업허가정보표준데이터-20240628.xlsx

rawData <- readxl::read_excel("../data/전국태양광발전소전기사업허가정보표준데이터-20240813.xlsx", sheet = '데이터', skip = 0, col_names = T) ## 전국: 50,000개

rawData_prc <- rawData %>%
  mutate(설비용량 = as.numeric(설비용량),
         설치면적 = as.numeric(설치면적)) %>%
  filter(!is.na(설치면적),
          !is.na(설비용량)) %>%
  select(소재지도로명주소, 소재지지번주소, 설치상세위치구분명, 설비용량, 설치면적)


PV_status <- rawData_prc %>%
  filter(설치상세위치구분명 == "옥외")

sum(PV_status$설치면적) / sum(PV_status$설비용량)



rftp_PV_status <- rawData_prc %>%
  filter(설치상세위치구분명 == "옥상")

sum(OutPV_status$설치면적) / sum(OutPV_status$설비용량)


###  경기도 ###
rawData_GG <- rawData %>%
  mutate(설비용량 = as.numeric(설비용량),
         설치면적 = as.numeric(설치면적)) %>%
  filter(!is.na(설치상세위치구분명)) %>%
  filter(grepl("경기", 소재지도로명주소) | grepl("경기", 소재지지번주소)) %>%
  filter(!is.na(설치면적))
  
rftp_PV_status <- rawData_GG %>%
  select(소재지도로명주소, 설치상세위치구분명, 설비용량, 설치면적) %>%
  mutate(coef = 설치면적 / 설비용량) %>%
  filter(coef > 1 & coef < 100,
         설치면적 <= 5000)          # total: 636개, median: 318번row


rftp_PV_status_totalCapacity <- sum(rftp_PV_status$설비용량)
rftp_PV_status_totalArea <- sum(rftp_PV_status$설치면적)


log10_rftp_PV_status_totalCapacity <- sum(log10(rftp_PV_status$설비용량))
log10_rftp_PV_status_totalArea <- sum(log10(rftp_PV_status$설치면적))
log10_rftp_PV_status_totalArea/log10_rftp_PV_status_totalCapacity


ggplot(data = rftp_PV_status, aes(x =  설비용량, y = 설치면적)) +
  geom_point(size = 2) +
  geom_abline(slope = 1.4260, intercept = 0, linetype = 2) +
  scale_x_continuous(trans = 'log10') +
  scale_y_continuous(trans = 'log10')
  

















