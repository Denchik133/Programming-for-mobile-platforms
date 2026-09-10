# Архітектурне порівняння Android та iOS

## 1. Мета роботи

Метою роботи є порівняння архітектур мобільних платформ **Android** та **iOS**, щоб новий розробник команди міг зрозуміти основні рівні операційних систем, їх призначення та відмінності у життєвому циклі екранів.

Android побудований як Linux-based програмний стек, у якому між застосунком і ядром розташовані Android Runtime, системні бібліотеки, HAL та API framework. ([Android Developers][1])

iOS використовує багаторівневу архітектуру, у якій вищі рівні спираються на системні служби та низькорівневі механізми. Традиційне архітектурне представлення iOS включає **Cocoa Touch, Media, Core Services та Core OS**. ([Apple Developer][2])

# 2. Архітектура Android

Основні компоненти Android можна представити як стек від апаратного рівня до застосунку.

```mermaid
flowchart TB
    A["Застосунок Android<br/>Kotlin / Java / C++"]
    B["Android API Framework<br/>Activity Manager<br/>View System<br/>Notification Manager<br/>Content Providers"]
    C["Android Runtime (ART)<br/>Core Libraries"]
    D["Native C/C++ Libraries<br/>Graphics, Media, SQLite та ін."]
    E["Hardware Abstraction Layer (HAL)<br/>Camera, Bluetooth, Sensors"]
    F["Linux Kernel<br/>Пам'ять, процеси, драйвери, безпека"]

    A --> B
    B --> C
    B --> D
    B --> E
    C --> F
    D --> F
    E --> F
```

### Основні рівні Android

| Рівень                     | Призначення                                      | Приклади                                                               |
| -------------------------- | ------------------------------------------------ | ---------------------------------------------------------------------- |
| **Застосунок**             | Код конкретного мобільного застосунку            | Kotlin, Java, C++, Jetpack                                             |
| **Android API Framework**  | Високорівневі API для створення застосунків      | Activity Manager, View System, Notification Manager, Content Providers |
| **Android Runtime (ART)**  | Виконання коду застосунків                       | DEX, JIT/AOT-компіляція, Garbage Collection                            |
| **Native C/C++ Libraries** | Низькорівневі системні можливості                | графіка, мультимедіа, SQLite                                           |
| **HAL**                    | Стандартизований доступ до апаратних можливостей | камера, Bluetooth, сенсори                                             |
| **Linux Kernel**           | Базовий рівень ОС                                | процеси, пам'ять, драйвери, безпека                                    |

Android Runtime (ART) відповідає за виконання застосунків, а Android використовує DEX-байткод та механізми JIT/AOT-компіляції. HAL надає стандартизовані інтерфейси для роботи з апаратними компонентами. Нижнім рівнем є Linux Kernel, який забезпечує базові механізми роботи з пам'яттю, потоками та апаратними драйверами. ([Android Developers][1])

Окремою особливістю Android є компонентна модель застосунків. Застосунок працює у власному Linux-процесі та ізольованому середовищі безпеки. ([Android Developers][3])

# 3. Архітектура iOS

Архітектуру iOS доцільно розглядати як стек системних рівнів, де кожен вищий рівень використовує можливості нижчих.

```mermaid
flowchart TB
    A["Застосунок iOS<br/>Swift / Objective-C"]
    B["Cocoa Touch / Application Frameworks<br/>SwiftUI, UIKit, AppKit-подібні API"]
    C["Media<br/>Core Graphics, Core Animation, AVFoundation"]
    D["Core Services<br/>Foundation, Core Foundation, Core Data, Core Location"]
    E["Core OS<br/>Kernel, File System, Networking, Security, Power Management"]
    F["Апаратне забезпечення"]

    A --> B
    B --> C
    B --> D
    C --> D
    D --> E
    E --> F
```

### Основні рівні iOS

| Рівень                                   | Призначення                                 | Приклади                                                    |
| ---------------------------------------- | ------------------------------------------- | ----------------------------------------------------------- |
| **Застосунок**                           | Логіка конкретного застосунку               | Swift, Objective-C                                          |
| **Cocoa Touch / Application Frameworks** | Побудова інтерфейсу та взаємодія з системою | SwiftUI, UIKit                                              |
| **Media**                                | Графіка, анімація, аудіо та відео           | Core Graphics, Core Animation, AVFoundation                 |
| **Core Services**                        | Фундаментальні системні сервіси             | Foundation, Core Foundation, Core Data, Core Location       |
| **Core OS**                              | Низькорівневі функції операційної системи   | ядро, файлова система, мережа, безпека, керування живленням |
| **Апаратне забезпечення**                | Фізичні компоненти пристрою                 | CPU, GPU, камера, сенсори                                   |

Apple описує Cocoa Touch як application-framework layer iOS. Нижче розташовуються Media та Core Services, а Core OS містить ядро, файлову систему, мережеву інфраструктуру, механізми безпеки, керування живленням та драйвери. ([Apple Developer][2])

У сучасній розробці важливими точками входу до UI є **SwiftUI** та **UIKit**. Для UIKit Apple використовує scene-based модель, у якій окремий `UIScene` представляє одну інстанцію інтерфейсу застосунку. ([Apple Developer][4])