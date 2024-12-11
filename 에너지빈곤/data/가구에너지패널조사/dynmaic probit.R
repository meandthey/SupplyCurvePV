library(dplyr)
library(readxl)
library(tidyr)
library(ggplot2)
library(openxlsx)

## Unit Conversion ##
Mcal_to_kWh <- 1.162 
Mcal_to_MJ <- 4.184
thous <- 10^(3)
kerosLiter_to_kcal <- 8740   # 지역에너지통계연보, 에너지열량환산기준 
prpnKg_to_kcal <- 12000  # 지역에너지통계연보, 에너지열량환산기준
brqEach_to_kg <- 3.65 # Naver검색
brqKg_to_kcal <- 4710 # 지역에너지통계연보

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
  #'s11_110',	# 외벽창문수	연속	
  'r8_s11_201_300', # 실제 주이용 주난방설비기기	더미	23개
  'g_r8_s11_201_300', # 주난방연료	더미	7개
  'r4_s11_205_20',	# 실제 주이용하는 취사설비기기	더미	8개
  's11_603',	# 2020년_여름철_냉방만족도	더미	5개
  's11_604',	# 2020년 겨울철 난방 만족도	더미	5개
  's11_801',	# 가구원수	연속	
  's11_803_2',	# 가구주_교육정도	더미	4개
  'r_s11_803_3',	# 가구주_출생년도(주민등록 기준)	연속	
  's11_807'	# 연간 총소득(세금공제 후)	연속	
  
  
)


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

######################################
##### select & unify column Name #####
######################################

unify_ColumnName <- function(data, rawColname, uniColname, year) {
  
  outputData <- data %>%
    select(rawColname) %>%
    setNames(uniColname) %>%
    mutate(연도 = year)
  
  return(outputData)
  
}


######################################################################################################################################################################################
######################################################################################################################################################################################
######################################################################################################################################################################################
### Column Name ### [selected]
rawData_hhd_colName <- readxl::read_excel("./common/HEPS_columnName.xlsx", col_names = T, sheet = 'hhd')
rawData_hhd_colName_2019 <- rawData_hhd_colName$`2019`
rawData_hhd_colName_2020 <- rawData_hhd_colName$`2020`
rawData_hhd_colName_2021 <- rawData_hhd_colName$`2021`
rawData_hhd_colName_common <- rawData_hhd_colName$공통이름


rawData_energy_colName <- readxl::read_excel("./common/HEPS_columnName.xlsx", col_names = T, sheet = 'energy')
rawData_energy_colName_2019 <- rawData_energy_colName$`2019`
rawData_energy_colName_2020 <- rawData_energy_colName$`2020`
rawData_energy_colName_2021 <- rawData_energy_colName$`2021`
rawData_energy_colName_common <- rawData_energy_colName$공통이름


### 10차: 2019 ###
rawData_hhd_2019 <- read.csv("./10차_2019/10차가구에너지패널조사 마이크로데이터/HEPS10th_micro_hhd_230201.csv", header = T, fileEncoding = "EUC-KR")
rawData_energy_2019 <- read.csv("./10차_2019/10차가구에너지패널조사 마이크로데이터/HEPS10th_micro_energy_230201.csv", header = T, fileEncoding = "EUC-KR")

### 11차: 2020 ###
rawData_hhd_2020 <- read.csv("./11차_2020/11차가구에너지패널조사 마이크로데이터/HEPS11_micro_hhd_240118.csv", header = T, fileEncoding = "EUC-KR")
rawData_energy_2020 <- read.csv("./11차_2020/11차가구에너지패널조사 마이크로데이터/HEPS11_micro_energy_231128.csv", header = T, fileEncoding = "EUC-KR")

### 12차: 2021 ###
rawData_hhd_2021 <- read.csv("./12차_2021/12차가구에너지패널조사 마이크로데이터/HEPS12_micro_hhd_241127.csv", header = T, fileEncoding = "EUC-KR")
rawData_energy_2021 <- read.csv("./12차_2021/12차가구에너지패널조사 마이크로데이터/HEPS12_micro_energy_241127.csv", header = T, fileEncoding = "EUC-KR")



