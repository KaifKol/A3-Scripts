// ============================================================
//  SECTOR CONTROL — sc_init.sqf
//  Главный файл настройки. Только здесь нужно вносить правки.
// ============================================================

// --- ИГРОВЫЕ СТОРОНЫ ---
// Укажите какая игровая сторона соответствует каждой фракции.
// Меняйте только правую часть (WEST / EAST / INDEPENDENT).
SC_SIDE_BLUFOR      = WEST;         // Синие  (НАТО, AAF и т.д.)
SC_SIDE_OPFOR       = EAST;         // Красные (ЦСКА, противник)
SC_SIDE_INDEPENDENT = INDEPENDENT;  // Независимые (партизаны и т.д.)

// --- ЗАДАЧИ ПО ЗАХВАТУ ---
// true  — задача "Захватить сектор" создаётся для каждого сектора автоматически
//         и выполняется когда независимые захватывают зону.
// false — задачи не создаются.
SC_TASKS_ENABLED = true;

// ============================================================
//  НАСТРОЙКА СЕКТОРОВ
//
//  Формат каждой строки:
//  ["имя_триггера", "Название", начальный_владелец, очки_за_захват]
//
//  имя_триггера       — имя триггера из редактора Arma 3
//  Название           — отображаемое название на карте
//  начальный_владелец — SC_SIDE_BLUFOR / SC_SIDE_OPFOR / SC_SIDE_INDEPENDENT / sideEmpty
//  очки_за_захват     — сколько очков получает команда при захвате независимыми
// ============================================================
private _sectors = [
//   Триггер              Название     Владелец        Очки
    ["trigger_alpha",   "Альфа",    SC_SIDE_OPFOR,  5000],
    ["trigger_bravo",   "Браво",    SC_SIDE_OPFOR,  5000],
    ["trigger_charlie", "Чарли",    SC_SIDE_OPFOR,  5000]
];
// ============================================================

{
    _x params [
        ["_trigName", "",        [""]],
        ["_name",     "",        [""]],
        ["_side",     sideEmpty, [sideEmpty]],
        ["_reward",   0,         [0]]
    ];

    private _trig = missionNamespace getVariable [_trigName, objNull];

    if (!isNull _trig) then {
        [_trig, _name, _side, objNull, objNull, objNull, _reward] call compile preprocessFileLineNumbers
            "scripts\sector_control\sc_sector.sqf";
        diag_log format ["[SC] Запущен сектор: '%1' (триггер: %2, очки: %3)", _name, _trigName, _reward];
    } else {
        diag_log format ["[SC] ПРЕДУПРЕЖДЕНИЕ: триггер '%1' не найден. Пропускаем.", _trigName];
    };

} forEach _sectors;
