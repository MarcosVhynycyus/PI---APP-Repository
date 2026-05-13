# Casos de Teste - FinansMe

## Objetivo

Documentar os casos de teste automatizados para validar as funcionalidades essenciais do MVP do FinansMe, com foco em contrato de API, regras críticas de negócio e estrutura mínima das respostas.

Os testes foram implementados em:

```text
tests/finansme_api_contract_test.dart
tests/support/test_api_server.dart
```

## Escopo

Os testes cobrem o fluxo principal do MVP:

```text
cadastro > login > cadastros complementares > lançamento > consulta
```

Funcionalidades cobertas:

- Cadastro de usuário.
- Login.
- Atualização de usuário autenticado.
- Cadastro e consulta de contas financeiras.
- Cadastro de planos de conta.
- Cadastro de transatores.
- Cadastro, consulta, alteração e exclusão de movimentações financeiras.
- Validação do impacto de receitas e despesas no saldo.

## Estratégia

A suíte usa testes de contrato com um servidor HTTP local falso, implementado em `tests/support/test_api_server.dart`.

Essa abordagem permite validar:

- Método HTTP esperado.
- Rota chamada.
- Payload enviado.
- Header de autorização quando necessário.
- Status HTTP simulado.
- Estrutura mínima do corpo de resposta.
- Tratamento de erro feito pelo `ApiClient`.

A API real não é chamada durante os testes. Isso torna a execução reprodutível e independente de rede, banco de dados ou ambiente externo.

## Ambiente

- Flutter SDK.
- Dart SDK.
- Pacote `flutter_test`.
- Projeto FinansMe Flutter.

Comando principal:

```bash
flutter test tests
```

Comando de análise estática:

