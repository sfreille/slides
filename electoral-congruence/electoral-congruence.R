lapply(c("tidyverse", "rvest", "janitor", "scales", "lubridate",
         "shiny","rsconnect", "ggiraph", "data.table", "ggthemes","rio","here","ggthemes"",hrbrthemes"), require, character.only=TRUE)


options(scipen=999)
ec  <- import(here("data","coa3.xlsx"),setclass="data.table")
ec[,diff1 :=ifelse(sh_gob-sh_prez>=0,"gobW","prezW")]
ec[,diff2 :=sh_gob-sh_prez]

ggplot(ec, aes(sh_prez,sh_gob,color=diff1))+geom_point()+geom_abline(intercept=0,slope=1)+facet_wrap(year~regime)+labs(title="Vote shares: Presidents and gobernors -- By department",x="President-elect vote share",y="Governor-elect vote share")+theme_ipsum_ps(grid="XY", axis="xy")+theme(legend.position="none")

ggplot(ec, aes(sh_gob,sh_prez,color=factor(core),group=factor(core)))+geom_point()+geom_smooth(method="lm")+facet_wrap(year~regime)+labs(title="Vote shares: Presidents and governors -- By department and coalition status",x="President-elect vote share",y="Governor-elect vote share")+theme_ipsum_ps(grid="XY", axis="xy")+theme(legend.position="bottom")
ggsave(here("output","figs","relativebycore.jpg"),height=6,width=10)



ggplot(ec,aes(sh_gob,sh_prez,color=transf_pre1))+geom_point()+facet_wrap(core~provincia)
