    .data

buf:             .byte  32, '________________________________'
max_size_dec:    .word  -33
actual_buf_size: .word  0
const_newline:   .word  0x0a
input_addr:      .word  0x80
output_addr:     .word  0x84

    .text

    .org 0x100
_start:
    @p input_addr a!         \ a for input

    read_line

    write_output

    halt

read_line:
    lit buf b!               \ b for buf address
    @ lit 255 and            \ input_size:[]

    dup
    @p max_size_dec +
    -if error
read_line_while:
    dup                      \ input_size:input_size:[]
    if error                 \ input_size:[]

    @ lit 255 and            \ cur_sym:input_size:[]

    dup
    @p const_newline xor     \ check whether symbol is newline character
    if read_line_finish      \ finish reading if symbol was newline character

    !b                       \ input_size:[]

    lit -1 +                 \ input_size - 1:[]

    @p actual_buf_size lit 1 + \ actual_buf_size + 1:input_size:[]

    dup                      \ actual_buf_size + 1:actual_buf_size + 1:input_size:[]
    lit buf + b!             \ actual_buf_size + buf_address:input_size:[]

    !p actual_buf_size       \ input_size:[]

    read_line_while ;
read_line_finish:
    lit buf a!
    ;

write_output:
    @p output_addr b!
    @p actual_buf_size
write_output_while:
    dup
    if write_output_finish

    @+ lit 255 and

    !b

    lit -1 +
    write_output_while ;

write_output_finish:
    ;

error:
    @p output_addr b!
    lit -1 !b
    halt

