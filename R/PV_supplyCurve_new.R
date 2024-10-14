library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)
library(tidyverse)
#library(ggmacc)


## Setback Regulation 없는 지역은, setback 있을때랑 없을때 data를 똑같게 만듬.
##  포천시 산지, 동두천시 산지

exRate <- 1300
thous <- 10^(3) 
mil <- 10^(6)
SGG_order <- c("수원시", "용인시", "성남시", "부천시", "화성시", "안산시", "안양시", "평택시", "시흥시", "김포시",
               "광주시", "광명시", "군포시", "하남시", "오산시", "이천시", "안성시", "의왕시", "양평군", "여주시",
               "과천시", "고양시", "남양주시", "파주시", "의정부시", "양주시", "구리시", "포천시", "동두천시", "가평군",
               "연천군")
SGG_order_W_SN <- c("수원시", "용인시", "성남시", "부천시", "화성시", "안산시", "안양시", "평택시", "시흥시", "김포시",
                    "광주시", "광명시", "군포시", "하남시", "오산시", "이천시", "안성시", "의왕시", "양평군", "여주시", "과천시", "경기남부",
                    "고양시", "남양주시", "파주시", "의정부시", "양주시", "구리시", "포천시", "동두천시", "가평군", "연천군", "경기북부", "전체" )

SGG_South <- c("수원시", "용인시", "성남시", "부천시", "화성시", "안산시", "안양시", "평택시", "시흥시", "김포시",
               "광주시", "광명시", "군포시", "하남시", "오산시", "이천시", "안성시", "의왕시", "양평군", "여주시",
               "과천시")

SGG_North <- c("고양시", "남양주시", "파주시", "의정부시", "양주시", "구리시", "포천시", "동두천시", "가평군",
               "연천군")


## makeFullname ##
makeFullname <- function(data) {
  
  target <- data %>%
    mutate(SiGun = case_when(
      
      SiGun == "가평" ~ "가평군",
      SiGun == "고양" ~ "고양시",
      SiGun == "과천" ~ "과천시",
      SiGun == "광명" ~ "광명시",
      SiGun == "광주" ~ "광주시",
      SiGun == "구리" ~ "구리시",
      SiGun == "군포" ~ "군포시",
      SiGun == "김포" ~ "김포시",
      SiGun == "남양주" ~ "남양주시",
      SiGun == "동두천" ~ "동두천시",
      SiGun == "부천" ~ "부천시",
      SiGun == "성남" ~ "성남시",
      SiGun == "수원" ~ "수원시",
      SiGun == "시흥" ~ "시흥시",
      SiGun == "안산" ~ "안산시",
      SiGun == "안양" ~ "안양시",
      SiGun == "양주" ~ "양주시",
      SiGun == "양평" ~ "양평군",
      SiGun == "여주" ~ "여주시",
      SiGun == "연천" ~ "연천군",
      SiGun == "오산" ~ "오산시",
      SiGun == "용인" ~ "용인시",
      SiGun == "의왕" ~ "의왕시",
      SiGun == "의정부" ~ "의정부시",
      SiGun == "이천" ~ "이천시",
      SiGun == "파주" ~ "파주시",
      SiGun == "평택" ~ "평택시",
      SiGun == "포천" ~ "포천시",
      SiGun == "하남" ~ "하남시",
      SiGun == "화성" ~ "화성시",
      SiGun == "안성" ~ "안성시",
      
      TRUE ~ SiGun
      
    ))
  
  return(target)
  
}


orderSGG_Wtotal <- function(data) {
  
  targetData <- data %>%
    arrange(factor(시군, levels = SGG_order_W_SN))
  
  return(targetData)
  
}

writeExcel <- function(fileName, dataName, Name) {
  
  wb <- loadWorkbook(fileName)
  addWorksheet(wb, Name)
  writeData(wb, Name, dataName)
  saveWorkbook(wb, fileName, overwrite = TRUE)
  
  
}


