
coa <- read.csv("coa.csv",header=TRUE,sep=";",dec=",")
fis <- read.csv("Base_Fiscal_Provincias_19912015.csv",header=TRUE,sep=";",dec=",")
coa1 <- merge(coa,fis,by.x=c("year","provincia"),by.y=c("year","province"))


coa1$pop <- c(coa1$popul[1:2044],coa1$population[2045:3577])
coa1$unique <- as.factor(paste(coa1$idprov,coa1$indra,sep=""))
coa1$prez <- c(coa1$PREZ_FPV[1:1533],coa1$PREZ_PRO[1534:3577])
coa1$pvsc1 <- coa1$sharegob[coa1$year==2007]-coa1$PREZ_FPV[coa1$year==2003]
coa1$pvsc2 <- coa1$sharegob[coa1$year==2011]-coa1$PREZ_FPV[coa1$year==2007]
coa1$pvsc3 <- coa1$sharegob[coa1$year==2015]-coa1$PREZ_FPV[coa1$year==2011]


### FIGURES ###

par(mfrow=c(2,2))
plot(coa1$PREZ_FPV[coa1$year==2003],coa1$sharegob[coa1$year==2003],col=c("blue","red")[factor(coa1$diff[coa1$year==2003])],pch=16,xlim=c(0,1),ylim=c(0,1),main="% votos presidente y gobernador (electos)\n Por depto. Año 2003",xlab="% votos gobernador electo",ylab="% votos presidente electo")
abline(0,1,lwd=2)
plot(coa1$PREZ_FPV[coa1$year==2007],coa1$sharegob[coa1$year==2007],col=c("blue","red")[factor(coa1$diff[coa1$year==2007])],pch=16,xlim=c(0,1),ylim=c(0,1),main="% votos presidente y gobernador (electos\n Por depto. Año 2007",xlab="% votos gobernador electo",ylab="% votos presidente electo")
abline(0,1,lwd=2)
plot(coa1$PREZ_FPV[coa1$year==2011],coa1$sharegob[coa1$year==2011],col=c("blue","red")[factor(coa1$diff[coa1$year==2011])],pch=16,xlim=c(0,1),ylim=c(0,1),main="% votos presidente y gobernador (electos)\n Por depto. Año 2011",xlab="% votos gobernador electo",ylab="% votos presidente electo")
abline(0,1,lwd=2)
plot(coa1$PREZ_PRO[coa1$year==2015],coa1$sharegob[coa1$year==2015],col=c("blue","red")[factor(coa1$diff1[coa1$year==2015])],pch=16,xlim=c(0,1),ylim=c(0,1),main="% votos presidente y gobernador (electos)\n Por depto. Año 2015",xlab="% votos gobernador electo",ylab="% votos presidente electo")
abline(0,1,lwd=2)





### TRABAJAR CON UN DISSIMILARITY A NIVEL PROVINCIAL. Se define como SH del Gobernador Gannador menos Share del Presidente

### CREATE NEW VARS

coa1$diss1  <- coa1$sharegob-coa1$PREZ_FPV
coa1$diss2 <- coa1$sharegob-coa1$sharegob[coa1$year==2003]
coa1$diss3 <- coa1$PREZ_FPV-coa1$PREZ_FPV[coa1$year==2003]
coa1$diss4 <-  (coa1$sharegob-coa1$PREZ_FPV)/coa1$sharegob
coa1$diss5 <- coa1$sharegob/coa1$PREZ_FPV

coa1$apn_transf_pc <- (coa1$apn_transf*1000000/coa1$population)
coa1$gn_servsoc_pc <- (coa1$gn_servsoc*1000000/coa1$population)

coa1 <- coa1[coa1$preselec==1,]

aggregate(coa1$diss1,by=list(coa1$year,coa1$provincia),mean,na.rm=TRUE)
aggregate(coa1$diss2,by=list(coa1$year,coa1$provincia),mean,na.rm=TRUE)
aggregate(coa1$diss3,by=list(coa1$year,coa1$provincia),mean,na.rm=TRUE)
aggregate(coa1$diss3,by=list(coa1$departamento),mean,na.rm=TRUE)

