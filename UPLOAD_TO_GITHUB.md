# Инструкция по загрузке на GitHub

## Текущая ситуация

Проект полностью готов к загрузке:
- ✅ Git репозиторий инициализирован
- ✅ Все файлы закоммичены (22 файла)
- ✅ GitHub Actions workflow настроен

## Варианты загрузки

### Вариант 1: Создать репозиторий вручную (РЕКОМЕНДУЕТСЯ)

#### Шаг 1: Создайте репозиторий на GitHub

1. Откройте https://github.com/new
2. Заполните:
   - **Repository name**: `intercom-demo`
   - **Description**: `Smart Intercom Demo - Technical demo for Azail Security System`
   - **Visibility**: Public (для бесплатных GitHub Actions)
   - ⚠️ **НЕ добавляйте** README, .gitignore, license
3. Нажмите **"Create repository"**

#### Шаг 2: Скопируйте URL репозитория

После создания GitHub покажет URL вида:
```
https://github.com/YOUR_USERNAME/intercom-demo.git
```

#### Шаг 3: Дайте мне этот URL

Просто напишите мне URL, и я выполню команды:
```bash
git remote add origin <URL>
git branch -M main
git push -u origin main
```

---

### Вариант 2: Через sudo (автоматически)

Если вы предоставите sudo пароль, я:
1. Установлю GitHub CLI
2. Создам репозиторий автоматически
3. Загружу код

---

### Вариант 3: Через Personal Access Token

Если у вас есть GitHub Personal Access Token:

1. Создайте токен на https://github.com/settings/tokens
   - Права: `repo`, `workflow`
2. Дайте мне токен
3. Я настрою git credentials и загружу код

---

## Что произойдет после загрузки

1. ✅ Код появится на GitHub
2. ✅ GitHub Actions автоматически начнет сборку APK
3. ✅ Через 5-10 минут APK будет готов
4. ✅ Вы сможете скачать APK из раздела "Artifacts"

---

## Следующий шаг

**Выберите вариант и:**
- **Вариант 1**: Дайте мне URL созданного репозитория
- **Вариант 2**: Предоставьте sudo пароль
- **Вариант 3**: Дайте мне Personal Access Token

Рекомендую **Вариант 1** - самый простой и безопасный!
