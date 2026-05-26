# PetMil

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-blue?style=flat-square&logo=apple" />
  <img src="https://img.shields.io/badge/Swift-5-orange?style=flat-square&logo=swift" />
  <img src="https://img.shields.io/badge/UIKit-Code-purple?style=flat-square" />
  <img src="https://img.shields.io/badge/Architecture-MVP-green?style=flat-square" />
  <img src="https://img.shields.io/badge/Status-In_Development-yellow?style=flat-square" />
</p>

<p align="center">
  Pet-проект — iOS-приложение для отображения погоды.<br/>
  Кодовая вёрстка, модульная MVP-архитектура, CoreData.
</p>

---

## Возможности

- Отображение текущей погоды (температура, описание, город)
- Модульная архитектура с Assembly-паттерном
- Полностью кодовая вёрстка (без Storyboard)

> Проект находится в активной разработке — новые фичи добавляются по мере развития.

## Стек технологий

- **Язык:** Swift 5
- **UI:** UIKit (programmatic layout)
- **Архитектура:** MVP (Model-View-Presenter)
- **Хранение данных:** CoreData
- **DI:** Assembly-паттерн (ручная сборка модулей)

## Структура проекта

```
PetMil/
├── Modules/
│   └── Weather/
│       ├── WeatherAssembly.swift      # Сборка модуля
│       ├── WeatherModels.swift        # Модели данных
│       ├── WeatherPresenter.swift     # Бизнес-логика
│       └── WeatherViewController.swift # UI
├── Helpers/
│   ├── String+Helpers.swift           # Расширения строк
│   └── UIView+Helpers.swift           # Расширения UI
├── PetMil.xcdatamodeld                # CoreData модель
├── AppDelegate.swift
└── SceneDelegate.swift
```

## Требования

- iOS 13.0+
- Xcode 14+

## Запуск

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/EmilAxme/PetMil.git
   ```
2. Откройте `PetMil.xcodeproj` в Xcode
3. Запустите на симуляторе или устройстве (⌘R)

## Автор

**Emil** — [@EmilAxme](https://github.com/EmilAxme)