try <- dcast(coa1,provincia+year+apn_transf_pc+gn_servsoc_pc~.,value.var="diss5",mean,na.rm=TRUE)
try <- try[complete.cases(try),]

### Con transferencias del tesoro nacional
plot(try$apn_transf_pc[try$year!=2015],log(try$.[try$year!=2015]),xlab="Transferencias per capita",ylab="Diferencia entre share del Gobernador electo y share del Presidente",col="blue",pch=16,cex=1.15)
textxy(try$apn_transf_pc[try$year!=2015],try$.[try$year!=2015],try$pair[try$year!=2015],cex=0.9)


par(mfrow=c(1,2))
plot(try$apn_transf_pc[try$year!=2015],log(try$.[try$year!=2015]),xlab="Transferencias per capita",ylab="Diferencia entre share del Gobernador electo y share del Presidente",col="blue",pch=16,cex=1.15)
textxy(try$apn_transf_pc[try$year!=2015],try$.[try$year!=2015],try$pair[try$year!=2015],cex=0.9)

plot(try$apn_transf_pc,log(try$.),xlab="Transferencias per capita",ylab="Diferencia entre share del Gobernador electo y share del Presidente",col="blue",pch=16,cex=1.15)
textxy(try$apn_transf_pc[try$year!=2015],try$.[try$year!=2015],try$pair[try$year!=2015],cex=0.9)







plot(try$gn_servsoc_pc[try$year!=2015],try$.[try$year!=2015],xlab="Transferencias per capita",ylab="Diferencia entre share del Gobernador electo y share del Presidente",col="blue",pch=16,cex=1.15)
textxy(try$apn_transf_pc[try$year!=2015],try$.[try$year!=2015],try$pair[try$year!=2015],cex=0.9)


library(reshape)
library(reshape2)

setwd("/home/freille/Dropbox/PAPERS/PAPER_Aportes y Elecciones/")


### Para crear la base en formato LONG y luego sacar listado de partidos ###
### Base por departamentos no agregada.  ###

elec.l <- read.csv("FINAL_ELEC0311.csv",header=TRUE,sep="\t")
names(elec.l)
str(elec.l)

### Listado de PARTIDOS ####
partidos <- levels(elec.l$partido)
levels(elec.l$partido)
write.table(partidos,"listapartidosFreille.csv")

### Para convertir a formato WIDE  ###
### Por departamentos - Sin AGREGAR - Votos ###

elec.w.vs <- dcast(elec.l,year+eleccion+provincia+idprovincia+departamento+indra~partido,value.var="votos",sum,fill=NA_real_)
names(elec.w.vs)
length(elec.w.vs$year)
write.table(elec.w.vs,"elec_dpto_votes_wide.csv")

################## A NIVEL DEPARTAMENTAL ######
### Para convertir a formato WIDE  #############
### Por departamentos - Sin AGREGAR - Shares ###
################################################

elec.w.sh <- cbind(elec.w.vs[,1:6],elec.w.vs[,7:440]/elec.w.vs[,444])
options(scipen=999,digits=4)
write.table(elec.w.sh,"elec_dpto_shares_wide.csv")

elec.l.vs <- melt(elec.w.vs,id=c("year","eleccion","provincia","idprovincia","departamento","indra"),na.rm=TRUE)
colnames(elec.l.vs)[7] <- "partido"
colnames(elec.l.vs)[8] <- "votes"
names(elec.l.vs)
write.table(elec.l.vs,"elec_dpto_votes_long.csv")

elec.l.sh <- melt(elec.w.sh,id=c("year","eleccion","provincia","idprovincia","departamento","indra"),na.rm=TRUE)
colnames(elec.l.sh)[7] <- "partido"
colnames(elec.l.sh)[8] <- "shares"
names(elec.l.sh)
write.table(elec.l.vs,"elec_dpto_shares_long.csv")


###########################################################################################
######  Magic Code con data.table para colapsar y pasar de DEPARTAMENTO A PROVINCIA #######
###########################################################################################

elec.l.dt <- data.table(elec.l)
setkey(elec.l.dt,year,eleccion)
elec.l.prov <- elec.l.dt[,list(votos=sum(votos)),by=list(year,eleccion,idprovincia,provincia,partido)]

