# 🌱 HortApp - Gerenciador de Horta Inteligente

Um aplicativo Flutter para gerenciamento inteligente de hortas domésticas, com monitoramento automático, controle de plantações e interface intuitiva.

### 📱 Funcionalidades

### 🏠 Dashboard Inteligente
- **Status geral** da horta com estatísticas em tempo real
- **Agrupamento por canteiro** (1 entrada por canteiro, independente da quantidade)
- **Ações rápidas** com menu interativo para tarefas
- **Próxima colheita** e alertas automáticos

### 🌿 Gerenciamento de Plantas
- **Plantio simplificado** em 3 etapas (canteiro → planta → confirmação)
- **Agrupamento inteligente** por canteiro e tipo de planta
- **Quantidade e estimativa** de colheita
- **Ações de execução** (regar, adubar, podar, etc.)
- **Botões Colher/Deletar** com animações suaves

### 🗺️ Mapa da Horta
- **Vista aérea esquemática** dos canteiros
- **Informações detalhadas** de cada canteiro
- **Estado vazio** com botão para criar primeiro canteiro
- **Carregamento em tempo real** do Firebase

### 📅 Agenda Inteligente
- **Tarefas automáticas** baseadas no tipo de planta
- **Monitoramento personalizado** por espécie
- **Alertas e lembretes** inteligentes
- **Tarefas manuais** para atividades extras

### 📚 Inventário Completo
- **Catálogo de plantas** do JSON local
- **Abas organizadas** (Para Plantio, Já Colhidas)
- **Filtros por categoria** (Hortaliças, Frutas, Ervas)
- **Criação de plantas personalizadas**

## 🚀 Tecnologias Utilizadas

- **Flutter** - Framework multiplataforma
- **Firebase** - Backend e autenticação
  - Firebase Auth (login/registro)
  - Cloud Firestore (banco de dados)
  - Firebase Storage (arquivos)
- **Dart** - Linguagem de programação

## 📦 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada
├── models/                   # Modelos de dados
│   ├── planta.dart          # Modelo de planta
│   ├── horta_data.dart      # Modelos da horta
│   └── firestore_models.dart # Modelos do Firebase
├── screens/                  # Telas do aplicativo
│   ├── dashboard_screen.dart
│   ├── plantas_screen.dart
│   ├── mapa_horta_screen.dart
│   ├── agenda_screen.dart
│   ├── inventario_screen.dart
│   ├── plantio_screen.dart
│   └── auth/                # Telas de autenticação
├── services/                 # Serviços
│   ├── firebase_service.dart
│   ├── planta_service.dart
│   ├── data_sync_service.dart
│   └── planta_monitoring_service.dart
└── widgets/                  # Componentes reutilizáveis
    ├── status_card.dart
    ├── tarefa_card.dart
    └── quick_action_button.dart
```

## 🛠️ Instalação e Configuração

### Pré-requisitos
- Flutter SDK (versão 3.0+)
- Dart SDK
- Firebase CLI
- Android Studio / VS Code

### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/hortapp.git
cd hortapp
```

### 2. Instale as dependências
```bash
flutter pub get
```

### 3. Configure o Firebase
```bash
# Instale o Firebase CLI
npm install -g firebase-tools

# Configure o projeto
firebase login
firebase init

# Configure o FlutterFire
dart pub global activate flutterfire_cli
flutterfire configure
```

### 4. Execute o aplicativo
```bash
# Para desenvolvimento
flutter run

# Para produção
flutter build apk --release
```

## 🔧 Configuração do Firebase

### 1. Crie um projeto no Firebase Console
- Acesse [Firebase Console](https://console.firebase.google.com)
- Crie um novo projeto
- Ative Authentication e Firestore

### 2. Configure a autenticação
- Vá em Authentication > Sign-in method
- Ative Email/Password e Anonymous

### 3. Configure o Firestore
- Vá em Firestore Database
- Crie o banco de dados
- Configure as regras de segurança

### 4. Estrutura do Firestore
```
Collections:
├── usuarios/           # Dados dos usuários
├── canteiros/         # Canteiros da horta
├── plantacoes/        # Plantações realizadas
├── tarefas/           # Tarefas automáticas
├── alertas/           # Alertas e notificações
├── plantas_inventario/ # Catálogo de plantas
└── plantas_personalizadas/ # Plantas customizadas
```

## 📱 Funcionalidades Principais

### 🌱 Sistema de Plantio
1. **Seleção de canteiro** - Escolha onde plantar
2. **Escolha da planta** - Selecione do inventário
3. **Configuração** - Quantidade e estimativa
4. **Confirmação** - Plantio automático com monitoramento

### 📊 Dashboard Inteligente
- **Estatísticas em tempo real**
- **Agrupamento por canteiro**
- **Ações rápidas interativas**
- **Próximas colheitas**

### 🗺️ Mapa da Horta
- **Visualização esquemática**
- **Informações dos canteiros**
- **Estado vazio com criação**

### 📅 Agenda Automática
- **Tarefas baseadas no tipo de planta**
- **Monitoramento personalizado**
- **Alertas inteligentes**

## 🎨 Interface e UX

### Design System
- **Cores principais**: Verde (#2E7D32) e branco
- **Tipografia**: Roboto
- **Componentes**: Material Design 3
- **Animações**: Suaves e intuitivas

### Responsividade
- **Mobile-first** design
- **Adaptável** a diferentes tamanhos
- **Navegação intuitiva**

## 🔄 Fluxo de Dados

### 1. Autenticação
```
Login/Registro → Firebase Auth → Dashboard
```

### 2. Plantio
```
Selecionar Canteiro → Escolher Planta → Configurar → Confirmar → Firebase
```

### 3. Monitoramento
```
Planta Plantada → Tarefas Automáticas → Alertas → Execução
```

## 🚀 Deploy e Produção

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📈 Roadmap

### Versão 1.1
- [ ] Notificações push
- [ ] Relatórios de produtividade
- [ ] Integração com sensores IoT

### Versão 1.2
- [ ] IA para recomendações
- [ ] Compartilhamento de hortas
- [ ] Marketplace de sementes

### Versão 2.0
- [ ] Realidade aumentada
- [ ] Análise de solo
- [ ] Integração com clima

## 🤝 Contribuição

### Como contribuir
1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

### Padrões de código
- **Dart**: Siga as convenções do Dart
- **Flutter**: Use widgets reutilizáveis
- **Firebase**: Estrutura consistente
- **Commits**: Mensagens descritivas

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👥 Autores

- **Desenvolvedor Principal** - [Seu Nome](https://github.com/seu-usuario)
- **Contribuidores** - Veja [CONTRIBUTORS.md](CONTRIBUTORS.md)

## 📞 Suporte

- **Email**: suporte@hortapp.com
- **Issues**: [GitHub Issues](https://github.com/seu-usuario/hortapp/issues)
- **Documentação**: [Wiki](https://github.com/seu-usuario/hortapp/wiki)

## 🙏 Agradecimentos

- Comunidade Flutter
- Firebase Team
- Contribuidores do projeto
- Usuários beta testers

---

**🌱 HortApp - Cultivando o futuro da agricultura doméstica! 🌱**