library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)
library(tidyverse)
#library(ggmacc)



exRate <- 1300
thous <- 10^(3) 
mil <- 10^(6)
emisCoef_Gen <- 0.4434 # (tCO2/MWh)  = (MtCO2/TWh)


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



## SiGun: SGG_to_Eng ##
SGG_to_Eng <- function(data) {
  
  target <- data %>%
    mutate(SiGun = case_when(
      
      SiGun == "가평군" ~ "Gapyeong",
      SiGun == "고양시" ~ "Goyang",
      SiGun == "과천시" ~ "Gwacheon",
      SiGun == "광명시" ~ "Gwangmyeong",
      SiGun == "광주시" ~ "Gwangju",
      SiGun == "구리시" ~ "Guri",
      SiGun == "군포시" ~ "Gunpo",
      SiGun == "김포시" ~ "Gimpo",
      SiGun == "남양주시" ~ "Namyangju",
      SiGun == "동두천시" ~ "Dongducheon",
      SiGun == "부천시" ~ "Bucheon",
      SiGun == "성남시" ~ "Seongnam",
      SiGun == "수원시" ~ "Suwon",
      SiGun == "시흥시" ~ "Siheung",
      SiGun == "안산시" ~ "Ansan",
      SiGun == "안양시" ~ "Anyang",
      SiGun == "양주시" ~ "Yangju",
      SiGun == "양평군" ~ "Yangpyeong",
      SiGun == "여주시" ~ "Yeoju",
      SiGun == "연천군" ~ "Yeoncheon",
      SiGun == "오산시" ~ "Osan",
      SiGun == "용인시" ~ "Yongin",
      SiGun == "의왕시" ~ "Uiwang",
      SiGun == "의정부시" ~ "Uijeongbu",
      SiGun == "이천시" ~ "Icheon",
      SiGun == "파주시" ~ "Paju",
      SiGun == "평택시" ~ "Pyeongtaek",
      SiGun == "포천시" ~ "Pocheon",
      SiGun == "하남시" ~ "Hanam",
      SiGun == "화성시" ~ "Hwaseong",
      SiGun == "안성시" ~ "Anseong",
      
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
      
      # LandType == "산업단지" ~ "Industrial complex",
      # LandType == "물류단지" ~ "Logistics complex",
      # LandType == "공동주택" ~ "Residential complex",
      # LandType == "공공건축물" ~ "Public buildings",
      # LandType == "산지" ~ "Mountainous area",
      # LandType == "농지" ~ "Farmland",
      # LandType == "주차장" ~ "Parking lot",
      # LandType == "도로유휴부지" ~ "Roadside land",
      # LandType == "육상정수역" ~ "Water"
      
      LandType == "산업단지" ~ "Industrial",
      LandType == "물류단지" ~ "Logistics",
      LandType == "공동주택" ~ "Residential",
      LandType == "공공건축물" ~ "Public",
      LandType == "산지" ~ "Mountain",
      LandType == "농지" ~ "Farmland",
      LandType == "주차장" ~ "Parking",
      LandType == "도로유휴부지" ~ "Roadside",
      LandType == "육상정수역" ~ "Water"
      
    )) %>%
    mutate(LandType = factor(LandType, levels = c("Water", "Parking", "Roadside", "Mountain", "Farmland",
                                                  "Public", "Logistics", "Industrial", "Residential")))

  
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
        
        grepl("이격거리규제없음", LandList[i]) ~ "No Setback",
        TRUE ~ "Current Setback"
        
      )) %>%
      
      # KEEI의 LCOE 데이터에서는 부천시가 '구'까지 안나와 있고, 부천시 통으로 되어 있음
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
  mutate(Scenario = "No Setback")


AgriArea_YesSB <- rawData_AgriArea_YesSB %>%
  select(rearea_02, ADM_SECT_C) %>%
  mutate(Scenario = "Current Setback")

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

rawData_full <- rawData_full %>%
  bind_rows(AgriArea_trmd)
###### 농지 Area Data Import ###### End






###### 면적(Area)에 관한 fullData에 capacity, generation을 계산  ###### 