######################A NIVEL PROVINCIAL###########################
###################################################################
### Long to Wide para sacar ratios/shares de vuelta a Long ########
###################################################################

elec.w.prov.votes <- dcast(elec.l.prov,year+eleccion+provincia+idprovincia~partido,value.var="votos")
write.table(elec.w.prov.votes,"elec_prov_votes.csv")
elec.w.prov.shares <- cbind(elec.w.prov.votes[,1:4],elec.w.prov.votes[,5:438]/elec.w.prov.votes[,442])
write.table(elec.w.prov.shares,"elec_prov_shares.csv")

elec.l.prov.shares <- melt(elec.w.prov.shares,id=c("year","eleccion","provincia","idprovincia"),na.rm=TRUE)
colnames(elec.l.prov.shares)[5] <- "partido"
colnames(elec.l.prov.shares)[6] <- "shares"
names(elec.l.prov.shares)
write.table(elec.l.prov.shares,"elec_prov_shares.csv")

elec.l.prov.votes <- melt(elec.w.prov.votes,id=c("year","eleccion","provincia","idprovincia"),na.rm=TRUE)
colnames(elec.l.prov.votes)[5] <- "partido"
colnames(elec.l.prov.votes)[6] <- "votes"
names(elec.l.prov.votes)
write.table(elec.l.prov.votes,"elec_prov_votes.csv")

elec.l.prov <- merge(elec.l.prov.votes,elec.l.prov.shares)
write.table(elec.l.prov,"elec_prov_long.csv")


#### TO OBTAIN EFFECTIVE NUMBER OF PARTIES.

elec.w.dpto.shares <- cbind(elec.w.sh[,1:440],(1/rowSums(elec.w.sh[,7:440]**2,na.rm=TRUE)))

#### BASE para FPV Coattails ######

elec.w.dpto <- dcast(elec.l.sh,year+provincia+idprovincia+departamento+indra~eleccion+partido,value.var="shares")

### agregando variables de ECNP y BASES FINALES NO TOCAR!!! ###3

elec.w.dpto.final <- cbind(elec.w.dpto[,1:670],encpdip=(1/rowSums(elec.w.dpto[,6:416]**2,na.rm=TRUE)),encpprez=(1/rowSums(elec.w.dpto[,417:476]**2,na.rm=TRUE)),encpsen=(1/rowSums(elec.w.dpto[,477:670]**2,na.rm=TRUE)))

elec.w.fpv <- elec.w.dpto.final[,c(1:5,208,216,217,218,219,271,445,447,448,576,577,578,579,603,671,672,673)]
write.table(elec.w.fpv, "elec_w_fpv.csv")


###############################
#### Merge con bases lucas ####
###############################

### Para armar BASE para COATTAILS #####

seba <- read.csv("elec_w_fpv.csv",header=TRUE,sep=",")
lucas <- read.csv("lucas.csv",header=TRUE,sep="\t")
coa <- merge(seba,lucas,by=c("year","idprovincia","indra"))
write.table(coa,"coa.csv")


#### In Excel, ELIMINATE LEZAMA, ELIMINATE VARIABLES "NA".




############ REGRESSION MODELS ################

library(plm)
library(nlme)
library(lme4)
library(pscl)
library(stargazer)
coa <- read.csv("coa.csv",header=TRUE)
names(coa)
str(coa)
coa <- plm.data(coa,indexes=c("year","indra"))
pdim(coa,"year")

####3 PRIMERA TABLA - GUBERNATORIAL ####

sink("results.txt")
lm1.gub.all <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1)),data=coa)
summary(lm1.gub.all)
lm1.gub.con <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1)),data=coa[coa$conc_prez_gob==1,])
summary(lm1.gub.con)
lm1.gub.sep <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1)),data=coa[coa$dias_prez_gob>0,])
lm2.gub.all <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre,data=coa)
summary(lm2.gub.con)
lm2.gub.sep <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre,data=coa[coa$dias_prez_gob>0,])
lm3.gub.sep <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre+pubemp+desocupacion,data=coa[coa$dias_prez_gob>0,])
lm4.gub.sep <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre+pubemp*core+desocupacion,data=coa[coa$dias_prez_gob>0,])
summary(lm4.gub.sep)
lm5.gub.sep <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre+pubemp*core+desocupacion+icg_gov,data=coa[coa$dias_prez_gob>0,])
summary(lm5.gub.sep)
sink()