TypeToEng <- function(data) {
  
  engData <- data %>%
    mutate(LandType = case_when(
      
      LandType == "산업단지" ~ "Industrial complex",
      LandType == "물류단지" ~ "Logistics complex",
      LandType == "공동주택" ~ "Residential complex",
      LandType == "공공건축물" ~ "Public buildings",
      LandType == "산지" ~ "Mountainous area",
      LandType == "농지" ~ "Farmland",
      LandType == "주차장" ~ "Parking lot",
      LandType == "도로유휴부지" ~ "Roadside land",
      LandType == "육상정수역" ~ "Water"
      
    )) %>%
    mutate(LandType = factor(LandType, levels = c("Industrial complex", "Logistics complex", "Residential complex", "Public buildings",
                                         "Mountainous area", "Farmland", "Parking lot", "Roadside land", "Water"))) %>%

  
  return(engData)
  
}



## 필요면적: m2/kW, 시나리오:
rawData_prm <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "parameter", col_names = T, skip = 1) 


## capacity factor (%) ##
rawData_cf <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "CF", col_names = T, skip = 1) 

cf_bySGG <- rawData_cf %>%
  group_by(SiGun) %>% summarize(CapacityFactor = mean(CapacityFactor)) %>% ungroup() %>%
  mutate(CapacityFactor = round(CapacityFactor, digit = 2),
         CapacityFactor = CapacityFactor / 100,
         Units = 'ratio')
cf_avg <- mean(cf_bySGG$CapacityFactor)


## Area (m2) ##
LandList <- excel_sheets("../data/totalData_individual.xlsx")[!excel_sheets("../data/totalData_individual.xlsx") %in% c("LCOE_byTech","LCOE_bySGGTech","parameter", "CF", "setbackRegion")]


getFullData <- function() {
  
  FullData <- c()
  for ( i in 1:length(LandList)) {
    
    eachData <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = LandList[i], col_names = T)
    
    eachData <- eachData %>%
      mutate(Scenario = case_when(
        
        grepl("이격거리규제없음", LandList[i]) ~ "No setbacks",
        TRUE ~ "Setbacks"
        
      )) %>%
      mutate(Gu = case_when(
        
        SiGun == "부천시" ~ NA,
        TRUE ~ Gu
        
      ))
    
    FullData <- FullData %>% 
      bind_rows(eachData) %>%
      makeFullname()
    
  }
  
  return(FullData)
}

rawData_full <- getFullData()
rawData_full <- rawData_full %>%
  mutate(LandType = case_when(
    
    LandType %in% c("공동주택아파트", "공동주택다세대연립") ~ "공동주택",
    TRUE ~ LandType
    
  ))


###### 농지 Area Data Import ###### Start

#guess_encoding("../data/농지/경기도_시군구_코드.csv")
#guess_encoding("../data/농지/농지_이격거리미적용_시군구.csv")
#GG_SGG_code <- read_csv("../data/농지/경기도_시군구_코드.csv",  col_names = T, locale = locale(encoding = "EUC-KR"))
GG_SGG_code <- read_csv("../data/농지/SGG_code.csv",  col_names = T, locale = locale(encoding = "EUC-KR"))
rawData_AgriArea_NoSB <- read_csv("../data/농지/농지_이격거리미적용_시군구.csv",  col_names = T)
rawData_AgriArea_YesSB <- read_csv("../data/농지/농지_이격거리적용_시군구.csv",  col_names = T)

AgriArea_NoSB <- rawData_AgriArea_NoSB %>%
  select(rearea_02, ADM_SECT_C) %>%
  mutate(Scenario = "No setbacks")


AgriArea_YesSB <- rawData_AgriArea_YesSB %>%
  select(rearea_02, ADM_SECT_C) %>%
  mutate(Scenario = "Setbacks")

AgriArea <- AgriArea_NoSB %>%
  bind_rows(AgriArea_YesSB) 

# trmd: trimmed
AgriArea_trmd <- AgriArea %>%
  left_join(GG_SGG_code, by = c("ADM_SECT_C" = "구_code")) %>%
  mutate(LandType = '농지',
         Technology = 'grdmtd_PV',
         ID = c(1:nrow(.))) %>%
  rename(Area = rearea_02,
         SiGun = 시군,
         Gu = 구) %>%
  select(LandType, Technology, ID, SiGun, Gu, Area, Scenario) %>%
  mutate(Gu = case_when(
    
    SiGun == "부천시" ~ NA,
    TRUE ~ Gu
    
  ))