rawData_fullpower <- rawData_full %>%
  left_join(rawData_prm, by = c("LandType")) %>%
  left_join(cf_bySGG, by = c("SiGun")) %>%
  mutate(Capacity = Area / DensityFactor * c(AreaFactor / 100),
         Generation = Capacity * CapacityFactor * 8760) %>%
  select(-DensityFactor, -AreaFactor, -CapacityFactor, -Units)
  


###### Area, Capacity, Generation Data에 LCOE 정보를 추가적으로 붙임  ######
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

## 주차장 부지에 LCOE join ## 주차장은 '구' 에 대한 정보가 없어서, '구' 가 있는 '시'의 경우 '구'들의 평균값을 '시'의 대표 값으로 설정
rawData_fullpower_wLCOE_Parking <- rawData_fullpower %>%
  filter(LandType == "주차장") %>%
  left_join(rawData_LCOE_bySGGTech_avg, by = c("SiGun", "Technology")) %>%
  select(-Units)


rawData_fullpower_wLCOE <- rawData_fullpower_wLCOE_woParking %>%
  bind_rows(rawData_fullpower_wLCOE_Parking)




## [totalData] 를 만듬
##### 31개 시군 중에 setback 규제가 있는 지역이 12개 있는데, 해당 지역을 표시 해줌.
##### TC(Total cost)를 LCOE * Generation으로 정의 및 계산
##### 각 변수별로 단위 정리 해줌.
setbackRegion <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "setbackRegion", col_names = T, skip = 0)

totalData <- rawData_fullpower_wLCOE %>%
  mutate(TC = Generation * LCOE) %>%
  mutate(avgLCOE = TC/Generation) %>%
  mutate(Area = Area/10^(6), # m2 to km2
         Capacity = Capacity/10^(6), # kW to GW
         Generation = Generation / 10^(9),   # kWh to TWh
         LCOE = LCOE / exRate,  # Won to USD
         TC = TC / exRate / 10^(6),  # Won to Mil.USD
         avgLCOE = avgLCOE / exRate) %>% # Won to USD
  mutate(setbackRegion = case_when(
    
    SiGun %in% setbackRegion$setbackRegion ~ 'setbackRegion',
    TRUE ~ 'No setbackRegion'
    
  ))



##[totalData_woID_mnpt]를 만듬: 시군별로 합쳐진 data이며, 아래의 내용과 같이 maniumpate(mnpt)한 데이터임.
#### Data Manipulation due to mismatch GIS data ######## 
#### Setback을 적용 시키고 난 후에 오히려 면적이 더 커지는 경우는 아래와 같이 처리함. #####
###### Setback Regulation 없는 지역은, setback 있을때의 수치를, setback 없을때 data와 똑같게 만듬.
###### Setback이 있는 지역 중에 Setback 적용 이후의 면적이 더 큰 경우는 setback 있을때의 수치를, setback 없을때 data와 똑같게 만듬.(포천시 산지, 동두천시 산지)
###### Setback이 있는 지역 중에 Setback 적용 이후의 면적이 작은 경우(정상적인 경우), setback 있을때의 수치를, setback 있을때와 같게 만듬. (정상적인 현상)
###### 위의 과정은 개별부지(ID가 붙어 있는 data)에 대해서는 적용할 수 없고, 시군별로 합쳐진 데이터에 대해서만 실행할 수 있음. 왜냐면 각 부지의 ID별로 setback / No setback 변화된 수치를 알 수 없기 때문.


totalData_woID <- totalData %>%
  group_by(LandType, Technology, SiGun, Scenario, setbackRegion) %>%
  summarize(Area = sum(Area),
            Capacity = sum(Capacity),
            Generation = sum(Generation),
            TC = sum(TC)) %>% ungroup()

  

totalData_woID_YesSB <- totalData_woID %>%
  filter(Scenario =='Current Setback')

totalData_woID_NoSB <- totalData_woID %>%
  filter(Scenario =='No Setback')

totalData_woID_YesSB_NoSB <-  totalData_woID_NoSB %>%
  left_join(totalData_woID_YesSB, by = c("LandType", "Technology", "SiGun"))



