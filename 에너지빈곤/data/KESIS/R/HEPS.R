library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)

############ KESIS Panel ############ 

##########################
##### hhd columnName #####
##########################


# id_hh : 가구ID
# s11_city : 광역시도_CODE: 31(경기)
# m_r_s11_105 : 준공년도
# m_r2_s11_106_10 : 주거전용면적
# g_r_s11_110_11 : 외벽창문_이중창문 비율_범주화 1(없음), 2(25%미만), 3(25-30%), 4(50% 이상)
# r8_s11_201_300 : 실제 주이용 주난방설비기기 0(없음) ~ 22(기타)


# r_s11_204_00 : 이용하고 있는 냉방설비기기_없음
# r_s11_204_01 : 이용하고 있는 냉방설비기기_선풍기
# s11_204_02 : 이용하고 있는 냉방설비기기_냉풍기
# r_s11_204_03 : 이용하고 있는 냉방설비기기_에어컨
# r2_s11_204_04 : 이용하고 있는 냉방설비기기_중앙냉방
# s11_204_05 : 이용하고 있는 냉방설비기기_지열
# s11_204_06: 이용하고 있는 냉방설비기기_기타


# s11_603 : 2020년_여름철_냉방만족도
# s11_604 : 2020년 겨울철 난방 만족도


# s11_605_1	에너지효율개선경험_고효율 보일러 교체(현거주주택 기준)
# s11_605_2	에너지효율개선경험_고효율 냉방설비 교체(현거주주택 기준)
# s11_605_3	에너지효율개선경험_LED 조명으로 교체(현거주주택 기준)
# s11_605_4	에너지효율개선경험_환기시스템 신규 또는 교체(현거주주택 기준)
# s11_605_5	에너지효율개선경험_이중창 또는 효율좋은 창호 교체(현거주주택 기준)
# s11_605_6	에너지효율개선경험_외벽 단열재 보강(현거주주택 기준)
# s11_605_7	에너지효율개선경험_보온 단열용품 설치(현거주주택 기준)
# s11_605_8	에너지효율개선경험_해당없음(현거주주택 기준)


# s11_801 : 가구원 수
# s11_806 : 연간 총소득(세금공제 전) (단위: 만원원)


hhd_colnames <- c(
  'id_hh', # 가구ID
 's11_city', # 광역시도_CODE: 31(경기)
 'm_r_s11_105', # 준공년도
  'm_r2_s11_106_10', # 주거전용면적
  'g_r_s11_110_11', # 외벽창문_이중창문 비율_범주화 1(없음), 2(25%미만), 3(25-30%), 4(50% 이상)
  
  'r8_s11_201_300', # 실제 주이용 주난방설비기기 0(없음) ~ 22(기타)
  
  'r_s11_204_00', # 이용하고 있는 냉방설비기기_없음
  'r_s11_204_01', # 이용하고 있는 냉방설비기기_선풍기
  's11_204_02', # 이용하고 있는 냉방설비기기_냉풍기
  'r_s11_204_03', # 이용하고 있는 냉방설비기기_에어컨
  'r2_s11_204_04', # 이용하고 있는 냉방설비기기_중앙냉방
  's11_204_05', # 이용하고 있는 냉방설비기기_지열
  's11_204_06', # 이용하고 있는 냉방설비기기_기타
  
  's11_603', # 2020년_여름철_냉방만족도
  's11_604', # 2020년 겨울철 난방 만족도
  
  's11_605_1',	# 에너지효율개선경험_고효율 보일러 교체(현거주주택 기준)
  's11_605_2',	# 에너지효율개선경험_고효율 냉방설비 교체(현거주주택 기준)
  's11_605_3',	# 에너지효율개선경험_LED 조명으로 교체(현거주주택 기준)
  's11_605_4',	# 에너지효율개선경험_환기시스템 신규 또는 교체(현거주주택 기준)
  's11_605_5',	# 에너지효율개선경험_이중창 또는 효율좋은 창호 교체(현거주주택 기준)
  's11_605_6',	# 에너지효율개선경험_외벽 단열재 보강(현거주주택 기준)
  's11_605_7',	# 에너지효율개선경험_보온 단열용품 설치(현거주주택 기준)
  's11_605_8',	# 에너지효율개선경험_해당없음(현거주주택 기준)
  
  's11_801', # 가구원 수
  's11_807' # 연간 총소득(세금공제 후후)
  
)







