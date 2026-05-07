.data
.org 0x100
io_in:    .word 0x80
io_out:   .word 0x84
stk_top:  .word 0x1000

num_buf:  .byte '__________'
src_buf:  .byte '_________________________________'
src_len:  .word 0
spec_cnt: .word 1
dst_buf:  .byte '_____________________'


    .text
    .org 0x200
_start:
    movea.l stk_top, A7
    movea.l (A7), A7

    movea.l io_in, A0
    movea.l (A0), A0
    movea.l io_out, A1
    movea.l (A1), A1

    jsr slurp
    jsr render
    jsr emit
    halt

slurp:
    movea.l src_len, A4
    movea.l src_buf, A3
    movea.l spec_cnt, A5
slurp_next:
    move.b (A0), D7
    cmp.b 0x0A, D7
    beq slurp_done

    cmp.l 0x20, (A4)
    beq err_overflow
    add.l 1, (A4)

    move.b D7, (A3)+
    cmp.b 0x25, D7
    bne slurp_next

    add.l 1, (A5)
    jmp slurp_next
slurp_done:
    sub.l 1, (A5)
    move.b 0, (A3)
    rts

render:
    link A6, -1
    movea.l spec_cnt, A2
    movea.l src_buf, A3
    movea.l dst_buf, A5
render_step:
    move.b (A3)+, -1(A6)
    cmp.b 0, -1(A6)
    beq render_done

    cmp.b 0x25, -1(A6)
    beq render_spec

    move.b -1(A6), (A5)+
    jmp render_step

render_spec:
    sub.l 1, (A2)
    move.b (A3)+, -1(A6)

    cmp.b 0x64, -1(A6) ; %d
    beq spec_plain

    cmp.b 0x2D, -1(A6) ; %-Nd
    beq spec_left

    jmp spec_right

spec_plain:
    jsr read_num
    jsr write_num
    jmp render_step

spec_left:
    move.l 0, D0
    jsr read_width
    move.l D0, D2

    jsr read_num
    jsr write_num

    sub.l D1, D2
    ble render_step
    jsr pad_blanks
    jmp render_step

spec_right:
    move.l -1(A6), D0
    sub.l 0x30, D0
    jsr read_width
    move.l D0, D2

    jsr read_num

    sub.l D1, D2
    ble spec_right_emit
    jsr pad_blanks
spec_right_emit:
    jsr write_num
    jmp render_step

render_done:
    move.b 0, (A5)+
    unlk A6
    rts

pad_blanks:
    move.b 0x20, (A5)+
    sub.l 1, D2
    bne pad_blanks
    rts

read_width:
    move.l 0, D5
read_width_step:
    move.b (A3)+, D5
    cmp.b 0x64, D5
    beq read_width_done

    sub.b 0x30, D5
    mul.l 10, D0
    add.l D5, D0
    jmp read_width_step
read_width_done:
    rts

read_num:
    move.l 0, D0 ; value
    move.l 0, D1 ; digit count
    move.l 0, D4 ; sign flag
    move.l 0, D3
    movea.l num_buf, A4
read_num_step:
    move.b (A0), D3
    cmp.b 0x0A, D3
    beq read_num_done

    move.b D3, (A4)+
    add.l 1, D1

    cmp.b 0x2D, D3
    bne read_num_digit

    move.b 1, D4
    jmp read_num_step
read_num_digit:
    sub.b 0x30, D3
    cmp.l 9, D3
    bgt err_malformed
    cmp.l 0, D3
    bmi err_malformed

    mul.l 10, D0
    add.l D3, D0

    cmp.b 1, D4
    beq read_num_check_neg

    cmp.l 0, D0
    bmi err_malformed
    cmp.l 0x7FFFFFFF, D0
    bgt err_malformed
    jmp read_num_step
read_num_check_neg:
    cmp.l 0x80000000, D0
    beq read_num_step
    bpl err_malformed
    blt err_malformed
    jmp read_num_step
read_num_done:
    cmp.l 0, D1
    beq err_malformed
    rts

write_num:
    move.l D1, D6
    movea.l num_buf, A4
write_num_step:
    move.b (A4)+, (A5)+
    sub.l 1, D6
    bne write_num_step
    rts

emit:
    movea.l dst_buf, A2
emit_step:
    move.b (A2)+, D7
    cmp.b 0, D7
    beq emit_done
    move.b D7, (A1)
    jmp emit_step
emit_done:
    rts

err_overflow:
    move.l -1, (A1)
    halt

err_malformed:
    movea.l spec_cnt, A3
    move.l -1, (A1)

    move.l (A3), D0
    beq err_done
err_drain:
    move.b (A0), D7
    move.b D7, (A1)

    cmp.b 0x25, D7
    bne err_drain_check
    add.l 1, D0
err_drain_check:
    cmp.b 0x0A, D7
    bne err_drain

    sub.l 1, D0
    bne err_drain
err_done:
    halt