### merge & unify data ###
hhdData_2019 <- unify_ColumnName(rawData_hhd_2019, rawData_hhd_colName_2019, rawData_hhd_colName_common, 2019)
hhdData_2020 <- unify_ColumnName(rawData_hhd_2020, rawData_hhd_colName_2020, rawData_hhd_colName_common, 2020)
hhdData_2021 <- unify_ColumnName(rawData_hhd_2021, rawData_hhd_colName_2021, rawData_hhd_colName_common, 2021)

energyData_2019 <- unify_ColumnName(rawData_energy_2019, rawData_energy_colName_2019, rawData_energy_colName_common, 2019)
energyData_2020 <- unify_ColumnName(rawData_energy_2020, rawData_energy_colName_2020, rawData_energy_colName_common, 2020)
energyData_2021 <- unify_ColumnName(rawData_energy_2021, rawData_energy_colName_2021, rawData_energy_colName_common, 2021)


hhdData_merged <- hhdData_2019 %>%
  bind_rows(hhdData_2020, hhdData_2021)

energyData_merged <- energyData_2019 %>%
  bind_rows(energyData_2020, energyData_2021)


### Who has reponded every time? ###
hhd_alltime <- hhdData_merged %>%
  count(가구ID) %>%
  filter(n == 3) %>%
  pull(가구ID)


### select wanted sample ###
hhdData_wtdSample <- hhdData_merged %>%
  filter(가구ID %in% hhd_alltime)

energyData_wtdSample <- energyData_merged %>%
  filter(가구ID %in% hhd_alltime)

hhd_energyData_wtdSample <- hhdData_wtdSample %>%
  left_join(energyData_wtdSample, by = c("가구ID", "연도"))




### Add more variable ###
hhd_energyData_wtdSample_addVar <- hhd_energyData_wtdSample %>%
  
  # 난방연료 #
  mutate(난방연탄사용여부 = case_when(
    
    난방연료 == 1 ~ 1,
    TRUE ~ 0
    
  )) %>%
  mutate(난방등유사용여부 = case_when(
    
    난방연료 == 2 ~ 1,
    TRUE ~ 0
    
  )) %>%
  mutate(난방프로판사용여부 = case_when(
    
    난방연료 == 3 ~ 1,
    TRUE ~ 0
    
  )) %>%
  mutate(난방연등프사용여부 = case_when(
    
    난방연료 %in% c(1,2,3) ~ 1,
    TRUE ~ 0
    
  )) %>%
  
  # 취사 기기 #
  mutate(취사프로판사용여부 = case_when(
    
    취사설비 == 1 ~ 1,
    TRUE ~ 0
    
  ))
  
  # 
  # # 난방연료 #
  # mutate(연등프여부 = case_when(
  #   
  #   난방연료 %in% c(1,2,3) ~ 1,
  #   TRUE ~ 0
  #   
  # ))
  

  
  
  
  
  
  # mutate(경기도여부 = case_when(
  #   
  #   광역시도 == 31 ~ 1,
  #   TRUE ~ 0
  #   
  # ))
  

##################################################
############# TPR : Ten Percent Rule #############
##################################################
# 가처분소득 중 에너지비용이 차지하는 비중이 10% 이상.

#############################################################
############# MEPI : Multidimensional Energy Poverty Index ##
#############################################################
# [참고] 가계금융복지조사 결과표 : 3분위 2019년 처분가능소득: 3942 만원
# [참고] 가계금융복지조사 결과표 : 3분위 2020년 처분가능소득: 4109 만원
# [참고] 가계금융복지조사 결과표 : 3분위 2021년 처분가능소득: 4244 만원
thirdQ_income_2019 <- 3942
thirdQ_income_2020 <- 4109  
thirdQ_income_2021 <- 4244  
# 다음의 3가지 조건을 모두 충족.

