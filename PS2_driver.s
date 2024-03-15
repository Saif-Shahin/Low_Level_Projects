
.global _start
_start:
        bl      input_loop
end:
        b       end

//VGA Driver
.equ PIXEL_BUFFER, 0xC8000000
.equ CHARACTER_BUFFER, 0XC9000000
.equ PS2_DATA_REG, 0xFF200100

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

@ TODO: insert PS/2 driver here.

.global read_PS2_data_ASM
read_PS2_data_ASM:
    push {r4, lr}               // Save R4 and LR

    ldr r4, =PS2_DATA_REG       // Load the PS2_DATA_REG address into R4
    ldr A2, [r4]                // Load the value at the address in R4 (PS2_DATA_REG) into R1
    and A2, A2, #0x8000         // Check RVALID bit: AND R1 with 0x8000
    cmp A2, #0                  // Compare result with 0
    beq not_valid               // If zero, the RVALID bit is not set, branch to not_valid

    ldrb A2, [r4]               // Load the byte from PS2_DATA_REG into R1
    strb A2, [A1]               // Store the byte in R1 at the address in R0 (data)
    mov A1, #1                  // Set return value to 1 (success)
    b end_read_PS2_data_ASM     // Branch to end

not_valid:
    mov A1, #0                  // Set return value to 0 (failure)

end_read_PS2_data_ASM:
    pop {r4, pc}                // Restore R4 and return

// END OF PS/2

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}