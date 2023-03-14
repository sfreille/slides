dat <- read.csv("country-level-government-spending-vs-income.csv",header=TRUE)
dat <- dat[dat$Code!="QAT",]
dat <- dat[dat$Code!="KIR",]
dat <- dat[dat$Code!="TUV",]
dat2011 <- dat[dat$Year==2011,]
dat2011  <- dat2011[dat2011$Population..historical.estimates.<1500000000,]
dat2011  <- dat2011[dat2011$Population..historical.estimates.!="NA",]


pointsToLabel <- c("Russia","Venezuela","Iraq","Myanmar","Sudan","Afghanistan","Congo","Greece","Argentina","Italy","South Africa", "Spain","Botswana", "Cape Verde", "Bhutan","Rwanda","France","United States","Germany","Britain","Barbados","Norway","Japan","New Zealand","Singapore","Uruguay","Chile","Turkey","Portugal","Peru","Mexico","Israel","Italy","Lesotho","South Korea","Hong Kong","Lybia","Saudi Arabia","Kuwait","Oman","China","India","Kenya","Brazil","Mexico","Qatar","United Arab Emirates","Ethiophia","Pakistan","Libya","Greece","Fiji","Egypt","Malawi","Mozambique","Burundi")

png("fig01.png",width=1920,height=1080,res=225)
ggplot(dat2011, aes(x=Government.Expenditure..IMF.based.on.Mauro.et.al...2015..,y=GDP.per.capita..PPP..constant.2017.international...)) + geom_point(colour="purple",alpha=0.5,aes(size=Population..historical.estimates.))+scale_size_continuous(range=c(1,30)) + geom_text_repel(size=4,aes(label=Entity), data=dat2011[dat2011$Entity %in% pointsToLabel,],min.segment.length = Inf)+theme(legend.position="none")+ ylab("PIB per capita (2010)")+xlab("Gasto publico como fraccion del PIB (2010)")+ theme(text=element_text(size=14),axis.text=element_text(size=14))+xlim(20,65)+scale_y_log10(breaks=c(1000,2000,5000,10000,20000,50000))
dev.off()


dat2 <- read.csv("country-level-taxes-vs-income.csv",header=TRUE)
dat22015 <- dat2[dat2$Year==2015,]

dat22015  <- dat22015[dat22015$Population..historical.estimates.<1500000000,]
dat22015  <- dat22015[dat22015$Population..historical.estimates.!="NA",]

png("fig02.png",width=1920,height=1080,res=225)
ggplot(dat22015, aes(x=Total.tax.revenue....of.GDP...ICTD..2021.., y=GDP.per.capita..PPP..constant.2017.international...)) + geom_point(colour="purple",alpha=0.5,aes(size=Population..historical.estimates.))+scale_size_continuous(range=c(1,30))+geom_text_repel(size=4,aes(label=Entity), data=dat22015[dat22015$Entity %in% pointsToLabel,],min.segment.length = Inf)+ylab("PIB per capita (2010)")+xlab("Recaudacion tributaria como fraccion del PIB (2010)")+ theme(text=element_text(size=14),axis.text=element_text(size=14))+xlim(20,50)+scale_y_log10(breaks=c(1000,2000,5000,10000,20000,50000))+theme(legend.position="none")
dev.off()