# 1. 소득대비 에너지비용 지출이 10%
# 2. 가계금융복지조사 결과표 : 3분위 2020년 처분가능소득: 4109만원
# 3. 건축물이 30년 이상.


### Energy Cost calculation ###
hhd_energyData_wtdSample_wCost <- hhd_energyData_wtdSample_addVar %>%
  mutate(전기요금 = 전기소비량 * Mcal_to_kWh * 108, # kWh * (원/kWh)
         난방요금 = 지역난방소비량 * 112, # Mcal * (원/Mcal)
         가스요금 = 도시가스소비량 * Mcal_to_MJ * 15.1, # Mcal * MCal_to_MJ * (원/MJ)
         등유요금 = 등유소비량 * thous / kerosLiter_to_kcal * 850, # Mcal * Mcal_to_kcal * kcal_to_Liter * (원/Liter)
         프판요금 = 프로판소비량 * thous / prpnKg_to_kcal * 1850, # 
         연탄요금 = 연탄소비량 * thous / brqKg_to_kcal / brqEach_to_kg * 657, # 
         #에너지요금 = sum(전기요금, 난방요금, 가스요금, 등유요금, 프판요금, 연탄요금)
         에너지요금 = 전기요금 + 난방요금 + 가스요금 + 등유요금 + 프판요금 + 연탄요금,
         에너지요금 = 에너지요금 / 10000) %>% # 만원
  mutate(에너지요금비중 = 에너지요금 / c(세후소득))

hhd_energyData_wtdSample_wCost_wTPR_wMEPI <- hhd_energyData_wtdSample_wCost %>%
  mutate(TPR = case_when(
    
    에너지요금비중 > 0.1 ~ 1,
    TRUE ~ 0
  )) %>%
  mutate(TPR_lag = lag(TPR)) %>%
  
  mutate(MEPI = case_when(
    
    TPR == 1 & 준공년도 <= 1994 & 연도 == 2019 & 세후소득 <= thirdQ_income_2019 ~ 1,
    TPR == 1 & 준공년도 <= 1994 & 연도 == 2020 & 세후소득 <= thirdQ_income_2020 ~ 1,
    TPR == 1 & 준공년도 <= 1994 & 연도 == 2021 & 세후소득 <= thirdQ_income_2021 ~ 1,
    TRUE ~ 0
    
  ))



######################################################
############# Data Trim & make lag term  #############
######################################################
fullData_wLag <- hhd_energyData_wtdSample_wCost_wTPR_wMEPI %>%
  filter(!c(교육정도 %in% c(-9, -8, 1938))) %>% # 결측치 143개
  filter(!c(세후소득 < 0 | is.na(세후소득))) %>% # 결측치 2257개
  group_by(가구ID) %>%
  mutate(TPR_lag = lag(TPR)) %>%
  mutate(MEPI_lag = lag(MEPI))



######################################################
################ Dynamic Probit Model ################
######################################################
### MEPI-1 ### basic 
model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 광역시도 + 주택종류 + 지하여부 + 옥탑여부 + 외벽수 + 
                난방연탄사용여부 + 난방등유사용여부 + 난방프로판사용여부 + 
                취사프로판사용여부 +
                교육정도 + 출생년도 + 가구원수,
              family = binomial(link = "probit")
) 
summary(model)

model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 광역시도 + 주택종류 + 지하여부 + 옥탑여부 + 외벽수 + 
                난방연등프사용여부 + 
                취사프로판사용여부 +
                교육정도 + 출생년도 + 가구원수,
              family = binomial(link = "probit")
) 
summary(model)

model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 광역시도 + 주택종류 + 지하여부 + 옥탑여부 + 외벽수 + 
                난방연료 + 
                취사프로판사용여부 +
                교육정도 + 출생년도,
              family = binomial(link = "probit")
) 
summary(model)



### TPR-1 ### basic 
model <- glm( data = fullData_wLag,
              TPR ~ TPR_lag + 광역시도 + 주택종류 + 외벽수 + 난방연료 + 취사설비 + 교육정도 + 출생년도 + 가구원수,
              family = binomial(link = "probit")
) 
summary(model)


