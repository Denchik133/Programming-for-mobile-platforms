# Практична робота №5 — Розробка віджетів у Flutter

## Опис проєкту

Навчальний Flutter-застосунок для демонстрації створення повторно використовуваних віджетів, анімацій, керування станом і тестування інтерфейсу.

Проєкт розроблено в межах дисципліни «Програмування мобільних платформ».

**Вебверсія:** [Відкрити застосунок на GitHub Pages](https://denchik133.github.io/Programming-for-mobile-platforms/)

**Репозиторій:** [Programming-for-mobile-platforms на GitHub](https://github.com/Denchik133/Programming-for-mobile-platforms)

## Мета роботи

- Створити власні `StatelessWidget` і `StatefulWidget`.
- Реалізувати повторно використовувані інтерактивні компоненти.
- Використати анімації для покращення взаємодії з користувачем.
- Реалізувати керування станом за допомогою `ChangeNotifier`.
- Написати автоматизовані тести.
- Підготувати адаптивну вебверсію та розгорнути її на GitHub Pages.

## Реалізована функціональність

- **ProfileWidget** — відображення профілю користувача.
- **CustomButton** — повторно використовувана кнопка з різними варіантами оформлення та станами.
- **AnimatedCounter** — лічильник із плавними анімаціями.
- **ProductCard** — інтерактивна картка товару з анімацією, можливістю додавання до кошика та керуванням обраним.
- **Каталог товарів** — адаптивне відображення товарів.
- **Component Showcase** — окремий екран для демонстрації створених компонентів.
- **AppState** — керування кошиком і вибраними товарами за допомогою `ChangeNotifier`.
- **Автоматизоване тестування** — перевірка віджетів, взаємодії користувача та логіки керування станом.
- **Веброзгортання** — автоматична збірка й публікація застосунку через GitHub Actions.

## Технології

- Flutter
- Dart
- Material Design 3
- `StatelessWidget` і `StatefulWidget`
- `AnimationController` та анімації Flutter
- `ChangeNotifier`
- Flutter Test
- Git і GitHub
- GitHub Actions
- GitHub Pages

## Структура проєкту

```text
pr5/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── screens/
│   ├── utils/
│   └── widgets/
├── test/
│   └── widgets/
├── docs/
│   ├── architecture/
│   ├── design/
│   └── screenshots/
├── pubspec.yaml
└── README.md
```

- `lib/models/` — моделі даних.
- `lib/screens/` — екрани застосунку.
- `lib/utils/` — тема, кольори та керування станом.
- `lib/widgets/` — повторно використовувані віджети.
- `test/` — автоматизовані тести.
- `docs/architecture/` — архітектурна документація.
- `docs/design/` — опис дизайн-системи.
- `docs/screenshots/` — скриншоти інтерфейсу.

## Запуск проєкту

Потрібно встановити Flutter SDK та перевірити його доступність:

```bash
flutter --version
flutter doctor
```

Перейдіть до папки проєкту та встановіть залежності:

```bash
cd pr5
flutter pub get
```

Запуск у браузері Chrome:

```bash
flutter run -d chrome
```

## Перевірка якості коду

Статичний аналіз:

```bash
flutter analyze
```

Запуск усіх тестів:

```bash
flutter test
```

Запуск тестів із формуванням звіту про покриття:

```bash
flutter test --coverage
```

Збірка вебверсії:

```bash
flutter build web --base-href /Programming-for-mobile-platforms/
```

## Документація та демонстрація

- **Архітектура:** [Переглянути архітектурну документацію](docs/architecture/app-architecture.md).
- **Дизайн-система:** [Переглянути опис дизайн-системи](docs/design/design-system.md).
- **Скриншоти:** [Головний екран](docs/screenshots/home-screen.png), [каталог товарів](docs/screenshots/product-catalog.png), [кошик та обране](docs/screenshots/cart-and-favorites.png).
- **Figma:** посилання буде додано після створення дизайн-макета.
- **Відеодемонстрація:** посилання буде додано після запису відео тривалістю 2–3 хвилини.

## Авторство

Клименко Денис, Ік-41