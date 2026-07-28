# Изучение программирования FPGA #
## Содержимое репозитория ##
Репозиторий содержит решения задач из некоторых модулей курса по FPGA (страница курса: https://lamagraph.github.io/intro-to-fpga-with-clash/index.html).
Большинство задач требуют написания программ на языке SystemVerilog.

Решения к задачам из модулей курса 2–4 были добавлены в рамках учебной практики второго семестра на Матмехе СПбГУ.

Задачи из остальных модулей были решены во время летней школы программирования на Матмехе СПбГУ 2026.

## Структура проекта ##
Число в начале имени папки в директории `src/` соответствует номеру модуля курса, где размещены условия задач, для которых в этой папке приведены решения.
```
src/
├── 01-basic-environment            # hello_world.sv
|
├── 02-combination-logic
│   ├── exercises                   # Выполненные задачи из 2 модуля курса
│   ├── adder_logic_1_bit.sv   ──┐
│   ├── adder_logic_1_bit_tb.sv  |─ # Код на SystemVerilog, переписанный со страниц курса
│   └── testbenches            ──┘    с целью ознакомления с языком
|
├── 03-principles-of-constructor
│   ├── 01_peirce_arrow_operations
│   ├── 02_sheffer_stroke_operations
│   ├── 04_adder_k_n_bit_numbers
│   ├── 05_adder_k_int_numbers
│   ├── 06_bitvector_reduction
│   ├── 07_bitvector_reduction_with_custom_operation
│   └── tests_for_01_and_02_tasks
|
│── 04-mux-demux
|   ├── 01_mux_4to1_logic
|   ├── 02_mux_2to1_impl.sv
|   ├── 03_lut_peirce_arrow
|   └── 04_ternary_relation
│
├── 05-types
│   ├── 01_byte_mult_double
│   ├── 02_floats_sum
│   ├── 03_float_mult_byte_extended
│   ├── 04_scalar_product
│
├── 06-sequential-logic
│   ├── 01_nor_reduce        # Решения к первой и четвёртой задачам 6 модуля
│   ├── 02_min_max_tracker
│   └── 03_zero_one_counter
│
├── 07-bus
│   ├── 01_merge_parallel
│   ├── 02_serial_1bit_adder
│   ├── 03_pairwise
│   └── 04-windowed
│
├── 08-cocotb
│   ├── 01_merge_parallel_test ──┐
│   ├── 02_serial_adder_test     |─ # Тесты к решённым задачам из 7 модуля (требуются в задаче 2 восьмого модуля)
│   ├── 03_pairwise_test         |
│   └── 04_windowed_test       ──┘
│
└── Makefile    # Используется для запуска тестов к различным решениям задач
```
