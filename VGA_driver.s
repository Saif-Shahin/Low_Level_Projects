.global _start
_start:
        bl      draw_test_screen
end:
        b       end
@ TODO: Insert VGA driver functions here:
.equ PIXEL_BUFFER, 0xC8000000
.equ CHARACTER_BUFFER, 0XC9000000

.global VGA_draw_point_ASM
VGA_draw_point_ASM:
    push {r4, lr} 

    cmp A1, #0 //A1 is x
    blt endVGA_draw_point_ASM
    cmp A2, #0 //A2 is y
    blt endVGA_draw_point_ASM
	mov r4, #300 
	add r4, r4, #19 // Store 319 into R8
	cmp A1, r4 // If x is greater than 319, x is invalid 
    bgt endVGA_draw_point_ASM
    cmp A2, #239
    bgt endVGA_draw_point_ASM

    lsl A2, A2, #10 //left shift y by 10
    lsl A1, A1, #1 //left shift x by 1
    orr A1, A1, A2 //replace with add?
    ldr A2, =PIXEL_BUFFER
    add A1, A1, A2 //A1 now represents the offset at the pixe buffer for c,y pixel. possible bug TRY ORR
    strh A3, [A1] //meant to store A3 (color) into the correct location. maybe I should use bit masking.

endVGA_draw_point_ASM:
    pop {r4, pc}
	
	
.global VGA_clear_pixelbuff_ASM
VGA_clear_pixelbuff_ASM:
    push {r4-r6, lr}

    mov r4, #0
loop_y:
    mov r5, #0
loop_x:
    mov A1, r5
    mov A2, r4
    mov A3, #0
    bl VGA_draw_point_ASM
    add r5, r5, #1
    cmp r5, #320
    blt loop_x

    add r4, r4, #1
    cmp r4, #240
    blt loop_y

    pop {r4-r6, pc}
	

.global VGA_write_char_ASM
VGA_write_char_ASM:
    push {r4, lr}

    cmp A1, #0
    blt endVGA_write_char_ASM
    cmp A2, #0
    blt endVGA_write_char_ASM
    cmp A1, #79
    bgt endVGA_write_char_ASM
    cmp A2, #59
    bgt endVGA_write_char_ASM

    lsl A2, A2, #7
    orr A1, A1, A2 //POSSIBLE BUG
    ldr A2, =CHARACTER_BUFFER
    add A1, A1, A2
    strb A3, [A1]

endVGA_write_char_ASM:
    pop {r4, pc}
	

.global VGA_clear_charbuff_ASM
VGA_clear_charbuff_ASM:
    push {r4-r5, lr}

    mov r4, #0
loop_y_char:
    mov r5, #0
loop_x_char:
    mov A1, r5
    mov A2, r4
    mov A3, #0
    bl VGA_write_char_ASM
    add r5, r5, #1
    cmp r5, #80
    blt loop_x_char

    add r4, r4, #1
    cmp r4, #60
    blt loop_y_char

    pop {r4-r5, pc}




//R=ENDOFDRIVERS
draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071