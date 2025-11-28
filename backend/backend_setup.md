# Backend Setup Guide

## Рекомендуемое решение: Supabase

Для быстрого развертывания демо рекомендуется использовать **Supabase** (бесплатный tier).

### Шаг 1: Создание проекта Supabase

1. Перейдите на [supabase.com](https://supabase.com)
2. Создайте бесплатный аккаунт
3. Создайте новый проект:
   - Project name: `intercom-demo`
   - Database password: (сохраните его)
   - Region: выберите ближайший регион

### Шаг 2: Настройка базы данных

1. В панели Supabase перейдите в **SQL Editor**
2. Скопируйте содержимое файла `schema.sql`
3. Вставьте и выполните SQL запрос
4. Проверьте, что таблицы созданы в разделе **Table Editor**

### Шаг 3: Настройка API

1. Перейдите в **Settings** → **API**
2. Найдите следующие параметры:
   - **Project URL**: `https://your-project.supabase.co`
   - **anon public key**: скопируйте этот ключ

### Шаг 4: Настройка GraphQL (опционально)

Supabase по умолчанию предоставляет REST API. Для GraphQL есть два варианта:

#### Вариант A: Использовать REST API (проще)

Измените файлы сервисов для использования REST API вместо GraphQL:

```dart
// В auth_service.dart
Future<Map<String, dynamic>> login(String phone, String password) async {
  final response = await http.post(
    Uri.parse('https://your-project.supabase.co/rest/v1/rpc/login'),
    headers: {
      'apikey': 'your-anon-key',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'phone': phone,
      'password': password,
    }),
  );
  // Handle response
}
```

#### Вариант B: Использовать pg_graphql (сложнее, но мощнее)

1. В Supabase включите расширение `pg_graphql`:
   ```sql
   CREATE EXTENSION IF NOT EXISTS pg_graphql;
   ```

2. GraphQL endpoint будет доступен по адресу:
   ```
   https://your-project.supabase.co/graphql/v1
   ```

### Шаг 5: Обновление конфигурации приложения

В файле `lib/main.dart` обновите следующие параметры:

```dart
final HttpLink httpLink = HttpLink(
  'https://YOUR-PROJECT.supabase.co/graphql/v1', // Замените YOUR-PROJECT
);

// Добавьте заголовок с API ключом
final AuthLink authLink = AuthLink(
  getToken: () async {
    return 'Bearer YOUR-ANON-KEY'; // Замените YOUR-ANON-KEY
  },
);
```

### Шаг 6: Настройка Row Level Security (RLS)

Для безопасности настройте RLS политики:

```sql
-- Включить RLS для таблиц
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE door_logs ENABLE ROW LEVEL SECURITY;

-- Политика для чтения пользователей (только свои данные)
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Политика для логов (только свои логи)
CREATE POLICY "Users can view own logs"
  ON door_logs FOR SELECT
  USING (user_id = auth.uid());

-- Политика для создания логов
CREATE POLICY "Users can create own logs"
  ON door_logs FOR INSERT
  WITH CHECK (user_id = auth.uid());
```

## Альтернатива: Hasura Cloud

Если нужен более мощный GraphQL:

1. Создайте аккаунт на [hasura.io](https://hasura.io)
2. Создайте новый проект
3. Подключите PostgreSQL базу данных
4. Импортируйте схему из `schema.sql`
5. Hasura автоматически создаст GraphQL API

## Альтернатива: Собственный сервер

Для полного контроля можно развернуть собственный сервер:

### Node.js + Apollo Server

```bash
npm init -y
npm install apollo-server graphql pg
```

Создайте файл `server.js`:

```javascript
const { ApolloServer, gql } = require('apollo-server');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: 'postgresql://user:password@localhost:5432/intercom_db'
});

const typeDefs = gql`
  type User {
    id: ID!
    phone: String!
    apartment_number: String!
  }
  
  type DoorLog {
    id: ID!
    user_id: String!
    action: String!
    timestamp: String!
  }
  
  type Mutation {
    login(phone: String!, password: String!): AuthPayload
    openDoor(userId: String!): DoorLog
  }
  
  type AuthPayload {
    token: String!
    user: User!
  }
`;

// Resolvers implementation...

const server = new ApolloServer({ typeDefs, resolvers });
server.listen().then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`);
});
```

## Тестирование

После настройки backend:

1. Проверьте подключение через Postman или GraphQL Playground
2. Протестируйте запросы:
   - Login mutation
   - Open door mutation
   - Get door logs query

## Безопасность для продакшена

⚠️ **Важно**: Текущая конфигурация для демо. Для продакшена:

1. Используйте bcrypt для хеширования паролей
2. Настройте JWT токены с истечением срока
3. Включите HTTPS
4. Настройте CORS правильно
5. Добавьте rate limiting
6. Настройте мониторинг и логирование
