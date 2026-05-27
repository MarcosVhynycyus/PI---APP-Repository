# Casos de Teste — FinansMe

Projeto: Finansme Flutter
Tecnologia: Flutter / Dart
Normas aplicadas: ISO/IEC/IEEE 29119-1 · 29119-2 · 29119-4

## Objetivo

Documentar os casos de teste automatizados para validar as funcionalidades dos seis módulos do MVP do FinansMe, com foco em contrato de API, regras de negócio e estrutura mínima das respostas.

Os testes estão implementados em:

```text
tests/support/test_api_server.dart
tests/user_test/signin_test.dart
tests/user_test/login_test.dart
tests/user_test/update_user_test.dart
tests/account_test/create_account_test.dart
tests/account_test/list_accounts_test.dart
tests/account_test/balance_test.dart
tests/account_plan_test/account_plan_test.dart
tests/transactor_test/transactor_test.dart
tests/financial_movement_test/create_movement_test.dart
tests/financial_movement_test/list_movements_test.dart
tests/financial_movement_test/update_movement_test.dart
tests/financial_movement_test/delete_movement_test.dart
tests/ai_advisor_test/ai_advisor_test.dart
```

## Sistema sob Teste

Aplicativo Finansme Flutter — sistema de gestão financeira pessoal. O sistema sob teste corresponde à camada de integração entre o aplicativo Flutter e a API REST de back-end, exercida via `ApiClient`.

## Itens de Teste

- `ApiClient` — camada de serviços HTTP.
- Módulo User — endpoints `/signin`, `/login`, `/alter`.
- Módulo Account — endpoints `/accounts`, `/user-accounts`, `/user-balance`.
- Módulo Account Plan — endpoint `/account-plans`.
- Módulo Transactor — endpoint `/transactors`.
- Módulo Financial Movement — endpoints `/financial-movements`, `/user-financial-movements`.
- Módulo AI Advisor — endpoint `/ai-response`.
- `TestApiServer` — servidor HTTP mock utilizado nos testes.

## Escopo

- Cadastro, login e atualização de dados de usuário.
- Cadastro e listagem de contas financeiras.
- Consulta de saldo consolidado do usuário.
- Cadastro e listagem de planos de conta.
- Cadastro e listagem de transatores.
- Criação, listagem, atualização e exclusão de movimentações financeiras.
- Consulta ao conselheiro financeiro de IA.
- Validação de autenticação via token Bearer.
- Validação de campos obrigatórios e regras de negócio.

## Fora de Escopo

- Integração com a API REST real de produção.
- Testes de interface (UI) das telas Flutter.
- Testes de performance e carga.
- Testes de segurança ofensiva (pen-test).
- Configuração de banco de dados.
- Integração com provedores externos de IA.

## Estratégia

A suíte usa testes de integração de API com um servidor HTTP local mock implementado em `tests/support/test_api_server.dart`. Cada teste enfileira um handler que valida a requisição recebida e devolve uma resposta simulada.

Essa abordagem permite validar:

- Método HTTP e rota chamados.
- Payload enviado pelo `ApiClient`.
- Header de autorização quando necessário.
- Status HTTP e estrutura mínima do corpo de resposta.
- Tratamento de exceção `ApiException` pelo `ApiClient`.

A API real não é chamada. A execução é reprodutível e independente de rede, banco de dados ou ambiente externo.

As condições de teste foram derivadas pelas seguintes técnicas (ISO/IEC/IEEE 29119-4):

| Técnica | Finalidade |
| --- | --- |
| Particionamento de Equivalência | Separar entradas válidas e inválidas em classes |
| Valor Limite | Validar fronteiras de valores numéricos e campos vazios |
| Transição de Estado | Validar mudança de estado do sistema (saldo, token, duplicatas) |
| Teste Baseado em Cenário | Validar fluxos compostos por múltiplas chamadas |
| Tabela de Decisão | Validar combinações de presença/ausência de token e credenciais |
| Teste de Contrato | Validar estrutura e tipos dos payloads de requisição e resposta |

## Ambiente

- Flutter SDK.
- Dart SDK.
- Pacote `flutter_test`.
- Pacote `integration_test`.
- Sistema operacional: macOS / Linux / Windows.

## Tipos de Teste

- **Teste de Unidade** — camada `ApiClient` e serializações.
- **Teste de Integração de API** — com servidor HTTP mock (`TestApiServer`).
- **Teste Funcional** — regras de negócio: saldo, autenticação, validações.
- **Teste de Contrato** — estrutura de payloads de requisição e resposta.

## Critérios de Entrada

- Projeto Flutter compilando sem erros.
- `ApiClient` e serviços de domínio implementados.
- `TestApiServer` implementado em `tests/support/test_api_server.dart`.
- Endpoints REST do back-end especificados e versionados.
- Documentos A, B e C de teste concluídos e aprovados.

## Critérios de Saída

- 100% dos casos de teste planejados executados.
- 0 reprovações em casos de teste críticos (autenticação, saldo, cadastros).
- Defeitos identificados registrados e tratados.
- Resultado de cada execução salvo em log.
- Relatório consolidado de execução produzido.

## Ordem de Execução

1. Módulo User (`signin` → `login` → `update`).
2. Módulo Account (`create` → `list` → `balance`).
3. Módulo Account Plan.
4. Módulo Transactor.
5. Módulo Financial Movement (`create` → `list` → `update` → `delete`).
6. Módulo AI Advisor.

## Riscos

| ID | Risco |
| --- | --- |
| R01 | Autenticação falha permitir acesso indevido a recursos protegidos |
| R02 | Token expirado ou inválido ser aceito pelo sistema |
| R03 | Saldo do usuário ficar inconsistente após movimentações |
| R04 | Cadastros aceitarem dados inválidos (e-mail mal formado, senha curta, valores negativos) |
| R05 | Estrutura da resposta da API divergir do contrato esperado |
| R06 | Exclusão ou atualização afetar registros de outro usuário |
| R07 | Duplicação de registros únicos (e-mail, plano, transator) não ser bloqueada |
| R08 | Resposta do conselheiro de IA ser vazia, nula ou em formato inesperado |
| R09 | Mensagens de erro não retornarem o status HTTP correto |
| R10 | Listagens não respeitarem o usuário autenticado |

