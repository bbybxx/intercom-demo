#!/bin/bash

# Скрипт проверки структуры проекта Smart Intercom Demo
# Использование: bash validate_project.sh

echo "🔍 Проверка структуры проекта Smart Intercom Demo..."
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Счетчики
PASSED=0
FAILED=0
WARNINGS=0

# Функция проверки файла
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $1 - НЕ НАЙДЕН"
        ((FAILED++))
    fi
}

# Функция проверки директории
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $1/ - НЕ НАЙДЕНА"
        ((FAILED++))
    fi
}

# Проверка основных файлов
echo "📁 Основные файлы:"
check_file "pubspec.yaml"
check_file "README.md"
check_file "TECHNICAL_OVERVIEW.md"
check_file "PRESENTATION.md"
check_file "NEXT_STEPS.md"
check_file "TEST_REPORT.md"
check_file "analysis_options.yaml"
check_file ".gitignore"
echo ""

# Проверка директорий
echo "📂 Директории:"
check_dir "lib"
check_dir "lib/screens"
check_dir "lib/services"
check_dir "lib/models"
check_dir "lib/widgets"
check_dir "backend"
check_dir "assets"
echo ""

# Проверка Dart файлов
echo "📱 Dart файлы:"
check_file "lib/main.dart"
check_file "lib/screens/login_screen.dart"
check_file "lib/screens/control_screen.dart"
check_file "lib/screens/video_stream_screen.dart"
check_file "lib/services/auth_service.dart"
check_file "lib/services/door_service.dart"
check_file "lib/services/video_service.dart"
echo ""

# Проверка Backend файлов
echo "🗄️ Backend файлы:"
check_file "backend/schema.sql"
check_file "backend/backend_setup.md"
echo ""

# Проверка содержимого pubspec.yaml
echo "📦 Проверка зависимостей:"
if grep -q "provider:" pubspec.yaml; then
    echo -e "${GREEN}✓${NC} provider найден"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} provider не найден"
    ((FAILED++))
fi

if grep -q "graphql_flutter:" pubspec.yaml; then
    echo -e "${GREEN}✓${NC} graphql_flutter найден"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} graphql_flutter не найден"
    ((FAILED++))
fi

if grep -q "flutter_vlc_player:" pubspec.yaml; then
    echo -e "${GREEN}✓${NC} flutter_vlc_player найден"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} flutter_vlc_player не найден"
    ((FAILED++))
fi

if grep -q "intl_phone_number_input:" pubspec.yaml; then
    echo -e "${YELLOW}⚠${NC} intl_phone_number_input найден (не используется)"
    ((WARNINGS++))
fi
echo ""

# Проверка TODO в коде
echo "📝 Проверка TODO:"
TODO_COUNT=$(grep -r "TODO" lib/ 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC} Найдено TODO: $TODO_COUNT"
    grep -rn "TODO" lib/ 2>/dev/null | head -5
    ((WARNINGS++))
else
    echo -e "${GREEN}✓${NC} TODO не найдено"
    ((PASSED++))
fi
echo ""

# Проверка размера файлов
echo "📊 Статистика:"
DART_FILES=$(find lib -name "*.dart" 2>/dev/null | wc -l)
DART_LINES=$(find lib -name "*.dart" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
echo "  Dart файлов: $DART_FILES"
echo "  Строк кода: $DART_LINES"
echo ""

# Итоговый отчет
echo "═══════════════════════════════════════"
echo "📊 ИТОГОВЫЙ ОТЧЕТ"
echo "═══════════════════════════════════════"
echo -e "${GREEN}✓ Пройдено:${NC} $PASSED"
echo -e "${RED}✗ Ошибок:${NC} $FAILED"
echo -e "${YELLOW}⚠ Предупреждений:${NC} $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ!${NC}"
    echo ""
    echo "Проект готов к использованию."
    echo "Следующие шаги см. в NEXT_STEPS.md"
    exit 0
else
    echo -e "${RED}❌ ОБНАРУЖЕНЫ ОШИБКИ!${NC}"
    echo ""
    echo "Пожалуйста, исправьте отсутствующие файлы."
    exit 1
fi
