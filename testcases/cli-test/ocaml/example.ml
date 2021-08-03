(* 将多个参数合并到一个元组中，但这种方式不能部分求值 *)
let plus3 (a, b, c) =
  a + b + c ;;
(* val plus3 : int * int * int -> int = <fun> *)

print_int (plus3 (1,2,3)) ;;  (* 6- : unit = () *)