## Arquivos de Teste

```text
tests/
  support/
    test_api_server.dart
  user_test/
    signin_test.dart
    login_test.dart
    update_user_test.dart
  account_test/
    create_account_test.dart
    list_accounts_test.dart
    balance_test.dart
  account_plan_test/
    account_plan_test.dart
  transactor_test/
    transactor_test.dart
  financial_movement_test/
    create_movement_test.dart
    list_movements_test.dart
    update_movement_test.dart
    delete_movement_test.dart
  ai_advisor_test/
    ai_advisor_test.dart
```

## Massa de Teste

Usuário base:

```json
{
  "name": "Maria Silva",
  "email": "maria@teste.com",
  "password_hash": "12345678",
  "active": true
}
```

Token autenticado:

```text
token-ct-finansme
```

Contas financeiras:

```json
{ "description": "Carteira",       "balance": 150.00 }
{ "description": "Poupança",       "balance":   0.00 }
{ "description": "Conta Corrente", "balance": 500.00 }
```

Planos de conta:

```json
{ "description": "Alimentação" }
{ "description": "Transporte"  }
```

Transatores:

```json
{ "name": "Supermercado X" }
{ "name": "Farmácia Y"     }
```

Movimentação financeira base (despesa):

```json
{
  "type_movement_id": 2,
  "movement_date": "2026-04-14",
  "due_date": "2026-04-14",
  "payment_date": null,
  "doc_num": "DOC-001",
  "transator_id": 30,
  "value": 80.50,
  "payment_method_id": 1,
  "situation_id": 1,
  "account_id": 10,
  "account_plan_id": 20,
  "reason": "Compra mensal"
}
```

Movimentação financeira base (receita):

```json
{
  "type_movement_id": 1,
  "movement_date": "2026-04-14",
  "due_date": "2026-04-14",
  "payment_date": null,
  "doc_num": "DOC-001",
  "transator_id": 30,
  "value": 100.00,
  "payment_method_id": 1,
  "situation_id": 1,
  "account_id": 10,
  "account_plan_id": 20,
  "reason": "Salário"
}
```

ID de movimentação para edição/exclusão: `501`

## Matriz de Cobertura

