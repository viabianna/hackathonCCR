#carregar pacotes
library(googlesheets4)
library(dplyr)

#carregar bases
atividades <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Form Responses 2'!A:C")
usuarios <-  read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'perfil'!A:G")
acr_pontos <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Atividades'!A:H")
desc_pontos <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Descontos ativos'!A:B")
cupons <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Form Responses 3'!A:D")%>% filter(`Desconto aplicado?`=="Sim")  


#somar e subtrair pontos
acrescimos <- inner_join(atividades, acr_pontos, by="Atividade")
acrescimos <- acrescimos %>% 
  group_by(Usuario) %>% 
  summarise(Pontos_positivos = sum(`Pontos/atividade`))

cupons <- cupons %>%
  rename( Cupons = "Aplicar desconto") 
decrescimos <- inner_join(cupons, desc_pontos, by="Cupons")
decrescimos <- decrescimos %>% 
  group_by(Usuario) %>% 
  summarise(Pontos_negativos = sum(`Pontos`))
total <- full_join(acrescimos, decrescimos, by="Usuario")
total[is.na(total)] <- 0
total$saldo <- total$Pontos_positivos - total$Pontos_negativos

#criar tabela de saldo
data_atualizacao <- rep(Sys.time(), nrow(usuarios))

saldo <- data.frame(usuarios$usuario, data_atualizacao) %>% rename(Usuario = "usuarios.usuario")
saldo <- left_join(saldo, total, by="Usuario")
saldo[is.na(saldo)] <- 0
saldo <- data.frame(Usuario = saldo$Usuario,
                    Atualizacao = saldo$data_atualizacao,
                    Saldo = saldo$saldo)

#registro em tabela

sheet_write(saldo, ss="https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", sheet = "carteira")
