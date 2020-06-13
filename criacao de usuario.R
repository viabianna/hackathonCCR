#carregar pacotes
library(googlesheets4)
library(dplyr)

#carregar base de novos usuarios
users_raw <- read_sheet("https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", range = "'Form Responses 1'!A:Q")

#preparo da base de perfil
users_raw <- users_raw %>%
  rename( name = "Nome:", idade = "Idade:", genero = "Gênero", altura = "Altura (cm)", peso = "Peso (kg)",
          sono = "Quantas horas você costuma dormir por noite?", atividades = "Quantas vezes por semana você pratica atividades físicas?",
          refeicoes = "Quantas refeições você faz por dia?", agua = "Quantos litros de água você bebe por dia?",
          dirige = "Quantas horas você geralmente dirige em um dia?", fumo = "Você é fumante?",
          diabetes = "Você tem diabetes?", hipertenso = "Você tem hipertensão?" , cardiaco = "Você tem problemas cardíacos?",
          lombar = "Com que frequência você sente dores na lombar?" , joelho = "Com que frequência você sente dores no joelho?"  )

for (i in 1:nrow(users_raw)){
  if (users_raw$atividades[i] == "Nunca"){users_raw$atividades[i] <- 5}
  else if (users_raw$atividades[i] == "Menos de uma vez por semana"){users_raw$atividades[i] <- 4}
  else if (users_raw$atividades[i] == "Uma vez por semana"){users_raw$atividades[i] <- 3}
  else if (users_raw$atividades[i] == "Duas a três vezes por semana"){users_raw$atividades[i] <- 2}
  else if (users_raw$atividades[i] == "Quatro a cinco vezes por semana"){users_raw$atividades[i] <- 1}
  else if (users_raw$atividades[i] == "Mais de cinco vezes por semana"){users_raw$atividades[i] <- 0}
  if (users_raw$hipertenso[i] == "Não") {users_raw$hipertenso[i] <- 0}
  else if (users_raw$hipertenso[i] == "Não sei") {users_raw$hipertenso[i] <- 1.5}
  else {users_raw$hipertenso[i] <- 3}
  if (users_raw$cardiaco[i] == "Não") {users_raw$cardiaco[i] <- 0}
  else if (users_raw$cardiaco[i] == "Não sei") {users_raw$cardiaco[i] <- 1.5}
  else {users_raw$cardiaco[i] <- 3}
  if (users_raw$joelho[i] == "Nunca"){users_raw$joelho[i] <- 0}
  else if (users_raw$joelho[i] == "Menos de uma vez por semana"){users_raw$joelho[i] <- 1}
  else if (users_raw$joelho[i] == "Algumas vezes por semana"){users_raw$joelho[i] <- 2}
  else {users_raw$joelho[i] <- 3}
  if (users_raw$lombar[i] == "Nunca"){users_raw$lombar[i] <- 0}
  else if (users_raw$lombar[i] == "Menos de uma vez por semana"){users_raw$lombar[i] <- 1}
  else if (users_raw$lombar[i] == "Algumas vezes por semana"){users_raw$lombar[i] <- 2}
  else {users_raw$lombar[i] <- 3}
  
}

#cálculo de pontos
IMC <- users_raw$peso /( (users_raw$altura / 100) * (users_raw$altura / 100) )
IMC_pontos <- rep(0, nrow(users_raw))

for (i in 1:nrow(users_raw)){
  if (IMC[i] < 18.5) {IMC_pontos[i] <- 2}
  else if(IMC[i] < 25){IMC_pontos[i] <- 0}
  else if(IMC[i] < 30){IMC_pontos[i] <- 1}
  else if(IMC[i] < 35){IMC_pontos[i] <- 2.2}
  else if(IMC[i] < 40){IMC_pontos[i] <- 3.5}
  else{IMC_pontos[i] <- 5}
}


cardiaco <- (as.numeric( users_raw$hipertenso) + as.numeric(users_raw$cardiaco))*16
atividade <- as.numeric(users_raw$atividades) * 8
IMC_pontos <- IMC_pontos *4
idade <- ((users_raw$idade)/10) *2
dores <- as.numeric(users_raw$joelho) + as.numeric(users_raw$lombar)


score_final <- cardiaco + IMC_pontos + idade + dores + atividade

teste <- data.frame (users_raw$name, cardiaco, IMC_pontos, idade, dores, atividade, score_final)

#calculo de grupo
grupo <- rep("Sedentário Nível 1", nrow(users_raw))
for (i in 1:nrow(users_raw)){
  if(score_final[i] < 20){grupo[i] <- "Ativo Nível 2"}
  else if(score_final[i] < 50){grupo[i] <- "Ativo Nível 1"}
  else if(score_final[i] < 100){grupo[i] <- "Sedentário Nível 1"}
}

subgrupo <- rep("nenhum", nrow(users_raw))
for (i in 1:nrow(users_raw)){
  if(cardiaco[i] >=48){subgrupo[i] <- "cardiaco"}
  else if(users_raw$lombar[i] >=2){subgrupo[i] <- "coluna"}
}

#output

perfil <- data.frame (usuario = users_raw$name, idade = users_raw$idade, genero = users_raw$genero, IMC, grupo, subgrupo, criacao = users_raw$Timestamp)

#registro em tabela

sheet_write(perfil, ss="https://docs.google.com/spreadsheets/d/1t3868phzUgR2Q_8k_wQpYMM7G-Nc61xXpdV4TMVPbB0/edit#gid=0", sheet = "perfil")


