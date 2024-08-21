library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)

thous <- 10^(3) 
mil <- 10^(6)

## 전국태양광발전소전기사업허가정보표준데이터-20240628.xlsx
# 설비용량, 설비면적 둘다 숫자 있는 것중에 가능한 샘플은 아래와 같음.
# 기타: 1279
# 옥외: 2390
# 옥상: 5207
# 건물일체형 : 4
# 주차장: 25

rawData <- readxl::read_excel("../data/전국태양광발전소전기사업허가정보표준데이터-20240813.xlsx", sheet = '데이터', skip = 0, col_names = T) %>%
  mutate(설비용량 = as.numeric(설비용량),
         설치면적 = as.numeric(설치면적))## 전국: 50,000개

allprvData <- rawData %>%
  filter(!is.na(설치면적),
         !is.na(설비용량)) %>%
  filter(설치상세위치구분명 == "옥외" |
           설치상세위치구분명 == "옥상" ) %>%
  mutate(coef = 설치면적 / 설비용량) %>%
  select(소재지도로명주소, 소재지지번주소, 설치상세위치구분명, 설비용량, 설치면적, coef) %>%
  arrange(coef) %>%
  mutate(ID = c(1:nrow(.))) %>%
  filter(ID > 24 & ID < 2322) %>%
  mutate(설치상세위치구분명 = case_when(
    
    설치상세위치구분명 == "옥외" ~ "Ground-mounted PV",
    설치상세위치구분명 == "옥상" ~ "Roof-top PV"
    
  ))




##### normal Scale #####

allprvData %>%
  filter(설치상세위치구분명 == "Ground-mounted PV") %>%
  mutate(average = sum(설치면적)/sum(설비용량)) 

allprvData %>%
  filter(설치상세위치구분명 == "Roof-top PV") %>%
  mutate(average = sum(설치면적)/sum(설비용량))

averageLine_Normal <- data.frame(sl = c(11.5083, 7.2379),
                    int = c(0,0),
                    Type = c("Ground-mounted PV", "Roof-top PV"))

ggplot(data = allprvData, aes(x =  설비용량, y = 설치면적)) +
  geom_point(aes(colour = 설치상세위치구분명), size = 5) +
  geom_abline(data = averageLine_Normal, linetype = 2, linewidth = 0.8, aes(slope = sl, intercept = int, colour = Type)) +
  theme(legend.position = "right",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 40)) +
  scale_x_continuous(breaks = c(0, 250, 500, 750, 1000)) +
  scale_y_continuous(breaks = c(0, 5000, 10000, 15000, 20000, 25000, 30000))
  #coord_cartesian(expand = FALSE,
  #                xlim = c(1, 50000), ylim = c(1, 50000)) +
  #annotation_logticks() 



##### Log10 Scale #####
allprvData %>%
  filter(설치상세위치구분명 == "Ground-mounted PV") %>%
  mutate(average = sum(log10(설치면적))/sum(log10(설비용량)))


allprvData %>%
  filter(설치상세위치구분명 == "Roof-top PV") %>%
  mutate(average = sum(log10(설치면적))/sum(log10(설비용량)))

averageLine_Log10 <- data.frame(sl = c(1.4834, 1.4336),
                                 int = c(0,0),
                                 Type = c("Ground-mounted PV", "Roof-top PV"))



  

ggplot(data = allprvData, aes(x =  설비용량, y = 설치면적)) +
  geom_point(aes(colour = 설치상세위치구분명), size = 5) +
  geom_abline(data = averageLine_Log10, linetype = 2, linewidth = 0.8, aes(slope = sl, intercept = int, colour = Type)) +

  # scale_x_continuous(trans = 'log10') +
  # scale_y_continuous(trans = 'log10') +
  
  # coord_cartesian(expand = FALSE, 
  #                 xlim = c(1, 2000), ylim = c(1, 50000)) +
  
  theme(legend.position = "right",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 40)) +
  scale_x_continuous(breaks = c(1, 10, 50, 100, 500, 1000, 5000, 10000), trans = 'log10') +
  scale_y_continuous(breaks = c(1, 10, 50, 100, 500, 1000, 5000, 10000), trans = 'log10') +
  coord_cartesian(expand = FALSE,
                  xlim = c(1, 50000), ylim = c(1, 50000)) +
  annotation_logticks() 






## Spatial Join의 Output

rawData <- readxl::read_excel("../data/PV설치 사례조사.xlsx", sheet = '데이터', skip = 0, col_names = T)

rawData_graphData <- rawData %>%
  mutate(technology = case_when(
    
    유형 %in% c("산단", "공동주택", "물류센터", "공공건축물") ~ "Roof-top PV",
    유형 == "주차장" ~ "Ground-mounted PV (Parking lot)",
    유형 == "도로IC" ~ "Ground-mounted PV (Roadside)"
    
  ))
 



##### Normal Scale #####

rawData_graphData_RatioCheck <- rawData_graphData %>%
  group_by(technology) %>% summarize(`설치면적(m2)` = sum(`설치면적(m2)`),
                                     `전체면적 (m2)` = sum(`전체면적 (m2)`)) %>%
  mutate(ratio = `설치면적(m2)` / `전체면적 (m2)`)


averageLine_normal <- data.frame(sl = c(0.189, 0.284, 0.545),
                                int = c(0,0,0),
                                Type = c("Ground-mounted PV (Parking lot)", "Ground-mounted PV (Roadside)", "Roof-top PV"))