| ID | Módulo | Endpoint | Cenário | Status | Técnica | Prioridade |
| --- | --- | --- | --- | --- | --- | --- |
| CT01 | User — Cadastro | `POST /signin` | Cadastro válido | `201` | Equiv. | Alta |
| CT02 | User — Cadastro | `POST /signin` | E-mail duplicado | `409` | Trans. Estado | Alta |
| CT03 | User — Cadastro | `POST /signin` | Campo name ausente | `400` | Equiv. | Alta |
| CT04 | User — Cadastro | `POST /signin` | E-mail inválido | `400` | Equiv. | Alta |
| CT05 | User — Cadastro | `POST /signin` | Senha muito curta | `422` | Valor Limite | Alta |
| CT06 | User — Cadastro | `POST /signin` | Body vazio | `400` | Valor Limite | Alta |
| CT07 | User — Login | `POST /login` | Login válido | `200` | Equiv. | Alta |
| CT08 | User — Login | `POST /login` | Senha incorreta | `401` | Equiv. | Alta |
| CT09 | User — Login | `POST /login` | Usuário inexistente | `401` | Equiv. | Alta |
| CT10 | User — Login | `POST /login` | Campos vazios | `400` | Equiv. + VL | Alta |
| CT11 | User — Login | `POST /login` | Campo email ausente | `400` | Equiv. | Alta |
| CT12 | User — Login | `POST /login` | Token presente na resposta | `200` | Contrato | Alta |
| CT13 | User — Atualização | `PUT /alter` | Atualização válida com token | `200` | Equiv. | Alta |
| CT14 | User — Atualização | `PUT /alter` | Sem token | `401` | Tab. Decisão | Alta |
| CT15 | User — Atualização | `PUT /alter` | Token expirado | `401` | Trans. Estado | Alta |
| CT16 | User — Atualização | `PUT /alter` | Dados inválidos | `400` | Equiv. + VL | Média |
| CT17 | User — Atualização | `PUT /alter` | Atualização parcial (nome) | `200` | Equiv. | Média |
| CT18 | Account — Cadastro | `POST /accounts` | Conta válida | `201` | Equiv. | Alta |
| CT19 | Account — Cadastro | `POST /accounts` | Saldo zero | `201` | Valor Limite | Alta |
| CT20 | Account — Cadastro | `POST /accounts` | Sem descrição | `400` | Equiv. | Alta |
| CT21 | Account — Cadastro | `POST /accounts` | Saldo negativo | `400` | Valor Limite | Alta |
| CT22 | Account — Cadastro | `POST /accounts` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT23 | Account — Cadastro | `POST /accounts` | Com autenticação válida | `201` | Equiv. | Alta |
| CT24 | Account — Listagem | `GET /user-accounts` | Listar contas autenticado | `200` | Equiv. + Contrato | Média |
| CT25 | Account — Listagem | `GET /user-accounts` | Múltiplas contas | `200` | Cenário | Média |
| CT26 | Account — Listagem | `GET /user-accounts` | Lista vazia | `200` | Valor Limite | Média |
| CT27 | Account — Listagem | `GET /user-accounts` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT28 | Account — Listagem | `GET /user-accounts` | Tipos dos campos | `200` | Contrato | Média |
| CT29 | Account — Saldo | `GET /user-balance` | Consultar saldo | `200` | Equiv. + Contrato | Alta |
| CT30 | Account — Saldo | `GET /user-balance` | Saldo aumenta após receita | `200` | Trans. Estado | Alta |
| CT31 | Account — Saldo | `GET /user-balance` | Saldo diminui após despesa | `200` | Trans. Estado | Alta |
| CT32 | Account — Saldo | `GET /user-balance` | Impacto sequencial receita/despesa | `200` | Cenário | Alta |
| CT33 | Account — Saldo | `GET /user-balance` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT34 | Account Plan | `POST /account-plans` | Plano válido | `201` | Equiv. | Alta |
| CT35 | Account Plan | `POST /account-plans` | Sem descrição | `400` | Equiv. | Alta |
| CT36 | Account Plan | `POST /account-plans` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT37 | Account Plan | `POST /account-plans` | Descrição duplicada | `409` | Trans. Estado | Alta |
| CT38 | Account Plan | `GET /account-plans` | Listar planos | `200` | Contrato | Média |
| CT39 | Account Plan | `GET /account-plans` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT40 | Transactor | `POST /transactors` | Transator válido | `201` | Equiv. | Alta |
| CT41 | Transactor | `POST /transactors` | Sem nome | `400` | Equiv. | Alta |
| CT42 | Transactor | `POST /transactors` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT43 | Transactor | `POST /transactors` | Nome duplicado | `409` | Trans. Estado | Alta |
| CT44 | Transactor | `GET /transactors` | Listar transatores | `200` | Contrato | Média |
| CT45 | Transactor | `GET /transactors` | Lista vazia | `200` | Valor Limite | Média |
| CT46 | Transactor | `GET /transactors` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT47 | Movement — Criação | `POST /financial-movements` | Despesa válida | `201` | Equiv. | Alta |
| CT48 | Movement — Criação | `POST /financial-movements` | Receita válida | `201` | Equiv. | Alta |
| CT49 | Movement — Criação | `POST /financial-movements` | Campo reason ausente | `400` | Equiv. | Alta |
| CT50 | Movement — Criação | `POST /financial-movements` | Valor negativo | `400` | Valor Limite | Alta |
| CT51 | Movement — Criação | `POST /financial-movements` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT52 | Movement — Criação | `POST /financial-movements` | Tipo inválido | `400` | Equiv. | Alta |
| CT53 | Movement — Listagem | `GET /user-financial-movements` | Listar autenticado | `200` | Equiv. + Contrato | Alta |
| CT54 | Movement — Listagem | `GET /user-financial-movements` | Lista vazia | `200` | Valor Limite | Média |
| CT55 | Movement — Listagem | `GET /user-financial-movements` | Múltiplas movimentações | `200` | Cenário | Média |
| CT56 | Movement — Listagem | `GET /user-financial-movements` | Tipos dos campos | `200` | Contrato | Média |
| CT57 | Movement — Listagem | `GET /user-financial-movements` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT58 | Movement — Atualização | `PUT /financial-movements/{id}` | Alteração com sucesso | `200` | Trans. Estado | Média |
| CT59 | Movement — Atualização | `PUT /financial-movements/{id}` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT60 | Movement — Atualização | `PUT /financial-movements/{id}` | ID inexistente | `404` | Equiv. | Média |
| CT61 | Movement — Atualização | `PUT /financial-movements/{id}` | Dados inválidos | `400` | Valor Limite | Média |
| CT62 | Movement — Atualização | `PUT /financial-movements/{id}` | Atualização parcial (reason) | `200` | Equiv. | Média |
| CT63 | Movement — Exclusão | `DELETE /financial-movements/{id}` | Exclusão com sucesso | `200` | Trans. Estado | Média |
| CT64 | Movement — Exclusão | `DELETE /financial-movements/{id}` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT65 | Movement — Exclusão | `DELETE /financial-movements/{id}` | ID inexistente | `404` | Equiv. | Média |
| CT66 | Movement — Exclusão | `DELETE /financial-movements/{id}` | Token inválido | `403` | Tab. Decisão | Alta |
| CT67 | AI Advisor | `GET /ai-response` | Resposta da IA autenticado | `200` | Equiv. | Alta |
| CT68 | AI Advisor | `GET /ai-response` | Sem autenticação | `401` | Tab. Decisão | Alta |
| CT69 | AI Advisor | `GET /ai-response` | Resposta não vazia | `200` | VL + Contrato | Alta |
| CT70 | AI Advisor | `GET /ai-response` | Chave AI_response no payload | `200` | Contrato | Alta |
| CT71 | AI Advisor | `GET /ai-response` | Token expirado | `401` | Trans. Estado | Alta |

## Casos de Teste

### Módulo User — Cadastro (`POST /signin`)

#### CT01 — Cadastrar usuário com dados válidos

Rota: `POST /signin`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/signin_test.dart` — CT01

Entrada:

```json
{
  "name": "Maria Silva",
  "email": "maria@teste.com",
  "password_hash": "12345678",
  "active": true
}
```

Resultado esperado:

- HTTP `201 Created`.
- Corpo contendo a chave `message` (String).

---

#### CT02 — Bloquear cadastro com e-mail duplicado

Rota: `POST /signin`
Técnica: Transição de Estado
Arquivo: `tests/user_test/signin_test.dart` — CT02
Pré-condição: usuário com `maria@teste.com` já cadastrado.

Entrada: mesmo payload de CT01.

Resultado esperado:

- HTTP `409 Conflict`.
- Corpo contendo `message` com referência a `E-mail`.
- Exceção `ApiException` com `statusCode` igual a `409`.

Regra coberta: RF02.

---

#### CT03 — Rejeitar cadastro com campo obrigatório ausente

Rota: `POST /signin`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/signin_test.dart` — CT03

Entrada: payload sem o campo `name`.

Resultado esperado:

- HTTP `400 Bad Request`.
- Corpo contendo `message` com referência ao campo `name`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT04 — Rejeitar cadastro com e-mail inválido

