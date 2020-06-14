#carregar pacotes
library(googlesheets4)
library(dplyr)

#carregar bases
atividades <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Form Responses 2'!A:C")
saldo <-  read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'carteira'!A:C")
desc_pontos <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Descontos ativos'!A:B")
cupons <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Form Responses 3'!A:D") %>% rename(Cupons = "Aplicar desconto")



aplicar_desconto <- inner_join (cupons, desc_pontos, by = "Cupons") %>%
  filter((is.na(`Desconto aplicado?`)==TRUE)|(`Desconto aplicado?`=="Atualizar Saldo"))   
saldo_atual <- saldo %>% filter(Usuario == aplicar_desconto$Usuario[1])
nova_entrada <- atividades %>% 
  group_by(Usuario) %>% 
  summarise(ultima_atividade = max(Timestamp))%>% 
  filter(Usuario == aplicar_desconto$Usuario[1])
#verifica se saldo de pontos está atualizado e, caso não esteja, solicita atualização de saldo.
#Se o saldo estiver atualizado, insere a informação se o cupom foi ou não aplicado
if(nova_entrada$ultima_atividade > saldo_atual$Atualizacao){
  aplicar_desconto$`Desconto aplicado?`[1] <- 'Atualizar Saldo'
} else if (aplicar_desconto$Pontos[1] > saldo_atual$Saldo){
    aplicar_desconto$`Desconto aplicado?`[1] <- "Não"
} else {
      aplicar_desconto$`Desconto aplicado?`[1] <- "Sim"
}


for(i in 1:nrow(cupons)){
  if ((cupons$Timestamp[i] == aplicar_desconto$Timestamp[1]) & (cupons$Usuario[i] == aplicar_desconto$Usuario[1])){
    cupons$`Desconto aplicado?`[i] <- aplicar_desconto$`Desconto aplicado?`[1]
  }
}
cupons <- cupons %>% rename("Aplicar desconto" = "Cupons")

#atualiza planilha de descontos com a informação
sheet_write(cupons, ss="https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", sheet = 'Form Responses 3')