totalData_woID_temp <- totalData_woID_YesSB_NoSB %>%
  mutate(Area.y = case_when(
    
    Scenario.y == 'Current Setback' & setbackRegion.y == 'No setbackRegion' ~ Area.x,
    Scenario.y == 'Current Setback' & setbackRegion.y == 'setbackRegion' & Area.y > Area.x ~ Area.x,
    Scenario.y == 'Current Setback' & setbackRegion.y == 'setbackRegion' & Area.y <= Area.x ~ Area.y,
    TRUE ~ 0
    
  )) %>%
  mutate(Capacity.y = case_when(
    
    Scenario.y == 'Current Setback' & setbackRegion.y == 'No setbackRegion' ~ Capacity.x,
    Scenario.y == 'Current Setback' & setbackRegion.y == 'setbackRegion' & Capacity.y > Capacity.x ~ Capacity.x,
    Scenario.y == 'Current Setback' & setbackRegion.y == 'setbackRegion' & Capacity.y <= Capacity.x ~ Capacity.y,
    TRUE ~ 0
    
  )) %>%
  mutate(Generation.y = case_when(
    
    Scenario.y == 'Current Setback' & setbackRegion.y == 'No setbackRegion' ~ Generation.x,
    Scenario.y == 'Current Setback' & setbackRegion.y == 'setbackRegion' & Generation.y > Generation.x ~ Generation.x,
    Scenario.y == 'Current Setback' & setbackRegion.y == 'setbackRegion' & Generation.y <= Generation.x ~ Generation.y,
    TRUE ~ 0
    
  )) %>%
  mutate(TC.y = case_when(
    
    Scenario.y == 'Current Setback' & setbackRegion.y == 'No setbackRegion' ~ TC.x,
    Scenario.y == 'Current Setback' & setbackRegion.y == 'setbackRegion' & TC.y > TC.x ~ TC.x,
    Scenario.y == 'Current Setback' & setbackRegion.y == 'setbackRegion' & TC.y <= TC.x ~ TC.y,
    TRUE ~ 0
    
  )) %>%
  mutate(Scenario.y = case_when(
    
    is.na(Scenario.y) ~ 'Current Setback',
    TRUE ~ Scenario.y
    
  )) %>%
  mutate(setbackRegion.y = case_when(
    
    is.na(setbackRegion.y) ~ 'setbackRegion',
    TRUE ~ setbackRegion.y
    
  ))
  

totalData_woID_temp_NoSB <- totalData_woID_temp %>%
  select(LandType, Technology, SiGun, Scenario.x, setbackRegion.x, Area.x, Capacity.x, Generation.x, TC.x) %>%
  rename(Scenario = Scenario.x,
         setbackRegion = setbackRegion.x,
         Area = Area.x,
         Capacity = Capacity.x,
         Generation = Generation.x,
         TC = TC.x)
  

totalData_woID_temp_YesSB <- totalData_woID_temp %>%
  select(LandType, Technology, SiGun, Scenario.y, setbackRegion.y, Area.y, Capacity.y, Generation.y, TC.y) %>%
  rename(Scenario = Scenario.y,
         setbackRegion = setbackRegion.y,
         Area = Area.y,
         Capacity = Capacity.y,
         Generation = Generation.y,
         TC = TC.y)

totalData_woID_mnpt <- totalData_woID_temp_NoSB %>%
  bind_rows(totalData_woID_temp_YesSB)

totalData %>%
  filter(Scenario == 'No Setback')
######################################
######## [End] Clear Data Set ######## 
######################################


# Fig 1 #
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
  TypeToEng() %>%
  rename(`Land Use Type` = `LandType`)

ggplot(data = graphData %>% mutate(variable = factor(variable, levels = c("Area", "Capacity", "Generation"))), aes(x =  Scenario, y = value, fill = `Land Use Type`)) +
  geom_bar(stat='identity') +
  facet_wrap(~variable, scales = 'free') +
  theme(legend.position = "right",
        #axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1),
        text = element_text(size = 40)) +
  labs(color = 'Land Use Type')

# Summary table for Fig 1. #  경기도 면적 10,171km2

graphData_total_TEMP <- graphData %>%
  group_by(Scenario, variable) %>% summarize(value = sum(value)) %>% ungroup() %>%
  mutate(LandType = 'Total', .before = Scenario)

graphData_wTotal <- graphData %>%
  bind_rows(graphData_total_TEMP)

Fig1_Table <- graphData_wTotal %>%
  spread(key = Scenario, value = value) %>%
  mutate(diffRate = 100 * c(`No Setback` - `Current Setback`) / `Current Setback`)



