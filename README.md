# Capi-Bank — Flutter

App Flutter do Capi-Bank, com o visual pixel P&B do SemUmReal-mobile.
Fala com a API que já está no Render, **sem mudar a API**.

- **API:** https://desafio-capi-bank.onrender.com — v6.0.0, docs em `/docs`
- **Front de referência:** SemUmReal-mobile (React Native Expo, pixel art P&B) — só o visual foi traduzido para Flutter. O código dele **não** foi copiado.

## Login — DIRETO na API, sem Google, sem e-mail/senha

Decisão final: **não há usuário do app separado**. O login vai direto
para a API Capi-Bank, e é a API que fica com os clientes lá.

- **Tela de login:** campo CPF (11 dígitos), botão preto ENTRAR, link
  CRIAR CONTA. Visual igual ao `docs/login.jpg` do original: título
  SEMUMREAL, subtítulo SEU DINHEIRO SEM FIRULA, e embaixo a arte do
  joguinho — sol-moeda com $ e o dolarzinho correndo (Mario-style).
- **Sem botão de Login com Google. Sem e-mail, sem senha.** A API v6
  não tem esses campos — e-mail/senha/Google só existiriam numa V2 da API.
- **Quem já tem cadastro:** entra só com o CPF —
  `POST /auth/login?cpf=` guarda o Bearer e vai para a Home com as 5 abas.
- **CRIAR CONTA:** cadastro do cliente na API —
  `POST /clientes/` (cpf, nome, data_nascimento, endereco) → login
  automático `POST /auth/login?cpf=` (gera o Bearer) → abrir conta
  `POST /contas/` (agência 0001) → Home. Tudo num fluxo só, com a
  lógica embutida, sem fazer nada na mão no Swagger.

## As 5 abas (rodapé, igual ao original)

Barra inferior de 72px, fundo branco, borda superior de 2px preta,
ícones pixel de 24px (casinha, setinha, mais, gráfico, perfil):
ativo preto #111111, inativo cinza #6B6B6B. Todas ligadas à API real,
sem mock.

| Aba | Ícone | O que faz | API |
|---|---|---|---|
| INÍCIO | casinha | Resumo da Conta: nome, conta/agência, saldo, 3 transações recentes | `GET /clientes/me`, `GET /contas/`, `GET /contas/{n}/saldo`, `GET /contas/{n}/extrato` |
| TRANSAÇÕES | setinha dupla | Extrato completo + Depositar / Sacar / Transferir | `GET /contas/{n}/extrato`, `POST /depositar`, `/sacar`, `/transferir` |
| NOVO | mais na caixa | Criar NOVA CONTA (agência 0001) e trocar a conta ativa — o cliente pode ter várias contas | `GET /contas/`, `POST /contas/` |
| RELATÓRIOS | gráfico | Auditoria / logs | `GET /logs/?limit=100` |
| PERFIL | userzinho | Dados do cliente (nome, CPF, nascimento, endereço) + SAIR (apaga o Bearer) | `GET /clientes/me` |

Saque (Double Guard da API): máx. R$ 500 por operação, 3 saques/dia,
10 transações/dia, R$ 1.200/dia.

## Estrutura

```
pubspec.yaml
lib/
  main.dart                  # entry + gate de sessão (Bearer → 5 abas)
  capi_bank_api.dart         # serviço da API (não mudar os endpoints)
  create_account_flow.dart   # cadastro → login → abrir conta
  login_page.dart            # página de login avulsa (só CPF) — legado, mantida
  theme/app_theme.dart       # tokens pixel P&B (cores, espaçamento ×8, Press Start 2P)
  utils/format.dart          # brl() e datas em pt-BR
  screens/
    login_screen.dart        # login direto na API, só CPF + arte do joguinho
    register_screen.dart     # cadastro do cliente na API + abrir conta
    main_shell.dart          # carrega cliente/contas/saldo/extrato e reparte nas abas
    account_data.dart        # dados da conta ativa compartilhados pelas abas
    home_tab.dart            # INÍCIO — resumo da conta
    transactions_tab.dart    # TRANSAÇÕES — extrato + depositar/sacar/transferir
    new_tab.dart             # NOVO — criar conta e trocar a conta ativa
    reports_tab.dart         # RELATÓRIOS — logs de auditoria
    profile_tab.dart         # PERFIL — dados do cliente + sair
  widgets/
    pixel_widgets.dart       # PixelCard, PixelButton, PixelError, PixelField
    pixel_tab_bar.dart       # barra de 5 abas, ícones pixel desenhados via CustomPaint
    coin_game.dart           # sol-moeda + dolarzinho correndo (login) e versão estática
```

## Como rodar

```bash
cd capi-bank-flutter
flutter pub get
flutter run
```

Requisitos: Flutter SDK 3.24+ / Dart 3.5+.

Na primeira chamada o Render gratuito pode demorar alguns segundos (cold start) — é normal.

> Não foi executada nenhuma compilação, análise ou teste
> (`flutter analyze/run`, `npm`, build). Vale rodar
> `flutter pub get && flutter analyze` antes do primeiro `flutter run`.

## Deploy (futuro, NÃO feito agora)

O que vai para o Railway + Cloudflare depois é a **build web**:

```bash
flutter build web --release
```

A saída em `build/web/` é um site estático, que pode ser servido pelo Railway e exposto num subdomínio de `infocapibaribe.com` no Cloudflare. Nada disso foi configurado nem publicado neste passo.

## Decisões em aberto

- **V2:** depois, se o front mandar, a API pode ser ajustada pelo front (por exemplo, e-mail/senha/Google). Na V1, a API fica como está.
