.global _start
_start:
        bl      input_loop
end:
        b       end

//A1 is x
//A2 is y
//A3 is color

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
    pop {r4, lr}
    bx lr
	
	
.global VGA_clear_pixelbuff_ASM
VGA_clear_pixelbuff_ASM:
    push {r4-r6, lr}

    mov r4, #0
loop_y:
    mov r5, #0
loop_x:
    mov A1, r5
    mov A2, r4
    ldr A3, =0xbfbfbf //A3 is color
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

// PS/2 Driver
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


//Draw grid test

.global GoL_draw_grid_ASM
GoL_draw_grid_ASM:
    push {r0-r7, lr}           // Save registers r4-r6 and lr

    // Draw horizontal lines
    mov r4, #0                 // Initialize r4 as the y-coordinate
    mov r5, #20                // Set r5 as the y-increment
VGA_draw_line_ASM:
    mov r6, #0                 // Initialize r6 as the x-coordinate
draw_horizontal_line:
    mov A1, r6                 // Set A1 to x-coordinate
    mov A2, r4                 // Set A2 to y-coordinate
    mov A3, #0                 // Set A3 to color (black)
    bl VGA_draw_point_ASM      // Call VGA_draw_point_ASM to draw the point
    add r6, r6, #1             // Increment x-coordinate
    cmp r6, #320               // Compare x-coordinate with 320
    blt draw_horizontal_line   // If x-coordinate is less than 320, loop to draw_horizontal_line

    add r4, r4, r5             // Increment y-coordinate by y-increment (20)
    cmp r4, #240               // Compare y-coordinate with 240
    blt VGA_draw_line_ASM       // If y-coordinate is less than 240, loop to horizontal_lines

    // Draw vertical lines
    mov r6, #0                 // Initialize r6 as the x-coordinate
    mov r5, #20                // Set r5 as the x-increment
vertical_lines:
    mov r4, #0                 // Initialize r4 as the y-coordinate
draw_vertical_line:
    mov A1, r6                 // Set A1 to x-coordinate
    mov A2, r4                 // Set A2 to y-coordinate
    mov A3, #0                 // Set A3 to color (black)
    bl VGA_draw_point_ASM      // Call VGA_draw_point_ASM to draw the point
    add r4, r4, #1             // Increment y-coordinate
    cmp r4, #240               // Compare y-coordinate with 240
    blt draw_vertical_line     // If y-coordinate is less than 240, loop to draw_vertical_line

    add r6, r6, r5             // Increment x-coordinate by x-increment (20)
    cmp r6, #320               // Compare x-coordinate with 320
    blt vertical_lines         // If x-coordinate is less than 320, loop to vertical_lines

    pop {r0-r7, pc}            // Restore registers r4-r6 and return
//end of draw grid test

//draw square//

.global VGA_draw_rect_ASM_y
VGA_draw_rect_ASM:
    push {r0-r7, r9-r12, lr}           // Save registers r4-r6 and lr
	mov r9, A1 //  RECTANGLE ORIGIN Y-COORDINATE
	mov r10, A2 //RECTANGLE ORIGIN X-COORDINATE
    // Draw horizontal lines
    mov r4, r9                 // Initialize r4 as the y-coordinate <--- RECTANGLE ORIGIN Y-COORDINATE
    mov r5, #1                // Set r5 as the y-increment (1 fir shaded in rectangle)
	mov r12, A3 				// rectangle width
	mov r11, A4 //rectangle height

VGA_draw_line_rect_ASM_y:
    mov r6, r10                 // Initialize r6 as the x-coordinate <--- RECTANGLE ORIGIN X-COORDINATE
	add r12, r12, r6
	add r11, r11, r4
draw_horizontal_line_rect_y:
    mov A1, r6                 // Set A1 to x-coordinate
    mov A2, r4                 // Set A2 to y-coordinate
    ldr A3, =0xff2600          // Set A3 to color (pink)
    bl VGA_draw_point_ASM      // Call VGA_draw_point_ASM to draw the point
    add r6, r6, #1             // Increment x-coordinate
    cmp r6, r12               // Compare x-coordinate with r12 <--- RECTANGLE WIDTH
    blt draw_horizontal_line_rect_y   // If x-coordinate is less than 120, loop to draw_horizontal_line

    add r4, r4, r5             // Increment y-coordinate by y-increment (1)
