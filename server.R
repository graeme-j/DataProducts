library(lubridate)
library(forecast)
library(ggplot2)
library(dplyr)
shinyServer(function(input, output) {
  rates <- read.table("ExchangeRates.txt", header = TRUE, sep = "\t", stringsAsFactors = F)
  output$main_plot <- renderPlot({
    rates$DateKey <- ymd(rates$DateKey)
    rates$Currency <- factor(rates$Currency)
    
    g <- ggplot(rates, aes(DateKey, RateToCAD, colour = Currency)) + geom_line(data = rates, aes(group=Currency), size=2) + xlab("")
    
    if(input$rolling_avg){
      
      USD_ma <- ma(rates%>%filter(Currency=="USD")%>%select(RateToCAD), order=input$ma_size)
      EUR_ma <- ma(rates%>%filter(Currency=="EUR")%>%select(RateToCAD), order=input$ma_size)
      GBP_ma <- ma(rates%>%filter(Currency=="GBP")%>%select(RateToCAD), order=input$ma_size)
      dates <- rates%>%filter(Currency=="USD")%>% select(DateKey)
      ma_d <- rbind(data.frame(DateKey = dates, RateToCAD = USD_ma, Currency = "USD"),data.frame(DateKey = dates, RateToCAD = EUR_ma, Currency = "EUR"),data.frame(DateKey = dates, RateToCAD = GBP_ma, Currency = "GBP"))
      
      g <- g + geom_line(data = ma_d, aes(group=Currency), color = rgb(.4,.4,.4,1), size=1) 
      
    }
    if(input$trendline){
      g <- g + geom_smooth(method = "lm", se=F, aes(group = Currency), colour ="red")
    }
    if(input$forecast){
      USD_ts<- ts((rates%>%filter(Currency=="USD")%>%select(RateToCAD))$RateToCAD, frequency = 12, start = c(2013,12))
      usd_f <- hw(USD_ts, seasonal = "additive", damped = TRUE, h=6, initial = "optimal")
      GBP_ts<- ts((rates%>%filter(Currency=="GBP")%>%select(RateToCAD))$RateToCAD, frequency = 12, start = c(2013,12))
      gbp_f <- hw(GBP_ts, seasonal = "additive", damped = TRUE, h=6, initial = "optimal")
      EUR_ts<- ts((rates%>%filter(Currency=="EUR")%>%select(RateToCAD))$RateToCAD, frequency = 12, start = c(2013,12))
      eur_f <- hw(EUR_ts, seasonal = "additive", damped = TRUE, h=6, initial = "optimal")
      
      usd_df_f <- data.frame(date=as.Date(as.yearmon(time(usd_f$mean))), Y=as.matrix(usd_f$mean))
      gbp_df_f <- data.frame(date=as.Date(as.yearmon(time(gbp_f$mean))), Y=as.matrix(gbp_f$mean))
      eur_df_f <- data.frame(date=as.Date(as.yearmon(time(eur_f$mean))), Y=as.matrix(eur_f$mean))
      
      g <- g + geom_smooth(aes(x=date, y=Y), colour='blue', data=usd_df_f, stat='identity')
      g <- g + geom_smooth(aes(x=date, y=Y), colour='green', data=gbp_df_f, stat='identity')
      g <- g + geom_smooth(aes(x=date, y=Y), colour='red', data=eur_df_f, stat='identity')
    }
    g
    #plot(rates$DateKey, rates$RateToCAD, type="l")
    # hist(faithful$eruptions,
    #      probability = TRUE,
    #      breaks = as.numeric(input$n_breaks),
    #      xlab = "Duration (minutes)",
    #      main = "Geyser eruption duration")
    # 
    # if (input$individual_obs) {
    #   rug(faithful$eruptions)
    # }
    # 
    # if (input$density) {
    #   dens <- density(faithful$eruptions,
    #                   adjust = input$bw_adjust)
    #   lines(dens, col = "blue")
    # }
    # 
  })
})