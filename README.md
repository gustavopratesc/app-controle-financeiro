# 📊 Controle Financeiro - Arquitetura Offline-First

Um aplicativo de gestão financeira construído com foco em resiliência de dados e experiência do usuário contínua. O sistema implementa uma arquitetura **Offline-First**, permitindo que o usuário gerencie suas despesas e receitas sem depender de conexão com a internet, garantindo a sincronização assíncrona com a nuvem (PostgreSQL) assim que a rede é restabelecida.

## 🚀 Principais Funcionalidades

* **Autenticação Local:** Gestão de acesso e sessão de usuário via SQLite.
* **CRUD Financeiro Completo:** Inserção, listagem e remoção de transações (Receitas e Despesas).
* **Cálculo de Saldo Dinâmico:** Reatividade em tempo real para o saldo geral do usuário.
* **Sincronização Assíncrona (Background Sync):** Fila de sincronização invisível que detecta transações pendentes no banco local e as envia para o servidor remoto.
* **Exclusão Bi-direcional:** Remoção de registros no dispositivo local com espelhamento automático no banco de dados em nuvem.

## 🛠️ Tecnologias Utilizadas

Este projeto unifica ferramentas robustas de front-end com conceitos avançados de persistência e integração de backend:

* **Front-end & Mobile:** Flutter / Dart
* **Gerenciamento de Estado:** Riverpod (para reatividade otimizada e injeção de dependências)
* **Banco de Dados Local:** SQLite (Persistência Offline)
* **Backend as a Service (BaaS):** Supabase
* **Banco de Dados Remoto:** PostgreSQL
* **Padrão de Arquitetura:** MVVM (Model-View-ViewModel) e Repository Pattern

## 🏗️ Decisões de Arquitetura

Para garantir um código escalável, testável e de fácil manutenção, o projeto foi estruturado utilizando **MVVM**.
* **Models:** Definição rigorosa das entidades do sistema.
* **Repositories:** Abstração completa da camada de acesso a dados. O aplicativo não sabe de onde os dados vêm, apenas confia no repositório.
* **ViewModels:** Isolamento total das regras de negócio e cálculo de estado, mantendo as Views limpas e focadas apenas na renderização de UI.
* **Serviços (Services):** Camada dedicada à comunicação externa e rotinas de sincronização remota, tratando falhas de rede de forma silenciosa para não quebrar a experiência do usuário.

## ⚙️ Como Executar o Projeto

**1. Clone o repositório:**
```
git clone [https://github.com/seu-usuario/app-controle-financeiro.git](https://github.com/seu-usuario/app-controle-financeiro.git)

2. Acesse a pasta do projeto:

cd app-controle-financeiro

3. Instale as dependências:

flutter pub get
4. Configure as chaves do Supabase:
Abra o arquivo lib/main.dart e insira as suas credenciais de projeto (URL e Publishable Key) no bloco de inicialização Supabase.initialize().

5. Execute o aplicativo:

flutter run

(Para gerar o executável final otimizado para Android, utilize flutter build apk --release)