//    cmp r4, r11               // Compare y-coordinate with 140 <--- RECTANGLE HEIGHT
//    blt VGA_draw_line_rect_ASM_y       // If y-coordinate is less than 140, loop to horizontal_lines

    // Draw vertical lines
    mov r6, r10                 // Initialize r6 as the x-coordinate
//    mov r5, #1                // Set r5 as the x-increment
vertical_lines_rect_y:
//    mov r4, #0                 // Initialize r4 as the y-coordinate
draw_vertical_line_rect_y:
    mov A1, r6                 // Set A1 to x-coordinate
    mov A2, r4                 // Set A2 to y-coordinate
    ldr A3, =0xff2600          // Set A3 to color (pink)
    bl VGA_draw_point_ASM      // Call VGA_draw_point_ASM to draw the point
    add r4, r4, #1             // Increment y-coordinate
    cmp r4, r11               // Compare y-coordinate with 140 <--- RECTANGLE HEIGHT
    blt draw_vertical_line_rect_y     // If y-coordinate is less than 140, loop to draw_vertical_line

    add r6, r6, r5             // Increment x-coordinate by x-increment (1)
    cmp r6, r12               // Compare x-coordinate with 320 <--- RECTANGLE WIDTH
    blt vertical_lines_rect_yreset         // If x-coordinate is less than 320, loop to vertical_lines

    pop {r0-r7, r9-r12, pc}   

vertical_lines_rect_yreset:
mov r4, r9
b draw_vertical_line_rect_y


.global VGA_draw_rect_ASM_r
VGA_draw_rect_ASM_r:
    push {r0-r7, r9-r12, lr}           // Save registers r4-r6 and lr
	mov r9, A1 //  RECTANGLE ORIGIN Y-COORDINATE
	mov r10, A2 //RECTANGLE ORIGIN X-COORDINATE
    // Draw horizontal lines
    mov r4, r9                 // Initialize r4 as the y-coordinate <--- RECTANGLE ORIGIN Y-COORDINATE
    mov r5, #1                // Set r5 as the y-increment (1 fir shaded in rectangle)
	mov r12, A3 				// rectangle width
	mov r11, A4 //rectangle height

VGA_draw_line_rect_ASM_r:
    mov r6, r10                 // Initialize r6 as the x-coordinate <--- RECTANGLE ORIGIN X-COORDINATE
	add r12, r12, r6
	add r11, r11, r4
draw_horizontal_line_rect_r:
    mov A1, r6                 // Set A1 to x-coordinate
    mov A2, r4                 // Set A2 to y-coordinate
    ldr A3, =0xFA1F          // Set A3 to color (pink)
    bl VGA_draw_point_ASM      // Call VGA_draw_point_ASM to draw the point
    add r6, r6, #1             // Increment x-coordinate
    cmp r6, r12               // Compare x-coordinate with r12 <--- RECTANGLE WIDTH
    blt draw_horizontal_line_rect_r   // If x-coordinate is less than 120, loop to draw_horizontal_line

    add r4, r4, r5             // Increment y-coordinate by y-increment (1)
//    cmp r4, r11               // Compare y-coordinate with 140 <--- RECTANGLE HEIGHT
//    blt VGA_draw_line_rect_ASM_y       // If y-coordinate is less than 140, loop to horizontal_lines

    // Draw vertical lines
    mov r6, r10                 // Initialize r6 as the x-coordinate
