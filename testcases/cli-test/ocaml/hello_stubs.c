#include <stdio.h>
  #include <caml/mlvalues.h>
  #include <caml/memory.h>

  CAMLprim value
  caml_print_hello (value unit)
  {
      CAMLparam1(unit);
  
      printf("Hello world!\n");
      fflush(stdout);
  
      CAMLreturn (Val_unit);
  }
