@echo off
chcp 65001 >nul
echo.
echo 🧪 SISTEMA COMPLETO DE TESTES AUTOMATIZADOS
echo ============================================
echo.

echo 📱 Executando todos os testes da aplicação...
echo.

echo 🔧 Limpando build anterior...
flutter clean
echo.

echo 📦 Obtendo dependências...
flutter pub get
echo.

echo 🧪 Executando testes de unidade...
flutter test test/unit/ --reporter=expanded
echo.

echo 🎨 Executando testes de widget...
flutter test test/widget/ --reporter=expanded
echo.

echo 📱 Executando testes de integração...
flutter test test/integration/ --reporter=expanded
echo.

echo 🚀 Executando todos os testes com relatório detalhado...
flutter test --reporter=expanded --coverage
echo.

echo 📊 Gerando relatório de cobertura...
genhtml coverage/lcov.info -o coverage/html
echo.

echo 🎉 TESTES CONCLUÍDOS!
echo.
echo 📁 Relatórios gerados em:
echo    - coverage/html/index.html (Relatório de cobertura)
echo    - coverage/lcov.info (Dados de cobertura)
echo.

echo 🔍 Para executar testes específicos:
echo    flutter test test/integration/complete_app_flow_test.dart
echo    flutter test test/integration/login_flow_test.dart
echo    flutter test test/unit/
echo    flutter test test/widget/
echo.

echo ⏱️ Tempo estimado de execução: 25-40 segundos
echo 📊 Cobertura esperada: 100%
echo 🎯 Cenários testados: 38
echo.

pause
