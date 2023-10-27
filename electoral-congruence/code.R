here::i_am("P:/r-Projects/papers/electoral-congruence")

library(here)
library(rgdal)
library(ggplot2)
library(data.table)
library(rio)
library(readr)
library(reshape2)
library(viridis)
library(hrbrthemes)
hrbrthemes::import_roboto_condensed()

### FUENTE D EDATOS
dat_mes  <- import(here("data","mesas-agrupaciones.csv"),setclass="data.table")
dat_pos  <- import(here("data","descripcion_postulaciones.csv"),setclass="data.table",encoding = "UTF-8")
dat_dis  <- import(here("data","distritos.csv"),setclass="data.table",encoding = "UTF-8")
dat_sec  <- import(here("data","secciones.csv"),setclass="data.table",encoding = "UTF-8")

dat <- merge(dat_mes,dat_pos)
dat <- merge(dat,dat_sec,by=c("distrito","seccion"))
dat <- merge(dat,dat_dis,by="distrito")

pre <- dat[categoria=="100000000000"]
pre_dep  <- pre[,.(vts=sum(votos)),by=list(distrito,seccion,nombre_seccion,nombre_agrupacion)]
pre_dep[,prop :=round(prop.table(vts),4), .(distrito,seccion)]
export(pre_dep[nombre_agrupacion %in% "FRENTE DE TODOS"],here("output","data","pre_dep.xlsx"))

### Gobernador PBA
gob_pba  <- dat[categoria=="402000000000"]
gob_pba_dep   <- gob_pba[,.(vts=sum(votos)),by=list(distrito,seccion,nombre_seccion,nombre_agrupacion)]
gob_pba_dep[,prop :=round(prop.table(vts),4), .(seccion)]
export(gob_pba_dep[nombre_agrupacion %in% "FRENTE DE TODOS"],here("output","data","gob_pba_dep.xlsx"))

### Gobernador
gob_cat  <- dat[categoria=="403000000000"]
gob_cat_dep <- gob_cat[,.(vts=sum(votos)),by=list(distrito,seccion,nombre_seccion,nombre_agrupacion)]
gob_cat_dep[,prop :=round(prop.table(vts),4), .(seccion)]
export(gob_cat_dep[nombre_agrupacion %in% "FRENTE DE TODOS"],here("output","data","gob_cat_dep.xlsx"))

### LOAD MAIN DATA - Create new vars, select numeric cols and collapse at PRO level

coa  <- import(here("data-raw","coa.xlsx"),setclass="data.table",dec=".")
coa[,diff1 :=ifelse(sh_gob-sh_prez>=0,"gobW","prezW")]
coa[,diff2 :=sh_gob-sh_prez]

coa[,shift(.SD,2,NA,"lag",TRUE),.(departamento,provincia),.SDcols=17]
coa[,sh_gob_pre :=shift(.SD,2,NA,"lag"),.(departamento,provincia),.SDcols=17]
coa[,encpprezLAA_pre :=shift(.SD,2,NA,"lag"),.(departamento,provincia),.SDcols=28]
coa[,sh_prez_pre :=shift(.SD,2,NA,"lag"),.(departamento,provincia),.SDcols=16]


cols=c("idprov","preselec","reelec_gobp","reelec_gobN","reelec_prezp","reelec_prezN","gpp","ppp","sh_prez","sh_gob","comp_prez","comp_gob","encp_gob","encpdipLAA","encpprezLAA","core","universitarios","desocupacion","nbi","pubemp","dias_prez_dn","dias_prez_sn","dias_prez_gob","dias_dn_gob","dias_sn_gob","conc_prez_dn","conc_prez_sn","conc_prez_gob","conc_gob_dn","conc_gob_sn","PREZ_FPV_svs")

coa.p  <- coa[year %in% c("2003","2007","2011","2015","2019"),lapply(.SD,mean,na.rm=TRUE),by=.(year,provincia,party_gob,regime),.SDcols=cols]

### Figures - Province level

ggplot(coa.p,aes(factor(year),gpp))+geom_bar(stat="identity",fill="purple",color="black")+facet_wrap(~provincia,nrow=4)+labs(title="Gubernatorial power",subtitle="Coding: 1=Neither party/person reelected,2=Party/not person reelected,3=Person/not party reelected,4=Both party and person reelected",x="Year",y="Gubernatorial power scale")+theme_ipsum_ps()+theme(legend.position="none")
ggsave(here("output","figs","gpp.jpg"),height=8,width=12)

ggplot(coa.p,aes(factor(year),encp_gob,group=provincia,color=factor(regime)))+geom_line()+facet_wrap(~provincia,nrow=4)+labs(title="Sub-national electoral competition: effectivennumber of competing parties (ENCP)",x="Year",y="Evolution of effective electoral competition (by ruling national regime)")+theme_ipsum_ps()
ggsave(here("output","figs","encp.jpg"),height=8,width=12)

ggplot(as.data.table(with(coa.p,table(party_gob,year))),aes(year,party_gob,fill=N))+geom_tile()+scale_fill_viridis(direction=-1)+theme_ipsum()+labs(title="Number of sub-national governments by party brand and year",x="Year",y="Party brand")
ggsave(here("output","figs","narrowing.jpg"),height=10,width=12)