```bash
flutter analyze tests
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

Conta financeira:

```json
{
  "description": "Carteira",
  "balance": 150.0
}
```

Plano de conta:

```json
{
  "description": "Alimentação"
}
```

Transator:

```json
{
  "name": "Supermercado X"
}
```

Movimentação financeira base:

```json
{
  "type_movement_id": 2,
  "movement_date": "2026-04-14",
  "due_date": "2026-04-14",
  "payment_date": null,
  "doc_num": "DOC-001",
  "transator_id": 30,
  "value": 80.5,
  "payment_method_id": 1,
  "situation_id": 1,
  "account_id": 10,
  "account_plan_id": 20,
  "reason": "Compra mensal"
}
```

## Matriz de Cobertura

| ID | Endpoint | Cenário | Resultado esperado | Prioridade |
| --- | --- | --- | --- | --- |
| CT01 | `POST /signin` | Cadastro válido | `201` com `message` | Alta |
| CT02 | `POST /signin` | E-mail duplicado | `409` com `message` | Alta |
| CT03 | `POST /login` | Login válido | `200` com `message` e `token` | Alta |
| CT04 | `PUT /alter` | Atualização de usuário com autorização | `200` com `message` | Alta |
| CT05 | `POST /accounts` | Conta com descrição e saldo válidos | `201` com `message` | Alta |
| CT06 | `GET /user-accounts` | Listar contas do usuário | `200` com `message` e `data[]` | Média |
| CT07 | `POST /account-plans` | Plano de conta válido | `201` com `message` | Alta |
| CT08 | `POST /transactors` | Transator válido com autorização | `201` com `message` | Alta |
| CT09 | `POST /financial-movements` | Lançamento válido | `201` com `message` | Alta |
| CT10 | `POST /financial-movements` | Campo obrigatório ausente | `400` com `message` | Alta |
| CT11 | `GET /user-financial-movements` | Listagem autenticada | `200` com `message` e `data[]` | Alta |
| CT12 | `GET /user-balance` | Saldo após receita e despesa | `200` com `balance` | Alta |
| CT13 | `PUT /financial-movements/{id}` | Alteração de lançamento existente | `200` com `message` | Média |
| CT14 | `DELETE /financial-movements/{id}` | Exclusão de lançamento existente | `200` com `message` | Média |

## Casos de Teste

### CT01 - Cadastrar usuário com sucesso

Rota: `POST /signin`

Pré-condição: e-mail inexistente na base.

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

- HTTP `201`.
- Corpo contendo a chave `message`.
- Nome com no mínimo 3 caracteres.
- E-mail válido.
- Senha com no mínimo 8 caracteres.

### CT02 - Bloquear cadastro com e-mail duplicado

Rota: `POST /signin`

Pré-condição: usuário já cadastrado com o mesmo e-mail.

Entrada: repetir o payload do CT01.

Resultado esperado:

- HTTP `409`.
- Corpo contendo a chave `message`.
- Exceção `ApiException` com `statusCode` igual a `409`.

Regra coberta: RN01 - Unicidade do e-mail.

### CT03 - Realizar login com sucesso

Rota: `POST /login`

Pré-condição: usuário existente e ativo.

Entrada:

```json
{
  "email": "maria@teste.com",
  "password_hash": "12345678"
}
```

Resultado esperado:

- HTTP `200`.
- Corpo contendo `message`.
- Corpo contendo `token`.

### CT04 - Atualizar usuário autenticado

Rota: `PUT /alter`

Pré-condição: usuário autenticado com token válido.

Header:

```text
Authorization: Bearer token-ct-finansme
```

Entrada:

```json
{
  "name": "Maria Souza",
  "password_hash": "87654321",
  "active": true
}
```

Resultado esperado:

- HTTP `200`.
- Corpo contendo `message`.
- Requisição enviada com header de autorização.

### CT05 - Cadastrar conta financeira válida

Rota: `POST /accounts`

Pré-condição: API disponível.

Entrada:

```json
{
  "description": "Carteira",
  "balance": 150.0
}
```

Resultado esperado:

- HTTP `201`.
- Corpo contendo `message`.
- Descrição obrigatória.
- Saldo maior ou igual a zero.

### CT06 - Listar contas do usuário

Rota: `GET /user-accounts`

Pré-condição: usuário autenticado e com ao menos uma conta cadastrada.

Header:

```text
Authorization: Bearer token-ct-finansme
```

Resultado esperado:

- HTTP `200`.
- Corpo contendo `message`.
- Corpo contendo `data[]`.
- Cada item de `data[]` deve possuir `id_account`, `description` e `balance`.

### CT07 - Cadastrar plano de conta válido

Rota: `POST /account-plans`

Pré-condição: usuário autenticado.

Header:

```text
Authorization: Bearer token-ct-finansme
```

Entrada:

```json
{
  "description": "Alimentação"
}
```

Resultado esperado:

- HTTP `201`.
- Corpo contendo `message`.
- Descrição obrigatória.

### CT08 - Cadastrar transator com autorização

Rota: `POST /transactors`

Pré-condição: usuário autenticado.

Header:

```text
Authorization: Bearer token-ct-finansme
```

Entrada:

```json
{
  "name": "Supermercado X"
}
```

Resultado esperado:

- HTTP `201`.
- Corpo contendo `message`.
- Nome entre 3 e 100 caracteres.

### CT09 - Registrar movimentação financeira válida

Rota: `POST /financial-movements`

Pré-condição: conta, plano de conta e transator já cadastrados.

Header:

```text
Authorization: Bearer token-ct-finansme
```

Entrada: payload completo de movimentação financeira.

Resultado esperado:

- HTTP `201`.
- Corpo contendo `message`.
- `value` maior que zero.
- `doc_num` preenchido.
- `reason` preenchido.

Regra coberta: RN08 - Obrigatoriedade de dados no lançamento.

### CT10 - Rejeitar lançamento com campo obrigatório ausente

Rota: `POST /financial-movements`

Pré-condição: usuário autenticado.

Entrada: payload do CT09 sem o campo `reason`.

Resultado esperado:

- HTTP `400`.
- Corpo contendo `message`.
- Exceção `ApiException` com `statusCode` igual a `400`.
- Mensagem indicando o campo obrigatório ausente.

Regra coberta: RN08 - Obrigatoriedade de dados no lançamento.

### CT11 - Listar movimentações do usuário

Rota: `GET /user-financial-movements`

Pré-condição: usuário autenticado e com ao menos um lançamento cadastrado.

Header:

```text
Authorization: Bearer token-ct-finansme
```

Resultado esperado:

- HTTP `200`.
- Corpo contendo `message`.
- Corpo contendo `data[]`.
- Cada item deve possuir:

```text
id_financial_movement
type_movement_id
movement_date
due_date
payment_date
doc_num
transator_id
value
situation_id
account_id
account_plan_id
reason
```

### CT12 - Validar impacto do lançamento no saldo

Rota: `GET /user-balance`

Pré-condição: usuário autenticado e conta vinculada.

Fluxo:

1. Consultar saldo inicial.
2. Criar uma receita.
3. Consultar saldo após receita.
4. Criar uma despesa.
5. Consultar saldo após despesa.

Resultado esperado:

- Todas as consultas retornam HTTP `200`.
- Corpo das consultas contém `balance`.
- O saldo aumenta após uma receita.
- O saldo diminui após uma despesa.

Regra coberta: RN10 - Impacto no saldo da conta.

### CT13 - Alterar lançamento existente

Rota: `PUT /financial-movements/{id}`

Pré-condição: usuário autenticado e lançamento existente.

Header:

```text
Authorization: Bearer token-ct-finansme
```

Entrada: payload completo de movimentação financeira com `reason` ajustado.

Resultado esperado:

- HTTP `200`.
- Corpo contendo `message`.
- Requisição enviada para o id informado.

### CT14 - Excluir lançamento existente

Rota: `DELETE /financial-movements/{id}`

Pré-condição: usuário autenticado e lançamento existente.

Header:

```text
Authorization: Bearer token-ct-finansme
```

Resultado esperado:

- HTTP `200`.
- Corpo contendo `message`.
- Requisição enviada para o id informado.

## Rastreabilidade

| Caso | Requisito relacionado | Regra relacionada |
| --- | --- | --- |
| CT01 | RF01 | - |
| CT02 | RF01 | RN01 |
| CT03 | RF02 | - |
| CT04 | RF04 | - |
| CT05 | RF05 | RN05 |
| CT06 | RF05 | RN05 |
| CT07 | RF06 | RN06 |
| CT08 | RF07 | RN07 |
| CT09 | RF08, RF09 | RN08 |
| CT10 | RF08, RF09 | RN08 |
| CT11 | RF10 | - |
| CT12 | RF08, RF10 | RN10 |
| CT13 | RF08, RF09 | RN08 |
| CT14 | RF08, RF09 | - |

## Critérios de Aceite

A etapa de teste é considerada aprovada quando:

- Todos os testes automatizados em `tests/finansme_api_contract_test.dart` passam.
- A análise estática em `tests` não apresenta problemas.
- Os casos CT01 a CT14 possuem cobertura automatizada.
- As rotas autenticadas validam o envio do header `Authorization`.
- Os cenários de erro validam o `statusCode` esperado na `ApiException`.

## Resultado da Execução

Última execução realizada:

```bash
flutter test tests
```

Resultado:

```text
14 testes executados.
14 testes aprovados.
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