stargazer(lm1.gub.con,lm1.gub.sep,lm2.gub.sep,lm3.gub.sep,lm4.gub.sep,lm5.gub.sep,title="Gubernational Coattails",align=TRUE,column.sep.width="0",omit.stat=c("LL"),digits=2,df=FALSE,dep.var.labels="Presidential Vote Share",font.size="footnotesize")

lm1.gub.sub <- lm(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_svs+log(abs(dias_prez_gob+1))+nbi,data=coa[coa$dias_prez_gob>=0,])

plm1.gub.sub <- plm(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_svs+log(abs(dias_prez_gob+1))+nbi,data=coa[coa$dias_prez_gob>=0,],index=c("indra","year"),effect="individual",model="within")

plm2.gub.sub <- plm(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_svs+log(abs(dias_prez_gob+1))+nbi,data=coa[coa$dias_prez_gob>=0,],index=c("indra","year"),effect="time",model="within")

me1.gub.sub <- lmer(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_svs+log(abs(dias_prez_gob+1))+(1|provincia.x),data=coa[coa$dias_prez_gob>=0,],REML=FALSE)

me2.gub.sub <- lmer(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_svs+log(abs(dias_prez_gob+1))+(sharegob|provincia.x),data=coa[coa$dias_prez_gob>=0,],REML=FALSE)

me3.gub.sub <- lmer(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_svs+log(abs(dias_prez_gob+1))+(sharegob*core|provincia.x),data=coa[coa$dias_prez_gob>=0,],REML=FALSE)

me2.gub.alt <- lmer(PREZ_FPV~sharegob*core+encpprez+universitarios+log(abs(dias_prez_gob+1))+(sharegob|idprovincia),data=coa,REML=FALSE)

jpeg("effects1.jpg",height=600,width=800)
dotplot(ranef(me3.gub.sub),postvar=TRUE)
dev.off()

stargazer(lm1.gub.sub,plm1.gub.sub,plm2.gub.sub,me1.gub.sub,me2.gub.sub,me3.gub.sub,title="Gubernational Coattails",align=TRUE,column.sep.width="0",omit.stat=c("LL"),digits=2,df=FALSE,dep.var.labels="Presidential Vote Share",font.size="footnotesize")



### SEGUND TABLE - sin svs

lm1.gub.sub.2 <- lm(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_pre+log(abs(dias_prez_gob+1))+nbi,data=coa[coa$dias_prez_gob>=0,])

plm1.gub.sub.2 <- plm(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_pre+log(abs(dias_prez_gob+1))+nbi,data=coa[coa$dias_prez_gob>=0,],index=c("indra","year"),effect="individual",model="within")

plm2.gub.sub.2 <- plm(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_pre+log(abs(dias_prez_gob+1))+nbi,data=coa[coa$dias_prez_gob>=0,],index=c("indra","year"),effect="time",model="within")

me1.gub.sub.2 <- lmer(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_pre+log(abs(dias_prez_gob+1))+(1|provincia.x),data=coa[coa$dias_prez_gob>=0,],REML=FALSE)

me2.gub.sub.2 <- lmer(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_pre+log(abs(dias_prez_gob+1))+(sharegob|provincia.x),data=coa[coa$dias_prez_gob>=0,],REML=FALSE)

me3.gub.sub.2 <- lmer(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_pre+log(abs(dias_prez_gob+1))+(sharegob*core|provincia.x),data=coa[coa$dias_prez_gob>=0,],REML=FALSE)

me2.gub.alt.2 <- lmer(PREZ_FPV~sharegob*core+encpprez+universitarios+log(abs(dias_prez_gob+1))+(sharegob|idprovincia),data=coa,REML=FALSE)

jpeg("effectsalt.jpg",height=600,width=800)
dotplot(ranef(me3.gub.sub.2),postvar=TRUE)
dev.off()


