# Regras de Negócio – FinansMe

As regras de negócio definem as condições e restrições que devem ser respeitadas pelo sistema durante seu funcionamento. Elas garantem que os dados registrados sejam válidos e que o comportamento da aplicação esteja alinhado com o objetivo do sistema.

---

## RN01 – Autenticação Obrigatória

O usuário deve estar autenticado no sistema para acessar qualquer funcionalidade relacionada às suas informações financeiras.

Usuários não autenticados podem acessar apenas:
- Tela de login
- Tela de cadastro

---

## RN02 – Registro de Transações

Toda transação financeira registrada pelo usuário deve conter obrigatoriamente:

- Tipo da transação (receita ou despesa)
- Valor
- Data
- Descrição ou identificação da transação

Caso alguma dessas informações esteja ausente, a transação não deve ser registrada.

---

## RN03 – Valor da Transação

O valor de uma transação deve ser maior que zero.

Valores iguais ou menores que zero não devem ser aceitos pelo sistema.

---

## RN04 – Classificação de Transações

Todas as transações devem ser classificadas como:

- Receita (entrada de dinheiro)
- Despesa (saída de dinheiro)

Essa classificação será utilizada para cálculos de saldo e relatórios financeiros.

---

## RN05 – Associação de Transação ao Usuário

Cada transação registrada deve estar associada exclusivamente ao usuário que a criou.

Usuários não podem visualizar ou modificar transações de outros usuários.

---

## RN06 – Cálculo do Saldo Financeiro

O saldo financeiro do usuário deve ser calculado da seguinte forma:

Saldo = Soma das receitas – Soma das despesas

Esse saldo será apresentado na tela principal do aplicativo.

---

## RN07 – Edição de Transações

O usuário pode editar apenas as transações que ele próprio registrou.

Após a edição, o sistema deve atualizar automaticamente o saldo financeiro do usuário.

---

## RN08 – Exclusão de Transações

O usuário pode excluir transações registradas.

Após a exclusão, o sistema deve recalcular o saldo financeiro automaticamente.

---

## RN09 – Persistência de Dados

Todas as transações registradas devem ser armazenadas no banco de dados de forma permanente, garantindo que os dados permaneçam disponíveis mesmo após o encerramento da sessão do usuário.

---

## RN10 – Integridade de Dados

O sistema deve garantir que alterações realizadas em transações (edição ou exclusão) não causem inconsistências nos dados financeiros armazenados.

Qualquer operação que falhe deve ser cancelada sem comprometer as informações existentes.