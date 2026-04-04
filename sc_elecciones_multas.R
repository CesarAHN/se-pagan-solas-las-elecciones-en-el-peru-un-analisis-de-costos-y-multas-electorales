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
library(gt)
#devtools::install_github("jthomasmock/gtExtras")
library(gtExtras)
library(ggridges)
library(tidyr)
library(ggplot2)
library(ggelegant)

#----------------------------------------------
oracion<-function(x){
  x<-tolower(x)
  substring(x,1,1)<-toupper(substring(x,1,1))
  x
}
#----------------------------------------------


# Los distritos pobres. 
dp<-read.xlsx("Datos/pobreza_distritos.xlsx")

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
pv<-read_csv2("Datos/Resultdos_elecciones_presidenciales_1er_vuelta.csv",
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

sv<-read_csv2("Datos/Resultados_2da_vuelta_Version_PCM .csv",
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

tb_elecciones %>%
  summarise(votaron=sum(votaron),
            habiles=sum(habiles)) %>% mutate(p=1-(votaron/habiles))

# Tasa de ausentismo por regiones.
tb_elecciones %>% group_by(VUELTA,DEPARTAMENTO) %>% 
  summarise(votaron=sum(votaron),
            habiles=sum(habiles)) %>% mutate(p=1-(votaron/habiles)) %>% arrange(VUELTA,-p)->taba

taba %>% filter(VUELTA=="Primera") %>% mutate(DEPARTAMENTO=oracion(DEPARTAMENTO)) %>% 
  ggplot(aes(x=p, y=reorder(DEPARTAMENTO,p)))+
  geom_col(fill="#34495E")+
  scale_x_continuous(labels = scales::percent, breaks = seq(0,1,.05),
                     limits = c(0,.44), expand = c(0,0))+
  labs(x="Tasa de ausentismo", y="Departamentos",
       title = "Tasa de ausentismo por departamentos",
       subtitle = "Primera vuelta elecciones generales 2021",
       caption = "ELABORACIÓN: https://github.com/CesarAHN")+
  geom_text(aes(label = scales::percent(p, accuracy = .1)), hjust=-.2)+
  theme_elegante_std()+
  theme(plot.caption = element_text(face = "bold", hjust = 0))
ggsave("plots/img1.png", width = 9, height = 8)

taba %>% filter(VUELTA=="Segunda") %>% mutate(DEPARTAMENTO=oracion(DEPARTAMENTO)) %>% 
  ggplot(aes(x=p, y=reorder(DEPARTAMENTO,p)))+
  geom_col(fill="#6B8E23")+
  scale_x_continuous(labels = scales::percent, breaks = seq(0,1,.05),
                     limits = c(0,.42), expand = c(0,0))+
  labs(x="Tasa de ausentismo", y="Departamentos",
       title = "Tasa de ausentismo por departamentos",
       subtitle = "Segunda vuelta elecciones generales 2021",
       caption = "ELABORACIÓN: https://github.com/CesarAHN")+
  geom_text(aes(label = scales::percent(p, accuracy = .1)), hjust=-.2)+
  theme_elegante_std()+
  theme(plot.caption = element_text(face = "bold", hjust = 0))
ggsave("plots/img2.png", width = 9, height = 8)

# Por pobreza.
tb_elecciones %>% group_by(VUELTA,CLASIFICACIÓN) %>% 
  summarise(votaron=sum(votaron),
            habiles=sum(habiles)) %>% mutate(p=1-(votaron/habiles)) %>% arrange(VUELTA,-p)

tb_elecciones %>% group_by(CLASIFICACIÓN) %>% 
  summarise(votaron=sum(votaron),
            habiles=sum(habiles)) %>% mutate(p=1-(votaron/habiles)) %>% arrange(-p)



# Multa total
tb_elecciones %>% mutate(multa_mesa=multa*(habiles-votaron))->tb_elecciones

# Primera vuelta.
tb_elecciones %>% filter(VUELTA=="Primera") %>% group_by(DEPARTAMENTO) %>% 
  summarise(multa_departamento=sum(multa_mesa)) %>% arrange(-multa_departamento) %>%
  bind_rows(tb_elecciones %>% filter(VUELTA=="Primera") %>% 
              summarise(t=sum(multa_mesa)) %>% rename(multa_departamento = t) %>% mutate(DEPARTAMENTO="TOTAL"))->tab1
tab1 %>% 
  mutate(multa_departamento=scales::dollar(multa_departamento, prefix = "s/. "))

tab1 %>% filter(DEPARTAMENTO!="TOTAL") %>% mutate(DEPARTAMENTO=oracion(DEPARTAMENTO)) %>% 
  ggplot(aes(x=multa_departamento,y=reorder(DEPARTAMENTO,multa_departamento)))+
  geom_col(fill="#34495E")+
  scale_x_continuous(labels = scales::dollar_format(scale=1e-6,prefix = "S/ ",suffix = " M"),
                     limits = c(0,250000000), expand = c(0,0), breaks = seq(0,240000000,50000000))+
  labs(x="Multa por departamento (millones de S/)", y="Departamentos",
       title = "Multas por omisión al sufragio por departamento",
       subtitle = "Primera vuelta elecciones presidenciales 2021",
       caption = "ELABORACIÓN: https://github.com/CesarAHN")+
  geom_text(aes(label = scales::dollar(multa_departamento,prefix = "S/ ")), hjust=-0.1)+
  annotate("label", x=200000000,y=6, 
           label=paste0("Total: ",scales::dollar(tab1 %>% filter(DEPARTAMENTO=="TOTAL") %>%
                                                   pull(multa_departamento), prefix = "S/ ")),
           fill = "white",color = "#D35400",size = 5,label.size = .5, fontface="bold")+
  theme_elegante_std()+
  theme(plot.caption = element_text(face = "bold", hjust = 0))
ggsave("plots/img3.png", width = 9, height = 8)

# Segunda vuelta.
tb_elecciones %>% filter(VUELTA=="Segunda") %>% group_by(DEPARTAMENTO) %>% 
  summarise(multa_departamento=sum(multa_mesa)) %>% arrange(-multa_departamento) %>%
  bind_rows(tb_elecciones %>% filter(VUELTA=="Segunda") %>% 
              summarise(t=sum(multa_mesa)) %>% rename(multa_departamento = t) %>% mutate(DEPARTAMENTO="TOTAL"))->tab2
tab2 %>% 
  mutate(multa_departamento=scales::dollar(multa_departamento, prefix = "s/. "))

tab2 %>% filter(DEPARTAMENTO!="TOTAL") %>% mutate(DEPARTAMENTO=oracion(DEPARTAMENTO)) %>% 
  ggplot(aes(x=multa_departamento,y=reorder(DEPARTAMENTO,multa_departamento)))+
  geom_col(fill="#6B8E23")+
  scale_x_continuous(labels = scales::dollar_format(scale=1e-6,prefix = "S/ ",suffix = " M"),
                     limits = c(0,220000000), expand = c(0,0))+
  labs(x="Multa por departamento (millones de S/)", y="Departamentos",
       title = "Multas por omisión al sufragio por departamento",
       subtitle = "Segunda vuelta elecciones presidenciales 2021",
       caption = "ELABORACIÓN: https://github.com/CesarAHN")+
  geom_text(aes(label = scales::dollar(multa_departamento,prefix = "S/ ")), hjust=-0.1)+
  annotate("label", x=180000000,y=6, 
           label=paste0("Total: ",scales::dollar(tab2 %>% filter(DEPARTAMENTO=="TOTAL") %>%
                                                   pull(multa_departamento), prefix = "S/ ")),
           fill = "white",color = "#D35400",size = 5,label.size = .5, fontface="bold")+
  theme_elegante_std()+
  theme(plot.caption = element_text(face = "bold", hjust = 0))
ggsave("plots/img4.png", width = 9, height = 8)


# Total.
tb_elecciones %>% group_by(DEPARTAMENTO) %>% summarise(multa_departamento=sum(multa_mesa)) %>% arrange(-multa_departamento) %>%
  bind_rows(tb_elecciones %>% summarise(t=sum(multa_mesa)) %>% rename(multa_departamento = t) %>% mutate(DEPARTAMENTO="TOTAL"))->total

total %>% filter(DEPARTAMENTO!="TOTAL") %>% mutate(DEPARTAMENTO=oracion(DEPARTAMENTO)) %>% 
  ggplot(aes(x=multa_departamento,y=reorder(DEPARTAMENTO,multa_departamento)))+
  geom_col(fill="#D4A017")+
  scale_x_continuous(labels = scales::dollar_format(scale=1e-6,prefix = "S/ ",suffix = " M"),
                     limits = c(0,420000000), breaks = seq(0,1500000000,100000000), expand = c(0,0))+
  labs(x="Multa por departamento (millones de S/)", y="Departamentos",
       title = "Multas por omisión al sufragio por departamento",
       subtitle = "Consolidado de la primera y segunda vuelta de las elecciones presidenciales 2021",
       caption = "ELABORACIÓN: https://github.com/CesarAHN")+
  geom_text(aes(label = scales::dollar(multa_departamento,prefix = "S/ ")), hjust=-0.1)+
  annotate("label", x=320000000,y=6, 
           label=paste0("Total: ",scales::dollar(total %>% filter(DEPARTAMENTO=="TOTAL") %>%
                                                   pull(multa_departamento), prefix = "S/ ")),
           fill = "white",color = "#D35400",size = 5,label.size = .5, fontface="bold")+
  theme_elegante_std()+
  theme(plot.caption = element_text(face = "bold", hjust = 0))
ggsave("plots/img5.png", width = 9, height = 8)

total %>% 
  mutate(multa_departamento=scales::dollar(multa_departamento, prefix = "s/. ")) %>% View()

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


#-----------------------------------------------------------------------------------------------------------------------
# Escenario 2026.
(27325432-1210813) - tb_elecciones %>% filter(VUELTA=="Primera") %>% summarise(sum(habiles)) %>% pull()

tb_elecciones %>% group_by(CLASIFICACIÓN) %>% 
  summarise(votaron=sum(votaron),
            habiles=sum(habiles)) %>% mutate(p=1-(votaron/habiles)) %>% arrange(-p) %>% mutate(multas=c(27.5,55,110)) %>% 
  mutate(participacion_pobreza=habiles/sum(habiles),
         padron_electoral=2*(27325432-1210813)) %>% 
  mutate(habiles_2026=padron_electoral*participacion_pobreza,
         monto=habiles_2026*p*multas)->tab4

tab4 %>% summarise(sum(monto))

#----------
tb_elecciones %>% group_by(CLASIFICACIÓN) %>% 
  summarise(votaron=sum(votaron),
            habiles=sum(habiles)) %>% mutate(p=1-(votaron/habiles)) %>% arrange(-p) %>% mutate(multas=c(27.5,55,110)) %>% 
  mutate(participacion_pobreza=habiles/sum(habiles),
         padron_electoral=2*(27325432-1210813)) %>% 
  mutate(habiles_2026=padron_electoral*participacion_pobreza,
         monto=habiles_2026*p*multas) %>% mutate(x=sum(p*habiles)/sum(habiles)) %>% 
  select(CLASIFICACIÓN,p,multas,habiles_2026,x)->tt

tasas <- seq(0, 0.5, by = 0.01)

tt %>% crossing(nueva_tasa = tasas) %>% mutate(pp = (nueva_tasa / x) * p,
                                               monto = pp * habiles_2026 * multas) %>% 
  group_by(nueva_tasa) %>% summarise(total = sum(monto), .groups = "drop")->simulacion

simulacion %>% ggplot(aes(x=nueva_tasa, y=total))+
  geom_line(color="#2C3E50")+
  scale_y_continuous(labels = scales::dollar_format(scale = 1e-6,prefix = "S/ ",suffix = " M"),
                     breaks = seq(0,5000000000,400000000))+
  scale_x_continuous(labels = scales::percent, breaks = seq(0,1,.05))+
  labs(y="Recaudación por multas (millones de S/)", 
       x="Tasa de inasistencia electoral",
       title = "Simulación de recaudación por multas electorales (2026)",
       subtitle = "Comparación con el presupuesto estimado del proceso electoral",
       caption = "ELABORACIÓN: https://github.com/CesarAHN")+
  geom_hline(yintercept = 820738683,linetype = "dashed",color = "#E74C3C",linewidth = 1)+
  annotate("text",x = 0.42,y = 820738683,label = "Presupuesto elecciones generales 2026",
           vjust = -0.5,color = "#E74C3C")+
  geom_vline(xintercept = 0.259, color = "#34495E",linewidth = 1,linetype = "dashed")+
  annotate("text",x = 0.2,y = 2700000000,label = "Tasa de inasistencia\nelecciones 2021",color = "#34495E")+
  theme_elegante_std()+
  theme(plot.caption = element_text(face = "bold", hjust = 0))

ggsave("plots/img6.png", width = 9, height = 7)

#-----------------------------------------------------------------------------------------------------------------------

tb_elecciones %>% group_by(VUELTA) %>% 
  summarise(votaron = sum(votaron), habiles = sum(habiles), .groups = "drop") %>% 
  mutate(p = 1 - (votaron / habiles)) %>% gt() %>% 
  cols_label(VUELTA = "Ronda electoral", votaron = "Ciudadanos que sufragaron", 
             habiles = "Electores hábiles", p = "Tasa de ausentismo") %>% 
  fmt_number(columns = c(votaron, habiles), decimals = 0, sep_mark = ",") %>% 
  fmt_percent(columns = p, decimals = 1) %>% 
  cols_align(align = "center", columns = everything()) %>% 
  tab_style(style = list(cell_fill(color = "#0A2540"), cell_text(color = "white", weight = "bold")), 
            locations = cells_column_labels()) %>% 
  tab_style(style = cell_fill(color = "#F4F6F6"), locations = cells_body(rows = 1)) %>% 
  tab_style(style = cell_fill(color = "#E5E8E8"), locations = cells_body(rows = 2)) %>% 
  tab_style(style = cell_text(weight = "bold"), locations = cells_title()) %>% 
  tab_style(style = cell_text(weight = "bold"), locations = cells_source_notes()) %>% 
  tab_header(title = "TASA DE AUSENTISMO EN LAS ELECCIONES GENERALES 2021",
             subtitle = "Primera y segunda vuelta") %>% 
  tab_source_note("ELABORACIÓN: https://github.com/CesarAHN")


#-----------------------------------------------------------------------------------------------------------------------

tb_elecciones %>% group_by(CLASIFICACIÓN) %>% 
  summarise(votaron=sum(votaron), habiles=sum(habiles), .groups="drop") %>% 
  mutate(p=1-(votaron/habiles)) %>% arrange(-p) %>% gt() %>% 
  cols_label(CLASIFICACIÓN="Clasificación socioeconómica", votaron="Ciudadanos que sufragaron",
             habiles="Electores hábiles", p="Tasa de ausentismo") %>% 
  fmt_number(columns=c(votaron,habiles), decimals=0, sep_mark=",") %>% 
  fmt_percent(columns=p, decimals=1) %>% cols_align(align="center", columns=everything()) %>%
  tab_style(style=list(cell_fill(color="#0A2540"), cell_text(color="white", weight="bold")),
            locations=cells_column_labels()) %>% 
  tab_style(style=cell_fill(color="#F4F6F6"), locations=cells_body(rows=1)) %>%
  tab_style(style=cell_fill(color="#E5E8E8"), locations=cells_body(rows=2)) %>%
  tab_style(style=cell_text(weight="bold"), locations=cells_title()) %>%
  tab_style(style=cell_text(weight="bold"), locations=cells_source_notes()) %>%
  tab_header(title="TASA DE AUSENTISMO SEGÚN CLASIFICACIÓN SOCIOECONÓMICA", 
             subtitle="Primera y segunda vuelta de las elecciones generales 2021") %>%
  tab_source_note("ELABORACIÓN: https://github.com/CesarAHN")

#-----------------------------------------------------------------------------------------------------------------------

tb_elecciones %>% group_by(VUELTA,CLASIFICACIÓN) %>% 
  summarise(votaron=sum(votaron), habiles=sum(habiles), .groups="drop") %>% 
  mutate(p=1-(votaron/habiles)) %>% arrange(VUELTA,-p) %>% gt() %>% 
  cols_label(VUELTA="Ronda electoral", CLASIFICACIÓN="Clasificación socioeconómica", 
               votaron="Ciudadanos que sufragaron", habiles="Electores hábiles", p="Tasa de ausentismo") %>%
  fmt_number(columns=c(votaron,habiles), decimals=0, sep_mark=",") %>% 
  fmt_percent(columns=p, decimals=1) %>% cols_align(align="center", columns=everything()) %>% 
  tab_style(style=list(cell_fill(color="#0A2540"), cell_text(color="white", weight="bold")), 
            locations=cells_column_labels()) %>% 
  tab_style(style=cell_fill(color="#F4F6F6"), locations=cells_body(rows=1:3)) %>% 
  tab_style(style=cell_fill(color="#E5E8E8"), locations=cells_body(rows=4:6)) %>% 
  tab_style(style=cell_text(weight="bold"), locations=cells_title()) %>% 
  tab_style(style=cell_text(weight="bold"), locations=cells_source_notes()) %>% 
  tab_header(title="TASA DE AUSENTISMO SEGÚN RONDA ELECTORAL Y CLASIFICACIÓN SOCIOECONÓMICA",
             subtitle="Elecciones generales 2021") %>% 
  tab_source_note("ELABORACIÓN: https://github.com/CesarAHN")

#-----------------------------------------------------------------------------------------------------------------------

presupuesto %>% gt() %>% 
  cols_label(Destino="Entidad", Monto="Presupuesto (S/.)") %>% 
  fmt_number(columns=Monto, decimals=0, sep_mark=",", pattern="S/ {x}") %>% 
  cols_align(align="center", columns=everything()) %>% 
  tab_style(style=list(cell_fill(color="#0A2540"), cell_text(color="white", weight="bold")), locations=cells_column_labels()) %>% 
  tab_style(style=cell_fill(color="#F4F6F6"), locations=cells_body(rows=seq(1, nrow(presupuesto), by=2))) %>% 
  tab_style(style=cell_fill(color="#E5E8E8"), locations=cells_body(rows=seq(2, nrow(presupuesto), by=2))) %>% 
  tab_style(style=cell_text(weight="bold"), locations=cells_body(rows=nrow(presupuesto))) %>% 
  tab_style(style=cell_text(weight="bold"), locations=cells_title()) %>% 
  tab_style(style=cell_text(weight="bold"), locations=cells_source_notes()) %>% 
  tab_header(title="PRESUPUESTO DE LAS ELECCIONES GENERALES 2021",
             subtitle="Distribución de recursos por entidad") %>% 
  tab_source_note("ELABORACIÓN: https://github.com/CesarAHN")

#-----------------------------------------------------------------------------------------------------------------------

tab3 %>% select(multa_departamento,Monto,Diferencia,p)->tab33

names(tab33)<-c("Multa_elecciones_2021","Presupuesto_elecciones_2021","Diferencia entre multa y presupuesto","%")

tab33 %>% gt() %>% 
  cols_label(Multa_elecciones_2021="Multa elecciones 2021", 
             Presupuesto_elecciones_2021="Presupuesto elecciones 2021", 
             `Diferencia entre multa y presupuesto`="Diferencia", `%`="Proporción") %>%
  fmt_number(columns=c(Multa_elecciones_2021,Presupuesto_elecciones_2021,`Diferencia entre multa y presupuesto`),
             decimals=0, sep_mark=",", pattern="S/ {x}") %>% 
  fmt_percent(columns=`%`, decimals=1) %>% cols_align(align="center", columns=everything()) %>% 
  tab_style(style=list(cell_fill(color="#0A2540"), cell_text(color="white", weight="bold")),
            locations=cells_column_labels()) %>% 
  tab_style(style=cell_fill(color="#F4F6F6"), locations=cells_body(rows=1)) %>% 
  tab_style(style=cell_text(weight="bold"), locations=cells_title()) %>% 
  tab_style(style=cell_text(weight="bold"), locations=cells_source_notes()) %>% 
  tab_header(title="MULTAS VS PRESUPUESTO ELECTORAL 2021", 
             subtitle="Comparación agregada") %>% 
  tab_source_note("ELABORACIÓN: https://github.com/CesarAHN")

#-----------------------------------------------------------------------------------------------------------------------