Fig1_Table_IndLog <- Fig1_Table %>%
  filter(LandType %in% c("Industrial", "Logistics")) %>%
  group_by(variable) %>% summarize(`Current Setback` = sum(`Current Setback`),
                                   `No Setback` = sum(`No Setback`))


# Fig 2 #
### How much would generation be reduced by setback regulation? ### by LandType including both setback and Nosetback

totalData_woID_mnpt_NoSB <- totalData_woID_mnpt %>%
  filter(Scenario == 'No Setback')

totalData_woID_mnpt_YesSB <- totalData_woID_mnpt %>%
  filter(Scenario == 'Current Setback')

totalData_woID_mnpt_Reduction_byLandType <- totalData_woID_mnpt_NoSB %>%
  left_join(totalData_woID_mnpt_YesSB, by = c("LandType", "Technology", "SiGun", "setbackRegion")) %>%
  mutate(Generation.x = Generation.x - Generation.y,
         Scenario.x = 'Reduction') %>%
  rename(Scenario = Scenario.x,
         Area = Area.x,
         Capacity = Capacity.x,
         Generation = Generation.x,
         TC = TC.x) %>%
  select(LandType, Scenario, Generation) # Area, TC 등 추가하면 됨

graphData <- totalData_woID_mnpt_YesSB %>%
  bind_rows(totalData_woID_mnpt_Reduction_byLandType) %>%
  group_by(LandType, Scenario) %>% summarize(Generation = sum(Generation)) %>% ungroup() %>%
  TypeToEng() %>%
  #mutate(LandType = factor(LandType, levels = c("산지", "공동주택", "농지", "산업단지", "육상정수역", "공공건축물", "물류단지", "주차장"))) %>%
  # mutate(LandType = factor(LandType, levels = c("Residential complex", "Mountainous area", "Industrial complex", 
  #                                               "Farmland",  "Water", "Public buildings", "Logistics complex", "Parking lot"))) %>%
  mutate(LandType = factor(LandType, levels = c('Residential', "Industrial", "Water", "Farmland", "Mountain",
                                                 "Public", "Logistics", "Roadside", "Parking"))) %>%
  mutate(Scenario = case_when(
    
    Scenario == "Reduction" ~ "No Setback (Addtional amount)",
    TRUE ~ Scenario
    
  )) %>%
  mutate(Scenario = factor(Scenario, levels = c("No Setback (Addtional amount)", "Current Setback"))) %>%
  rename(`Land Use Type` = `LandType`)
  


ggplot(data = graphData , aes(x =  `Land Use Type`, y = Generation, fill = Scenario)) +
  geom_bar(stat='identity') +
  #facet_wrap(~LandType, scales = 'free') +
  theme(legend.position = "right",
        axis.title.x = element_blank(),
        #axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1),
        text = element_text(size = 45)) +
  scale_fill_manual(values = c("palegreen3","palegreen4")) +
  #scale_fill_brewer(palette = "Greens") +
   ylab("Geneartion (TWh)")


graphData %>%
  spread(key = Scenario, value = Generation) %>%
  mutate(incRate = 100 * `No Setback (Addtional amount)` / c(`Current Setback`) )



# Fig 3 #
### How much would generation be reduced by setback regulation? ### by SiGun including both setback and Nosetback

totalData_woID_mnpt_Reduction_bySGG <- totalData_woID_mnpt_NoSB %>%
  left_join(totalData_woID_mnpt_YesSB, by = c("LandType", "Technology", "SiGun", "setbackRegion")) %>%
  mutate(Generation.x = Generation.x - Generation.y,
         Scenario.x = 'Reduction') %>%
  rename(Scenario = Scenario.x,
         Area = Area.x,
         Capacity = Capacity.x,
         Generation = Generation.x,
         TC = TC.x) %>%
  select(LandType, SiGun, Scenario, Area, Capacity, Generation, TC) %>%
  group_by(LandType, SiGun, Scenario) %>% summarize(Generation = sum(Generation)) %>% ungroup()



## tempData : Reduction양을 LandType별로 색을 넣으려고, Scenario 칼럼에 '공공건축물' (Resid)단어를 넣을 예정.
totalData_woID_mnpt_Reduction_bySGG_graphData <- totalData_woID_mnpt_Reduction_bySGG %>%
  TypeToEng() %>%
  mutate(Scenario = LandType) %>%
  select(-LandType)