### MEPI-1 ### basic 
model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 광역시도 + 주택종류 + 외벽수 + 입주형태 + 난방연료 + 취사설비 + 교육정도 + 출생년도 + 가구원수,
              family = binomial(link = "probit")
) 
summary(model)


### MEPI-1 ### basic 
model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 광역시도 + 주택종류 + 외벽수 + 입주형태 + 가구원수 +
                등유사용여부 + 난방프로판사용여부 + 연탄사용여부 + 취사프로판사용여부 + 교육정도 + 출생년도,
              family = binomial(link = "probit")
) 
summary(model)




### MEPI-1 ### basic + 지하여부 + 옥탑여부 + (프판여부 - 취사설비) + (연여부 + 등여부 + 프여부 - 난방연료)
model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 광역시도 + 주택종류 + 지하여부 + 옥탑여부 + 외벽수 + 
                등유사용여부 + 난방프로판사용여부 + 연탄사용여부 + 취사프로판사용여부 + 교육정도 + 출생년도,
              family = binomial(link = "probit")
) 
summary(model)






### MEPI-1 ### basic + 지하여부 + 옥탑여부 + (프판여부 - 취사설비) + (연등프여부 - 난방연료)
model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 광역시도 + 주택종류 + 지하여부 + 옥탑여부 + 외벽수 + 연등프여부 + 프판여부 + 교육정도 + 출생년도,
              family = binomial(link = "probit")
) 
summary(model)





### MEPI-1 ###   + 경기도여부, -광역시도
model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 주택종류 + 외벽수 + 난방기기 + 난방연료 + 취사설비 + 교육정도 + 출생년도 + 경기도여부,
              family = binomial(link = "probit")
) 
summary(model)


### MEPI-1 ### energyType여부
model <- glm( data = fullData_wLag,
              MEPI ~ MEPI_lag + 광역시도 + 주택종류 + 외벽수 + 난방기기 + 난방연료 + 취사설비 + 교육정도 + 출생년도 + 지역난방사용여부 + 등유사용여부 + 프로판사용여부 + 연탄사용여부,
              family = binomial(link = "probit")
) 
summary(model)
logLik(model)













# 2. Dynamic Probit 모델 적합
model <- glm( data = fullData_TPR_wLag,
  TPR ~ TPR_lag + 광역시도 + 주택종류 + 외벽수 + 주택방향 + 준공년도 + 난방기기 + 난방연료 + 취사설비 + 냉방만족도 + 난방만족도 + 가구원수 + 교육정도 + 출생년도 + 세후소득 + 
    전기소비량 + 지역난방소비량 + 도시가스소비량 + 등유소비량 + 프로판소비량 + 기타석유소비량 + 연탄소비량 + 기타연료소비량 + 석유소비량,  # 설명 변수 포함
  family = binomial(link = "probit")
)

model <- glm( data = fullData_TPR_wLag,
              TPR ~  TPR_lag + 광역시도 + 주택종류 + 외벽수 + 주택방향 + 준공년도 + 난방기기 + 난방연료 + 취사설비 + 냉방만족도 + 난방만족도 +  교육정도 + 출생년도, # 설명 변수 포함
              family = binomial(link = "probit")
)

# 3. 결과 요약
summary(model)

# 4. 예측값 계산
data$predicted_prob <- predict(model, type = "response")

# 5. 지역별 예측값 분석 (옵션)
data %>%
  group_by(dummy1) %>%
  summarise(mean_prob = mean(predicted_prob)) %>%
  arrange(desc(mean_prob))





# 필요한 패키지 설치 및 로드
#library(dplyr)

# 1. 데이터 준비
set.seed(123)  # 재현성을 위해 시드 설정
n <- 5789  # 개체 수
t <- 3     # 시계열 길이

