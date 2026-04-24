# ObjectPlacer — скрипт размещения объектов для Arma 3

Скрипт позволяет игрокам размещать объекты на карте прямо во время миссии через контекстное меню. Поддерживает категории объектов, предпросмотр, вращение, изменение высоты и удаление.

---

## Состав

```
scripts/
└── objectPlacer/
    ├── objectPlacer.sqf       — основной скрипт (клиентская часть)
    ├── objectList.sqf         — список объектов и категорий
    └── objectPlacerDialog.hpp — диалоговое окно выбора объекта
description.ext
init.sqf
```

---

## Установка

### 1. Скопируй файлы

Скопируй папку `objectPlacer` в папку `scripts` твоей миссии.

---

### 2. description.ext

Подключи диалог и базовые классы. Добавь в `description.ext`:

```cpp
#include "scripts\objectPlacer\objectPlacerDialog.hpp"
```

Если файла `description.ext` нет — создай его в корне папки миссии.

---

### 3. init.sqf

Добавь в `init.sqf` серверные функции и вызов скрипта:

```sqf
if (isServer) then {
    "OBJECT_PLACER_REQUEST" addPublicVariableEventHandler {
        params ["_name", "_value"];
        private _classname = _value select 0;
        private _pos       = _value select 1;
        private _dir       = _value select 2;
        private _obj = createVehicle [_classname, _pos, [], 0, "NONE"];
        _obj setPosATL _pos;
        _obj setDir _dir;
        [_obj] remoteExec ["fnc_addDeleteAction", 0];
    };
    "OBJECT_DELETE_REQUEST" addPublicVariableEventHandler {
        params ["_name", "_value"];
        deleteVehicle _value;
    };
};

if (hasInterface) then {
    execVM "scripts\objectPlacer\objectPlacer.sqf";
};
```

---

### 4. Настройка списка объектов

Открой `scripts\objectPlacer\objectList.sqf` и добавь свои объекты по образцу:

```sqf
objectCategories = [
    [
        "Название категории",
        [
            ["Название объекта", "classname_объекта"],
            ["Ещё объект",       "другой_classname"]
        ]
    ]
];
```

---

### 5. Лимит объектов (по желанию)

В файле `objectPlacer.sqf` найди строку:

```sqf
maxPlacedObjects = 20;
```

И замени `20` на нужное тебе число.

---

## Управление

| Действие | Клавиша |
|---|---|
| Открыть меню выбора объекта | Контекстное меню → «Выбрать объект» |
| Установить объект | ЛКМ |
| Отменить размещение | ПКМ |
| Повернуть влево / вправо | Q / E |
| Поднять / опустить | Колесико мыши |
| Удалить объект | Подойти к объекту → контекстное меню → «Удалить объект» |

---

## Требования

- Arma 3
- Мультиплеер: работает на выделенном сервере

---

## Совместимость

Скрипт не конфликтует с ACE, CBA и другими модами при условии что `description.ext` оформлен корректно.
