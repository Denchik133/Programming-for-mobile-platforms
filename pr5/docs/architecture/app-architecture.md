
# Архітектура застосунку Widget Store

## 1. Загальна архітектура

Застосунок побудований на Flutter із використанням компонентного підходу. Головний екран `HomeScreen` відображає віджети профілю, лічильника та каталогу товарів. Клас `AppState` на основі `ChangeNotifier` зберігає стан кошика й обраного.

```mermaid
flowchart TD
    A[WidgetsShowcaseApp] --> B[HomeScreen]
    B --> C[ProfileWidget]
    B --> D[AnimatedCounter]
    B --> E[ProductCard]
    B --> F[AppState]
    E --> G[CustomButton]
    E --> F
    F --> H[Кошик]
    F --> I[Обране]
    B --> J[AppTheme]
    J --> K[AppColors]
```

## 2. Керування станом

`AppState` успадковує `ChangeNotifier` і надає методи для додавання товарів до кошика, видалення товарів, очищення кошика та перемикання обраного. Для відображення лічильників у верхній панелі використовується `AnimatedBuilder`.

```mermaid
flowchart TD
    A[Дія користувача] --> B{Дія}
    B -->|Додати товар| C[addToCart]
    B -->|Обране| D[toggleFavorite]
    C --> E[notifyListeners]
    D --> E
    E --> F[AnimatedBuilder]
    F --> G[Оновлення лічильника]
```

## 3. Організація коду

- `lib/main.dart` — точка входу та головний екран.
- `lib/models/` — моделі користувача й товару.
- `lib/utils/` — тема, кольори та керування станом.
- `lib/widgets/` — повторно використовувані UI-компоненти.
- `test/` — автоматизовані тести віджетів і стану застосунку.