Rota: `POST /signin`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/signin_test.dart` — CT04

Entrada:

```json
{
  "name": "Maria Silva",
  "email": "email-invalido",
  "password_hash": "12345678",
  "active": true
}
```

Resultado esperado:

- HTTP `400 Bad Request`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT05 — Rejeitar cadastro com senha muito curta

Rota: `POST /signin`
Técnica: Valor Limite
Arquivo: `tests/user_test/signin_test.dart` — CT05

Entrada:

```json
{
  "name": "Maria Silva",
  "email": "maria@teste.com",
  "password_hash": "123",
  "active": true
}
```

Resultado esperado:

- HTTP `422 Unprocessable Entity`.
- Exceção `ApiException` com `statusCode` igual a `422`.

---

#### CT06 — Rejeitar cadastro com body vazio

Rota: `POST /signin`
Técnica: Valor Limite
Arquivo: `tests/user_test/signin_test.dart` — CT06

Entrada: `{}`

Resultado esperado:

- HTTP `400 Bad Request`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

### Módulo User — Login (`POST /login`)

#### CT07 — Realizar login com credenciais válidas

Rota: `POST /login`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/login_test.dart` — CT01

Entrada:

```json
{
  "email": "maria@teste.com",
  "password_hash": "12345678"
}
```

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- Corpo contendo `token` igual a `"token-ct-finansme"`.

---

#### CT08 — Rejeitar login com senha incorreta

Rota: `POST /login`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/login_test.dart` — CT02

Entrada:

```json
{
  "email": "maria@teste.com",
  "password_hash": "senhaerrada"
}
```

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT09 — Rejeitar login com usuário inexistente

Rota: `POST /login`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/login_test.dart` — CT03

Entrada:

```json
{
  "email": "naoexiste@teste.com",
  "password_hash": "12345678"
}
```

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT10 — Rejeitar login com campos vazios

Rota: `POST /login`
Técnica: Particionamento de Equivalência + Valor Limite
Arquivo: `tests/user_test/login_test.dart` — CT04

Entrada:

```json
{
  "email": "",
  "password_hash": ""
}
```

Resultado esperado:

- HTTP `400 Bad Request`.
- Corpo contendo `message` com referência a `e-mail`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT11 — Rejeitar login com campo email ausente

Rota: `POST /login`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/login_test.dart` — CT05

Entrada: `{ "password_hash": "12345678" }`

Resultado esperado:

- HTTP `400 Bad Request`.
- Corpo contendo `message` com referência ao campo `email`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT12 — Verificar que resposta de login contém token

Rota: `POST /login`
Técnica: Teste de Contrato
Arquivo: `tests/user_test/login_test.dart` — CT06

Entrada:

```json
{
  "email": "maria@teste.com",
  "password_hash": "12345678"
}
```

Resultado esperado:

- HTTP `200 OK`.
- Resposta contém as chaves `message` e `token`.
- `token` é String não vazia.

---

### Módulo User — Atualização (`PUT /alter`)

#### CT13 — Atualizar usuário autenticado com sucesso

Rota: `PUT /alter`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/update_user_test.dart` — CT01

Header: `Authorization: Bearer token-ct-finansme`

Entrada:

```json
{
  "name": "Maria Souza",
  "password_hash": "87654321",
  "active": true
}
```

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- Requisição enviada com header `Authorization: Bearer token-ct-finansme`.

---

#### CT14 — Rejeitar atualização sem token

Rota: `PUT /alter`
Técnica: Tabela de Decisão
Arquivo: `tests/user_test/update_user_test.dart` — CT02

Entrada: mesmo payload de CT13 sem header de autorização.

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT15 — Rejeitar atualização com token expirado

Rota: `PUT /alter`
Técnica: Transição de Estado
Arquivo: `tests/user_test/update_user_test.dart` — CT03

Header: `Authorization: Bearer token-expirado`

Entrada: mesmo payload de CT13.

Resultado esperado:

- HTTP `401 Unauthorized`.
- Corpo contendo `message` com referência a `Token`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT16 — Rejeitar atualização com dados inválidos

Rota: `PUT /alter`
Técnica: Particionamento de Equivalência + Valor Limite
Arquivo: `tests/user_test/update_user_test.dart` — CT04

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "name": "", "password_hash": "" }`

Resultado esperado:

- HTTP `400 Bad Request`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT17 — Atualizar apenas o nome do usuário

Rota: `PUT /alter`
Técnica: Particionamento de Equivalência
Arquivo: `tests/user_test/update_user_test.dart` — CT05

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "name": "Novo Nome" }`

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- Requisição enviada com header de autorização.

---

### Módulo Account — Cadastro (`POST /accounts`)

#### CT18 — Cadastrar conta financeira com dados válidos

Rota: `POST /accounts`
Técnica: Particionamento de Equivalência
Arquivo: `tests/account_test/create_account_test.dart` — CT01

Entrada: `{ "description": "Carteira", "balance": 150.00 }`

Resultado esperado:

- HTTP `201 Created`.
- Corpo contendo `message` (String).

---

#### CT19 — Cadastrar conta com saldo zero

Rota: `POST /accounts`
Técnica: Valor Limite
Arquivo: `tests/account_test/create_account_test.dart` — CT02

Entrada: `{ "description": "Poupança", "balance": 0.00 }`

Resultado esperado:

- HTTP `201 Created`.
- Corpo contendo `message` (String).

---

#### CT20 — Rejeitar cadastro de conta sem descrição

Rota: `POST /accounts`
Técnica: Particionamento de Equivalência
Arquivo: `tests/account_test/create_account_test.dart` — CT03

Entrada: `{ "balance": 100.00 }`

Resultado esperado:

- HTTP `400 Bad Request`.
- Corpo contendo `message` com referência ao campo `description`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT21 — Rejeitar cadastro com saldo negativo

Rota: `POST /accounts`
Técnica: Valor Limite
Arquivo: `tests/account_test/create_account_test.dart` — CT04

