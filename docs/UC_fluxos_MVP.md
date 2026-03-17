# Casos de Uso e Fluxos do Sistema – FinansMe

## 1. Objetivo

Este documento consolida os **casos de uso do sistema**, seus **fluxos principais e alternativos** e a **relação entre cada caso de uso e a arquitetura MVP (Model-View-Presenter)**, com base no escopo, requisitos funcionais, regras de negócio e backlog do projeto FinansMe.

## 2. Base de referência

A documentação foi derivada dos seguintes artefatos do projeto:

- Escopo do sistema
- Requisitos funcionais
- Regras de negócio
- Requisitos não funcionais
- Product backlog

## 3. Casos de uso do sistema

### UC01 – Cadastrar usuário
**Objetivo:** permitir que um novo usuário crie uma conta.

**Atores:** Usuário

**Requisitos relacionados:** RF01, RN01

**User story relacionada:** US01

**Fluxo principal:**
1. O usuário acessa a tela de cadastro.
2. O sistema solicita os dados de cadastro.
3. O usuário informa os dados obrigatórios.
4. O sistema valida os dados informados.
5. O sistema cria a conta do usuário.
6. O sistema confirma o cadastro.

**Fluxos alternativos:**
- 4A. Dados obrigatórios não informados.
  - 4A.1. O sistema exibe mensagem de validação.
  - 4A.2. O usuário corrige os dados e reenviá o formulário.
- 5A. Usuário já cadastrado.
  - 5A.1. O sistema informa que já existe conta vinculada ao identificador informado.
  - 5A.2. O sistema orienta o usuário a realizar login.

---

### UC02 – Autenticar usuário
**Objetivo:** permitir acesso seguro às funcionalidades do sistema.

**Atores:** Usuário

**Requisitos relacionados:** RF02, RN01, RN03, RNF03

**User story relacionada:** US02

**Fluxo principal:**
1. O usuário acessa a tela de login.
2. O sistema solicita e-mail e senha.
3. O usuário informa suas credenciais.
4. O sistema valida as credenciais.
5. O sistema autentica o usuário.
6. O sistema redireciona para a tela principal.

**Fluxos alternativos:**
- 4A. Credenciais inválidas.
  - 4A.1. O sistema informa falha na autenticação.
  - 4A.2. O usuário pode tentar novamente.
- 4B. Usuário não cadastrado.
  - 4B.1. O sistema informa que a conta não foi encontrada.
  - 4B.2. O sistema sugere cadastro.

---

### UC03 – Registrar transação
**Objetivo:** permitir o lançamento de receita ou despesa.

**Atores:** Usuário autenticado

**Requisitos relacionados:** RF03, RF05, RN02, RN03, RN04, RN05, RN09

**User stories relacionadas:** US03, US04

**Fluxo principal:**
1. O usuário acessa a funcionalidade de nova transação.
2. O sistema exibe o formulário de lançamento.
3. O usuário informa tipo, valor, data e descrição.
4. O sistema valida os campos obrigatórios.
5. O sistema valida se o valor é maior que zero.
6. O sistema associa a transação ao usuário autenticado.
7. O sistema registra a transação.
8. O sistema confirma o lançamento.
9. O sistema atualiza o saldo do usuário.

**Fluxos alternativos:**
- 4A. Campo obrigatório não informado.
  - 4A.1. O sistema impede o salvamento.
  - 4A.2. O sistema destaca os campos pendentes.
- 5A. Valor menor ou igual a zero.
  - 5A.1. O sistema exibe mensagem de erro.
  - 5A.2. O usuário corrige o valor.
- 7A. Falha ao persistir a transação.
  - 7A.1. O sistema cancela a operação.
  - 7A.2. O sistema preserva a integridade dos dados.
  - 7A.3. O sistema informa que o lançamento não foi concluído.

---

### UC04 – Visualizar histórico de transações
**Objetivo:** exibir ao usuário suas transações registradas.

**Atores:** Usuário autenticado

**Requisitos relacionados:** RF04, RN05

**User story relacionada:** US06

**Fluxo principal:**
1. O usuário acessa a tela de histórico.
2. O sistema consulta as transações associadas ao usuário autenticado.
3. O sistema apresenta a lista de transações.

**Fluxos alternativos:**
- 2A. Usuário sem transações cadastradas.
  - 2A.1. O sistema exibe histórico vazio.
  - 2A.2. O sistema sugere registrar a primeira transação.
- 2B. Falha na consulta.
  - 2B.1. O sistema informa indisponibilidade temporária.

---

### UC05 – Visualizar situação financeira
**Objetivo:** apresentar resumo consolidado de receitas, despesas e saldo.

**Atores:** Usuário autenticado

**Requisitos relacionados:** RF06, RN06