###### 농지 Area Data Import ###### End

rawData_full <- rawData_full %>%
  bind_rows(AgriArea_trmd)

rawData_fullpower <- rawData_full %>%
  left_join(rawData_prm, by = c("LandType")) %>%
  left_join(cf_bySGG, by = c("SiGun")) %>%
  mutate(Capacity = Area / DensityFactor * c(AreaFactor / 100),
         Generation = Capacity * CapacityFactor * 8760) %>%
  select(-DensityFactor, -AreaFactor, -CapacityFactor, -Units)
  


## LCOE by technology (원/kWh) ##
rawData_LCOE_byTech <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "LCOE_byTech", col_names = T, skip = 1)

rawData_LCOE_bySGGTech <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "LCOE_bySGGTech", col_names = T) %>%
  gather(-SiGun, -Gu, -Units, key = Technology, value = LCOE)

rawData_LCOE_bySGGTech_avg <- rawData_LCOE_bySGGTech %>%
  group_by(SiGun, Technology, Units) %>% summarize(LCOE = mean(LCOE)) %>% ungroup()

## 모든 부지 (주차장 제외)에 LCOE join ##
rawData_fullpower_wLCOE_woParking <- rawData_fullpower %>%
  filter(LandType != "주차장") %>%
  left_join(rawData_LCOE_bySGGTech, by = c("SiGun", "Gu", "Technology")) %>%
  select(-Units) %>%
  
  ## 육상정수역은 수상태양광 LCOE 값 하나로 모두 통일.
  mutate(LCOE = case_when(
    
    LandType == "육상정수역" ~ rawData_LCOE_byTech %>% filter(Technology == 'flt_PV') %>% pull(LCOE),
    TRUE ~ LCOE
    
  ))

## 주차장 부지에 LCOE join ##
rawData_fullpower_wLCOE_Parking <- rawData_fullpower %>%
  filter(LandType == "주차장") %>%
  left_join(rawData_LCOE_bySGGTech_avg, by = c("SiGun", "Technology")) %>%
  select(-Units)


rawData_fullpower_wLCOE <- rawData_fullpower_wLCOE_woParking %>%
  bind_rows(rawData_fullpower_wLCOE_Parking)
  
setbackRegion <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "setbackRegion", col_names = T, skip = 0)

totalData <- rawData_fullpower_wLCOE %>%
  mutate(TC = Generation * LCOE) %>%
  mutate(avgLCOE = TC/Generation) %>%
  mutate(Area = Area/10^(6), # m2 to km2
         Capacity = Capacity/10^(6), # kW to GW
         Generation = Generation / 10^(9),   # kWh to TWh
         TC = TC / exRate / 10^(6),  # Won to Mil.USD
         avgLCOE = avgLCOE / exRate) %>% # Won to USD
  mutate(setbackRegion = case_when(
    
    SiGun %in% setbackRegion$setbackRegion ~ 'setbackRegion',
    TRUE ~ 'No setbackRegion'
    
  ))


######## Clear Data Set end ######## 


### How would many capacity be reduced by setback regulation? ### by SiGunGu
rawData_fullpower_forTable_bySGG <- totalData %>%
  group_by(SiGun, LandType, Scenario) %>% 
  summarize(Area = sum(Area),
            Capacity = sum(Capacity),
            Generation = sum(Generation),
            TC = sum(TC)) %>% ungroup()

rawData_fullpower_forTable_bySGG_NoSB <- rawData_fullpower_forTable_bySGG %>%
  filter(Scenario == "No setbacks")


rawData_fullpower_forTable_bySGG_YesSB <- rawData_fullpower_forTable_bySGG %>%
  filter(Scenario == "Setbacks")


graphData <- rawData_fullpower_forTable_bySGG_NoSB %>%
  left_join(rawData_fullpower_forTable_bySGG_YesSB, by = c("SiGun", "LandType")) %>%
  mutate(diff_SCN = Capacity.x - Capacity.y) %>%
  select(SiGun, LandType, diff_SCN)

  