#############################
##### energy columnName #####
#############################

energy_colnames <- c(
   'id_hh', # 가구ID
   # 월별 전기소비 2020년 # (kWh)
   # 'c_s11_telec_2001', 
   # 'c_s11_telec_2002',
   # 'c_s11_telec_2003',
   # 'c_s11_telec_2004',
   # 'c_s11_telec_2005',
   # 'c_s11_telec_2006',
   # 'c_s11_telec_2007',
   # 'c_s11_telec_2008',
   # 'c_s11_telec_2009',
   # 'c_s11_telec_2010',
   # 'c_s11_telec_2011',
   # 'c_s11_telec_2012',
   'c_s11_telec_2013',
  
  
  # 월별 지역난방 2020년 # (Mcal)
  # 's11_dheat_2001',
  # 's11_dheat_2002',
  # 's11_dheat_2003',
  # 's11_dheat_2004',
  # 's11_dheat_2005',
  # 's11_dheat_2006',
  # 's11_dheat_2007',
  # 's11_dheat_2008',
  # 's11_dheat_2009',
  # 's11_dheat_2010',
  # 's11_dheat_2011',
  # 's11_dheat_2012',
  's11_dheat_2013',
  
  
  # 월별 도시가스 2020년 # (Mcal)
  # 'c_s11_cgas_2001',	
  # 'c_s11_cgas_2002',	
  # 'c_s11_cgas_2003',	
  # 'c_s11_cgas_2004',	
  # 'c_s11_cgas_2005',	
  # 'c_s11_cgas_2006',	
  # 'c_s11_cgas_2007',	
  # 'c_s11_cgas_2008',	
  # 'c_s11_cgas_2009',	
  # 'c_s11_cgas_2010',	
  # 'c_s11_cgas_2011',	
  # 'c_s11_cgas_2012',
  'c_s11_cgas_2013',
  
  
  # 월별 등유 2020년 # (Mcal)
  # 'c_s11_oil_2001',	
  # 'c_s11_oil_2002',	
  # 'c_s11_oil_2003',	
  # 'c_s11_oil_2004',	
  # 'c_s11_oil_2005',	
  # 'c_s11_oil_2006',	
  # 'c_s11_oil_2007',	
  # 'c_s11_oil_2008',	
  # 'c_s11_oil_2009',	
  # 'c_s11_oil_2010',	
  # 'c_s11_oil_2011',
  # 'c_s11_oil_2012',	
  'c_s11_oil_2013',	
  
  
  # 월별 프로판 2020년 # (Mcal)
  # 'c_s11_pp_2001',	
  # 'c_s11_pp_2002',	
  # 'c_s11_pp_2003',	
  # 'c_s11_pp_2004',	
  # 'c_s11_pp_2005',	
  # 'c_s11_pp_2006',	
  # 'c_s11_pp_2007',	
  # 'c_s11_pp_2008',	
  # 'c_s11_pp_2009',	
  # 'c_s11_pp_2010',	
  # 'c_s11_pp_2011',	
  # 'c_s11_pp_2012',	
  'c_s11_pp_2013',	
  
  
  # 월별 기타석유 2020년 # (Mcal)
  # 'c_s11_opp_2001',	
  # 'c_s11_opp_2002',	
  # 'c_s11_opp_2003',	
  # 'c_s11_opp_2004',	
  # 'c_s11_opp_2005',	
  # 'c_s11_opp_2006',	
  # 'c_s11_opp_2007',	
  # 'c_s11_opp_2008',	
  # 'c_s11_opp_2009',	
  # 'c_s11_opp_2010',	
  # 'c_s11_opp_2011',	
  # 'c_s11_opp_2012',	
  'c_s11_opp_2013',	
  
  
  # 월별 연탄 2020년 # (Mcal)
  # 'c_s11_br_2001',	
  # 'c_s11_br_2002',	
  # 'c_s11_br_2003',
  # 'c_s11_br_2004',	
  # 'c_s11_br_2005',	
  # 'c_s11_br_2006',	
  # 'c_s11_br_2007',	
  # 'c_s11_br_2008',	
  # 'c_s11_br_2009',	
  # 'c_s11_br_2010',	
  # 'c_s11_br_2011',	
  # 'c_s11_br_2012',	
  'c_s11_br_2013',	
  
  
  # 월별 기타연료 2020년 # (Mcal)
  # 's11_nr_2001',	
  # 's11_nr_2002',	
  # 's11_nr_2003',	
  # 's11_nr_2004',	
  # 's11_nr_2005',	
  # 's11_nr_2006',	
  # 's11_nr_2007',	
  # 's11_nr_2008',	
  # 's11_nr_2009',	
  # 's11_nr_2010',	
  # 's11_nr_2011',	
  # 's11_nr_2012',	
  's11_nr_2013',	
  
  # 월별 총에너지소비 2020년 # (Mcal)
  # 'c_s11_total_2001',	
  # 'c_s11_total_2002',	
  # 'c_s11_total_2003',	
  # 'c_s11_total_2004',	
  # 'c_s11_total_2005',	
  # 'c_s11_total_2006',	
  # 'c_s11_total_2007',
  # 'c_s11_total_2008',	
  # 'c_s11_total_2009',	
  # 'c_s11_total_2010',	
  # 'c_s11_total_2011',	
  # 'c_s11_total_2012',	
  'c_s11_total_2013'
  
)