//    mov r5, #1                // Set r5 as the x-increment
vertical_lines_rect_r:
//    mov r4, #0                 // Initialize r4 as the y-coordinate
draw_vertical_line_rect_r:
    mov A1, r6                 // Set A1 to x-coordinate
    mov A2, r4                 // Set A2 to y-coordinate
    ldr A3, =0xFA1F          // Set A3 to color (pink)
    bl VGA_draw_point_ASM      // Call VGA_draw_point_ASM to draw the point
    add r4, r4, #1             // Increment y-coordinate
    cmp r4, r11               // Compare y-coordinate with 140 <--- RECTANGLE HEIGHT
    blt draw_vertical_line_rect_r     // If y-coordinate is less than 140, loop to draw_vertical_line

    add r6, r6, r5             // Increment x-coordinate by x-increment (1)
    cmp r6, r12               // Compare x-coordinate with 320 <--- RECTANGLE WIDTH
    blt vertical_lines_rect_yreset_r         // If x-coordinate is less than 320, loop to vertical_lines

    pop {r0-r7, r9-r12, pc}   

vertical_lines_rect_yreset_r:
mov r4, r9
b draw_vertical_line_rect_r

// end of draw square

.global input_loop
input_loop:
        push {r4-r6, lr}
		bl GoL_draw_board_ASM
		bl VGA_clear_pixelbuff_ASM
		bl GoL_draw_grid_ASM

		mov A1, #100 
		mov A2, #100
		mov A3, #100
		mov A4, #80
//bl VGA_draw_rect_ASM
	bl VGA_draw_rect_ASM


        bl draw_cursor



GoL_draw_board_ASM:

	bl VGA_clear_pixelbuff_ASM
	bl GoL_draw_grid_ASM
	
		//inititializing the squares on the board
			mov A1, #120 
			mov A2, #80
			mov A3, #100
			mov A4, #20
			bl VGA_draw_rect_ASM
			
			mov A1, #100 
			mov A2, #140
			mov A3, #100
			mov A4, #20
			bl VGA_draw_rect_ASM
			
			mov A1, #40 
			mov A2, #140
			mov A3, #20
			mov A4, #60
			bl VGA_draw_rect_ASM
			
			mov A1, #120 
			mov A2, #160
			mov A3, #20
			mov A4, #80
			bl VGA_draw_rect_ASM
			
			
			mov A1, #40 
			mov A2, #40
			mov A3, #40
			mov A4, #40
			bl VGA_draw_rect_ASM_r
			
			mov A1, #80 
			mov A2, #0
			mov A3, #40
			mov A4, #40
			bl VGA_draw_rect_ASM_r
			
			
			mov A1, #30 
			mov A2, #240
			mov A3, #60
			mov A4, #10
			bl VGA_draw_rect_ASM_r
			
			mov A1, #40 
			mov A2, #260
			mov A3, #60
			mov A4, #10
			bl VGA_draw_rect_ASM_r
			

			
			b inf

inf:
b inf
			
			

check_input:
        bl read_PS2_data_ASM
        cmp A1, #1
        bne check_input

        // move cursor
        cmp A2, #'w'
        beq move_up
        cmp A2, #'a'
        beq move_left
        cmp A2, #'s'
        beq move_down
        cmp A2, #'d'
        beq move_right

        // toggle grid state
        cmp A2, #' '
        bne input_loop
        bl toggle_grid_state
        b input_loop

move_up:
        sub r5, r5, #20
        cmp r5, #0
        bge update_cursor
        add r5, r5, #20
        b input_loop

move_left:
        sub r4, r4, #16
        cmp r4, #0
        bge update_cursor
        add r4, r4, #16
        b input_loop

move_down:
        add r5, r5, #20
        cmp r5, #240
        blt update_cursor
        sub r5, r5, #20
        b input_loop

move_right:
        add r4, r4, #16
        cmp r4, #320
        blt update_cursor
        sub r4, r4, #16
        b input_loop

update_cursor:
        bl draw_cursor
        b input_loop

draw_cursor:
        push {r6, lr}
        mov A1, r4
        mov A2, r5
        bl VGA_draw_point_ASM
        pop {r6, pc}

toggle_grid_state:
        push {r6, lr}
        mov A1, r4
        mov A2, r5
        ldr A3, [A1, A2]      // Load grid state at x, y
        eor A3, A3, #1        // Toggle grid state
        str A3, [A1, A2]      // Store the updated state
        pop {r6, pc}