ggplot(data = graphData, aes(x =  SiGun, y = diff_SCN, fill = LandType)) +
  geom_bar(stat='identity') +
  #facet_wrap(~variable, scales = 'free') +
  theme(legend.position = "right",
        #axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1),
        text = element_text(size = 40))








### Making Summary Table ### by LandType
rawData_fullpower_forTable_byLandType <- totalData %>%
  group_by(LandType, Scenario) %>% 
  summarize(Area = sum(Area),
            Capacity = sum(Capacity),
            Generation = sum(Generation),
            TC = sum(TC)) %>% ungroup()
  

##### Draw total graph fill by Land ##### Fig1.
graphData <- rawData_fullpower_forTable_byLandType %>%
  select(-TC) %>%
  gather(key = variable, value = value, -LandType, -Scenario) %>%
  TypeToEng()

ggplot(data = graphData %>% mutate(variable = factor(variable, levels = c("Area", "Capacity", "Generation"))), aes(x =  Scenario, y = value, fill = LandType)) +
  geom_bar(stat='identity') +
  facet_wrap(~variable, scales = 'free') +
  theme(legend.position = "right",
        #axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1),
        text = element_text(size = 40))


graphData_gen <- graphData %>%
  filter(variable == 'Generation')

ggplot(data = graphData_gen, aes(x =  Scenario, y = value, fill = LandType)) +
  geom_bar(stat='identity') +
  facet_wrap(~LandType, scales = 'free', nrow = 2) +
  theme(legend.position = "right",
        #axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1),
        text = element_text(size = 40))

graphData_gen %>%
  spread(key = Scenario, value = value) %>%
  mutate(reducRate = 100 * c(`No setbacks` - `Setbacks`) / `No setbacks`)


### Making Summary Table ### by Total
rawData_fullpower_wLCOE_forTable_byTotal <- rawData_fullpower_forTable_byLandType %>%
  group_by(Scenario) %>% 
  summarize(Area = sum(Area),
            Capacity = sum(Capacity),
            Generation = sum(Generation),
            TC = sum(TC)) %>% ungroup() %>%
  mutate(avgLCOE = TC / Generation) %>%
  mutate(LandType = '전체', .before = Scenario)

rawData_fullpower_wLCOE_forTable <- rawData_fullpower_forTable_byLandType %>%
  bind_rows(rawData_fullpower_wLCOE_forTable_byTotal)


summary_byLandType_forTable_NoSB <- rawData_fullpower_wLCOE_forTable %>%
  filter(이격거리 =="N")

summary_byLandType_forTable_YesSB <- rawData_fullpower_wLCOE_forTable %>%
  filter(이격거리 =="Y")

###########################################



## percent Matrix (LandType * SiGun)
test <- totalData %>%
  filter(Scenario == 'No setbacks') %>%
  group_by(LandType, SiGun, setbackRegion) %>% summarize(Generation = sum(Generation)) %>% ungroup() %>%
  group_by(setbackRegion) %>% mutate(share = 100 * Generation / sum(Generation)) %>% ungroup()




test <- totalData %>%
  filter(Scenario == 'No setbacks') %>%
  group_by(LandType, SiGun) %>% summarize(Generation = sum(Generation)) %>%
  mutate(setbackRegion = case_when(
    
    SiGun %in% setbackRegion$setbackRegion ~ 'setbackRegion',
    TRUE ~ 'No setbackRegion'
    
  )) %>% ungroup() %>%
  mutate(share = 100 * Generation / sum(Generation)) %>%
  select(-Generation) %>%
  spread( key = LandType, value = share)