stargazer(lm1.gub.sub.2,plm1.gub.sub.2,plm2.gub.sub.2,me1.gub.sub.2,me2.gub.sub.2,me3.gub.sub.2,title="Gubernational Coattails",align=TRUE,column.sep.width="0",omit.stat=c("LL"),digits=2,df=FALSE,dep.var.labels="Presidential Vote Share",font.size="footnotesize")


####3 SEGUNDA TABLA  -- CONGRESIONAL LOWER HOUSE ####

lm1.dip <- lm(PREZ_FPV~DN_FPV+encpprez,data=coa)
plm1.dip <- plm(PREZ_FPV~DN_FPV+encpprez,data=coa,index=c("indra","year"),effect="individual",model="within")
plm2.dip <- plm(PREZ_FPV~DN_FPV+encpprez,data=coa,index=c("indra","year"),effect="time",model="within")
me1.dip <- lmer(PREZ_FPV~DN_FPV+encpprez+(1|provincia.x),data=coa,REML=FALSE)
me2.dip <- lmer(PREZ_FPV~DN_FPV+encpprez+universitarios+log(abs(dias_prez_dn+1))+(DN_FPV|idprovincia),data=coa,REML=FALSE)
stargazer(lm1.dip,plm1.dip,plm2.dip,me1.dip,me2.dip,title="Congressional (Lower House) Coattails",align=TRUE,column.sep.width="2",omit.stat=c("LL"),df=TRUE,digits=2,dep.var.labels="Presidential Vote Share",font.size="footnotesize")



lm1.dip <- lm(PREZ_FPV~DN_FPV,data=coa)
lm1.sen <- lm(PREZ_FPV~SN_FPV,data=coa)
lm2.dip <- lm(PREZ_FPV~DN_FPV2,data=coa)
lm2.sen <- lm(PREZ_FPV~SN_FPV2,data=coa)


plm2.gub <- plm(PREZ_FPV~sharegob+core,data=coa,index=c("year","indra"),effect="twoways",model="within")
plm1.dip <- plm(PREZ_FPV~DN_FPV2,data=coa,index=c("year","indra"),effect="twoways",model="within")

### other controls to add: concurrence; days; partyalign

coa$PREZ_FPV_pre <- as.numeric(c(rep("NA",511),rep("NA",511),coa$PREZ_FPV[coa$year==2003],rep("NA",511),coa$PREZ_FPV[coa$year==2007]))





#### PLOTS ####

######  horizontal COATTAIL ######

jpeg("coattDN.jpg",height=800,width=1280)
par(mfrow=c(1,2))
plot(coa$PREZ_FPV,coa$DN_FPV,col=factor(coa$year),pch=16,main="Legislative Coattails - DN, all period \nToma solo lista 'Frente para la Victoria'",cex=1.5)
legend('topleft',legend=c("2003","2007","2011"),col=c(1,3,5),lty=1:1)
plot(coa$PRESIDENTE_FRENTE.PARA.LA.VICTORIA,coa$DN_FPV_amplio,col=factor(coa$year),pch=16,main="Legislative Coattails - DN, all period \nToma listas 'Frente para la Victoria' y 'Justicialista'",cex=1.5)
legend('topleft',legend=c("2003","2007","2011"),col=c(1,3,5),lty=1:1)
dev.off()

jpeg("coattSN.jpg",height=800,width=1280)
par(mfrow=c(1,2))
plot(coa$PRESIDENTE_FRENTE.PARA.LA.VICTORIA,coa$SN_FRENTE.PARA.LA.VICTORIA,col=factor(coa$year),pch=16,main="Legislative Coattails - SN, all period",cex=1.5)
legend('topleft',legend=c("2003","2007","2011"),col=c(1,3,5),lty=1:1)
plot(coa$PRESIDENTE_FRENTE.PARA.LA.VICTORIA,coa$SN_FPV_amplio,col=factor(coa$year),pch=16,main="Legislative Coattails - SN, all period \nToma listas 'Frente para la Victoria' y 'Justicialista'",cex=1.5)
legend('topleft',legend=c("2003","2007","2011"),col=c(1,3,5),lty=1:1)
dev.off()

###### GUBERNATORIAL COATTAILS #####
plot(coa$PREZ_FPV,coa$sharegob,col=factor(coa$year))

