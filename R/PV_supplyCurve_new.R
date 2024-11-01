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
                                   `No Setback` = sum(`No Setback`),)


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
  geom_vline(xintercept = c(9*0.136*8760/1000), linetype = 'dashed')  # 경기도 9GW가 목표니까 그에 대응되는 발전량을 표시. # CF 적용할때 경기도 평균이 13.6% 였음.
  # sum(testGraph_NoSB$TC)/sum(testGraph_NoSB$Generation)
  # sum(testGraph_YesSB$TC)/sum(testGraph_YesSB$Generation)
  #geom_hline(yintercept = 280.2165) +
  #geom_hline(yintercept = 234.1442)

  


#######################################


rawData_fullpower_forTable_byLandType <- totalData %>%
  group_by(LandType, Scenario) %>% 
  summarize(Area = sum(Area),
            Capacity = sum(Capacity),
            Generation = sum(Generation),
            TC = sum(TC)) %>% ungroup()


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
  filter(Scenario =="No Setback")

summary_byLandType_forTable_YesSB <- rawData_fullpower_wLCOE_forTable %>%
  filter(Scenario =="Setback")


















### How would many capacity be reduced by setback regulation? ### by SiGunGu representing just difference between scenarios.
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
  mutate(diff_SCN = Generation.x - Generation.y) %>%
  select(SiGun, LandType, diff_SCN)

  


ggplot(data = graphData, aes(x =  SiGun, y = diff_SCN, fill = LandType)) +
  geom_bar(stat='identity') +
  #facet_wrap(~LandType, scales = 'free') +
  theme(legend.position = "right",
        #axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1),
        text = element_text(size = 40))








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




  







#facet_wrap(~유형)
#geom_text(data=tt, aes(x=x1+(x2-x1)/2, y=y1+(y2-y1)/2, label=r), size=4)
#opts(title="geom_rect", plot.title=theme_text(size=40, vjust=1.5))


### 유형별 ###
rawData_fullpower_wLCOE_ordered_indType <- rawData_fullpower_wLCOE_ordered %>%
  filter(LandType == "산업단지")

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

