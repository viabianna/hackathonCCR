# hackathonCCR
# Equipe 211 - Duca

Os algoritmos apresentados criam um plano de treinamento e dão pontuação para a execução frequente desses treinos, a partir da referência tecnica abaixo:

*referência tecnica desenvolvida pelo grupo* em https://drive.google.com/file/d/1zQj1WG7zJM02E48RbZO2pnVCzSFbjMfQ/view?usp=sharing


Os inputs e outputs do algoritmo podem ser visto nas planilhas indicadas em *como testar*.

**1. cálculo de perfil**

com base nas respostas do formulário 1,  algoritmo indica qual o perfil do nosso usuário, levando em consideração os principais índices de saúde a serem observados. Esses índices têm pesos diferentes no score final conforme a sua importância. Além disso o usuário pode estar em um subgrupo conforme algumas condições específicas, como cardíaco ou que sofre de dores musculares ou posturais.

**2. atualizar saldo por atividade feita**

além dos pontos absolutos por atividade feita, o usuário recebe uma bonificação se fizer o treino completo todos os dias. Se o usuário fizer o treino completo mais de uma vez em um dia, ele só ganhará bonificação no primeiro treino. A bonificação cresce 10% por dia de treino, mas se o usuário deixa de treinar um dia, o valor da bonificação volta para o dia 1.

**3. uso de cupom**

quando o usuário utiliza um cupom, verificamos seu saldo. Se é maior que o valor do cupom, a ação é validada e o cupom descontado; se for menor que o valor do cupom, a ação é rejeitada.
