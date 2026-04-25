    .data

input_addr:      .word  0x80
output_addr:     .word  0x84

    .text

_start:
    lui      t0, %hi(input_addr)             ;  int * input_addr_const = 0x00

    lw       t0, 0(t0)                       ; int input_addr = * input_addr_const

    lw       t1, 0(t0)                       ; int a = *input_addr
    lw       t2, 0(t0)                       ; int b = *input_addr

gcd:
    beqz     t2, gcd_end                     ; while (b != 0) {
    mv       t3, t1                          ; int temp = a
    mv       t1, t2                          ; a = b
    rem      t2, t3, t2                      ; b = temp % b
    j        gcd                             ; }
gcd_abs:
    bgt      t1, zero, gcd_end               ; if a > 0 return a
    lui      t3, -1                          ; temp = -1
    mul      t1, t1, t3                      ; a *= -1
gcd_end:
    lui      t0, %hi(output_addr)            ; int * output_addr_const = 0x04;
    addi     t0, t0, %lo(output_addr)        ; // t0 <- 0x04;

    lw       t0, 0(t0)                       ; int output_addr = *output_addr_const;
    ; // t0 <- *t0;

    sw       t1, 0(t0)                       ; *output_addr_const = acc;
    ; // *t0 = t1;

    halt