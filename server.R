library(shiny)
library(rCharts)

# Read the data file
cdata=read.csv("www/college_ranking.csv", header=T)

# Split the data into two frames - one is for Universities, the other is for Liberal Arts Colleges
cdata_u=subset(cdata, Type=="University")
cdata_la=subset(cdata, Type=="Liberal Arts")

# Rank the data based on the mid-career Salary, separately in each College Category and then combine back into one data frame
cdata_u$Payrank=rank(-cdata_u$Salary, ties.method="min")
cdata_la$Payrank=rank(-cdata_la$Salary, ties.method="min")
cdata=rbind(cdata_u, cdata_la)

# Run the regression predicting one ranking parameter by the other and add the predicted (fitted) ranking to the data frame
model=lm(Payrank~Ranking, data=cdata)
cdata$Fitted=fitted(model)

# Calculate the threshold that will be used to categorize colleges
sterror=summary(model)$sigma
threshold=1.2*sterror

# Categorize colleges based on the distance from the regression line
cdata$Conclusion="Properly Rated"
cdata$Conclusion=ifelse(cdata$Fitted-cdata$Payrank > 0, yes="Underrated", no="Overrated")
cdata$Conclusion=ifelse(abs(cdata$Fitted-cdata$Payrank) < threshold, yes="Properly Rated", no=cdata$Conclusion)

# Draw the chart that will react to users' inputs
shinyServer(function(input, output) {
  output$help_file = renderText(includeHTML("www/documentation.html"))
  output$ratingsChart = renderChart({
    
    type_string=ifelse(input$type=="All", yes="0", no="Type==input$type")
    region_string=ifelse(input$region=="All", yes="0", no="Region==input$region")
    ownership_string=ifelse(input$ownership=="All", yes="0", no="Ownership==input$ownership")
    
    cdata_tmp=cdata
    cdata_tmp=eval(parse(text=paste("subset(cdata_tmp,", ifelse(type_string==0, yes='', no=type_string), ")")))
    cdata_tmp=eval(parse(text=paste("subset(cdata_tmp,", ifelse(region_string==0, yes='', no=region_string), ")")))
    cdata_tmp=eval(parse(text=paste("subset(cdata_tmp,", ifelse(ownership_string==0, yes='', no=ownership_string), ")")))

    p=rPlot(
      Payrank~Ranking, data=cdata_tmp, 
      type='point',
      size=list(const=3),
      tooltip="#!function(item) {return item.Name + ': $' + item.Salary}!#",
      color='Conclusion'
    )
    
    p$guides(
      color=list(scale="#! function(value) {
             color_mapping={Overrated:'red', Underrated:'blue', 'Properly Rated':'green'}
             return color_mapping[value];
  } !#"),
      y = list(title = "PayScale Ranking", min=0, max=200), x = list(title = "US News Ranking", min=0, max=200)
    )
    
    p$layer(y='Fitted', x='Ranking', data=cdata, type='line', color=list(const='red'), size=list(const=2))
    p$set(width=700, height=800)
    p$set(title="US Colleges Rating")
    p$set(legend=T)
    p$addParams(dom="ratingsChart")
    return(p)
  })
})