## Unit Conversion ##
Mcal_to_kWh <- 1.162 
Mcal_to_MJ <- 4.184
thous <- 10^(3)
kerosLiter_to_kcal <- 8740   # 지역에너지통계연보, 에너지열량환산기준 
prpnKg_to_kcal <- 12000  # 지역에너지통계연보, 에너지열량환산기준
brqEach_to_kg <- 3.65 # Naver검색
brqKg_to_kcal <- 4710 # 지역에너지통계연보


rawData_hhd <- read.csv("../KESIS/HEPS11_micro_240118/HEPS11_micro_hhd_240118.csv", header = T, fileEncoding = "EUC-KR")

rawData_hhd %>%
  count(s11_city)


rawData_energy <- read.csv("../KESIS/HEPS11_micro_240118/HEPS11_micro_energy_231128.csv", header = T, fileEncoding = "EUC-KR")


hhdData <- rawData_hhd %>%
  select(hhd_colnames)

energyData <- rawData_energy %>%
  select(energy_colnames)

hhenergyData <- hhdData %>%
  left_join(energyData, by = 'id_hh')

EnCostData <- hhenergyData %>%
  mutate(전기요금 = c_s11_telec_2013 * Mcal_to_kWh * 108, # kWh * (원/kWh)
         난방요금 = s11_dheat_2013 * 112, # Mcal * (원/Mcal)
         가스요금 = c_s11_cgas_2013 * Mcal_to_MJ * 15.1, # Mcal * MCal_to_MJ * (원/MJ)
         등유요금 = c_s11_oil_2013 * thous / kerosLiter_to_kcal * 850, # Mcal * Mcal_to_kcal * kcal_to_Liter * (원/Liter)
         프판요금 = c_s11_pp_2013 * thous / prpnKg_to_kcal * 1850,
         연탄요금 = c_s11_br_2013 * thous / brqKg_to_kcal / brqEach_to_kg * 657,
         #에너지요금 = sum(전기요금, 난방요금, 가스요금, 등유요금, 프판요금, 연탄요금)
         에너지요금 = 전기요금 + 난방요금 + 가스요금 + 등유요금 + 프판요금 + 연탄요금) %>% # 원
  mutate(에너지요금비중 = 에너지요금 / c(s11_807 * 10000)) %>%
  arrange(desc(에너지요금비중))
  
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