Entrada: `{ "description": "Conta inválida", "balance": -50.00 }`

Resultado esperado:

- HTTP `400 Bad Request`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT22 — Rejeitar cadastro de conta sem autenticação

Rota: `POST /accounts`
Técnica: Tabela de Decisão
Arquivo: `tests/account_test/create_account_test.dart` — CT05

Entrada: `{ "description": "Conta sem auth", "balance": 100.00 }` (sem token)

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT23 — Cadastrar conta com autenticação válida

Rota: `POST /accounts`
Técnica: Particionamento de Equivalência
Arquivo: `tests/account_test/create_account_test.dart` — CT06

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "description": "Conta Corrente", "balance": 500.00 }`

Resultado esperado:

- HTTP `201 Created`.
- Corpo contendo `message` (String).
- Requisição enviada com header de autorização.

---

### Módulo Account — Listagem (`GET /user-accounts`)

#### CT24 — Listar contas do usuário autenticado

Rota: `GET /user-accounts`
Técnica: Particionamento de Equivalência + Teste de Contrato
Arquivo: `tests/account_test/list_accounts_test.dart` — CT01

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- `data[]` não vazio.
- Cada item de `data[]` contém as chaves `id_account`, `description` e `balance`.

---

#### CT25 — Listar múltiplas contas do usuário

Rota: `GET /user-accounts`
Técnica: Teste Baseado em Cenário
Arquivo: `tests/account_test/list_accounts_test.dart` — CT02
Pré-condição: usuário possui 3 contas cadastradas.

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- `data.length` igual a `3`.

---

#### CT26 — Retornar lista vazia quando usuário não tem contas

Rota: `GET /user-accounts`
Técnica: Valor Limite
Arquivo: `tests/account_test/list_accounts_test.dart` — CT03

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- `data` igual a `[]`.

---

#### CT27 — Rejeitar listagem de contas sem autenticação

Rota: `GET /user-accounts`
Técnica: Tabela de Decisão
Arquivo: `tests/account_test/list_accounts_test.dart` — CT04

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT28 — Validar estrutura completa de cada conta retornada

Rota: `GET /user-accounts`
Técnica: Teste de Contrato
Arquivo: `tests/account_test/list_accounts_test.dart` — CT05

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- `id_account` é `int`.
- `description` é `String`.
- `balance` é `num`.

---

### Módulo Account — Saldo (`GET /user-balance`)

#### CT29 — Consultar saldo do usuário autenticado

Rota: `GET /user-balance`
Técnica: Particionamento de Equivalência + Teste de Contrato
Arquivo: `tests/account_test/balance_test.dart` — CT01

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- Corpo contendo `balance` (num).

---

#### CT30 — Saldo aumenta após lançamento de receita

Rota: `GET /user-balance` + `POST /financial-movements`
Técnica: Transição de Estado + Teste Baseado em Cenário
Arquivo: `tests/account_test/balance_test.dart` — CT02

Header: `Authorization: Bearer token-ct-finansme`

Fluxo:

1. `GET /user-balance` → capturar `saldoInicial`.
2. `POST /financial-movements` com `type_movement_id = 1` e `value = 100.00`.
3. `GET /user-balance` → capturar `saldoAposReceita`.

Resultado esperado:

- Todas as chamadas retornam `200`/`201`.
- `saldoAposReceita['balance'] > saldoInicial['balance']`.

Regra coberta: RF16.

---

#### CT31 — Saldo diminui após lançamento de despesa

Rota: `GET /user-balance` + `POST /financial-movements`
Técnica: Transição de Estado + Teste Baseado em Cenário
Arquivo: `tests/account_test/balance_test.dart` — CT03

Header: `Authorization: Bearer token-ct-finansme`

Fluxo:

1. `GET /user-balance` → capturar `saldoInicial`.
2. `POST /financial-movements` com `type_movement_id = 2` e `value = 40.00`.
3. `GET /user-balance` → capturar `saldoAposDespesa`.

Resultado esperado:

- Todas as chamadas retornam `200`/`201`.
- `saldoAposDespesa['balance'] < saldoInicial['balance']`.

Regra coberta: RF16.

---

#### CT32 — Validar impacto sequencial de receita e despesa

Rota: `GET /user-balance` + `POST /financial-movements`
Técnica: Teste Baseado em Cenário + Transição de Estado
Arquivo: `tests/account_test/balance_test.dart` — CT04

Header: `Authorization: Bearer token-ct-finansme`

Fluxo:

1. `GET /user-balance` → `saldoInicial`.
2. `POST /financial-movements` (receita `value = 100.00`).
3. `GET /user-balance` → `saldoAposReceita`.
4. `POST /financial-movements` (despesa `value = 40.00`).
5. `GET /user-balance` → `saldoAposDespesa`.

Resultado esperado:

- `saldoAposReceita['balance'] > saldoInicial['balance']`.
- `saldoAposDespesa['balance'] < saldoAposReceita['balance']`.

Regra coberta: RF16.

---

#### CT33 — Rejeitar consulta de saldo sem autenticação

Rota: `GET /user-balance`
Técnica: Tabela de Decisão
Arquivo: `tests/account_test/balance_test.dart` — CT05

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

### Módulo Account Plan (`/account-plans`)

#### CT34 — Cadastrar plano de conta com dados válidos

Rota: `POST /account-plans`
Técnica: Particionamento de Equivalência
Arquivo: `tests/account_plan_test/account_plan_test.dart` — CT01

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "description": "Alimentação" }`

Resultado esperado:

- HTTP `201 Created`.
- Corpo contendo `message` (String).
- Requisição enviada com header de autorização.

---

#### CT35 — Rejeitar plano de conta sem descrição

