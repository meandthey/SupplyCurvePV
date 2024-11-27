library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)

############ KESIS Panel ############ 

##########################
##### hhd columnName #####
##########################

hhd_colnames <- c(
  'id_hh', # 가구ID
 's11_city', # 광역시도_CODE: 31(경기)
 
 'r2_s11_101',	# 주택종류	더미	10개
 'r_s11_103',	# 외벽수	연속	
 's11_104',	# 주택방향	더미	8개
 'm_r_s11_105',	# 준공년도	연속	
 's11_110',	# 외벽창문수	연속	
 'r8_s11_201_300', # 실제 주이용 주난방설비기기	더미	23개
 'g_r8_s11_201_300', # 주난방연료	더미	7개
 'r4_s11_205_20',	# 실제 주이용하는 취사설비기기	더미	8개
 's11_603',	# 2020년_여름철_냉방만족도	더미	5개
 's11_604',	# 2020년 겨울철 난방 만족도	더미	5개
 's11_801',	# 가구원수	연속	
 's11_803_2',	# 가구주_ 교육정도	더미	4개
 'r_s11_803_3',	# 가구주_ 출생년도(주민등록 기준)	연속	
 's11_807'	# 연간 총소득(세금공제 후)	연속	
 
 
)



SIDO_code_to_name <- function(data) {
  
  outputData <- data %>%
    mutate(s11_city = case_when(
      
      s11_city == 11 ~ "서울",
      s11_city == 21 ~ "부산",
      s11_city == 22 ~ "대구",
      s11_city == 23 ~ "인천",
      s11_city == 24 ~ "광주",
      s11_city == 25 ~ "대전",
      s11_city == 26 ~ "울산",
      s11_city == 29 ~ "세종",
      s11_city == 31 ~ "경기",
      s11_city == 32 ~ "강원",
      s11_city == 33 ~ "충북",
      s11_city == 34 ~ "충남",
      s11_city == 35 ~ "전북",
      s11_city == 36 ~ "전남",
      s11_city == 37 ~ "경북",
      s11_city == 38 ~ "경남",
      s11_city == 39 ~ "제주"
      
    )) %>%
    rename(시도명 = s11_city)
  
  
}



#############################
##### energy columnName #####
#############################

energy_colnames <- c(
  'id_hh', # 가구ID
  'c_s11_telec_2013',	# 전기합계_연간소비량	연속
  's11_dheat_2013',	#	지역난방_연간소비량	연속
  'c_s11_cgas_2013',	#	도시가스_연간소비량	연속
  'c_s11_oil_2013',	#	등유_연간소비량	연속
  'c_s11_pp_2013',	#	프로판_연간소비량	연속
  'c_s11_opp_2013',	#	기타석유_연간소비량	연속
  'c_s11_br_2013',	#	연탄_합계_연간소비량	연속
  's11_nr_2013',	#	기타연료_연간소비량	연속
  'c_s11_tpet_2013'	#	석유소계_연간소비량	연속
  
  
  
)

## Unit Conversion ##
Mcal_to_kWh <- 1.162 
Mcal_to_MJ <- 4.184
thous <- 10^(3)
kerosLiter_to_kcal <- 8740   # 지역에너지통계연보, 에너지열량환산기준 
prpnKg_to_kcal <- 12000  # 지역에너지통계연보, 에너지열량환산기준
brqEach_to_kg <- 3.65 # Naver검색
brqKg_to_kcal <- 4710 # 지역에너지통계연보


rawData_hhd <- read.csv("./11차가구에너지패널조사 마이크로데이터/HEPS11_micro_hhd_240118.csv", header = T, fileEncoding = "EUC-KR")

rawData_hhd %>%
  count(s11_city)


rawData_energy <- read.csv("./11차가구에너지패널조사 마이크로데이터/HEPS11_micro_energy_231128.csv", header = T, fileEncoding = "EUC-KR")


hhdData <- rawData_hhd %>%
  select(hhd_colnames)

energyData <- rawData_energy %>%
  select(energy_colnames)   ## All unit is 'Mcal'

hhenergyData <- hhdData %>%
  left_join(energyData, by = 'id_hh') %>%
  SIDO_code_to_name()
  

