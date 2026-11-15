# Validade Zero — MVP

Aplicativo móvel desenvolvido para o controle de validade de insumos perecíveis e aplicação visual do método PEPS (Primeiro a Entrar, Primeiro a Sair), alinhado ao **ODS 12 (Consumo e Produção Responsáveis)**.

## Arquitetura e Tecnologias
- **Padrão Arquitetural:** MVC (Model-View-Controller)
- **Framework Mobile:** Flutter (Dart)
- **Gerenciamento de Estado:** Provider
- **Backend / Persistência:** Firebase Authentication & Cloud Firestore (NoSQL)

## Estrutura de Pastas (`lib/`)
- `models/`: Entidades de domínio (`LotePerecivel`) e serialização NoSQL.
- `controllers/`: Regras de negócio, cálculo de prazos e controle de estado (`Provider`).
- `views/`: Interfaces gráficas acessíveis (Login, Cadastro e Dashboard PEPS) com redundância visual (cores + ícones + textos) para acessibilidade.

## Como Executar Localmente
1. Instale as dependências: `flutter pub get`
2. Execute os testes unitários: `flutter test`
3. Inicie a aplicação: `flutter run`