# 면적: km2, 발전용량: GW, 발전량: TWh, TC: Milion USD, avgLCOE: USD/kWh
finalSummary_byLandType_forTable <- summary_byLandType_forTable_NoSB %>%
  left_join(summary_byLandType_forTable_YesSB, by = c("유형")) %>%
  mutate(면적_diff = 면적.y - 면적.x,
         면적_diffR = 100 * c(면적_diff / 면적.x),
         
         발전용량_diff = 발전용량.y - 발전용량.x,
         발전용량_diffR = 100 * c(발전용량_diff / 발전용량.x),
         
         발전량_diff = 발전량.y - 발전량.x,
         발전량_diffR = 100 * c(발전량_diff / 발전량.x),
         
         TC_diff = TC.y - TC.x,
         TC_diffR = 100 * c(TC_diff / TC.x),
         
         avgLCOE_diff = avgLCOE.y - avgLCOE.x,
         avgLCOE_diffR = 100 * c(avgLCOE_diff / avgLCOE.x)) %>%
  select(유형, 
         면적.x, 면적.y, 면적_diff, 면적_diffR, 
         발전용량.x, 발전용량.y, 발전용량_diff, 발전용량_diffR,
         발전량.x, 발전량.y, 발전량_diff, 발전량_diffR,
         TC.x, TC.y, TC_diff, TC_diffR,
         avgLCOE.x, avgLCOE.y, avgLCOE_diff, avgLCOE_diffR) %>%
  arrange(발전용량.x)




  







rawData_fullpower_wLCOE_ordered_YesSB <- totalData %>%
  arrange(desc(발전량)) %>%
  arrange(LCOE) %>%
  filter(이격거리 == "Y") %>%
  filter(유형 != '육상정수역')


rawData_fullpower_wLCOE_ordered_NoSB <- totalData %>%
  arrange(desc(발전량)) %>%
  arrange(LCOE) %>%
  filter(이격거리 == "N") %>%
  filter(유형 != '육상정수역')


### 전체 ###
testGraph_YesSB <- rawData_fullpower_wLCOE_ordered_YesSB %>%
  mutate(x1 = lag(cumsum(발전량)),
         x2 = cumsum(발전량),
         y1 = 0,
         y2 = LCOE) %>%
  mutate(x1 = case_when(
    
    is.na(x1) ~ 0,
    TRUE ~ x1
    
  ))

testGraph_NoSB <- rawData_fullpower_wLCOE_ordered_NoSB %>%
  mutate(x1 = lag(cumsum(발전량)),
         x2 = cumsum(발전량),
         y1 = 0,
         y2 = LCOE) %>%
  mutate(x1 = case_when(
    
    is.na(x1) ~ 0,
    TRUE ~ x1
    
  ))

ggplot() + 
  scale_x_continuous(name="x") + 
  scale_y_continuous(name="y") +
  geom_rect(data=testGraph_YesSB, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=유형), alpha=0.5, linewidth = 0.1) +
  geom_rect(data=testGraph_NoSB, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=유형), alpha=0.5, linewidth = 0.1)
#facet_wrap(~유형)
#geom_text(data=tt, aes(x=x1+(x2-x1)/2, y=y1+(y2-y1)/2, label=r), size=4)
#opts(title="geom_rect", plot.title=theme_text(size=40, vjust=1.5))


### 유형별 ###
rawData_fullpower_wLCOE_ordered_indType <- rawData_fullpower_wLCOE_ordered %>%
  filter(유형 == "산업단지")

testGraph <- rawData_fullpower_wLCOE_ordered_indType %>%
  mutate(x1 = lag(cumsum(발전량)),
         x2 = cumsum(발전량),
         y1 = 0,
         y2 = LCOE) %>%
  mutate(x1 = case_when(
    
    is.na(x1) ~ 0,
    TRUE ~ x1
    
  ))

ggplot() + 
  scale_x_continuous(name="x") + 
  scale_y_continuous(name="y") +
  geom_rect(data=testGraph, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=유형), alpha=0.5, linewidth = 0.1)


ggplot(data = testGraph, aes(x = x2,, y = y2)) +
  geom_point() +
  geom_path()



############# 유형별로 그려보기기 ############# 

ind_tt_graph <- supplyCurve_test_order %>%
  filter(유형 == "산업단지") %>%
  mutate(x1 = lag(cumsum(발전량)),
         x2 = cumsum(발전량),
         y1 = 0,
         y2 = LCOE) %>%
  mutate(x1 = case_when(
    
    is.na(x1) ~ 0,
    TRUE ~ x1
    
  ))

  
  

ggplot() + 
  scale_x_continuous(name="x") + 
  scale_y_continuous(name="y") +
  geom_rect(data=ind_tt_graph, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=유형), alpha=0.5, linetype = 1)



tt %>%
  



