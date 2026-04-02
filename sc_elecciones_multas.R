########################################################################################################################
#                              ¿Cuánto cuestan en realidad las elecciones?
########################################################################################################################  
# Autor: César Huamaní Ninahuanca
# Fecha: 01/04/2026

#-----------------------------------------------------------------------------------------------------------------------
library(openxlsx)
library(dplyr)
library(data.table)
library(naniar)
library(readr)

# Los distritos pobres. 
dp<-read.xlsx("C:/Users/cesar/Downloads/pobreza_distritos.xlsx")

dp %>% select(UBIGEO,DEPARTAMENTO,PROVINCIA,DISTRITO,CLASIFICACIÓN) %>% as_tibble()->dp

dp %>% filter(!is.na(UBIGEO))->dp

dp %>% mutate(UBIGEO=ifelse(nchar(UBIGEO)==5,paste0("0",UBIGEO),UBIGEO))->dp

dp %>% miss_var_summary()

dp %>% filter(is.na(DEPARTAMENTO))

dp %>% mutate(DEPARTAMENTO=ifelse(PROVINCIA=="CALLAO" & is.na(DEPARTAMENTO),"CALLAO",
                                  ifelse(PROVINCIA=="CHUPACA" & is.na(DEPARTAMENTO), "JUNIN",
                                         ifelse(PROVINCIA=="CAYLLOMA" & is.na(DEPARTAMENTO),"AREQUIPA",DEPARTAMENTO))))->dp

dp %>% filter(is.na(CLASIFICACIÓN))

dp %>% mutate(CLASIFICACIÓN=case_when(UBIGEO=="040201"~"NO POBRE",
                                      UBIGEO=="110904"~"NO POBRE",
                                      TRUE~CLASIFICACIÓN))->dp # Según valores similares del mpa de pobreza del INEI.

dp %>% mutate(CLASIFICACIÓN=case_when(grepl("POBRE EXTREMO",CLASIFICACIÓN)~"POBRE EXTREMO",
                                      grepl("^NO POBRE$|^POBRE NO$",CLASIFICACIÓN)~"NO POBRE",
                                      TRUE~"POBRE"))->dp

# Multa.
dp %>% mutate(multa=case_when(CLASIFICACIÓN=="NO POBRE"~88,
                              CLASIFICACIÓN=="POBRE"~44,
                              CLASIFICACIÓN=="POBRE EXTREMO"~22))->dp


# Los resultados de la primera vuelta.
pv<-read_csv2("C:/Users/cesar/Downloads/Resultdos_elecciones_presidenciales_1er_vuelta.csv",
              locale = locale(encoding = "ISO-8859-1"))

# guess_encoding("C:/Users/cesar/Downloads/Resultdos_elecciones_presidenciales_1er_vuelta.csv")

pv %>% filter(DESCRIP_ESTADO_ACTA!="SIN INSTALAR")->pv

pv %>% select(UBIGEO,MESA_DE_VOTACION,TIPO_OBSERVACION,N_CVAS,N_ELEC_HABIL) %>%
  rename(votaron=N_CVAS, habiles=N_ELEC_HABIL) %>% as_tibble()->pv

pv %>% filter(grepl("^[0-2]",UBIGEO))->pv # Solo electores de Perú.

pv %>% miss_var_summary() # Todo completo

pv %>% filter(is.na(votaron))

#-------
# Los resultados de la segunda vuelta.

sv<-read_csv2("C:/Users/cesar/Downloads/Resultados_2da_vuelta_Version_PCM .csv",
              locale = locale(encoding = "ISO-8859-1"))

sv %>% filter(DESCRIP_ESTADO_ACTA!="SIN INSTALAR")->sv

sv %>% select(UBIGEO,MESA_DE_VOTACION,TIPO_OBSERVACION,N_CVAS,N_ELEC_HABIL) %>%
  rename(votaron=N_CVAS, habiles=N_ELEC_HABIL) %>% as_tibble()->sv

