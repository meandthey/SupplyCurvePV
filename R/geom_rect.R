library(plotly)

df <- data.frame(name = c("Nixon", "Ford", "Carter", "Reagan", "Bush", "Clinton", "Bush", "Obama"),
                 start = as.Date(c("1969-01-20", "1974-08-09", "1977-01-20", "1981-01-20",
                                   "1989-01-20", "1993-01-20", "2001-01-20", "2009-01-20")),
                 end = as.Date(c("1974-08-09", "1977-01-20", "1981-01-20", "1989-01-20", 
                                 "1993-01-20", "2001-01-20", "2009-01-20", "2017-01-20")),
                 party = c("R", "R", "D", "R", "R", "D", "R", "D"),
                 stringsAsFactors = FALSE) %>%
  mutate(median_x = start + floor((end-start)/2))

p <- ggplot(economics, aes(x=date,y=unemploy)) +
  geom_rect(data=df, aes(NULL,NULL,xmin=start,xmax=end,fill=party),
            ymin=0,ymax=16000, colour="white", size=0.5, alpha=0.2) +
  scale_fill_manual(values=c("R" = "red", "D" = "blue")) +
  geom_line() +
  geom_text(data=df,aes(x=median_x,y=3000,label=name), size=3) +
  labs(title = "Unemmployment numbers since 1967",
       y = "No. unemployed (x 1000)")
fig <- ggplotly(p)
fig




#########################################################################################################################################################################################
d=data.frame(x1=c(1,3,1,5,4), x2=c(2,4,3,6,6), y1=c(1,1,4,1,3), y2=c(2,2,5,3,5), t=c('a','a','a','b','b'), r=c(1,2,3,4,5))
ggplot() + 
  scale_x_continuous(name="x") + 
  scale_y_continuous(name="y") +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2, fill=t), color="black", alpha=0.5, size = 2) +
  geom_text(data=d, aes(x=x1+(x2-x1)/2, y=y1+(y2-y1)/2, label=r), size=4)
  opts(title="geom_rect", plot.title=theme_text(size=40, vjust=1.5))
