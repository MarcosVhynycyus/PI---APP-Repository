# 💰 FinansMe - Controle Financeiro Pessoal

Aplicativo mobile para gestão de finanças pessoais, desenvolvido com **Flutter** no frontend e **Nest.js** no backend, que se comunica através de uma API RESTful. O sistema permite o controle completo de despesas e receitas, com suporte a lançamentos recorrentes ou pontuais, além da gestão de bancos e contas.

---

## 📌 Sobre o Projeto

O **Meu Dinheiro** nasceu da necessidade de oferecer uma ferramenta simples, eficiente e personalizável para que pessoas físicas possam organizar suas finanças do dia a dia. Com ele, o usuário consegue visualizar para onde seu dinheiro está indo, planejar gastos futuros e manter um histórico claro de todas as movimentações financeiras.

---

## 🎯 Problema

Muitas pessoas enfrentam dificuldades para controlar seus gastos mensais, seja por falta de uma ferramenta adequada, seja pela complexidade das soluções existentes. Planilhas podem se tornar confusas e aplicativos genéricos nem sempre se adaptam à realidade de cada um. O **Meu Dinheiro** resolve isso oferecendo uma interface intuitiva e recursos essenciais para o dia a dia financeiro, com suporte a lançamentos recorrentes (como contas fixas) e a possibilidade de organizar o dinheiro em diferentes contas e bancos.

---

## 👥 Público-alvo

- Pessoas físicas que desejam organizar suas finanças pessoais.
- Profissionais autônomos que precisam separar gastos pessoais dos profissionais.
- Famílias que querem controlar o orçamento doméstico de forma colaborativa.
- Usuários que buscam uma alternativa gratuita e de código aberto aos aplicativos pagos.

---

## 🚀 Objetivo

Oferecer uma solução completa e de fácil utilização para o controle financeiro pessoal, permitindo que o usuário:

- Registre despesas e receitas de forma rápida.
- Categorize os lançamentos para entender seus hábitos de consumo.
- Configure transações recorrentes (ex.: aluguel, salário, assinaturas).
- Gerencie múltiplas contas e bancos em um só lugar.
- Acompanhe relatórios e gráficos que facilitem a tomada de decisões.

---

## 📦 Épicos Iniciais

Os épicos abaixo representam as grandes frentes de desenvolvimento do projeto e serão detalhados em funcionalidades menores ao longo das sprints.

### 1. Gestão de Contas e Bancos
- Cadastro, edição e exclusão de bancos.
- Criação de contas (corrente, poupança, dinheiro físico) associadas a um banco.
- Visualização do saldo atualizado de cada conta.

### 2. Gestão de Transações
- Registro de despesas e receitas com data, valor, categoria e conta vinculada.
- Capacidade de anexar comprovantes ou observações.
- Edição e exclusão de lançamentos.

### 3. Transações Recorrentes
- Configuração de lançamentos que se repetem automaticamente (diário, semanal, mensal, anual).
- Visualização de próximos lançamentos e ajuste de recorrências.
- Opção de pausar ou encerrar uma recorrência.

### 4. Dashboard e Relatórios
- Visão geral do saldo total, receitas e despesas do mês.
- Gráficos por categoria (pizza, barras) para análise de gastos.
- Histórico de evolução patrimonial ao longo do tempo.

### 5. Configurações e Perfil
- Gerenciamento de categorias de despesas e receitas (personalizáveis).
- Definição de moeda padrão e formato de data.
- Controle de usuários e autenticação (login/registro).

---

## 🛠️ Tecnologias Utilizadas

- **Frontend Mobile:** Flutter (Dart)
- **Backend:** Nest.js (Node.js + TypeScript)
- **API:** RESTful
- **Banco de Dados:** (a definir – PostgreSQL, MySQL ou MongoDB)
- **Autenticação:** JWT (JSON Web Tokens)

---

## ⚙️ Como executar o projeto

### Pré-requisitos
- Flutter SDK (versão estável mais recente)
- Node.js (v16 ou superior) e npm/yarn
- Nest CLI (opcional)
- Banco de dados configurado (ex.: PostgreSQL)

### Backend (Nest.js)
1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/meu-dinheiro.git