**User story relacionada:** US07

**Fluxo principal:**
1. O usuário acessa a tela principal.
2. O sistema consulta as transações do usuário.
3. O sistema calcula receitas, despesas e saldo.
4. O sistema apresenta o resumo financeiro.

**Fluxos alternativos:**
- 2A. Usuário sem transações registradas.
  - 2A.1. O sistema apresenta saldo zerado.
  - 2A.2. O sistema exibe resumo vazio.
- 3A. Inconsistência em atualização interrompida.
  - 3A.1. O sistema cancela a operação de cálculo baseada em dados incompletos.
  - 3A.2. O sistema mantém o último estado íntegro disponível.

---

### UC06 – Editar transação
**Objetivo:** permitir correção de uma transação registrada.

**Atores:** Usuário autenticado

**Requisitos relacionados:** RN05, RN07, RN10

**User story relacionada:** US05

**Fluxo principal:**
1. O usuário seleciona uma transação de sua lista.
2. O sistema exibe os dados atuais.
3. O usuário altera as informações desejadas.
4. O sistema valida os novos dados.
5. O sistema atualiza a transação.
6. O sistema recalcula o saldo.
7. O sistema confirma a edição.

**Fluxos alternativos:**
- 1A. Tentativa de editar transação de outro usuário.
  - 1A.1. O sistema nega a operação.
- 4A. Dados inválidos após edição.
  - 4A.1. O sistema bloqueia a atualização.
  - 4A.2. O usuário ajusta os dados.
- 5A. Falha na atualização.
  - 5A.1. O sistema desfaz a operação.
  - 5A.2. O sistema mantém os dados anteriores.

---

### UC07 – Excluir transação
**Objetivo:** remover uma transação registrada pelo próprio usuário.

**Atores:** Usuário autenticado

**Requisitos relacionados:** RN05, RN08, RN10

**User story relacionada:** US05

**Fluxo principal:**
1. O usuário seleciona uma transação.
2. O sistema solicita confirmação.
3. O usuário confirma a exclusão.
4. O sistema remove a transação.
5. O sistema recalcula o saldo.
6. O sistema confirma a exclusão.

**Fluxos alternativos:**
- 3A. Usuário cancela a exclusão.
  - 3A.1. O sistema encerra a operação sem alterações.
- 1A. Tentativa de excluir transação de outro usuário.
  - 1A.1. O sistema nega a operação.
- 4A. Falha na exclusão.
  - 4A.1. O sistema restaura o estado anterior.
  - 4A.2. O sistema informa que a exclusão não foi concluída.

---

### UC08 – Gerenciar contas ou bancos
**Objetivo:** permitir visualização e gerenciamento das contas financeiras do usuário.

**Atores:** Usuário autenticado

**Requisitos relacionados:** RF07

**User story relacionada:** US08

**Fluxo principal:**
1. O usuário acessa a tela de contas ou bancos.
2. O sistema consulta os dados cadastrados.
3. O sistema apresenta as contas do usuário.
4. O usuário realiza uma ação de gerenciamento disponível.
5. O sistema salva a alteração e atualiza a visualização.

**Fluxos alternativos:**
- 2A. Não existem contas cadastradas.
  - 2A.1. O sistema exibe lista vazia.
- 5A. Falha ao salvar alteração.
  - 5A.1. O sistema informa erro e mantém o estado anterior.

---

### UC09 – Visualizar e editar perfil
**Objetivo:** permitir manutenção dos dados do usuário.

**Atores:** Usuário autenticado

**Requisitos relacionados:** RF08

**User story relacionada:** US09

**Fluxo principal:**
1. O usuário acessa a tela de perfil.
2. O sistema apresenta os dados atuais.
3. O usuário altera as informações permitidas.
4. O sistema valida os dados.
5. O sistema salva as alterações.
6. O sistema confirma a atualização do perfil.

**Fluxos alternativos:**
- 4A. Dados inválidos.
  - 4A.1. O sistema informa inconsistências.
  - 4A.2. O usuário corrige os campos.
- 5A. Falha ao salvar perfil.
  - 5A.1. O sistema informa erro e mantém os dados anteriores.

---

### UC10 – Navegar entre telas
**Objetivo:** permitir deslocamento entre as telas principais do aplicativo.

**Atores:** Usuário

**Requisitos relacionados:** RF09

**Fluxo principal:**
1. O usuário seleciona uma opção de navegação.
2. O sistema carrega a tela correspondente.
3. O sistema exibe a funcionalidade escolhida.

**Fluxos alternativos:**
- 2A. Tentativa de acesso a tela protegida sem autenticação.
  - 2A.1. O sistema redireciona para login.
- 2B. Falha de carregamento.
  - 2B.1. O sistema informa erro temporário.