plot(coa$PRESIDENTE_FRENTE.PARA.LA.VICTORIA[coa$year==2011],coa$DN_FRENTE.PARA.LA.VICTORIA[coa$year==2011],col=1,pch=16)

xyplot(coa$PREZ_FPV[coa$core==1]~coa$sharegob[coa$core==1]|coa$provincia.x[coa$core==1])



#### PLOTS

col <- c("blue","yellow","red","magenta","green")

par(mfrow=c(1,2))
plot(coa$sharegob,coa$PREZ_FPV,col=col[factor(coa$year)],pch=16,cex=1.5,cex.lab=1.5,cex.axis=1.5)
legend("bottomright",legend=factor(coa$year[coa$departamento.x=="Castelli"]),col=col,lty=1:1,lwd=5)
title(main="Vote shares, dept.level",sub="Alignment not accounted for")
plot(coa$sharegob*coa$core,coa$PREZ_FPV,col=col[factor(coa$year)],pch=16,cex=1.5,cex.lab=1.5,cex.axis=1.5)
legend("bottomright",legend=factor(coa$year[coa$departamento.x=="Castelli"]),col=col,lty=1:1,lwd=5)
title(main="Vote shares, dept.level",sub="Alignment accounted for")


par(mfrow=c(1,2))
plot(coa$DN_FPV,coa$PREZ_FPV,col=col[factor(coa$year)],pch=16,cex=1.5,cex.lab=1.5,cex.axis=1.5)
legend("bottomright",legend=factor(coa$year[coa$departamento.x=="Castelli"]),col=col,lty=1:1,lwd=5)
title(main="Votes shares, dept. level",sub="No matching")
plot(coa$DN_FPV2,coa$PREZ_FPV,col=col[factor(coa$year)],pch=16,cex=1.5,cex.lab=1.5,cex.axis=1.5)
legend("bottomright",legend=factor(coa$year[coa$departamento.x=="Castelli"]),col=col,lty=1:1,lwd=5)
title(main="Votes shares, dept. level",sub="With fuzzy matching (dept names)")

plot(coacore$DN_FPV,coacore$PREZ_FPV,col=col[factor(coacore$year)],pch=16,cex=1.5,cex.lab=1.5,cex.axis=1.5)

###3 final tables


sink("results.txt")
lm1.gub.all <- lm(PREZ_FPV~sharegob*core+encpprez,data=coa)
summary(lm1.gub.all.bis)
lm1.gub.con <-  lm(PREZ_FPV~sharegob*core+encpprez,data=coa[coa$conc_prez_gob==1,])
summary(lm1.gub.con)
lm1.gub.sep <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1)),data=coa[coa$dias_prez_gob>0,])
summary(lm1.gub.sep)
lm1.gub.all.bis <- lm(PREZ_FPV~sharegob*core+encpprez+conc_prez_gob*sharegob+log(abs(dias_prez_gob+1)),data=coa)
summary(lm1.gub.all.bis)
lm2.gub.all.bis <- lm(PREZ_FPV~sharegob*core+encpprez+conc_prez_gob*sharegob+log(abs(dias_prez_gob+1))+pubemp,data=coa)
summary(lm2.gub.all.bis)
lm3.gub.all.bis <- lm(PREZ_FPV~sharegob*core+encpprez+conc_prez_gob*sharegob+log(abs(dias_prez_gob+1))+pubemp+PREZ_FPV_pre,data=coa)
summary(lm3.gub.all.bis)
lm1.gub.all.03 <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+conc_prez_gob*sharegob,data=coa[coa$year==2003,])
summary(lm1.gub.all.03)
lm4.gub.all.bis <- lm(PREZ_FPV~sharegob*core*conc_prez_gob+encpprez+log(abs(dias_prez_gob+1))+pubemp,data=coa)
summary(lm4.gub.all.bis)
lm1.gub.all.07 <- lm(PREZ_FPV~sharegob+encpprez+log(abs(dias_prez_gob+1))+conc_prez_gob*sharegob,data=coa[coa$year==2007,])
summary(lm1.gub.all.07)
lm1.gub.all.11 <- lm(PREZ_FPV~sharegob+encpprez+log(abs(dias_prez_gob+1))+conc_prez_gob*sharegob,data=coa[coa$year==2011,])
summary(lm1.gub.all.11)
sink()