EnCostData <- hhenergyData %>%
  mutate(전기요금 = c_s11_telec_2013 * Mcal_to_kWh * 108, # kWh * (원/kWh)
         난방요금 = s11_dheat_2013 * 112, # Mcal * (원/Mcal)
         가스요금 = c_s11_cgas_2013 * Mcal_to_MJ * 15.1, # Mcal * MCal_to_MJ * (원/MJ)
         등유요금 = c_s11_oil_2013 * thous / kerosLiter_to_kcal * 850, # Mcal * Mcal_to_kcal * kcal_to_Liter * (원/Liter)
         프판요금 = c_s11_pp_2013 * thous / prpnKg_to_kcal * 1850, # 
         연탄요금 = c_s11_br_2013 * thous / brqKg_to_kcal / brqEach_to_kg * 657, # 
         #에너지요금 = sum(전기요금, 난방요금, 가스요금, 등유요금, 프판요금, 연탄요금)
         에너지요금 = 전기요금 + 난방요금 + 가스요금 + 등유요금 + 프판요금 + 연탄요금,
         에너지요금 = 에너지요금 / 10000) %>% # 만원
  mutate(에너지요금비중 = 에너지요금 / c(s11_807 * 10000)) %>%
  
  
  arrange(desc(에너지요금비중)) %>%
  mutate(TPR = case_when(
    
    에너지요금비중 > 0.1 ~ "1",
    TRUE ~ "0"
  ))

TPR_Data <- EnCostData %>%
  select(id_hh, TPR)


##################################################
## MEPI : Multidimensional Energy Poverty Index ##
##################################################
# [참고] 가계금융복지조사 결과표 : 3분위 2020년 처분가능소득: 4109만원
thirdQ_income <- 4109  
# 다음의 3가지 조건을 모두 충족.

# 1. 소득대비 에너지비용 지출이 10%
# 2. 가계금융복지조사 결과표 : 3분위 2020년 처분가능소득: 4109만원
# 3. 건축물이 30년 이상.

MEPI_Data <- EnCostData %>%
  select(id_hh, 시도명, 에너지요금, s11_807, m_r_s11_105) %>%
  filter(s11_807 >= 0,
         s11_807 <= 10000) %>%
  #rename(준공년도 = m_r_s11_105) %>%
  mutate(MEPI = case_when(
    
    m_r_s11_105 <= 1994 & s11_807 <= thirdQ_income & 에너지요금/s11_807 >= 0.1 ~ "1",
    #세후소득 <= thirdQ_income & 에너지요금/세후소득 >= 0.1 ~ "yes",
    TRUE ~"0"
    
  )) %>%
  select(id_hh, MEPI)
# MEPI_Data <- EnCostData %>%
  





regData_TPR <- hhenergyData %>%
  left_join(TPR_Data, by = c("id_hh")) %>%
  #filter(시도명 == '경기') %>%
  mutate(TPR = as.numeric(TPR))


regData_MEPI <- hhenergyData %>%
  left_join(MEPI_Data, by = c("id_hh")) %>%
  #filter(시도명 == '전북') %>%
  mutate(TPR = as.numeric(MEPI))



aa <- glm(data = regData_TPR, family = binomial(link = "probit"),
    TPR ~ r2_s11_101 + r_s11_103 + s11_104 + m_r_s11_105 + s11_110 + r8_s11_201_300 + g_r8_s11_201_300 + r4_s11_205_20 + s11_603 + s11_604 + s11_801 + s11_803_2 + r_s11_803_3 + 
      s11_807 + c_s11_telec_2013 + s11_dheat_2013 + c_s11_cgas_2013 + c_s11_oil_2013 + c_s11_pp_2013 + c_s11_opp_2013 + c_s11_br_2013 + s11_nr_2013 + c_s11_tpet_2013)




aa <- glm(data = regData_MEPI, family = binomial(link = "probit"),
          TPR ~ r2_s11_101 + r_s11_103 + s11_104 + m_r_s11_105 + s11_110 + r8_s11_201_300 + g_r8_s11_201_300 + r4_s11_205_20 + s11_603 + s11_604 + s11_801 + s11_803_2 + r_s11_803_3 + s11_807 +
            c_s11_telec_2013 + s11_dheat_2013 + c_s11_cgas_2013 + c_s11_oil_2013 + c_s11_pp_2013 + c_s11_opp_2013 + c_s11_br_2013 + s11_nr_2013 + c_s11_tpet_2013)


bb <- glm(data = regData_MEPI, family = binomial(link = "probit"),
          TPR ~ r2_s11_101 + r_s11_103 + s11_104 + s11_110 + r8_s11_201_300 + g_r8_s11_201_300 + r4_s11_205_20 + s11_603 + s11_604 + s11_801 + s11_803_2 + r_s11_803_3)

## 다중공선성
bb <- glm(data = regData_MEPI, family = binomial(link = "probit"),
          TPR ~ r2_s11_101 + r_s11_103 + s11_104 + s11_110 + r8_s11_201_300 + g_r8_s11_201_300 + r4_s11_205_20 + s11_603 + s11_604 + s11_801 + s11_803_2 + r_s11_803_3 +
            c_s11_telec_2013 + s11_dheat_2013 + c_s11_cgas_2013 + c_s11_oil_2013 + c_s11_pp_2013 + c_s11_opp_2013 + c_s11_br_2013 + s11_nr_2013 + c_s11_tpet_2013)
            
  
# https://m.blog.naver.com/pmw9440/222092656399