ggplot(data = rawData_graphData, aes(x = `전체면적 (m2)`, y = `설치면적(m2)`)) +
  geom_point(aes(colour = technology), size = 5) +
  #geom_abline(slope = 1, linetype = 2) +
  geom_abline(data = averageLine_normal, linetype = 2, linewidth = 0.8, aes(slope = sl, intercept = int, colour = Type)) +
  
  
  scale_x_continuous(breaks = c(0, 5000, 10000, 15000)) +
  scale_y_continuous(breaks = c(0, 1000, 2000, 3000, 4000, 5000, 6000)) +
  
  # coord_cartesian(expand = FALSE, 
  #                 xlim = c(1, 2000), ylim = c(1, 50000)) +
  
  theme(legend.position = "right",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 40))





##### Log10 Scale #####

rawData_graphData %>%
  group_by(technology) %>% summarize(`설치면적(m2)` = sum(log10(`설치면적(m2)`)),
                                     `전체면적 (m2)` = sum(log10(`전체면적 (m2)`))) %>%
  mutate(ratio = `설치면적(m2)` / `전체면적 (m2)`)
  

averageLine_Log10 <- data.frame(sl = c(0.744, 0.845, 0.912),
                                int = c(0,0,0),
                                Type = c("Ground-mounted PV (Parking lot)", "Ground-mounted PV (Roadside)", "Roof-top PV"))


ggplot(data = rawData_graphData, aes(x = `전체면적 (m2)`, y = `설치면적(m2)`)) +
  geom_point(aes(colour = technology), size = 5) +
  #geom_abline(slope = 1, linetype = 2) +
  geom_abline(data = averageLine_Log10, linetype = 2, linewidth = 0.8, aes(slope = sl, intercept = int, colour = Type)) +
  
  
  scale_x_continuous(breaks = c(50, 100, 500, 1000, 5000, 10000), trans = 'log10') +
  scale_y_continuous(breaks = c(50, 100, 500, 1000, 5000, 10000), trans = 'log10') +
  
  # coord_cartesian(expand = FALSE, 
  #                 xlim = c(1, 2000), ylim = c(1, 50000)) +
  
  theme(legend.position = "right",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        #axis.text.x = element_blank(),
        #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        text = element_text(size = 40)) +
  annotation_logticks() 

ggplot(data = rawData_graphData, aes(x = `전체면적 (m2)`, y = `설치면적(m2)`)) +
  geom_point(aes(colour = technology), size = 2) +
  geom_abline(slope = 0.5, linetype = 2)




























rftp_allPrv <- rawData %>%
  filter(설치상세위치구분명 == "옥상") %>%
  filter(!is.na(설치면적),
         !is.na(설비용량)) %>%
  select(소재지도로명주소, 소재지지번주소, 설치상세위치구분명, 설비용량, 설치면적) %>%
  mutate(coef = 설치면적 / 설비용량)

sum(rftp_allPrv$설치면적) / sum(rftp_allPrv$설비용량)




rftp_GG <- rawData %>%
  filter(설치상세위치구분명 == "옥상") %>%
  filter(!is.na(설치면적),
         !is.na(설비용량)) %>%
  filter(grepl("경기", 소재지도로명주소) | grepl("경기", 소재지지번주소)) %>%
  select(소재지도로명주소, 소재지지번주소, 설치상세위치구분명, 설비용량, 설치면적)

sum(rftp_GG$설치면적) / sum(rftp_GG$설비용량)




ggplot(data = rftp_allPrv, aes(x =  설비용량, y = 설치면적)) +
  geom_point(size = 2) +
  geom_abline(slope = 1.4260, intercept = 0, linetype = 2) +
  scale_x_continuous(trans = 'log10') +
  scale_y_continuous(trans = 'log10')


ggplot(data = rftp_GG, aes(x =  설비용량, y = 설치면적)) +
  geom_point(size = 2) +
  geom_abline(slope = 1.4260, intercept = 0, linetype = 2) +
  scale_x_continuous(trans = 'log10') +
  scale_y_continuous(trans = 'log10')




grdmt_allPrv <- rawData %>%
  filter(설치상세위치구분명 == "옥외") %>%
  filter(!is.na(설치면적),
         !is.na(설비용량)) %>%
  #filter(grepl("경기", 소재지도로명주소) | grepl("경기", 소재지지번주소)) %>%
  select(소재지도로명주소, 소재지지번주소, 설치상세위치구분명, 설비용량, 설치면적)

sum(grdmt_allPrv$설치면적) / sum(grdmt_allPrv$설비용량)


grdmt_GG <- rawData %>%
  filter(설치상세위치구분명 == "옥외") %>%
  filter(!is.na(설치면적),
         !is.na(설비용량)) %>%
  filter(grepl("경기", 소재지도로명주소) | grepl("경기", 소재지지번주소)) %>%
  select(소재지도로명주소, 소재지지번주소, 설치상세위치구분명, 설비용량, 설치면적)

sum(grdmt_GG$설치면적) / sum(grdmt_GG$설비용량)




allPV_allPrv <- rftp_allPrv %>%
  bind_rows(grdmt_allPrv)

ggplot(data = allPV_allPrv, aes(x =  설비용량, y = 설치면적)) +
  geom_point(aes(colour = 설치상세위치구분명),size = 2 ) +
  geom_abline(slope = 1.4260, intercept = 0, linetype = 2) +
  scale_x_continuous(trans = 'log10') +
  scale_y_continuous(trans = 'log10')




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
  