stargazer(lm1.gub.all,lm1.gub.all.bis,lm2.gub.all.bis,lm4.gub.all.bis,df=FALSE,digits=2,title="Gubernational Coattails",align=TRUE,column.sep.width="0",omit.stat=c("LL"),dep.var.labels="Presidential Vote Share",font.size="scriptsize")




### OTHER

lm1.gub.all <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1)),data=coa)
summary(lm1.gub.all)
lm1.gub.con <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1)),data=coa[coa$conc_prez_gob==1,])
summary(lm1.gub.con)
lm1.gub.sep <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1)),data=coa[coa$dias_prez_gob>0,])
summary(lm1.gub.sep)
lm2.gub.all <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre,data=coa)
summary(lm2.gub.con)
lm2.gub.sep <-  lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre,data=coa[coa$dias_prez_gob>0,])
lm3.gub.sep <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre+pubemp+desocupacion,data=coa[coa$dias_prez_gob>0,])
lm4.gub.sep <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre+pubemp*core+desocupacion,data=coa[coa$dias_prez_gob>0,])
summary(lm4.gub.sep)
lm5.gub.sep <- lm(PREZ_FPV~sharegob*core+encpprez+log(abs(dias_prez_gob+1))+PREZ_FPV_pre+pubemp*core+desocupacion+icg_gov,data=coa[coa$dias_prez_gob>0,])
summary(lm5.gub.sep)
sink()



plm1.gub <- plm(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_pre,data=coa,index=c("indra","year"),effect="time",model="within")
summary(plm1.gub)
plm2.gub <- plm(PREZ_FPV~sharegob*core+sharegob*conc_prez_gob+encpprez+PREZ_FPV_pre,data=coa,index=c("indra","year"),effect="time",model="within")
summary(plm2.gub)
plm3.gub <- plm(PREZ_FPV~sharegob*core+encpprez+PREZ_FPV_pre,data=coa[coa$conc_prez_gob==0,],index=c("indra","year"),effect="time",model="within")
summary(plm3.gub)
plm4.gub <- plm(PREZ_FPV~sharegob*core*conc_prez_gob+encpprez+log(abs(dias_prez_gob+1))+pubemp,data=coa,index=c("indra","year"),effect="time",model="within")
summary(plm4.gub)

stargazer(plm1.gub,plm2.gub,plm3.gub,plm4.gub,df=FALSE,digits=2,title="Gubernational Coattails",align=TRUE,column.sep.width="0",omit.stat=c("LL"),dep.var.labels="Presidential Vote Share",font.size="scriptsize")

plm5.gub <- plm(PREZ_FPV~sharegob*core*conc_prez_gob+encpprez+log(abs(dias_prez_gob+1))+pubemp|desocupacionln+nbiln+universitariosln,data=coa,index=c("indra","year"),effect="time",model="within")
summary(plm5.gub)



### MAPAS

coa$coat1 <- coa$sharegob-coa$PREZ_FPV

map2003 <- merge(map,coa[coa$year==2003,],by=c("PROVINCIA","DEPARTA"))
map2007 <- merge(map,coa[coa$year==2007,],by=c("PROVINCIA","DEPARTA"))
map2011 <- merge(map,coa[coa$year==2011,],by=c("PROVINCIA","DEPARTA"))

map2003$coat1.c <- cut(map2003$coat1,0.2*(-5:5))
map2007$coat1.c <- cut(map2007$coat1,0.2*(-5:5))
map2011$coat1.c <- cut(map2011$coat1,0.2*(-5:5))

png("coattailsMap.png",width=800,height=1280,res=400)
p1=spplot(map2003,"coat1.c",col.regions=rev(heat.colors(10)),main="2003")
p2=spplot(map2007,"coat1.c",col.regions=rev(heat.colors(20)),main="2007")
p3=spplot(map2011,"coat1.c",col.regions=rev(heat.colors(20)),main="2011")
print(p1, position = c(0,0,.33,1),more=T)
print(p2, position = c(.33,0,.66,1),more = T)
print(p3, position = c(0.66,0,1,1))
dev.off()
