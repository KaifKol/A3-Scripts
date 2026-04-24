# VEM — Vehicle Exterior Manager
**Arma 3 | SQF скрипт | Мультиплеер**

Позволяет игрокам изменять навесное оборудование техники прямо в игре: маскировочные сети, антенны, лестницы, канистры и другие компоненты.  
Изменения видны всем игрокам на сервере (MP-ready).

---

## Структура файлов

```
scripts/VEM/
├── VEM_init.sqf                ← главный файл, настройки
├── VEM_GUI_defines.hpp         ← описание диалога
├── fnc_VEM_briefing.sqf        ← инструктаж для игроков
├── functions/
│   ├── fnc_VEM_action.sqf
│   ├── fnc_VEM_GUI_check.sqf
│   ├── fnc_VEM_condition_check.sqf
│   ├── fnc_VEM_reset.sqf
│   ├── fnc_VEM_update_status.sqf
│   └── fnc_VEM_variable_cleaner.sqf
└── vehicles/
    ├── fnc_VEM_common_setup.sqf
    ├── fnc_VEM_common_comp.sqf
    ├── fnc_VEM_common_comp_check.sqf
    ├── fnc_VEM_common_camo.sqf
    ├── fnc_VEM_common_camo_check.sqf
    ├── fnc_VEM_rebuild_comp_list.sqf
    └── exceptions/
        ├── Blackfoot/
        ├── Gorgon/
        ├── HBPN/
        ├── Marid/
        ├── Nyx/
        ├── Orca/
        └── UGV_rcws/
```

---

## Установка

### 1. Скопируй файлы
Скопируй папку `VEM` в директорию `scripts` своей миссии:
```
мояМиссия.Altis/scripts/VEM/
```

### 2. init.sqf
Добавь в `init.sqf` миссии:
```sqf
if (hasInterface) then {
    [] execVM "scripts\VEM\VEM_init.sqf";
};
```

### 3. description.ext
Добавь в `description.ext` миссии:
```cpp
#include "scripts\VEM\VEM_GUI_defines.hpp"
```

Если в миссии уже есть блок `CfgRemoteExec` — **не создавай второй**, а добавь VEM-строки в существующий:
```cpp
class CfgRemoteExec
{
    class Functions
    {
        mode = 1; jip = 0;

        // ... твои существующие записи ...

        class VEM_applyTexture   { allowedTargets = 0; };
        class VEM_applyAnim      { allowedTargets = 0; };
        class VEM_check_locality { allowedTargets = 2; };
    };
};
```
> Если блока `CfgRemoteExec` нет совсем — создай его как показано выше.

---

## Настройки

Все настройки находятся в начале файла `VEM_init.sqf`:

| Параметр | По умолчанию | Описание |
|---|---|---|
| `VEM_enable_camo` | `false` | Включить вкладку камуфляжа |
| `VEM_enable_components` | `true` | Включить вкладку компонентов |
| `VEM_interaction_distance` | `10` | Дистанция взаимодействия с техникой (метры) |
| `VEM_condition_check_options` | `[2]` | Условия активации (см. ниже) |

### Условия активации (`VEM_condition_check_options`)

| Значение | Условие |
|---|---|
| `[]` | Всегда доступно |
| `[1]` | Рядом должна быть сервисная техника |
| `[2]` | Игрок в зоне маркера `VEM_service_area_N` |
| `[3]` | Рядом FOB (KP Liberation) |

Можно комбинировать: `[1, 2]` — выполняется хотя бы одно условие.

### Зона обслуживания (условие 2)
Создай в редакторе маркер с именем `VEM_service_area_0`.  
Радиус проверки — **50 метров** от центра маркера.  
Маркер можно сделать невидимым: тип `Empty`, цвет `Default`.  
Для нескольких зон используй `VEM_service_area_0`, `VEM_service_area_1`, и т.д.

---

## Инструктаж для игроков (опционально)

Скрипт автоматически добавляет запись в журнал игрока (раздел «Инструктаж»).  
Это происходит автоматически — ничего дополнительно подключать не нужно.

---

## Совместимость

- Работает на выделенном сервере и локальном хосте
- Требует ванильную Arma 3 (без модов)
- Совместим с другими скриптами использующими `CfgRemoteExec` — просто объедини блоки в один

### Техника с отдельными обработчиками (exceptions)
Следующая техника имеет нестандартные конфиги и обрабатывается отдельно:

| Папка | Техника |
|---|---|
| `Gorgon` | Gorgon (все варианты) |
| `Nyx` | Nyx AT / Scout / AA / Cannon |
| `Marid` | Marid (v1 и v2) |
| `HBPN` | Hummingbird (вооружённые варианты) |
| `Blackfoot` | Blackfoot |
| `Orca` | Orca (все варианты) |
| `UGV_rcws` | UGV Stomper RCWS (все стороны) |

---

## Лицензия
Свободное использование и распространение. При публикации модификаций укажи оригинальный источник.
