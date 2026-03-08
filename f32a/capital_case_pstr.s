    .data

buf:             .byte  31, '_______________________________'
capitalized_str: .byte  31, '_______________________________'

const_newline:   .word  0x0a
const_space:     .word  0x20

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
    lit 31                   \ buffer_remaining:shift:[]
read_line_while:
    dup                      \ buffer_remaining:buffer_remaining:shift:[]
    if error                 \ buffer_remaining:shift:[]

    @ lit 255 and            \ cur_sym:buffer_remaining:shift:[]

    dup                      \ cur_sym:cur_sym:buffer_remaining:shift:[]
    @p const_newline xor     \ check whether symbol is newline character
    if read_line_finish      \ finish reading if symbol was newline character

    write_first_byte

    lit -1 +                 \ buffer_remaining - 1:shift:[]

    over lit 1 +             \ shift + 1:buffer_remaining - 1:[]

    dup                      \ shift + 1:shift + 1:buffer_remaining:[]
    lit buf + b!             \ move pointer, shift:buffer_remaining:[]

    over                     \ buffer_remaining:shift[]

    read_line_while ;
read_line_finish:
    drop                     \ buffer_remaining:shift:[]
    drop                     \ shift:[]

    lit -1 +                 \ shift - 1:[]

    lit buf b!

    write_first_byte

    lit buf a!
    ;

\ since current arch is little-endian, i.e., mem[0x00]=0x0f, mem[0x01]=0x0e, mem[0x02]=0x0d, mem[0x03]=0x0c 
\ will become 0x0c0d0e0f on read from address 0x00

write_first_byte:
    lit 0xffffff00 @b                       \ b_value:mask:input:[]

    and                      \ masked_value:input:[]
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