## just get the order of factors in SiGun lists.
SGGorder_bySetbackGen <- totalData_woID_mnpt_YesSB %>%
  group_by(SiGun) %>% summarize(Generation = sum(Generation)) %>% ungroup() %>%
  SGG_to_Eng() %>%
  arrange(desc(Generation)) %>%
  pull(SiGun)


graphData <- totalData_woID_mnpt_YesSB %>%
  bind_rows(totalData_woID_mnpt_Reduction_bySGG_graphData) %>%
  group_by(SiGun, Scenario) %>% summarize(Generation = sum(Generation)) %>% ungroup() %>%
  SGG_to_Eng() %>%
  mutate(SiGun = factor(SiGun, levels = SGGorder_bySetbackGen)) %>%
  mutate(Scenario = factor(Scenario, levels = rev(c("Current Setback", "Farmland", "Mountain", "Residential", "Industrial", "Water", "Logistics",  "Public", 'Roadside',"Parking"))))
  


ggplot(data = graphData , aes(x =  SiGun, y = Generation, fill = Scenario)) +
  geom_bar(stat='identity', color = 'black') +
  #facet_wrap(~LandType, scales = 'free') +
  theme(legend.position = "right",
        axis.title.x = element_blank(),
        #axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 45)) +
  #scale_fill_manual(values = c("palegreen3","palegreen4")) +
  #scale_fill_brewer(palette = "Greens") +
  ylab("Generation(TWh)")


#graphData_forCheck <-
graphData_LandTypeTotal_temp <- graphData %>%
  group_by(Scenario) %>% summarize(Generation = sum(Generation)) %>% ungroup()

graphData_sharebySGG_byLandType <- graphData %>%
  left_join(graphData_LandTypeTotal_temp, by = "Scenario") %>%
  mutate(share = 100 * c(Generation.x / Generation.y))

graphDataVV <- graphData_sharebySGG_byLandType %>%
  filter(Scenario == 'Farmland') %>%
  arrange(desc(share))


## Fig 4 : Supply curve of PV

rawData_fullpower_wLCOE_ordered_YesSB <- totalData %>%
  mutate(LCOE = LCOE * 1000) %>%  # Unit : $/kWh to $/MWh
  arrange(desc(Generation)) %>%
  arrange(LCOE) %>%
  filter(Scenario == "Current Setback") %>%
  TypeToEng() %>%
  mutate(LandType = factor(LandType, levels = rev(c("Residential", "Industrial", "Logistics", "Public", "Farmland", "Mountain", "Roadside", "Parking", "Water"))))
#filter(LandType != '육상정수역')


rawData_fullpower_wLCOE_ordered_NoSB <- totalData %>%
  mutate(LCOE = LCOE * 1000) %>%  # Unit : $/kWh to $/MWh
  arrange(desc(Generation)) %>%
  arrange(LCOE) %>%
  filter(Scenario == "No Setback") %>%
  TypeToEng() %>%
  mutate(LandType = factor(LandType, levels = rev(c("Residential", "Industrial", "Logistics", "Public", "Farmland", "Mountain", "Roadside", "Parking", "Water"))))
#filter(LandType != '육상정수역')


### 전체 ###
testGraph_YesSB <- rawData_fullpower_wLCOE_ordered_YesSB %>%
  mutate(x1 = lag(cumsum(Generation)),
         x2 = cumsum(Generation),
         y1 = 0,
         y2 = LCOE) %>%
  mutate(x1 = case_when(
    
    is.na(x1) ~ 0,
    TRUE ~ x1
    
  ))

testGraph_NoSB <- rawData_fullpower_wLCOE_ordered_NoSB %>%
  mutate(x1 = lag(cumsum(Generation)),
         x2 = cumsum(Generation),
         y1 = 0,
         y2 = LCOE) %>%
  mutate(x1 = case_when(
    
    is.na(x1) ~ 0,
    TRUE ~ x1
    
  ))

TWh_9GW <- c(9*0.136*8760/1000) # 9GW * CF * hours * converter
SMP <- c(167 / exRate * 1000)   # 167(won/kWh) * 1300 (won/USD) : USD/MWh



## supply curve in bar chart ##

ggplot() + 
  scale_x_continuous(name="x") + 
  scale_y_continuous(name="y") +
  geom_rect(data=testGraph_YesSB, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=LandType), alpha=0.5, linewidth = 0.1) +
  geom_rect(data=testGraph_NoSB, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=LandType), alpha=0.9, linewidth = 0.1) +
  theme(legend.position = "right",
        axis.title.x = element_blank(),
        #axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 45)) +
  geom_vline(xintercept = TWh_9GW, linetype = 'dashed') +  # 경기도 9GW가 목표니까 그에 대응되는 발전량을 표시. # CF 적용할때 경기도 평균이 13.6% 였음.
  geom_segment(aes(x = 4.04, y = 0, xend = 4.04, yend = 127.7),  linetype = 'dashed') +
  geom_segment(aes(x = 1.55, y = 0, xend = 1.55, yend = 127.7),  linetype = 'dashed') +
  geom_hline(yintercept = SMP, linetype = 'dashed')  # SMP 2023, 육지)  https://www.kpx.or.kr/smpYearly.es?mid=a10606080400&device=pc


## supply curve in bar chart with labeling ##
ggplot() + 
  scale_x_continuous(name="x") + 
  scale_y_continuous(name="y") +
  geom_rect(data=testGraph_YesSB, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=LandType), alpha=0.5, linewidth = 0.1) +
  geom_rect(data=testGraph_NoSB, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=LandType), alpha=0.9, linewidth = 0.1) +
  theme(legend.position = "right",
        axis.title.x = element_blank(),
        #axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 45)) +
  #geom_vline(xintercept = TWh_9GW, linetype = 'dashed') +  # 경기도 9GW가 목표니까 그에 대응되는 발전량을 표시. # CF 적용할때 경기도 평균이 13.6% 였음.
  #geom_segment(aes(x = 4.04, y = 0, xend = 4.04, yend = 127.7),  linetype = 'dashed') +
  #geom_segment(aes(x = 1.55, y = 0, xend = 1.55, yend = 127.7),  linetype = 'dashed') +
  #geom_hline(yintercept = SMP, linetype = 'dashed') +  # SMP 2023, 육지)  https://www.kpx.or.kr/smpYearly.es?mid=a10606080400&device=pc
  scale_x_continuous(limit = c(0,15), 
                     breaks = c(0, 1.55, 4.04, 10.72, 10.87, 14.99)) +
  
  scale_y_continuous(limit = c(0, 880),
                     breaks = c(0, 128.5, 243.8, 876.9))




## Line Graph ##
testGraph <- testGraph_YesSB %>%
  bind_rows(testGraph_NoSB)

ggplot(data = testGraph, aes(x = x2, y = y2, group = Scenario)) +
  geom_line(aes(colour = Scenario), linewidth = 1.5) +
  
  scale_x_continuous(limit = c(0,15), 
                     breaks = c(0, 1.55, 4.04, 10.72, 10.87, 14.99)) +
  
  scale_y_continuous(limit = c(0, 880),
                     breaks = c(0, 128.5, 243.8, 876.9))
                     
  
  
  ### Geom Segment 로 진행 ### Rendering 시간이 너무 오래걸림.
  #geom_vline(xintercept = TWh_9GW, linetype = 'dashed') +  # 경기도 9GW가 목표니까 그에 대응되는 발전량을 표시. # CF 적용할때 경기도 평균이 13.6% 였음.
  #geom_hline(yintercept = SMP, linetype = 'dashed') + # SMP 2023, 육지)  https://www.kpx.or.kr/smpYearly.es?mid=a10606080400&device=pc

  # geom_segment(aes(x = 1.55, y = 0, xend = 1.55, yend = SMP),  linetype = 'dashed') +          # 1
  # geom_segment(aes(x = 4.04, y = 0, xend = 4.04, yend = SMP),  linetype = 'dashed') +          # 2
  # 
  # geom_segment(aes(x = TWh_9GW, y = 0, xend = TWh_9GW, yend = 861.53),  linetype = 'dashed') + # 3
  # 
  # geom_segment(aes(x = 10.875, y = 0, xend = 10.875, yend = 876.923),  linetype = 'dashed') +  # 4
  # geom_segment(aes(x = 14.996, y = 0, xend = 14.996, yend = 876.923),  linetype = 'dashed') +  # 5
  # 
  # geom_segment(aes(x = 0, y = SMP, xend = 14.996, yend = SMP),  linetype = 'dashed') +         # 6
  # geom_segment(aes(x = 0, y = 243.846, xend = 14.996, yend = SMP),  linetype = 'dashed') +     # 7
  # geom_segment(aes(x = 0, y = 876.923, xend = 14.996, yend = 876.923),  linetype = 'dashed')   # 8
  


  #facet_wrap(~SIGUNGU, scales = 'free', ncol = 4) +
  scale_color_manual(values =  c(`배출량` = "black",
                                 `1인당 소득 효과` = 'green',
                                 `집약도 효과` = 'blue',
                                 `인구 효과` = 'red')) +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 40))