Rota: `POST /account-plans`
Técnica: Particionamento de Equivalência
Arquivo: `tests/account_plan_test/account_plan_test.dart` — CT02

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{}`

Resultado esperado:

- HTTP `400 Bad Request`.
- Corpo contendo `message` com referência ao campo `description`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT36 — Rejeitar cadastro de plano sem autenticação

Rota: `POST /account-plans`
Técnica: Tabela de Decisão
Arquivo: `tests/account_plan_test/account_plan_test.dart` — CT03

Entrada: `{ "description": "Transporte" }` (sem token)

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT37 — Rejeitar plano com descrição duplicada

Rota: `POST /account-plans`
Técnica: Transição de Estado
Arquivo: `tests/account_plan_test/account_plan_test.dart` — CT04
Pré-condição: plano `"Alimentação"` já cadastrado.

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "description": "Alimentação" }`

Resultado esperado:

- HTTP `409 Conflict`.
- Exceção `ApiException` com `statusCode` igual a `409`.

---

#### CT38 — Listar planos de conta do usuário

Rota: `GET /account-plans`
Técnica: Teste de Contrato
Arquivo: `tests/account_plan_test/account_plan_test.dart` — CT05

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- `data[]` não vazio.
- Cada item contém `id_account_plan` e `description`.

---

#### CT39 — Rejeitar listagem de planos sem autenticação

Rota: `GET /account-plans`
Técnica: Tabela de Decisão
Arquivo: `tests/account_plan_test/account_plan_test.dart` — CT06

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

### Módulo Transactor (`/transactors`)

#### CT40 — Cadastrar transator com dados válidos

Rota: `POST /transactors`
Técnica: Particionamento de Equivalência
Arquivo: `tests/transactor_test/transactor_test.dart` — CT01

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "name": "Supermercado X" }`

Resultado esperado:

- HTTP `201 Created`.
- Corpo contendo `message` (String).
- Requisição enviada com header de autorização.

---

#### CT41 — Rejeitar transator sem nome

Rota: `POST /transactors`
Técnica: Particionamento de Equivalência
Arquivo: `tests/transactor_test/transactor_test.dart` — CT02

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{}`

Resultado esperado:

- HTTP `400 Bad Request`.
- Corpo contendo `message` com referência ao campo `name`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT42 — Rejeitar cadastro de transator sem autenticação

Rota: `POST /transactors`
Técnica: Tabela de Decisão
Arquivo: `tests/transactor_test/transactor_test.dart` — CT03

Entrada: `{ "name": "Farmácia Y" }` (sem token)

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT43 — Rejeitar transator com nome duplicado

