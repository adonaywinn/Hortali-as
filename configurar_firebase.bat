@echo off
echo 🔥 CONFIGURANDO FIREBASE PARA HORTAPP 🔥
echo.
echo ========================================
echo.

echo 📦 Instalando dependências...
flutter pub get

echo.
echo 🧹 Limpando cache...
flutter clean

echo.
echo 📦 Reinstalando dependências...
flutter pub get

echo.
echo 🚀 Executando o app...
echo.
echo ✅ Se tudo estiver configurado corretamente,
echo    o app deve abrir no navegador sem erros!
echo.
echo 📋 Lembre-se de:
echo    1. Configurar o Firebase Console
echo    2. Copiar as configurações para web/firebase-config.js
echo    3. Ativar Authentication e Firestore
echo.

flutter run -d chrome

pause
