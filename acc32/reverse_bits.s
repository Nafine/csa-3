    .data

input_addr:      .word  0x80
output_addr:     .word  0x84
const_1:         .word  0x01
n:               .word  0
result:          .word  0
inv:             .word  0
counter:         .word  32

    .text

_start:
    load         input_addr
    load_acc
    store        n
    and          const_1
    store        inv
    jmp          inverse

inverse:
inverse_begin:
    load         result
    shiftl       const_1
    store        result

    load         n
    and          const_1
    or           result
    store        result

    load         n
    shiftr       const_1
    store        n

    load         counter
    sub          const_1
    store        counter
    beqz         inverse_end
    jmp          inverse_begin
inverse_end:

    load         result
    store_ind    output_addr

    halt