sv %>% filter(grepl("^[0-2]",UBIGEO))->sv # Solo electores de Perú.

sv %>% miss_var_summary() # Todo completo

sv %>% filter(is.na(votaron))

#------------
pv %>% mutate(VUELTA="Primera") %>% bind_rows(
  sv %>% mutate(VUELTA="Segunda"))->votos

#-----------------------------------------------------------------------------------------------------------------------

votos %>% left_join(dp) %>% filter(is.na(multa))

votos %>% left_join(dp)->tb_elecciones

tb_elecciones %>% miss_var_summary()

#-----------------------------------------------------------------------------------------------------------------------
# Tasa de ausentismo.
tb_elecciones %>% group_by(VUELTA) %>%
  summarise(votaron=sum(votaron),
            habiles=sum(habiles)) %>% mutate(p=1-(votaron/habiles))

# Tasa de ausentismo por regiones.
tb_elecciones %>% group_by(VUELTA,DEPARTAMENTO) %>% 
  summarise(votaron=sum(votaron),
            habiles=sum(habiles)) %>% mutate(p=1-(votaron/habiles)) %>% arrange(VUELTA,-p)


# Multa total
tb_elecciones %>% mutate(multa_mesa=multa*(habiles-votaron))->tb_elecciones

# Primera vuelta.
tb_elecciones %>% filter(VUELTA=="Primera") %>% group_by(DEPARTAMENTO) %>% 
  summarise(multa_departamento=sum(multa_mesa)) %>% arrange(-multa_departamento) %>%
  bind_rows(tb_elecciones %>% filter(VUELTA=="Primera") %>% 
              summarise(t=sum(multa_mesa)) %>% rename(multa_departamento = t) %>% mutate(DEPARTAMENTO="TOTAL"))->tab1
tab1 %>% 
  mutate(multa_departamento=scales::dollar(multa_departamento, prefix = "s/. "))

# Segunda vuelta.
tb_elecciones %>% filter(VUELTA=="Segunda") %>% group_by(DEPARTAMENTO) %>% 
  summarise(multa_departamento=sum(multa_mesa)) %>% arrange(-multa_departamento) %>%
  bind_rows(tb_elecciones %>% filter(VUELTA=="Segunda") %>% 
              summarise(t=sum(multa_mesa)) %>% rename(multa_departamento = t) %>% mutate(DEPARTAMENTO="TOTAL"))->tab2
tab2 %>% 
  mutate(multa_departamento=scales::dollar(multa_departamento, prefix = "s/. "))

# Total.
tb_elecciones %>% group_by(DEPARTAMENTO) %>% summarise(multa_departamento=sum(multa_mesa)) %>% arrange(-multa_departamento) %>%
  bind_rows(tb_elecciones %>% summarise(t=sum(multa_mesa)) %>% rename(multa_departamento = t) %>% mutate(DEPARTAMENTO="TOTAL"))->total

total %>% 
  mutate(multa_departamento=scales::dollar(multa_departamento, prefix = "s/. "))

#-----------------------------------------------------------------------------------------------------------------------
# Diferencia con el presupuesto.

presupuesto<-tibble(Destino=c("JNE","ONPE","RENIEC","Demanda adicional"),Monto=c(112438757,406568510,11743530,273260125))

presupuesto %>% bind_rows(
  presupuesto %>% summarise(Monto=sum(Monto)) %>% mutate(Destino="TOTAL") 
)->presupuesto

presupuesto %>% mutate(Monto=scales::dollar(Monto, prefix = "s/. "))

#-----------------------------------------------------------------------------------------------------------------------

total %>% filter(DEPARTAMENTO=="TOTAL") %>% bind_cols(
  presupuesto %>% filter(Destino=="TOTAL")
) %>% mutate(Diferencia=multa_departamento-Monto,
             p=Diferencia/Monto)->tab3

tab3 %>% mutate(across(c(multa_departamento,Monto,Diferencia), ~scales::dollar(., prefix = "S/. ")))




