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
│   ├── exercises                   # Выполненные упражнения из 2 модуля курса
│   │   └── testbenches             # Тестбенчи к выполненным упражнениям
|   |   └── build_and_test_all.sh   # Тест для CI для всех упражнений второго модуля
│   ├── adder_logic_1_bit.sv   ──┐
│   ├── adder_logic_1_bit_tb.sv  |─ # Код на SystemVerilog, переписанный со страниц курса
│   └── testbenches            ──┘    с целью ознакомления с языком
|
├── 03-principles-of-constructor    # Выполненные упражнения из 3 модуля курса
│   ├── 01_peirce_arrow_operations
│   ├── 02_sheffer_stroke_operations
│   ├── 04_adder_k_n_bit_numbers
│   ├── 05_adder_k_int_numbers
│   ├── 06_bitvector_reduction
│   ├── 07_bitvector_reduction_with_custom_operation
│   ├── build_and_test_all.sh       # Тест для CI для первых двух упражнений третьего модуля
│   └── tests_for_01_and_02_tasks
|
└── 04-mux-demux                    # Выполненные упражнения из 4 модуля курса
    ├── 01_mux_4to1_logic
    ├── 02_mux_2to1_impl.sv
    ├── 03_lut_peirce_arrow
    ├── 04_ternary_relation
    ├── build_and_test_all.sh       # Тест для CI для первого и четвёртого упражнений четвёртого модуля
    └── mux_2to1.sv                 # Код мультиплексора 2:1, который нужен для второго и четвёртого заданий
```
