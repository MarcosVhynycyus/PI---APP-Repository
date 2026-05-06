# Persistencia de Token - Implementacao

## Objetivo da feature

Garantir que o token retornado no login seja persistido e reutilizado automaticamente nos services protegidos, sem depender de `arguments` de rota.

## O que foi alterado

### 1. Persistencia e sessao

1. O token continua sendo recebido no `POST /login` via `LoginService`.
2. A tela de login salva o token com `AuthStore.setToken(result.token)`.
3. Foi criado um bootstrap de sessao no app (`SessionGate`) para decidir rota inicial:

- com token salvo: abre `MainNavigation`
- sem token: abre `LoginPage`

Arquivos:

- `lib/src/pages/login_page.dart`
- `lib/src/services/login_service.dart`
- `lib/src/services/auth_store.dart`
- `lib/src/app.dart`

### 2. Logout real

1. Foi adicionado `AuthStore.logout()` (alias semantico de `clear()`).
2. Ao sair no perfil, o token e removido e a navegacao e resetada para `'/login'`.
3. O clique no logo do header nao envia mais para login sem limpar sessao; agora volta para `'/main'`.

Arquivos:

- `lib/src/services/auth_store.dart`
- `lib/src/pages/profile_page.dart`
- `lib/src/widgets/page_header.dart`

### 3. Services protegidos com token interno

Padrao aplicado: cada service protegido recupera token diretamente do `AuthStore`, valida sessao e injeta `Bearer` via `ApiClient`.

Padrao usado:

1. Criar metodo privado `_getTokenOrThrow()`
2. Buscar token: `final token = await AuthStore.getToken()`
3. Validar token vazio/nulo e lancar excecao de sessao expirada
4. Chamar `api.get/post/put/delete(..., token: token)`

Services ajustados:

1. `BanksService`

- reforco de sessao
- uso consistente de token interno
- correcao de path no update para `'/accounts/$id'`

2. `FinancialMovementsService`

- removida dependencia de parametro `token` nos metodos
- token agora vem do store
- suporte ao endpoint protegido `'/user-financial-movements'`

3. `TransactorsService`

- removida dependencia de parametro `token` nos metodos
- token agora vem do store
- suporte ao endpoint protegido `'/user-transactors'`

4. `AccountPlansService`

- migrado para `ApiClient` + `AuthStore`
- leitura do endpoint protegido `'/user-account-plans'`

Arquivos:

- `lib/src/services/banks_service.dart`
- `lib/src/services/finacial_movements_service.dart`
- `lib/src/services/transactors_service.dart`
- `lib/src/services/account_plans_service.dart`

## Como usar a persistencia de token

### Fluxo de login

1. Chame `LoginService.login(email, password)`.
2. Receba `token` e `message`.
3. Salve: `await AuthStore.setToken(token)`.
4. Navegue para `'/main'`.

### Fluxo de chamada autenticada (services)

1. Nao passe token pela UI.
2. No service, use `_getTokenOrThrow()` para recuperar token.
3. Chame API com `token: token` no `ApiClient`.

Exemplo de padrao:

```dart
final token = await _getTokenOrThrow();
final response = await api.get('/user-accounts', token: token);
```

### Fluxo de logout

1. Chame `await AuthStore.logout()`.
2. Resete pilha de navegacao:

```dart
Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
```

## Endpoints protegidos cobertos

1. `/user-accounts`
2. `/user-financial-movements`
3. `/user-account-plans`
4. `/user-transactors`

## Validacao recomendada

1. Abrir app sem token salvo e confirmar abertura no login.
2. Fazer login valido e confirmar redirecionamento para `'/main'`.
3. Fechar e reabrir app para validar sessao persistida.
4. Acessar telas/fluxos que disparam services protegidos.
5. Fazer logout e confirmar retorno ao login.
6. Fechar e reabrir app para confirmar que token foi removido.

## Observacoes

1. `flutter analyze` sem erros de compilacao nas alteracoes desta feature.
2. Existem avisos antigos de deprecacao/style fora do escopo.
3. Nao existe pasta `test/` no projeto atualmente.
