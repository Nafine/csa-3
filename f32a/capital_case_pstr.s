    .data

buf:             .byte  32, '________________________________'
actual_buf_size: .word  0
max_size_dec:    .word  -33
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
    lit buf lit 1 + b!       \ b for buf address
    lit 1                    \ shift:[]
    @ lit 255 and            \ input_size:shift:[]
read_line_while:
    dup                      \ input_size:input_size:shift:[]
    if error                 \ input_size:shift:[]

    @ lit 255 and            \ cur_sym:input_size:shift:[]

    dup                      \ cur_sym:cur_sym:input_size:shift:[]
    @p const_newline xor     \ check whether symbol is newline character
    if read_line_finish      \ finish reading if symbol was newline character

    !b                       \ input_size:shift:[]

    lit -1 +                 \ input_size - 1:shift:[]

    over lit 1 +             \ shift + 1:input_size - 1:[]

    dup                      \ shift + 1:shift + 1:input_size:[]
    lit buf + b!             \ move pointer, shift:input_size:[]

    over                     \ input_size:shift[]

    read_line_while ;
read_line_finish:
    drop                     \ input_size:shift:[]
    drop                     \ shift:[]

    lit -1 +                 \ shift - 1:[]

    lit buf a!

    rewrite_size
    ;

rewrite_size:
    lit buf b!

    @ lit 0xffffff00         \ mask:first_byte:size:[]
    and                      \ masked_byte:size:[]
    xor !b                   \ rewrite first byte
    ;

write_output:
    @p output_addr b!
    @+ lit 255 and           \ buf_size:[]
write_output_while:
    dup                      \ buf_size:buf_size:[]
    if write_output_finish   \ buf_size:[]

    @+ lit 255 and           \ cur_sym:buf_size:[]

    !b                       \ buf_size:[]

    lit -1 +                 \ buf_size - 1:[]

    write_output_while ;

write_output_finish:
    drop                     \ remove remaining zero counter
    ;

error:
    @p output_addr b!
    lit -1 !b                \ write -1 to output
    halt