ggplot(data = graph_data, aes(x = year, y = value, group = variable)) +
  geom_point(aes(colour = variable), size = 8) +
  geom_line(aes(colour = variable), linewidth = 1.5) +
  facet_wrap(~SIGUNGU, scales = 'free', ncol = 4) +
  scale_color_manual(values =  c(`배출량` = "black",
                                 `1인당 소득 효과` = 'green',
                                 `집약도 효과` = 'blue',
                                 `인구 효과` = 'red')) +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 40))


## (경제적 비용) ##
QTarget_CurrentSB <- testGraph_YesSB %>%
  filter(x1 <= TWh_9GW)
QTarget_NoSB <- testGraph_NoSB %>%
  filter(x1 <= TWh_9GW)


PTarget_CurrentSB <- testGraph_YesSB %>%
  filter(LCOE <= SMP)
PTarget_NoSB <- testGraph_NoSB %>%
  filter(LCOE <= SMP)

Full_CurrentSB <- testGraph_YesSB
Full_NoSB <- testGraph_NoSB


calculTable <- function(data, Table1Name, Table2Name, ScenarioName) {
  
  outputData <- data %>%
    mutate(Table1 = Table1Name,
           Table2 = Table2Name,
           Scenario = ScenarioName,
           TotalGen = sum(Generation), # TWh
           TotalEmission = TotalGen * emisCoef_Gen, # MtCO2
           TotalCost = sum(TC), # Million USD
           AvgGenCost = TotalCost / TotalGen, # USD/MWh
           AvgEmisCost = TotalCost / TotalEmission # USD/tCO2
    ) %>%
    select(Table1, Table2, Scenario, TotalGen, TotalEmission, TotalCost, AvgGenCost, AvgEmisCost) %>%
    unique(.)
    
  
}