Rota: `POST /transactors`
Técnica: Transição de Estado
Arquivo: `tests/transactor_test/transactor_test.dart` — CT04
Pré-condição: transator `"Supermercado X"` já cadastrado.

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "name": "Supermercado X" }`

Resultado esperado:

- HTTP `409 Conflict`.
- Exceção `ApiException` com `statusCode` igual a `409`.

---

#### CT44 — Listar transatores do usuário

Rota: `GET /transactors`
Técnica: Teste de Contrato
Arquivo: `tests/transactor_test/transactor_test.dart` — CT05

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- `data[]` não vazio.
- Cada item contém `id_transactor` e `name`.

---

#### CT45 — Retornar lista vazia quando não há transatores

Rota: `GET /transactors`
Técnica: Valor Limite
Arquivo: `tests/transactor_test/transactor_test.dart` — CT06

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- `data` igual a `[]`.

---

#### CT46 — Rejeitar listagem de transatores sem autenticação

Rota: `GET /transactors`
Técnica: Tabela de Decisão
Arquivo: `tests/transactor_test/transactor_test.dart` — CT07

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

### Módulo Financial Movement — Criação (`POST /financial-movements`)

#### CT47 — Registrar movimentação financeira válida (despesa)

Rota: `POST /financial-movements`
Técnica: Particionamento de Equivalência
Arquivo: `tests/financial_movement_test/create_movement_test.dart` — CT01

Header: `Authorization: Bearer token-ct-finansme`

Entrada: payload completo com `type_movement_id = 2` e `value = 80.50`.

Resultado esperado:

- HTTP `201 Created`.
- Corpo contendo `message` (String).
- Payload enviado com todos os campos obrigatórios e header de autorização.

---

#### CT48 — Registrar movimentação financeira válida (receita)

Rota: `POST /financial-movements`
Técnica: Particionamento de Equivalência
Arquivo: `tests/financial_movement_test/create_movement_test.dart` — CT02

Header: `Authorization: Bearer token-ct-finansme`

Entrada: payload completo com `type_movement_id = 1` e `value = 3000.00`.

Resultado esperado:

- HTTP `201 Created`.
- Corpo contendo `message` (String).
- `type_movement_id` recebido igual a `1`.

---

#### CT49 — Rejeitar lançamento com campo obrigatório ausente

Rota: `POST /financial-movements`
Técnica: Particionamento de Equivalência
Arquivo: `tests/financial_movement_test/create_movement_test.dart` — CT03

Header: `Authorization: Bearer token-ct-finansme`

Entrada: payload completo sem o campo `reason`.

Resultado esperado:

- HTTP `400 Bad Request`.
- Corpo contendo `message` com referência ao campo `reason`.
- Exceção `ApiException` com `statusCode` igual a `400`.

Regra coberta: RF24.

---

#### CT50 — Rejeitar lançamento com valor negativo

Rota: `POST /financial-movements`
Técnica: Valor Limite
Arquivo: `tests/financial_movement_test/create_movement_test.dart` — CT04

Header: `Authorization: Bearer token-ct-finansme`

Entrada: payload com `value = -100.00`.

Resultado esperado:

- HTTP `400 Bad Request`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT51 — Rejeitar lançamento sem autenticação

Rota: `POST /financial-movements`
Técnica: Tabela de Decisão
Arquivo: `tests/financial_movement_test/create_movement_test.dart` — CT05

Entrada: payload completo sem token.

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT52 — Rejeitar lançamento com tipo de movimentação inválido

Rota: `POST /financial-movements`
Técnica: Particionamento de Equivalência
Arquivo: `tests/financial_movement_test/create_movement_test.dart` — CT06

Header: `Authorization: Bearer token-ct-finansme`

Entrada: payload com `type_movement_id = 99`.

Resultado esperado:

- HTTP `400 Bad Request`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

### Módulo Financial Movement — Listagem (`GET /user-financial-movements`)

#### CT53 — Listar movimentações do usuário autenticado

Rota: `GET /user-financial-movements`
Técnica: Particionamento de Equivalência + Teste de Contrato
Arquivo: `tests/financial_movement_test/list_movements_test.dart` — CT01

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- `data[]` não vazio.
- Cada item contém: `id_financial_movement`, `type_movement_id`, `movement_date`, `due_date`, `payment_date`, `doc_num`, `transator_id`, `value`, `situation_id`, `account_id`, `account_plan_id`, `reason`.

---

#### CT54 — Retornar lista vazia quando não há movimentações

Rota: `GET /user-financial-movements`
Técnica: Valor Limite
Arquivo: `tests/financial_movement_test/list_movements_test.dart` — CT02

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- `data` igual a `[]`.

---

#### CT55 — Listar múltiplas movimentações

Rota: `GET /user-financial-movements`
Técnica: Teste Baseado em Cenário
Arquivo: `tests/financial_movement_test/list_movements_test.dart` — CT03
Pré-condição: usuário possui 3 movimentações cadastradas.

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- `data.length` igual a `3`.

---

#### CT56 — Validar tipos dos campos de cada movimentação retornada

Rota: `GET /user-financial-movements`
Técnica: Teste de Contrato
Arquivo: `tests/financial_movement_test/list_movements_test.dart` — CT04

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- `id_financial_movement` é `int`.
- `type_movement_id` é `int`.
- `value` é `num`.
- `reason` é `String`.

---

#### CT57 — Rejeitar listagem de movimentações sem autenticação

Rota: `GET /user-financial-movements`
Técnica: Tabela de Decisão
Arquivo: `tests/financial_movement_test/list_movements_test.dart` — CT05

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

### Módulo Financial Movement — Atualização (`PUT /financial-movements/{id}`)

#### CT58 — Alterar lançamento existente com sucesso

Rota: `PUT /financial-movements/501`
Técnica: Transição de Estado
Arquivo: `tests/financial_movement_test/update_movement_test.dart` — CT01
Pré-condição: movimentação `501` existente.

Header: `Authorization: Bearer token-ct-finansme`

Entrada: payload completo com `reason = "Compra mensal ajustada"`.

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- Requisição enviada para `/financial-movements/501` com header de autorização.

---

#### CT59 — Rejeitar atualização sem autenticação

Rota: `PUT /financial-movements/501`
Técnica: Tabela de Decisão
Arquivo: `tests/financial_movement_test/update_movement_test.dart` — CT02

Entrada: payload válido sem token.

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT60 — Rejeitar atualização de lançamento inexistente

Rota: `PUT /financial-movements/9999`
Técnica: Particionamento de Equivalência
Arquivo: `tests/financial_movement_test/update_movement_test.dart` — CT03

Header: `Authorization: Bearer token-ct-finansme`

Entrada: payload válido para ID inexistente (`9999`).

Resultado esperado:

- HTTP `404 Not Found`.
- Exceção `ApiException` com `statusCode` igual a `404`.

---

#### CT61 — Rejeitar atualização com dados inválidos

Rota: `PUT /financial-movements/501`
Técnica: Valor Limite
Arquivo: `tests/financial_movement_test/update_movement_test.dart` — CT04

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "value": -999.00 }`

Resultado esperado:

- HTTP `400 Bad Request`.
- Exceção `ApiException` com `statusCode` igual a `400`.

---

#### CT62 — Atualizar apenas o motivo do lançamento

Rota: `PUT /financial-movements/501`
Técnica: Particionamento de Equivalência
Arquivo: `tests/financial_movement_test/update_movement_test.dart` — CT05

Header: `Authorization: Bearer token-ct-finansme`

Entrada: `{ "reason": "Ajuste de compra" }`

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- Requisição enviada com header de autorização.

---

### Módulo Financial Movement — Exclusão (`DELETE /financial-movements/{id}`)

#### CT63 — Excluir lançamento existente com sucesso

Rota: `DELETE /financial-movements/501`
Técnica: Transição de Estado
Arquivo: `tests/financial_movement_test/delete_movement_test.dart` — CT01
Pré-condição: movimentação `501` existente.

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `message` (String).
- Requisição enviada para `/financial-movements/501` com header de autorização.

---

#### CT64 — Rejeitar exclusão sem autenticação

Rota: `DELETE /financial-movements/501`
Técnica: Tabela de Decisão
Arquivo: `tests/financial_movement_test/delete_movement_test.dart` — CT02

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT65 — Rejeitar exclusão de lançamento inexistente

Rota: `DELETE /financial-movements/9999`
Técnica: Particionamento de Equivalência
Arquivo: `tests/financial_movement_test/delete_movement_test.dart` — CT03

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `404 Not Found`.
- Exceção `ApiException` com `statusCode` igual a `404`.

---

#### CT66 — Rejeitar exclusão com token inválido

Rota: `DELETE /financial-movements/501`
Técnica: Tabela de Decisão
Arquivo: `tests/financial_movement_test/delete_movement_test.dart` — CT04

Header: `Authorization: Bearer token-invalido`

Resultado esperado:

- HTTP `403 Forbidden`.
- Corpo contendo `message` sobre acesso negado.
- Exceção `ApiException` com `statusCode` igual a `403`.

---

### Módulo AI Advisor (`GET /ai-response`)

#### CT67 — Gerar resposta do conselheiro de IA para usuário autenticado

