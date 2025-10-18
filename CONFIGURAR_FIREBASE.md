# 🔥 Como Configurar o Firebase - Passo a Passo

## 🎯 **Resumo Rápido**
1. Criar projeto no Firebase Console
2. Ativar Authentication e Firestore
3. Copiar configurações para o código
4. Testar a conexão

---

## 📋 **PASSO 1: Criar Projeto no Firebase**

### 1.1 Acessar Firebase Console
- Vá para: https://console.firebase.google.com/
- Faça login com sua conta Google

### 1.2 Criar Novo Projeto
- Clique em **"Adicionar projeto"**
- Nome do projeto: `hortapp-hortalicas`
- ✅ Marque "Habilitar Google Analytics para este projeto"
- Escolha conta do Analytics (ou crie nova)
- Clique **"Criar projeto"**
- Aguarde alguns segundos...

---

## 🔐 **PASSO 2: Configurar Authentication**

### 2.1 Ativar Métodos de Login
- No menu lateral, clique **"Authentication"**
- Clique na aba **"Sign-in method"**
- Ative **"Email/Password"**:
  - Clique em "Email/Password"
  - Ative "Habilitar"
  - Clique "Salvar"
- Ative **"Anonymous"**:
  - Clique em "Anonymous"
  - Ative "Habilitar"
  - Clique "Salvar"

---

## 🗄️ **PASSO 3: Configurar Firestore Database**

### 3.1 Criar Banco de Dados
- No menu lateral, clique **"Firestore Database"**
- Clique **"Criar banco de dados"**
- Escolha **"Iniciar no modo de teste"** (para desenvolvimento)
- Selecione localização: **"southamerica-east1"** (São Paulo)
- Clique **"Próximo"**

### 3.2 Configurar Regras de Segurança
- Cole as regras abaixo no editor:

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

- Clique **"Publicar"**

---

## 📱 **PASSO 4: Configurar App Web**

### 4.1 Adicionar App Web
- No menu lateral, clique **"Configurações do projeto"** (ícone de engrenagem)
- Role para baixo até **"Seus aplicativos"**
- Clique no ícone **"Web"** (`</>`)
- Nome do app: `HortApp Web`
- ❌ **NÃO** marque "Também configurar o Firebase Hosting"
- Clique **"Registrar app"**

### 4.2 Copiar Configuração
- **COPIE** a configuração que aparece (algo como):

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "hortapp-hortalicas.firebaseapp.com",
  projectId: "hortapp-hortalicas",
  storageBucket: "hortapp-hortalicas.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890abcdef"
};
```

---

## 💻 **PASSO 5: Configurar no Código**

### 5.1 Atualizar firebase-config.js
- Abra o arquivo `web/firebase-config.js`
- **SUBSTITUA** toda a configuração pela sua configuração do Firebase Console
- Salve o arquivo

### 5.2 Instalar Dependências
Execute no terminal:

```bash
flutter pub get
```

### 5.3 Testar a Conexão
Execute no terminal:

```bash
flutter run -d chrome
```

---

## ✅ **PASSO 6: Verificar se Funcionou**

### 6.1 No Navegador
- O app deve abrir normalmente
- Não deve aparecer erros de Firebase no console
- O botão "PLANTAR AGORA" deve funcionar

### 6.2 No Firebase Console
- **Authentication**: Deve aparecer usuários anônimos quando você usar o app
- **Firestore**: Deve aparecer coleções quando você plantar algo

---

## 🚨 **Problemas Comuns e Soluções**

### ❌ **Erro: "Firebase not initialized"**
**Solução:**
- Verifique se o `firebase-config.js` está correto
- Confirme se o `main.dart` tem `await Firebase.initializeApp()`

### ❌ **Erro: "Permission denied"**
**Solução:**
- Verifique se as regras do Firestore estão corretas
- Confirme se o usuário está autenticado

### ❌ **Erro: "Network error"**
**Solução:**
- Verifique sua conexão com a internet
- Confirme se o projeto Firebase está ativo

### ❌ **Erro: "Could not find a set of Noto fonts"**
**Solução:**
- Este é apenas um aviso de fonte, não afeta o funcionamento
- Pode ser ignorado

---

## 🎉 **Pronto!**

Se você seguiu todos os passos:
- ✅ Firebase configurado
- ✅ Authentication ativado
- ✅ Firestore configurado
- ✅ App funcionando
- ✅ Dados sendo salvos na nuvem

**Agora você pode:**
- Plantar e ver os dados no Firebase Console
- Usar o app em qualquer dispositivo
- Ter backup automático das suas plantações
- Sincronizar dados entre dispositivos

---

## 📞 **Precisa de Ajuda?**

Se algo não funcionar:
1. Verifique se copiou a configuração correta
2. Confirme se todas as dependências foram instaladas
3. Teste com `flutter clean && flutter pub get`
4. Verifique o console do navegador para erros

**🎯 O app está pronto para usar com Firebase!** 🌱✨
