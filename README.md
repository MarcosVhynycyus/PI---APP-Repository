# Requisitos do Sistema

## 1. Requisitos Funcionais (RF)

### RF01 — Login do usuário
O sistema deve permitir que o usuário realize login com e-mail e senha.

### RF02 — Recuperar senha
O sistema deve permitir que o usuário solicite recuperação de senha por e-mail.

### RF03 — Atualização de perfil
O usuário pode alterar nome, foto e dados pessoais.

---

## 2. Requisitos Não Funcionais (RNF)

### RNF01 — Tempo de resposta
O sistema deve carregar telas principais em até **2 segundos**.

### RNF02 — Segurança
As senhas devem ser armazenadas usando hash seguro (ex.: bcrypt).

### RNF03 — Compatibilidade
O sistema deve funcionar nos navegadores Chrome, Edge e Firefox.

---

## 3. Regras de Negócio (RN)

### RN01 — Maioridade
Para criar uma conta, o usuário deve ter mais de 18 anos.

### RN02 — Bloqueio por inatividade
Usuários inativos por mais de 90 dias devem ser marcados como inativos.

### RN02 — Limite de tentativas de login
Após 5 tentativas inválidas, a conta deve ser temporariamente bloqueada.