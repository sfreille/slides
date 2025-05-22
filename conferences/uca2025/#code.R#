library(data.table)
library(ggplot2)
library(plotly)
options(scipen=999)

rop <- fread("subnational-rop.csv",encoding="Latin-1")
rot <- fread("subnational-rot.csv",encoding="Latin-1",fill=TRUE,dec=".")
gp <- fread("consolidado-gp.csv",dec=",")

### Plot 1
rop <- rop %>%
    pivot_longer(
        c("iibb","inmuebles","sellos","automotor","otros"),names_to="impuesto",values_to="valor")

rop <- rop %>%
    arrange(desc(valor)) %>%
    mutate(impuesto=factor(impuesto,levels=rev(unique(impuesto))))

p1 <- ggplot(rop,aes(year,valor,fill=impuesto))+geom_bar(position="fill",stat='identity')+scale_x_continuous(breaks = scales::pretty_breaks(n = 16))

ggplotly(p1,width=1400,height=500)

### Plot 2

p2 <- ggplot(rop[rop$provincia=="Buenos Aires",],aes(year,valor,fill=impuesto))+geom_bar(position="fill",stat='identity')+scale_x_continuous(breaks = scales::pretty_breaks(n = 16))+facet_wrap(~provincia)
ggplotly(p2,width=1400,height=500)

ggplot(rop[rop$provincia=="Tierra Del Fuego",],aes(year,valor,fill=impuesto))+geom_bar(position="fill",stat='identity')+scale_x_continuous(breaks = scales::pretty_breaks(n = 16))+facet_wrap(~provincia)

ggplot(rop,aes(year,valor,fill=impuesto))+geom_bar(position="fill",stat='identity')+scale_x_continuous(breaks = scales::pretty_breaks(n = 16))+facet_wrap(~provincia)

### Plot 3 a 5

rot <- rot[rot$year>1990,]
rot$res_pri_cat <- as.factor(ifelse(rot$res_pri>0, "Sup. Primario","Déf. Primario"))
rot$res_tot_cat <- as.factor(ifelse(rot$res_tot>0, "Sup. Total","Déf. Total"))
rot$gas_cor_per <- rot$gas_cor/rot$gas_tot
rot$gas_cap_per <- rot$gas_cap/rot$gas_tot
rot$gas_cor_pc  <- (rot$gas_cor/rot$pop)*1000000
rot$gas_cap_pc  <- (rot$gas_cap/rot$pop)*1000000
rot$gas_tot_pc <- (rot$gas_tot/rot$pop)*1000000
rot$trf_cor_pc <- (rot$trf_cor/rot$pop)*1000000
rot$trf_copa_pc <- (rot$trf_copa/rot$pop)*1000000
rot$gas_cor_cte_pc  <- (rot$gas_cor_cte/rot$pop)*1000000
rot$gas_cap_cte_pc  <- (rot$gas_cap_cte/rot$pop)*1000000
rot$gas_tot_cte_pc <- (rot$gas_tot_cte/rot$pop)*1000000
rot$trf_cor_cte_pc <- (rot$trf_cor_cte/rot$pop)*1000000
rot$trf_copa_cte_pc <- (rot$trf_copa_cte/rot$pop)*1000000


rot$year_period <- as.factor(ifelse(rot$year>1989&rot$year<2000,"Menem",ifelse(rot$year>2002&rot$year<2016,"Kirchner","Post-Kirchner")))

rot$year_period2 <- as.factor(ifelse(rot$year>1989&rot$year<2000,"Menem",ifelse(rot$year>2002&rot$year<2016,"Kirchner",ifelse(rot$year>2015&rot$year<2020,"Macri",ifelse(rot$year>2019&rot$year<2024,"AF/CFK","Milei")))))

### a valores constantes, transferencias corrientes
p3a <- ggplot(rot,aes(log(trf_cor_cte_pc),log(gas_tot_cte_pc),colour=year_period))+geom_point()+geom_smooth(method="lm")
ggplotly(p3a)

### a valores corrientes, transferencias corrientes
p3b <- ggplot(rot,aes(log(trf_cor_pc),log(gas_tot_pc),colour=year_period))+geom_point()+geom_smooth(method="lm")
ggplotly(p3b)


### a valores constantes, copa
p4a <- ggplot(rot,aes(log(trf_copa_cte_pc),log(gas_tot_cte_pc),colour=year_period2))+geom_point()+geom_smooth(method="lm")
ggplotly(p4a)

### a valores corrientes, copa
p4b <- ggplot(rot,aes(log(trf_copa_pc),log(gas_cap_pc)))+geom_point()+geom_smooth(method="lm")
ggplotly(p4b)

ggplot(rot, aes(year,provincia,fill=res_pri_cat))+geom_tile()
ggplot(rot, aes(year,provincia,fill=res_tot_cat))+geom_tile()

ggplot(rot, aes(year,provincia,fill=res_pri))+geom_tile()

### Plot 6

gp <- gp %>%
    pivot_longer(c("gp_nac_pbi","gp_pro_pbi","gp_mun_pbi"),names_to="nivel",values_to="porc_pbi")

p6 <- ggplot(gp,aes(year,porc_pbi,colour=nivel))+geom_line(linewidth=1.25,linetype=1)+geom_smooth(method="lm",linetype=2)+labs(title="Gasto publico (como %PBI) segun nivel de gobierno", x="Periodo", y="Gasto publico total (como % PBI)")+scale_x_continuous(breaks = scales::pretty_breaks(n = 10))+theme(legend.position="top")
ggplotly(p6)

### Plot 7

# a valores constantes
p7a <- ggplot(rot,aes(log(trf_cor_cte_pc),log(emp_pc),colour=year_period2))+geom_point()+geom_smooth(method="lm")
ggplotly(p7a)

p7b <- ggplot(rot,aes(log(trf_cor_pc),log(emp_pc),colour=year_period2))+geom_point()+geom_smooth(method="lm")
ggplotly(p7b)

p7c <- ggplot(rot,aes(log(trf_cor_pc),log(emp_pc)))+geom_point()+geom_smooth(method="lm")+facet_wrap(~year_period2)
ggplotly(p7c)

p7d <- ggplot(rot,aes(log(trf_cor_cte_pc),log(emp_pc)))+geom_point()+geom_smooth(method="lm")+facet_wrap(~year_period2)
ggplotly(p7d)

p7e <- ggplot(rot,aes(log(trf_cor_cte_pc),emp_pc))+geom_point()+geom_smooth(method="lm")+facet_wrap(~region)
ggplotly(p7e)

p7f <- ggplot(rot,aes(log(trf_copa_cte_pc),emp_pc,colour=year_period))+geom_point()+geom_smooth(method="lm",se=FALSE)+facet_wrap(~region,scales="free")+labs(title="Coparticipacion y empleo publico",x="(Log) Coparticipacion pc, a valores constantes",y="Empleo publico (por 1000 habitantes)")
ggplotly(p7f)

p7g <- ggplot(rot,aes(log(trf_cor_cte_pc),emp_pc,colour=year_period))+geom_point()+geom_smooth(method="lm",se=FALSE)+ facet_wrap(~region,scales="free")+labs(title="Transferencias corrientes y empleo publico",x="(Log) Transferencias corrientes pc, a valores constantes",y="Empleo publico (por 1000 habitantes)")
ggplotly(p7g)