Rota: `GET /ai-response`
Técnica: Particionamento de Equivalência
Arquivo: `tests/ai_advisor_test/ai_advisor_test.dart` — CT01

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- HTTP `200 OK`.
- Corpo contendo `AI_response` (String).
- Requisição enviada com header de autorização.

---

#### CT68 — Rejeitar consulta ao conselheiro sem autenticação

Rota: `GET /ai-response`
Técnica: Tabela de Decisão
Arquivo: `tests/ai_advisor_test/ai_advisor_test.dart` — CT02

Resultado esperado:

- HTTP `401 Unauthorized`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

#### CT69 — Validar que resposta da IA é uma string não vazia

Rota: `GET /ai-response`
Técnica: Valor Limite + Teste de Contrato
Arquivo: `tests/ai_advisor_test/ai_advisor_test.dart` — CT03

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- `AI_response` é `String`.
- `AI_response` não está vazia.

---

#### CT70 — Validar chave de resposta da IA no payload

Rota: `GET /ai-response`
Técnica: Teste de Contrato
Arquivo: `tests/ai_advisor_test/ai_advisor_test.dart` — CT04

Header: `Authorization: Bearer token-ct-finansme`

Resultado esperado:

- Resposta contém a chave `AI_response`.

---

#### CT71 — Rejeitar consulta ao conselheiro com token expirado

Rota: `GET /ai-response`
Técnica: Transição de Estado
Arquivo: `tests/ai_advisor_test/ai_advisor_test.dart` — CT05

Header: `Authorization: Bearer token-expirado`

Resultado esperado:

- HTTP `401 Unauthorized`.
- Corpo contendo `message` com referência a `Token`.
- Exceção `ApiException` com `statusCode` igual a `401`.

---

## Rastreabilidade

| Caso | Requisito(s) coberto(s) | Caso | Requisito(s) coberto(s) |
| --- | --- | --- | --- |
| CT01 | RF01 | CT37 | RF18 |
| CT02 | RF02 | CT38 | RF19 |
| CT03 | RF03 | CT39 | RF19 |
| CT04 | RF04 | CT40 | RF20 |
| CT05 | RF05 | CT41 | RF20 |
| CT06 | RF03 | CT42 | RF20 |
| CT07 | RF06 | CT43 | RF21 |
| CT08 | RF07 | CT44 | RF22 |
| CT09 | RF07 | CT45 | RF22 |
| CT10 | RF08 | CT46 | RF22 |
| CT11 | RF08 | CT47 | RF23 |
| CT12 | RF06 | CT48 | RF23 |
| CT13 | RF09 | CT49 | RF24 |
| CT14 | RF10 | CT50 | RF25 |
| CT15 | RF10 | CT51 | RF23 |
| CT16 | RF09 | CT52 | RF26 |
| CT17 | RF09 | CT53 | RF27 |
| CT18 | RF11 | CT54 | RF27 |
| CT19 | RF11 | CT55 | RF27 |
| CT20 | RF13 | CT56 | RF27 |
| CT21 | RF12 | CT57 | RF27 |
| CT22 | RF11 | CT58 | RF28 |
| CT23 | RF11 | CT59 | RF28 |
| CT24 | RF14 | CT60 | RF28 |
| CT25 | RF14 | CT61 | RF28 |
| CT26 | RF14 | CT62 | RF28 |
| CT27 | RF14 | CT63 | RF29 |
| CT28 | RF14 | CT64 | RF29 |
| CT29 | RF15 | CT65 | RF30 |
| CT30 | RF16 | CT66 | RF29 |
| CT31 | RF16 | CT67 | RF31 |
| CT32 | RF16 | CT68 | RF32 |
| CT33 | RF15 | CT69 | RF31 |
| CT34 | RF17 | CT70 | RF31 |
| CT35 | RF17 | CT71 | RF32 |
| CT36 | RF17 | | |

Cobertura: 71 casos de teste cobrem os 32 requisitos funcionais (RF01–RF32) — 100%.

## Critérios de Aceite

A etapa de teste é considerada aprovada quando:

- Todos os 71 testes automatizados em `tests/` passam.
- A análise estática em `tests/` não apresenta problemas.
- Os casos CT01 a CT71 possuem cobertura automatizada.
- As rotas autenticadas validam o envio do header `Authorization: Bearer`.
- Os cenários de erro validam o `statusCode` esperado na `ApiException`.
- Os testes de contrato validam os tipos dos campos retornados pela API.
- Os testes de saldo validam o impacto de receitas e despesas no `balance`.

## Controle

| Métrica | Valor |
| --- | --- |
| Planejados | 71 |
| Executados | 71 |
| Aprovados | 71 |
| Reprovados | 0 |
| Bloqueados | 0 |
| Cobertura RF | 32/32 (100%) |

## Resultado da Execução

Última execução realizada:

```bash
flutter test tests
```

Resultado por módulo:

| Módulo | Arquivo | Testes |
| --- | --- | --- |
| User — Cadastro | `signin_test.dart` | 6 |
| User — Login | `login_test.dart` | 6 |
| User — Atualização | `update_user_test.dart` | 5 |
| Account — Cadastro | `create_account_test.dart` | 6 |
| Account — Listagem | `list_accounts_test.dart` | 5 |
| Account — Saldo | `balance_test.dart` | 5 |
| Account Plan | `account_plan_test.dart` | 6 |
| Transactor | `transactor_test.dart` | 7 |
| Movement — Criação | `create_movement_test.dart` | 6 |
| Movement — Listagem | `list_movements_test.dart` | 5 |
| Movement — Atualização | `update_movement_test.dart` | 5 |
| Movement — Exclusão | `delete_movement_test.dart` | 4 |
| AI Advisor | `ai_advisor_test.dart` | 5 |
| **Total** | | **71** |

Resultado:

```text
71 testes executados.
71 testes aprovados.
0 testes reprovados.
```

Análise estática:

```bash
flutter analyze tests
```

Resultado:

```text
No issues found.
```