FF_Table <- calculTable(QTarget_CurrentSB, 'TargetBased', 'QuantityBased', 'CurrentSB') %>%
  bind_rows(calculTable(QTarget_NoSB, 'TargetBased', 'QuantityBased', 'NoSB'),
            
            calculTable(PTarget_CurrentSB, 'TargetBased', 'PriceBased', 'CurrentSB'),
            calculTable(PTarget_NoSB, 'TargetBased', 'PriceBased', 'NoSB'),
            
            calculTable(Full_CurrentSB, 'FullUtilization', "-", 'CurrentSB'),
            calculTable(Full_NoSB, 'FullUtilization', "-", 'NoSB'))



write.csv(FF_Table, "FF_Table.csv", fileEncoding = "EUC-KR")




testGraph_YesSB %>%
  filter(x1 <= TWh_9GW) %>%
  mutate(Table1 = 'TargetBased',
         Table2 = 'QuanBased',
         Scenario = 'CurrentSB',
         TotalGen = sum(Generation),
         TotalEmission = TotalGen * emisCoef_Gen,
         TotalCost = sum(TC),
         AvgGenCost = TotalCost / TotalGen,
         AvgEmisCost = TotalCost / TotalEmission
         ) %>%
  select(Table1, Table2, Scenario, TotalGen, TotalEmission, TotalCost, AvgGenCost, AvgEmisCost) %>%
  unique(.)

testGraph_NoSB %>%
  filter(x1 <= TWh_9GW) %>%
  mutate(barArea = sum(TC))


## (경제적 잠재량) ##
testGraph_YesSB %>%
  filter(LCOE <= SMP) %>%
  mutate(totGen = sum(Generation))

testGraph_NoSB %>%
  filter(LCOE <= SMP) %>%
  mutate(totGen = sum(Generation))

#######################################