###########################
## TPR: Ten Percent Rule ##
###########################

###### Gini Graph ######
graphData <- EnCostData %>%
  select(id_hh, 시도명, 에너지요금, 세후소득, c_s11_oil_2013, c_s11_pp_2013, c_s11_br_2013) %>%
  arrange(세후소득) %>%
  filter(세후소득 >= 0,
         세후소득 <= 10000) %>%
  mutate(OPB = case_when(
    
    c_s11_oil_2013 + c_s11_pp_2013 + c_s11_br_2013 == 0 ~ "no_OPB",
    c_s11_oil_2013 + c_s11_pp_2013 + c_s11_br_2013 != 0 ~ "yes_OPB"
    
  ))



ggplot(graphData, aes(x = 세후소득, y = 에너지요금, group = OPB)) + 
  geom_point(size = 2, aes(colour = OPB)) +
  geom_abline(slope = 0.1, intercept = 0, color = "darkgray", linetype = "dashed") +
  facet_wrap(~시도명)

  # geom_line( aes( colour = color_label), size = 0.5) +
  # 
  # theme(text = element_text(size = 50),
  #       #axis.text.x = element_text(angle = 90),
  #       axis.title.x = element_blank(),
  #       axis.title.y = element_blank(),
  #       legend.position = "none") +
  # #scale_shape_manual(values = c(15,16,17,  0,1,2)) +
  # scale_colour_manual(values = c( 'black', '#F53E2A', '#F5A01B', '#2A2AF5', '#2AAAF5' ))




##################################################
## MEPI : Multidimensional Energy Poverty Index ##
##################################################
  # [참고] 가계금융복지조사 결과표 : 3분위 2020년 처분가능소득: 4109만원
thirdQ_income <- 4109  
  # 다음의 3가지 조건을 모두 충족.
  
# 1. 소득대비 에너지비용 지출이 10%
# 2. 가계금융복지조사 결과표 : 3분위 2020년 처분가능소득: 4109만원
# 3. 건축물이 30년 이상.
  
graphData <- EnCostData %>%
  select(id_hh, 시도명, 에너지요금, 세후소득, m_r_s11_105) %>%
  filter(세후소득 >= 0,
    세후소득 <= 10000) %>%
  rename(준공년도 = m_r_s11_105) %>%
  mutate(MEPI = case_when(
    
    #준공년도 <= 1994 & 세후소득 <= thirdQ_income & 에너지요금/세후소득 >= 0.1 ~ "yes",
    세후소득 <= thirdQ_income & 에너지요금/세후소득 >= 0.1 ~ "yes",
    TRUE ~"no"
    
  ))
  

  
ggplot(graphData, aes(x = 세후소득, y = 에너지요금, group = MEPI)) + 
  geom_point(size = 2, aes(colour = MEPI)) +
  geom_abline(slope = 0.1, intercept = 0, color = "darkgray", linetype = "dashed") +
  facet_wrap(~시도명)
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  


totalData <- EnCostData %>%
  mutate(에너지빈곤층 = case_when(
    
    에너지요금비중 >= 0.1 ~ 'yes',
    TRUE ~ 'no'
    
  ))











  
EnPvData <- totalData %>%
  filter(에너지빈곤층 == 'yes')

EnPVData_EnUse <- EnPvData %>%
  group_by(s11_city) %>% summarize(c_s11_telec_2013 = sum(c_s11_telec_2013),
                                   s11_dheat_2013 = sum(s11_dheat_2013),
                                   c_s11_cgas_2013 = sum(c_s11_cgas_2013),
                                   c_s11_oil_2013 = sum(c_s11_oil_2013),
                                   c_s11_pp_2013 = sum(c_s11_pp_2013),
                                   c_s11_br_2013 = sum(c_s11_br_2013),
                                   c_s11_total_2013 = sum(c_s11_total_2013))

test <- EnPVData_EnUse %>%
  mutate(전기사용비중 = c_s11_telec_2013 / c_s11_total_2013,
         난방사용비중 = s11_dheat_2013  / c_s11_total_2013,
         가스사용비중 = c_s11_cgas_2013  / c_s11_total_2013,
         등유사용비중 = c_s11_oil_2013  / c_s11_total_2013,
         프판사용비중 = c_s11_pp_2013  / c_s11_total_2013,
         연탄사용비중 = c_s11_br_2013  / c_s11_total_2013)






EnCostData %>%
  count(s11_city)

EnPvData %>%
  filter(에너지빈곤층 == 'yes')

a <- EnPvData %>%
  filter(에너지빈곤층 == 'yes')
         #m_r_s11_105 <= 1994)

a %>% count(s11_city)


aa <- totalData %>%
  count(s11_city, 에너지빈곤층 ) %>%
  spread(에너지빈곤층,  n) %>%
  mutate(share = yes / c(no+yes)) %>%
  arrange(desc(share))








