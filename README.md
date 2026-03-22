# Изучение программирования FPGA #
## Содержимое репозитория ##
Репозиторий содержит выполненные упражнения из некоторых модулей курса по FPGA (страница курса: https://lamagraph.github.io/intro-to-fpga-with-clash/index.html).
Упражнения заключаются в написании программ на языке SystemVerilog.

Решения новых упражнений будут добавляться по мере готовности.

## Структура проекта ##
```
src/
├── 01-basic-environment            # hello_world.sv
|
├── 02-combination-logic
│   ├── exercises                   # Выполненные упражения из 2 модуля курса
│   │   └── testbenches             # Тестбенчи к выполненным упражнениям
|   |   └── build_and_test_all.sh   # Тест для CI для всех упражнений второго модуля
│   ├── adder_logic_1_bit.sv   ──┐
│   ├── adder_logic_1_bit_tb.sv  |─ # Код на SystemVerilog, переписанный со страниц курса
│   └── testbenches            ──┘    с целью ознакомления с языком
|
└── 03-principles-of-constructor    # Выполненные упражения из 3 модуля курса
    ├── 01_peirce_arrow_operations  # Первое упражнение
    │   └── testbenches
    └── build_and_test_all.sh       # Тест для CI для всего третьего модуля

```