##### 농지 data import #####
rawData_AgriArea <- read.csv("../data/농지/농지_이격거리미적용_시군구.csv",  header = T)
rawData_AgriArea <- read.csv("../data/농지/농지_이격거리미적용_시군구.csv",  header = T, fileEncoding="UTF-8")
































draw_supplyCurve_test <- supplyCurve_test %>%
  ggmacc(abatement = 발전량, mac = LCOE, fill = 유형, cost_threshold = 100,
         zero_line = TRUE, threshold_line = TRUE, threshold_fade = 0.3)






social_cost_of_carbon <- 66.1

full_macc <- uk_agroforestry %>%
  ggmacc(abatement = co2_tyear, mac = mac_gbp_tco2, fill = crop, cost_threshold = social_cost_of_carbon,
         zero_line = TRUE, threshold_line = TRUE, threshold_fade = 0.3)

full_macc







test_A <- test %>%
  filter(이격거리 == 'N') %>%
  mutate(유형_ID = paste0(유형, ID)) %>%
  filter(유형 != '육상정수역')


ggplot(test_A, aes(x = 유형_ID, y = 면적)) + 
  geom_point()
#geom_hline(yintercept = 2.65, linetype = 'dashed', colour = 'gray', linewidth = 1.5) +
theme(text = element_text(size = 110),
      axis.text.x = element_text(angle = 90),
      legend.position = 'right',
      axis.title.x = element_blank(),
      axis.title.y = element_blank())
  
test_B <- test_A %>%
  filter(유형 == '공공건축물',
         ID <= 3)


ggplot(test_B, aes(x = 유형_ID, y = 면적, width = 발전량/100000), binwidth = 10) + 
  geom_bar(stat = 'identity', position = 'dodge') +
  facet_grid(~유형)
  #geom_hline(yintercept = 2.65, linetype = 'dashed', colour = 'gray', linewidth = 1.5) +
  theme(text = element_text(size = 110),
        axis.text.x = element_text(angle = 90),
        legend.position = 'right',
        axis.title.x = element_blank(),
        axis.title.y = element_blank())



  


# FullData <- rawData_full %>%
#   left_join(rawData_prm, by = c("유형_full")) %>% relocate(ID) %>%
#   gather(-ID, -유형_full, -유형1, -유형2, -유형3, -유형4, -유형5, -유형6, -이격유형, -지역, -면적, -단위, -필요면적, key = 시나리오, value = 설치면적비중) %>%
#   left_join(cf_bySGG, by = "지역") %>% select(-Units) %>%
#   mutate(설비용량 = 면적 * c(설치면적비중 / 100) / 필요면적 / mil,
#          연발전량 = 설비용량 * 이용률 * 365 * 24) %>%
#   select(-필요면적, -단위, -설치면적비중, -이용률)
# 
# FullData_wSNT <- AddSthNth(FullData)
# 
# FullData_wSNT_Capa <- FullData_wSNT %>%
#   select(ID, 유형_full, 유형1, 유형2, 유형3, 유형4, 유형5, 유형6, 이격유형, 지역, 면적, 시나리오, "설비용량") %>%
#   spread(key = 시나리오, value = "설비용량")
# 
# FullData_wSNT_Gen <- FullData_wSNT %>%
#   select(ID, 유형_full, 유형1, 유형2, 유형3, 유형4, 유형5, 유형6, 이격유형, 지역, 면적, 시나리오, "연발전량") %>%
#   spread(key = 시나리오, value = "연발전량")
# 
# 
# PickWritedata <- function(IDs) {
#   
#   pickData_Capa <- FullData_wSNT_Capa %>%
#     filter(ID %in% IDs) %>%
#     orderSGG_Wtotal()
#   
#   pickData_Gen <- FullData_wSNT_Gen %>%
#     filter(ID %in% IDs) %>%
#     orderSGG_Wtotal()
#   
#   writeExcel("ReportTable.xlsx", pickData_Capa, "용량(GW)")
#   writeExcel("ReportTable.xlsx", pickData_Gen, "발전전량(GW)")
#   
# }
# 
# PickWritedata(c("1","10", "21", "22", "31", "72", "59", "60"))
# 

