#carregar pacotes
library(googlesheets4)
library(dplyr)
library(lubridate)

#carregar bases
atividades <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Form Responses 2'!A:C")
usuarios <-  read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'perfil'!A:G")
acr_pontos <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Atividades'!A:H")
desc_pontos <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Descontos ativos'!A:B")
cupons <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Form Responses 3'!A:D")%>% filter(`Desconto aplicado?`=="Sim")  



#calculo de dias entre treino completo
completos_data <- atividades %>% filter(Atividade == "Treino Completo")
completos_data$dia <- as.Date(completos_data$Timestamp)
completos_data <- completos_data %>% group_by(Usuario, dia) %>% summarise (Timestamp = min(Timestamp))%>%arrange(Usuario, Timestamp)
completos_data$intervalo <- 0
for (i in 1:(nrow(completos_data)-1)){
  if(completos_data$Usuario[i] == completos_data$Usuario[i+1]){
    completos_data$intervalo[i+1] <- (completos_data$dia[i] %--% completos_data$dia[i+1])/ddays(1)
  }
}

#adicionar pontuação exponencial por dias corridos de treino completo (pontuação extra por recorrencia)
completos_data$peso <- 1
for (i in 2:nrow(completos_data)){
  if(completos_data$Usuario[i] == completos_data$Usuario[i-1]){
    if(completos_data$intervalo[i]==1){
      completos_data$peso[i] <- completos_data$peso[i-1] * 1.1
    }
  }
}

#adicionar o peso à pontuação recebida
acrescimos <- inner_join(atividades, acr_pontos, by="Atividade")

for (i in 1:nrow(acrescimos)){
  for (j in 1:nrow(completos_data)){
    if (acrescimos$Atividade[i] == "Treino Completo" & acrescimos$Usuario[i] == completos_data$Usuario[j] & acrescimos$Timestamp[i] == completos_data$Timestamp[j]){
      acrescimos$`Pontos/atividade`[i] <- acrescimos$`Pontos/atividade`[i] * completos_data$peso[j]
    }
  }
}

#somar e subtrair pontos por atividade e uso de cupom

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
