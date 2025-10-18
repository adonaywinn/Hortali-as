# 🔥 Configuração do Firebase para HortApp

## 📋 Pré-requisitos

1. **Conta Google** para acessar o Firebase Console
2. **Projeto Flutter** configurado
3. **Node.js** instalado (para Firebase CLI)

## 🚀 Passo a Passo

### 1. Criar Projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em **"Adicionar projeto"**
3. Nome do projeto: `hortapp-hortalicas`
4. Ative o **Google Analytics** (opcional)
5. Clique em **"Criar projeto"**

### 2. Configurar Authentication

1. No menu lateral, clique em **"Authentication"**
2. Vá para a aba **"Sign-in method"**
3. Ative **"Email/Password"**
4. Ative **"Anonymous"** (para login temporário)

### 3. Configurar Firestore Database

1. No menu lateral, clique em **"Firestore Database"**
2. Clique em **"Criar banco de dados"**
3. Escolha **"Iniciar no modo de teste"** (para desenvolvimento)
4. Selecione a localização mais próxima (ex: `southamerica-east1`)

### 4. Configurar Storage

1. No menu lateral, clique em **"Storage"**
2. Clique em **"Começar"**
3. Escolha **"Iniciar no modo de teste"**
4. Selecione a localização do Storage

### 5. Obter Configurações do Projeto

1. No menu lateral, clique em **"Configurações do projeto"** (ícone de engrenagem)
2. Role para baixo até **"Seus aplicativos"**
3. Clique no ícone **"Web"** (`</>`)
4. Nome do app: `HortApp Web`
5. **NÃO** marque "Também configurar o Firebase Hosting"
6. Clique em **"Registrar app"**
7. **Copie a configuração** que aparece

### 6. Configurar o Projeto Flutter

#### 6.1. Instalar Firebase CLI

```bash
npm install -g firebase-tools
```

#### 6.2. Fazer Login no Firebase

```bash
firebase login
```

#### 6.3. Configurar Firebase no Projeto

```bash
cd hortalicas
firebase init
```

**Selecione:**
- ✅ Firestore
- ✅ Authentication
- ✅ Storage
- ✅ Hosting (opcional)

#### 6.4. Configurar para Web

1. Copie a configuração do Firebase Console
2. Cole no arquivo `web/firebase-config.js` (substitua os valores)

```javascript
const firebaseConfig = {
  apiKey: "sua-api-key",
  authDomain: "seu-projeto.firebaseapp.com",
  projectId: "seu-projeto-id",
  storageBucket: "seu-projeto.appspot.com",
  messagingSenderId: "123456789",
  appId: "seu-app-id"
};
```

### 7. Configurar Regras de Segurança

#### 7.1. Firestore Rules

No Firebase Console > Firestore > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários podem ler/escrever apenas seus próprios dados
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Plantações do usuário
    match /plantacoes/{plantacaoId} {
      allow read, write: if request.auth != null && 
        resource.data.usuarioId == request.auth.uid;
    }
    
    // Tarefas do usuário
    match /tarefas/{tarefaId} {
      allow read, write: if request.auth != null && 
        resource.data.usuarioId == request.auth.uid;
    }
    
    // Alertas do usuário
    match /alertas/{alertaId} {
      allow read, write: if request.auth != null && 
        resource.data.usuarioId == request.auth.uid;
    }
    
    // Canteiros do usuário
    match /canteiros/{canteiroId} {
      allow read, write: if request.auth != null && 
        resource.data.usuarioId == request.auth.uid;
    }
  }
}
```

#### 7.2. Storage Rules

No Firebase Console > Storage > Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /usuarios/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 8. Testar a Configuração

#### 8.1. Instalar Dependências

```bash
flutter pub get
```

#### 8.2. Executar o App

```bash
flutter run -d chrome
```

#### 8.3. Verificar no Firebase Console

1. **Authentication**: Deve aparecer usuários anônimos
2. **Firestore**: Deve aparecer coleções criadas
3. **Storage**: Deve aparecer arquivos enviados

## 📱 Funcionalidades Implementadas

### ✅ **Autenticação**
- Login anônimo automático
- Login com email/senha
- Logout

### ✅ **Banco de Dados**
- **Usuários**: Dados do perfil
- **Plantações**: Plantas plantadas pelo usuário
- **Tarefas**: Cronograma automático de rega/adubação
- **Alertas**: Notificações de colheita/pragas
- **Canteiros**: Áreas de plantio

### ✅ **Sistema Automático**
- **Criação automática** de tarefas ao plantar
- **Cronograma personalizado** por tipo de planta
- **Alertas inteligentes** baseados na planta
- **Sincronização em tempo real**

## 🔧 Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Executar no navegador
flutter run -d chrome

# Executar no Android
flutter run -d android

# Executar no iOS
flutter run -d ios

# Limpar cache
flutter clean
flutter pub get
```

## 🚨 Troubleshooting

### Erro: "Firebase not initialized"
- Verifique se o `firebase-config.js` está correto
- Confirme se o `main.dart` está inicializando o Firebase

### Erro: "Permission denied"
- Verifique as regras de segurança do Firestore
- Confirme se o usuário está autenticado

### Erro: "Network error"
- Verifique a conexão com a internet
- Confirme se o projeto Firebase está ativo

## 📞 Suporte

Se tiver problemas:
1. Verifique os logs no console do navegador
2. Confirme se todas as dependências estão instaladas
3. Teste com um projeto Firebase novo
4. Verifique se as regras de segurança estão corretas

---

**🎉 Pronto!** Seu HortApp agora está conectado ao Firebase e pode armazenar dados na nuvem!
