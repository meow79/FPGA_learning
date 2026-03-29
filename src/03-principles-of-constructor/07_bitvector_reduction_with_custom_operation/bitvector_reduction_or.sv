// Для свёртки битвектора дизъюнкцией, реализованной через стрелку Пирса, можно запустить следующий скрипт из директории с этим файлом:
// make -f ../../Makefile SOURCES="../01_peirce_arrow_operations/disjunction.sv ../../02-combination-logic/exercises/peirce_arrow.sv ./bitvector_reduction_or.sv" TOPMODULE=bitvector_reduction_or

// Вообще, файл можно скомпилировать с любым другим файлом, содержащим какую-то реализацию модуля disjunction

module bitvector_reduction_or #(
  parameter int SIZE = 8
) (
  input logic [SIZE-1:0] bitvector,
  output logic res
);
  logic [SIZE-1:0] temp_res;

  assign temp_res[0] = bitvector[0];
  assign res = temp_res[SIZE - 1];

  genvar i;
  generate
    for (i = 1; i < SIZE; ++i)
      disjunction my_or(
        .a(temp_res[i - 1]),
        .b(bitvector[i]),
        .res(temp_res[i])
      );
  endgenerate
endmodule
