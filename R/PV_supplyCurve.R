library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)

library(ggmacc)


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
    mutate(지역 = case_when(
      
      지역 == "가평" ~ "가평군",
      지역 == "고양" ~ "고양시",
      지역 == "과천" ~ "과천시",
      지역 == "광명" ~ "광명시",
      지역 == "광주" ~ "광주시",
      지역 == "구리" ~ "구리시",
      지역 == "군포" ~ "군포시",
      지역 == "김포" ~ "김포시",
      지역 == "남양주" ~ "남양주시",
      지역 == "동두천" ~ "동두천시",
      지역 == "부천" ~ "부천시",
      지역 == "성남" ~ "성남시",
      지역 == "수원" ~ "수원시",
      지역 == "시흥" ~ "시흥시",
      지역 == "안산" ~ "안산시",
      지역 == "안양" ~ "안양시",
      지역 == "양주" ~ "양주시",
      지역 == "양평" ~ "양평군",
      지역 == "여주" ~ "여주시",
      지역 == "연천" ~ "연천군",
      지역 == "오산" ~ "오산시",
      지역 == "용인" ~ "용인시",
      지역 == "의왕" ~ "의왕시",
      지역 == "의정부" ~ "의정부시",
      지역 == "이천" ~ "이천시",
      지역 == "파주" ~ "파주시",
      지역 == "평택" ~ "평택시",
      지역 == "포천" ~ "포천시",
      지역 == "하남" ~ "하남시",
      지역 == "화성" ~ "화성시",
      지역 == "안성" ~ "안성시",
      
      TRUE ~ 지역
      
    ))
  
  return(target)
  
}


orderSGG_Wtotal <- function(data) {
  
  targetData <- data %>%
    arrange(factor(지역, levels = SGG_order_W_SN))
  
  return(targetData)
  
}

writeExcel <- function(fileName, dataName, Name) {
  
  wb <- loadWorkbook(fileName)
  addWorksheet(wb, Name)
  writeData(wb, Name, dataName)
  saveWorkbook(wb, fileName, overwrite = TRUE)
  
  
}

## 필요면적: m2/kW, 시나리오:
rawData_prm <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "parameter", col_names = T, skip = 1) 


## capacity factor (%) ##
rawData_cf <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "CF", col_names = T, skip = 1) 

cf_bySGG <- rawData_cf %>%
  group_by(지역) %>% summarize(이용률 = mean(이용률)) %>% ungroup() %>%
  mutate(이용률 = round(이용률, digit = 2),
         이용률 = 이용률 / 100,
         Units = 'ratio')
cf_avg <- mean(cf_bySGG$이용률)


## capacity factor (%) ##
LandList <- excel_sheets("../data/totalData_individual.xlsx")[!excel_sheets("../data/totalData_individual.xlsx") %in% c("LCOE_byTech","LCOE_bySGGTech","parameter", "CF")]


getFullData <- function() {
  
  FullData <- c()
  for ( i in 1:length(LandList)) {
    
    eachData <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = LandList[i], col_names = T)
    
    eachData <- eachData %>%
      mutate(이격거리 = case_when(
        
        grepl("이격거리규제없음", LandList[i]) ~ "N",
        TRUE ~ "Y"
        
      ))
    
    FullData <- FullData %>% 
      bind_rows(eachData) %>%
      makeFullname()
    
  }
  
  return(FullData)
}

rawData_full <- getFullData()

rawData_fullpower <- rawData_full %>%
  left_join(rawData_prm, by = c("유형")) %>%
  left_join(cf_bySGG, by = c("지역")) %>%
  mutate(발전용량 = 면적 / coefficient * c(ratio / 100),
         발전량 = 발전용량 * 이용률 * 8760) %>%
  select(-coefficient, -ratio, -이용률, -Units)
  


## LCOE by technology (원/kWh) ##
rawData_LCOE_bySGGTech <- readxl::read_excel("../data/totalData_individual.xlsx", sheet = "LCOE_bySGGTech", col_names = T) 

rawData_LCOE_bySGGTech_avg <- rawData_LCOE_bySGGTech %>%
  gather(-시군구_1, -시군구_2, -Units, key = technology, value = LCOE) %>%
  group_by(시군구_1, technology, Units) %>% summarize(LCOE = mean(LCOE)) %>%
  rename(지역 = 시군구_1)


supplyCurve_test <- rawData_fullpower %>%
  left_join(rawData_LCOE_bySGGTech_avg, by = c("지역", "technology")) %>%
  filter(!is.na(LCOE))

supplyCurve_test_order <- supplyCurve_test %>%
  arrange(desc(발전량)) %>%
  arrange(LCOE)


tt <- supplyCurve_test_order %>%
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
  geom_rect(data=tt, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=유형), alpha=0.5, size = 0.1)
  #facet_wrap(~유형)
  #geom_text(data=tt, aes(x=x1+(x2-x1)/2, y=y1+(y2-y1)/2, label=r), size=4)
  #opts(title="geom_rect", plot.title=theme_text(size=40, vjust=1.5))


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
  



###































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