ggplot(coa.p,aes(year,encp_gob))+geom_line(col="red")+geom_line(aes(year,encpprezLAA),col="blue")+facet_wrap(~provincia,nrow=4)+labs(title="Party system trends: Federalization or nationalization",subtitle="NOTE: Governors (RED) and Presidents (BLUE)",x="Year",y="ENCP")+  theme_ipsum_ps()
ggsave(here("output","figs","convergence.jpg"),height=8,width=12)


### Figures - Department level

ggplot(coa[preselec %in% 1,], aes(sh_prez,sh_gob,color=diff1))+geom_point()+geom_abline(intercept=0,slope=1)+facet_wrap(year~regime)+labs(title="Vote shares: Presidents and gobernors -- By department",x="President-elect vote share",y="Governor-elect vote share")+theme_ipsum_ps(grid="XY", axis="xy")+theme(legend.position="none")
ggsave(here("output","figs","relative.jpg"),height=8,width=12)

ggplot(coa[preselec %in% 1,], aes(sh_prez,sh_gob,color=factor(year)))+geom_point()+geom_abline(intercept=0,slope=1)+facet_wrap(~provincia)+scale_color_viridis(discrete=TRUE,option="turbo",direction=1,begin=0.8)

ggplot(coa[preselec %in% 1,],aes(diff2,PREZ_FPV_svs))+geom_point()

ggplot(coa[preselec %in% 1 & provincia %in% "Misiones",], aes(sh_prez,sh_gob,color=factor(year)))+geom_point()+geom_abline(intercept=0,slope=1)+facet_wrap(~provincia)

ggplot(coa[preselec %in% 1 & dias_prez_gob > 0,],aes(dias_prez_gob,sh_gob-sh_prez,color=factor(year)))+geom_point()+labs(title="Desdoblamiento y diferencia con presidente",x="Dias antes de la elección a Presidente")

### POSSIBLY TO DISCARD


ggplot(coa.p,aes(factor(year),comp_gob)  )+geom_bar(stat="identity",fill="yellow",color="black")+geom_line(aes(factor(year),encp_gob,group=provincia),col="blue")+facet_wrap(~provincia,nrow=4)+labs(title="Effective number of competing parties (ENCP): Electoral competition",x="Year",y="Gubernatorial power scale")+theme_ipsum_ps()+theme(legend.position="none")
ggsave(here("output","figs","encp01.jpg"),height=10,width=12)


### Econometrics

m1.ols <- lm(sh_prez~sh_prez_pre+sh_gob_pre+factor(year),data=coa)
m2.ols <- lm(sh_prez~sh_prez_pre+sh_gob_pre*core+factor(year),data=coa)
m3.ols <- lm(sh_prez~sh_prez_pre+encpprezLAA_pre+sh_gob_pre*core+factor(year),data=coa)
m4.ols <- lm(sh_prez~sh_prez_pre+comp_prez+sh_gob_pre*core+factor(year),data=coa)
m5.ols <- lm(sh_prez~sh_prez_pre+comp_prez+sh_gob_pre*core+factor(year),data=coa[conc_prez_gob %in% 1,])
m6.ols <- lm(sh_prez~sh_prez_pre+comp_prez+sh_gob_pre*core+factor(year),data=coa[conc_prez_gob %in% 0,])

tab_model(m1.ols,m2.ols,m3.ols,m4.ols,m5.ols,m6.ols,show.intercept=F,show.ci=F,title="Presidential vote share: Pooled OLS",robust=TRUE,dv.labels=c("Prez_sh","Prez_sh","Prez_sh","Prez_sh","Concurrent","Non-concurrent"))

m1.plm <-  plm(sh_prez~sh_prez_pre+sh_gob_pre,data=coa,index=c("indra","year"),effect="time",model="within")
m2.plm <-  plm(sh_prez~sh_prez_pre+sh_gob_pre*core,data=coa,index=c("indra","year"),effect="time",model="within")
m3.plm <-  plm(sh_prez~sh_prez_pre+encpprezLAA_pre+sh_gob_pre*core,data=coa,index=c("indra","year"),effect="time",model="within")
m4.plm <-  plm(sh_prez~sh_prez_pre+encpprezLAA+sh_gob_pre*core,data=coa[conc_prez_gob %in% 1,],index=c("indra","year"),effect="time",model="within")
m5.plm <-  plm(sh_prez~sh_prez_pre+encpprezLAA+sh_gob_pre*core,data=coa[conc_prez_gob %in% 0,],index=c("indra","year"),effect="time",model="within")
m6.plm <-  plm(sh_prez~sh_prez_pre+encpprezLAA+sh_gob_pre*core,data=coa[conc_prez_gob %in% 1,],index=c("indra","year"),effect="twoways",model="within")
m7.plm <-  plm(sh_prez~sh_prez_pre+encpprezLAA+sh_gob_pre*core,data=coa[conc_prez_gob %in% 0,],index=c("indra","year"),effect="twoways",model="within")

tab_model(m3.plm,m4.plm,m5.plm,m6.plm,m7.plm,show.intercept=F,show.ci=F,title="Presidential vote share: Fixed-effects (within)",robust=TRUE,dv.labels=c("Prez_sh","Concurrent","Non-concurrent","Conc. (twoways)","Non-conc. (twoways)"))

m4.re <-  plm(sh_prez~sh_prez_pre+encpprezLAA+sh_gob_pre*core,data=coa[conc_prez_gob %in% 1,],index=c("indra","year"),model="random")
