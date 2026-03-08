    .data

buf:             .byte  31, '_______________________________'

const_newline:   .word  0x0a
const_space:     .word  0x20

const_a_neg:     .word  -97
const_z:         .word  122
const_A_neg:     .word  -65
const_Z:         .word  90

space_seen:      .word  1

input_addr:      .word  0x80
output_addr:     .word  0x84

    .text
    .org 0x100

    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

_start:
    read_line

    title

    write_output

    halt

    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

read_line:
    lit buf a!               \ a for output
    @p input_addr b!         \ b for input
read_line_while:
    @b lit 255 and           \ cur_sym:[]

    dup                      \ cur_sym:cur_sym:[]
    @p const_newline xor     \ check whether symbol is newline character
    if read_line_finish

    a lit -31 +
    if error

    lit 1 a + a!

    write_first_byte

    read_line_while ;
read_line_finish:
    drop                     \ []

    a
    lit buf a!

    write_first_byte
    ;


    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

title:
    lit buf a!               \ a for input

    @+ lit 255 and >r          \ input_remaining:[]
title_while:
    @ lit 255 and dup        \ cur_sym:cur_sym:input_remaining:[]

    \ branch if cur_sym is space
    @p const_space xor
    if space_seen_set

    \ branch if space was encountered
    @p space_seen lit -1 +
    if check_higher_a

    check_higher_A ;


    \ set space_seen and continue
space_seen_set:
    lit 1 !p space_seen
    drop
    title_while_end ;

check_higher_a:
    dup                      \ cur_sym:cur_sym:input_remaining:[]
    @p const_a_neg +         \ cur_sym - const_a:cur_sym:input_remaining:[]
    -if check_lower_z        \ branch if cur_sym >= const_a
    drop
    continue ; ;
check_lower_z:
    dup inv lit 1 +          \ -cur_sym:cur_sym:input_remaining:[]
    @p const_z +             \ const_z - cur_sym:cur_sym:input_remaining:[]
    -if capitalize_char      \ branch if cur_sym <= const_z
    drop
    continue ; ;

check_higher_A:
    dup                      \ cur_sym:cur_sym:input_remaining:[]
    @p const_A_neg +         \ cur_sym - const_A:cur_sym:input_remaining:[]
    -if check_lower_Z        \ branch if cur_sym >= const_A
    drop
    continue ; ;
check_lower_Z:
    dup inv lit 1 +          \ -cur_sym:cur_sym:input_remaining:[]
    @p const_Z +             \ const_Z - cur_sym:cur_sym:input_remaining:[]
    -if lowercase_char       \ branch if cur_sym <= const_Z
    drop
    continue ; ;

capitalize_char:
    lit -32 +                \ cur_sym-32:input_remaining:[]
    write_first_byte
    continue ;

lowercase_char:
    lit 32 +
    write_first_byte

continue:
    lit 0 !p space_seen
title_while_end:

    lit 1 a + a!             \ move pointer a -> a + 1

    next title_while 
    ;
title_finish:
    ;

    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

write_output:
    @p output_addr b!        \ b for output
    lit buf a!               \ a for input

    @+ lit 255 and
    lit -1 + >r
write_output_while:
    @+ lit 255 and           \ cur_sym:[]

    !b                       \ []

    next write_output_while
    ;

    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    \ since current arch is little-endian, i.e., mem[0x00]=0x0f, mem[0x01]=0x0e, mem[0x02]=0x0d, mem[0x03]=0x0c
    \ will become 0x0c0d0e0f on read from address 0x00
write_first_byte:
    lit 0xffffff00 @         \ a_value:mask:input:[]

    and                      \ masked_value:input:[]
    xor !                    \ rewrite first byte
    ;

    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

error:
    @p output_addr b!
    lit -858993460 !b        \ write error to output
    halt
