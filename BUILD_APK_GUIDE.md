# Инструкция по установке Android SDK и сборке APK

## Текущий статус

✅ **Установлено:**
- Flutter SDK 3.24.5 в `/home/bbybxx/flutter`
- Dart SDK (в составе Flutter)

❌ **Требуется для сборки APK:**
- Android SDK command-line tools
- Android build tools (версия 34.0.0)
- Android platform tools
- Java JDK 17+

---

## Вариант 1: Автоматическая установка (требует sudo)

### Шаг 1: Установить необходимые пакеты

```bash
sudo pacman -S --noconfirm unzip jdk17-openjdk
```

### Шаг 2: Распаковать Android command-line tools

```bash
cd /home/bbybxx/android-sdk/cmdline-tools
unzip cmdline-tools.zip
mv cmdline-tools latest
```

### Шаг 3: Установить Android SDK компоненты

```bash
export ANDROID_HOME=/home/bbybxx/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# Принять лицензии
yes | sdkmanager --licenses

# Установить необходимые компоненты
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### Шаг 4: Настроить Flutter

```bash
/home/bbybxx/flutter/bin/flutter config --android-sdk /home/bbybxx/android-sdk
/home/bbybxx/flutter/bin/flutter doctor --android-licenses
```

### Шаг 5: Собрать APK

```bash
cd "/home/bbybxx/work/dom demo/intercom_demo"
/home/bbybxx/flutter/bin/flutter pub get
/home/bbybxx/flutter/bin/flutter build apk --release
```

APK будет в: `build/app/outputs/flutter-apk/app-release.apk`

---

## Вариант 2: Использовать Docker (без sudo на хост-системе)

### Создать Dockerfile:

```dockerfile
FROM ubuntu:22.04

# Установить зависимости
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    openjdk-17-jdk wget

# Установить Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Установить Android SDK
RUN mkdir -p /android-sdk/cmdline-tools
WORKDIR /android-sdk/cmdline-tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
RUN unzip commandlinetools-linux-11076708_latest.zip && mv cmdline-tools latest

ENV ANDROID_HOME=/android-sdk
ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Принять лицензии и установить компоненты
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

WORKDIR /app
```

### Собрать и запустить:

```bash
docker build -t flutter-builder .
docker run -v "/home/bbybxx/work/dom demo/intercom_demo:/app" flutter-builder \
    sh -c "flutter pub get && flutter build apk --release"
```

---

## Вариант 3: Использовать онлайн CI/CD (GitHub Actions)

### Создать `.github/workflows/build.yml`:

```yaml
name: Build APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
      
      - run: flutter pub get
      - run: flutter build apk --release
      
      - uses: actions/upload-artifact@v3
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

Загрузите проект на GitHub и APK соберется автоматически.

---

## Вариант 4: Ручная установка (пошагово)

### 1. Установить Java JDK

```bash
# Скачать OpenJDK 17
wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz

# Распаковать
tar xzf openjdk-17.0.2_linux-x64_bin.tar.gz -C /home/bbybxx/

# Добавить в PATH
export JAVA_HOME=/home/bbybxx/jdk-17.0.2
export PATH=$PATH:$JAVA_HOME/bin
```

### 2. Настроить Android SDK

```bash
# Распаковать command-line tools (уже скачаны)
cd /home/bbybxx/android-sdk/cmdline-tools

# Использовать Python для распаковки (если нет unzip)
python3 -m zipfile -e cmdline-tools.zip .
mv cmdline-tools latest

# Настроить переменные окружения
export ANDROID_HOME=/home/bbybxx/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
```

### 3. Установить Android компоненты

```bash
# Принять лицензии
yes | sdkmanager --licenses

# Установить необходимые пакеты
sdkmanager "platform-tools"
sdkmanager "platforms;android-34"
sdkmanager "build-tools;34.0.0"
```

### 4. Собрать APK

```bash
cd "/home/bbybxx/work/dom demo/intercom_demo"

# Установить зависимости
/home/bbybxx/flutter/bin/flutter pub get

# Собрать APK
/home/bbybxx/flutter/bin/flutter build apk --release
```

---

## Быстрая проверка (что уже готово)

```bash
# Проверить Flutter
/home/bbybxx/flutter/bin/flutter --version

# Проверить Dart
/home/bbybxx/flutter/bin/dart --version

# Проверить структуру проекта
cd "/home/bbybxx/work/dom demo/intercom_demo"
ls -la
```

---

## Альтернатива: Отправить без APK

Вы можете отправить заказчику:
1. ✅ Исходный код проекта
2. ✅ Всю документацию
3. ✅ Инструкции по сборке
4. 📝 Пометка: "APK будет предоставлен после настройки окружения"

Это нормальная практика для демо-проектов.

---

## Рекомендация

**Самый простой вариант**: Использовать GitHub Actions (Вариант 3)
- Не требует локальной установки
- Автоматическая сборка
- Бесплатно для публичных репозиториев

**Самый быстрый вариант**: Установить пакеты через sudo (Вариант 1)
- 5-10 минут
- Одна команда

**Для продакшена**: Настроить локальное окружение (Вариант 4)
- Полный контроль
- Можно использовать многократно