# 더미 변수 포함한 데이터 생성
data <- data.frame(
  id = rep(1:n, each = t),            # 개체 ID
  time = rep(1:t, n),                 # 시간
  x1 = rnorm(n * t),                  # 연속형 변수 1
  x2 = rnorm(n * t),                  # 연속형 변수 2
  dummy1 = sample(0:1, n * t, TRUE),  # 더미 변수 1
  dummy2 = sample(0:1, n * t, TRUE),  # 더미 변수 2
  y = NA                              # 종속 변수
)

# 초기값 설정 및 동적 관계 생성
data <- data %>%
  group_by(id) %>%
  mutate(
    y_lag = lag(y),  # 시간 지연된 y 생성
    y = ifelse(time == 1, rbinom(1, 1, 0.5), NA)  # 첫 시간의 y를 랜덤 생성
  ) %>%
  ungroup()

# 나머지 y를 동적 관계로 생성
for (i in 2:nrow(data)) {
  if (!is.na(data$y[i - 1]) && data$id[i] == data$id[i - 1]) {
    data$y[i] <- rbinom(1, 1, pnorm(0.5 * data$y[i - 1] + 0.3 * data$x1[i] - 0.2 * data$x2[i] + 0.1 * data$dummy1[i] - 0.1 * data$dummy2[i]))
  }
}

# 결측치 제거
data <- data %>%
  group_by(id) %>%
  mutate(y_lag = lag(y)) %>%
  ungroup() %>%
  filter(!is.na(y_lag))

# 2. Dynamic Probit 모델 적합
model <- glm(
  y ~ y_lag + x1 + x2 + dummy1 + dummy2,  # 설명 변수 포함
  family = binomial(link = "probit"),
  data = data
)

# 3. 결과 요약
summary(model)

# 4. 예측값 계산
data$predicted_prob <- predict(model, type = "response")

# 5. 지역별 예측값 분석 (옵션)
data %>%
  group_by(dummy1) %>%
  summarise(mean_prob = mean(predicted_prob)) %>%
  arrange(desc(mean_prob))




# # 1. 가상 데이터 생성
# set.seed(123)  # 재현 가능성을 위해 시드 설정
# n <- 1000  # 데이터 개수
# 
# # 데이터프레임 생성
# data <- data.frame(
#   id = rep(1:100, each = 10),   # 100명의 개인 ID
#   time = rep(1:10, 100),        # 각 개인의 시간
#   x = rnorm(1000),              # 독립 변수 (연속형)
#   y = NA                        # 종속 변수 (이진형, Probit에 사용)
# )
# 
# # 초기값 설정 및 동적 관계 생성
# data$y[1] <- rbinom(1, 1, 0.5)  # 첫 값은 랜덤
# for (i in 2:nrow(data)) {
#   # 동적 구조: 이전 y값과 x값에 따라 y 결정
#   data$y[i] <- ifelse(data$time[i] > 1 & data$id[i] == data$id[i-1],
#                       rbinom(1, 1, pnorm(0.5 * data$y[i-1] + 0.3 * data$x[i])),
#                       rbinom(1, 1, 0.5))
# }
# 
# # 2. Lag 변수 생성 (y의 시간 지연변수)
# data <- data %>%
#   group_by(id) %>%
#   mutate(y_lag = lag(y, 1)) %>%
#   ungroup()
# 
# # Lag 데이터 결측치 제거 (첫 번째 row의 y_lag는 NA)
# data <- data %>% filter(!is.na(y_lag))
# 
# # 3. Dynamic Probit 모델 적합
# dynamic_probit_model <- glm(
#   y ~ y_lag + x,  # y_lag와 x를 독립변수로 사용
#   family = binomial(link = "probit"),  # Probit 링크 함수 사용
#   data = data
# )
# 
# # 4. 결과 요약
# summary(dynamic_probit_model)
# 
# # 5. 예측값 계산 (예: 새로운 데이터셋에서 예측)
# data$predicted_prob <- predict(dynamic_probit_model, type = "response")
# 
# # 결과 확인
# head(data)