## 4. Relação entre casos de uso e funcionalidades da arquitetura MVP

Na arquitetura **MVP (Model-View-Presenter)**:

- **View**: telas, formulários e componentes visuais.
- **Presenter**: recebe ações da View, valida regras de fluxo, coordena casos de uso e prepara os dados para exibição.
- **Model**: entidades, regras de negócio, serviços e persistência dos dados.

### 4.1 Mapeamento por responsabilidade

| Caso de uso | View | Presenter | Model |
|---|---|---|---|
| UC01 – Cadastrar usuário | Tela de cadastro, campos e mensagens | Valida entrada, coordena envio do cadastro, trata sucesso/erro | Entidade usuário, serviço de cadastro, persistência |
| UC02 – Autenticar usuário | Tela de login | Valida credenciais informadas, coordena autenticação e redirecionamento | Serviço de autenticação, sessão do usuário |
| UC03 – Registrar transação | Formulário de transação | Valida fluxo, aciona cadastro da transação, atualiza tela | Entidade transação, regras RN02/RN03/RN04/RN05, repositório |
| UC04 – Visualizar histórico | Tela de histórico | Solicita dados e organiza listagem para exibição | Repositório de transações, consulta por usuário |
| UC05 – Visualizar situação financeira | Home/dashboard | Solicita cálculo e prepara resumo | Regras de saldo, agregação de receitas e despesas |
| UC06 – Editar transação | Tela de edição | Valida alterações, envia atualização, reflete resultado | Atualização da transação, integridade e recálculo |
| UC07 – Excluir transação | Confirmação e feedback visual | Coordena exclusão e atualização da interface | Remoção da transação, integridade e recálculo |
| UC08 – Gerenciar contas ou bancos | Tela de contas/bancos | Coordena carregamento e manutenção das contas | Dados de contas, persistência e consulta |
| UC09 – Visualizar e editar perfil | Tela de perfil | Valida alterações e coordena atualização | Dados do usuário e persistência |
| UC10 – Navegar entre telas | Navegação/menu | Controla rotas e regras de acesso | Estado de autenticação e dados necessários |

### 4.2 Relação com funcionalidades do MVP

#### View
Responsável por:
- exibir formulários de login, cadastro, transação, perfil e contas;
- exibir histórico, resumo financeiro e mensagens de erro;
- capturar interações do usuário;
- garantir usabilidade compatível com RNF02.

#### Presenter
Responsável por:
- intermediar a comunicação entre interface e regras do sistema;
- validar fluxos principais e alternativos;
- aplicar restrições de autenticação;
- solicitar atualização da View após operações de cadastro, edição, exclusão e consulta;
- controlar navegação entre telas.

#### Model
Responsável por:
- representar usuário, transação e contas;
- aplicar regras de negócio RN01 a RN10;
- persistir e recuperar dados;
- recalcular saldo e manter integridade dos registros;
- garantir consistência das operações em caso de falha.

## 5. Relação entre casos de uso e MVP do produto

| Caso de uso | Presença no MVP do produto | Justificativa |
|---|---|---|
| UC01 – Cadastrar usuário | Sim | Necessário para entrada de novos usuários |
| UC02 – Autenticar usuário | Sim | Necessário para acesso seguro ao sistema |
| UC03 – Registrar transação | Sim | Funcionalidade central do produto |
| UC04 – Visualizar histórico | Sim | Necessário para acompanhamento financeiro |
| UC05 – Visualizar situação financeira | Sim | Entrega valor imediato ao usuário |
| UC06 – Editar transação | Sim | Previsto no backlog e nas regras de negócio |
| UC07 – Excluir transação | Sim | Previsto no backlog e nas regras de negócio |
| UC08 – Gerenciar contas ou bancos | Sim | Está no escopo funcional do sistema |
| UC09 – Visualizar e editar perfil | Sim | Faz parte do escopo definido |
| UC10 – Navegar entre telas | Sim | Suporte básico para uso do aplicativo |

## 6. Observações de consistência documental

Os arquivos PUML anteriores apresentam funcionalidades não previstas nos artefatos-base, como:
- interação com IA;
- recorrência de despesas;
- classificação automática por modelo de linguagem;
- recuperação de senha;
- planos de contas e transatores.

Esses elementos **não aparecem no escopo, backlog ou requisitos fornecidos** e, portanto, não devem compor a documentação principal do projeto nesta versão.

## 7. Conclusão

Com esta atualização, a documentação passa a:
- alinhar os casos de uso aos requisitos realmente definidos;
- registrar fluxos principais e alternativos;
- explicitar a ligação entre os casos de uso e a arquitetura MVP;
- manter coerência com o MVP do produto previsto para o FinansMe.