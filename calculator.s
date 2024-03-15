.equ SW_ADDR, 0xFF200040
.equ LED_ADDR, 0xFF200000
.equ HEX_ADDR, 0xFF200020
.equ HEX_ADDR1, 0xFF200030

.equ HEX0, 0xFF200020
.equ HEX1, 0xFF200021
.equ HEX2, 0xFF200022
.equ HEX3, 0xFF200023
.equ HEX4, 0xFF200030
.equ HEX5, 0xFF200031

.text
.global _start

_start:
LDR R11, =HEX4//display to write to in HEX_write_ASM
MOV R12, #9 //number to write in HEX_write_ASM
    B main

// main loop
main:
    BL read_slider_switches_ASM
   // MOV A2, #0x1
    //LSL A2, A1
    BL write_LEDs_ASM
	BL HEX_flood_ASM
	BL HEX_write_ASM
	BL HEX_clear_ASM
    B main_loop1
	
// Slider Switches Driver
// returns the state of slider switches in A1
// post- A1: slide switch state
.equ SW_ADDR, 0xFF200040
read_slider_switches_ASM:
    LDR A2, =SW_ADDR     // load the address of slider switch state
    LDR A1, [A2]         // read slider switch state A1 becomes sum of the switches if multiple switches on
    BX  LR

// LEDs Driver
// writes the state of LEDs (On/Off) in A1 to the LEDs' control register
// pre-- A1: data to write to LED state
.equ LED_ADDR, 0xFF200000
write_LEDs_ASM:
    LDR A2, =LED_ADDR    // load the address of the LEDs' state
    STR A1, [A2]         // update LED state with the contents of A1
    BX  LR
	
	
HEX_clear_ASM:
    PUSH {LR}           // save the return address
    LDR A2, =HEX_ADDR
    MOV A1, #0          // clear the segments for the selected HEX displays
    STR A1, [A2, #0]    // write to the HEX display data register
    STR A1, [A2, #16]   // write to the HEX display control register
    POP {PC}            // return from subroutine
	
HEX_flood_ASM:
ldr A2, =0xFF200020   @ load the address of the hex display control register
ldr A1, =0xFFFFFFFF      @ set the hex digit values to display (two digits represnt each hex display)
str A1, [A2]
ldr A2, =0xFF200030
str A1, [A2]
bx lr


HEX_write_ASM: //works for numbers 10-15. Cant select specific display.
    PUSH {LR}// save the return address
    BL HEX_clear_ASM
	LDR A2, =HEX_ADDR   // load the address of HEX display data register
    LDR R5, =HEX_ADDR1   // load the address of HEX display control register
    AND R12, #0xF        // mask out all but the lowest 4 bits (is this needed?)
	CMP R12, #0x0		// check if the value is 0
	BEQ display_0
	CMP R12, #0x1        // check if the value is 1
    BEQ display_1       // branch to display 1 if true
	
	CMP R12, #0x2
	BEQ display_2
	
	CMP R12, #0x3
	BEQ display_3
	
	CMP R12, #0x4
	BEQ display_4
	
	CMP R12, #0x5        // check if the value is 5
    BEQ display_5       // branch to display 5 if true
	
	CMP R12, #0x6
	BEQ display_6
	
	CMP R12, #0x7
	BEQ display_7
	
	CMP R12, #0x8
	BEQ display_8
	
	CMP R12, #0x9
	BEQ display_9
	
	CMP R12, #0xA        // check if the value is A
    BEQ display_A       // branch to display A if true
    CMP R12, #0xB        // check if the value is B
    BEQ display_B       // branch to display B if true
    CMP R12, #0xC        // check if the value is C
    BEQ display_C       // branch to display C if true
    CMP R12, #0xD        // check if the value is D
    BEQ display_D       // branch to display D if true
    CMP R12, #0xE        // check if the value is E
    BEQ display_E       // branch to display E if true
    CMP R12, #0xF        // check if the value is F
    BEQ display_F       // branch to display F if true
    B write_hex         // branch to write the HEX display registers

display_0:
	MOV A1, #0x3F
	B write_hex
display_1:
	MOV A1, #0x06
	B write_hex
	
display_2:
	MOV A1, #0x5B
	B write_hex
	
display_3:
	MOV A1, #0b1001111 //last is top, second last is top right, then bottom right, then bottom, then bottom left, then top left, then center 
	B write_hex
	
display_4:
	MOV A1, #0b1100110
	B write_hex
	
display_5:
	MOV A1, #0x6D
	B write_hex 
	
display_6:
	MOV A1, #0b1111101
	B write_hex
	
display_7:
	MOV A1, #0b000111
	B write_hex

display_8:
	MOV A1, #0b1111111
	B write_hex
	
display_9:
	MOV A1, #0b1100111
	B write_hex

display_A:
    MOV A1, #0x77       // set the bits to display an A
    B write_hex         // branch to write the HEX display registers
display_B:
    MOV A1, #0x7C       // set the bits to display a B
    B write_hex         // branch to write the HEX display registers
display_C:
    MOV A1, #0x39       // set the bits to display a C
    B write_hex         // branch to write the HEX display registers
display_D:
    MOV A1, #0x5E       // set the bits to display a D
    B write_hex         // branch to write the HEX display registers
display_E:
    MOV A1, #0x79       // set the bits to display an E
    B write_hex         // branch to write the HEX display registers
display_F:
    MOV A1, #0x71       // set the bits to display an F
write_hex:
	CMP R11, A2
	BEQ write_hex_0
	STR A1, [R5, #0]
    POP {PC}            // return from subroutinee
write_hex_0:
    STR A1, [A2, #0]    // write to the HEX display data register
	POP {PC}

///////seven methods///////

// Pushbutton addresses
.equ PB_DATA_ADDR, 0xFF200050
.equ PB_EDGECP_ADDR, 0xFF20005C
.equ PB_INTMASK_ADDR, 0xFF200058

// Pushbutton indices
.equ PB0, 0x00000001
.equ PB1, 0x00000002
.equ PB2, 0x00000004
.equ PB3, 0x00000008

// read_PB_data_ASM: Read pushbutton data
read_PB_data_ASM:
    ldr A2, =PB_DATA_ADDR
    ldr A1, [A2]
    BX LR

// PB_data_is_pressed_ASM: Check if the pushbutton is pressed
PB_data_is_pressed_ASM:
    push {A2, LR}
    bl read_PB_data_ASM
	//if then block
    tst A1, A2
    it ne
    movne A1, #0x1
    it eq
    moveq A1, #0x0
    pop {A2, LR}
    BX LR

// read_PB_edgecp_ASM: Read pushbutton edgecapture
read_PB_edgecp_ASM:
    ldr A2, =PB_EDGECP_ADDR
    ldr A1, [A2]
    BX LR

// PB_edgecp_is_pressed_ASM: Check if the pushbutton edgecapture is pressed
// pre-- A1: Pushbutton index
PB_edgecp_is_pressed_ASM:
    push {A2, LR}
    bl read_PB_edgecp_ASM
    tst A1, A2
    it ne
    movne A1, #0x1
    it eq
    moveq A1, #0x0
    pop {A2, LR}
    BX LR

// PB_clear_edgecp_ASM: Clear pushbutton edgecapture
// pre-- A1: Pushbutton index
PB_clear_edgecp_ASM:
    //push {A2, LR}
    ldr A2, =PB_EDGECP_ADDR
    mov A1, #0
   // pop {R1, LR}
   str A1, [A2]
    //BX LR

// enable_PB_INT_ASM: Enable pushbutton interrupt
// pre-- A1: Pushbutton indices
enable_PB_INT_ASM:
    ldr A2, =PB_INTMASK_ADDR
	mov A1, #15
	str A1, [A2]
    BX LR

// disable_PB_INT_ASM: Disable pushbutton interrupt
// pre-- A1: Pushbutton indices
disable_PB_INT_ASM:
    ldr A2, =PB_INTMASK_ADDR
	mov A1, #0
	str A1, [A2]
    BX LR


/// calculator

//Bug: 
main_loop1:
    // Read switch values for n and m
    ldr A1, =SW_ADDR
    and R6, A1, #0xF     // R6 = n (SW0-SW3)
    and R7, R0, #0xF0    // R7 = m (SW4-SW7)
    lsr R7, R7, #4       // Shift m to the right by 4 bits

    // Read pushbutton edgecapture
    bl read_PB_edgecp_ASM
	bl PB_data_is_pressed_ASM
    mov R5, A1           // R5 = edgecapture

    // Determine the operation (clear, multiply, subtract, add)
    tst R5, #PB0
    it eq
    beq clear_operation
    
	postclear: tst R5, #PB1
    it eq
    beq multiply_operation
    tst R5, #PB2
    it eq
    beq subtract_operation
    tst R5, #PB3
    it eq
    beq add_operation
	b main_loop1



clear_operation:
    // Clear r and the display
    mov R8, #0
    mov A1, #0x3F
    bl HEX_clear_ASM
    bl PB_clear_edgecp_ASM
	b postclear

multiply_operation:
    // r = r * n or r = n * m (if r = 0)
    cmp R8, #0
    it eq
    muleq R8, R6, R7
    it ne
    mulne R8, R8, R6
    b update_display

subtract_operation:
    // r = r - n or r = n - m (if r = 0)
    cmp R8, #0
    it eq
    subeq R8, R6, R7
    it ne
    subne R8, R8, R6
    b update_display

add_operation:
    // r = r + n or r = n + m (if r = 0)
    cmp R8, #0
    it eq
    addeq R8, R6, R7
    it ne
    addne R8, R8, R6
    b update_display

update_display:
    // Update the HEX display with r
    push {R0-R3, R5, R6, LR}
	mov R12, R8
	bl HEX_write_ASM
    // Check for overflow
    cmp R8, #0x100000
    blt not_overflow
    ldr R0, =0xFFF00001
    cmp R8, R0
    blt overflow

not_overflow:
    // Display r on the HEX displays
    mov A1, #0x3F           // Select all HEX displays
    bl HEX_clear_ASM        // Clear all HEX displays
    ldr A1, =HEX0           // Select HEX0 display
    ldr A1, =update_sign    // Load update_sign subroutine address
    bx A1                   // Branch to update_sign subroutine

overflow:
// Display "OVRFLO" on HEX displays
ldr A1, =HEX0
ldr A2, =0x4F // 'O'
bl HEX_write_ASM
ldr A1, =HEX1
ldr A2, =0x5C // 'V'
bl HEX_write_ASM
ldr A1, =HEX2
ldr A2, =0x50 // 'R'
bl HEX_write_ASM
ldr A1, =HEX3
ldr A2, =0x6D // 'F'
bl HEX_write_ASM
ldr A1, =HEX4
ldr A2, =0x54 // 'L'
bl HEX_write_ASM
ldr A1, =HEX5
ldr A2, =0x4F // 'O'
b PB_clear_edgecp_ASM

update_sign:
// Update the sign of r
cmp R8, #0
bge positive_result
neg R8, R8 // Make R8 positive for display purposes
ldr A1, =HEX0
ldr A2, =0x40 // '-' sign
bl HEX_write_ASM
b positive_result_done

positive_result:
ldr A1, =HEX0
bl HEX_clear_ASM

positive_result_done:
// Display the result
ldr A1, =HEX1
mov A2, R8, LSR #16
bl HEX_write_ASM
ldr A1, =HEX2
mov A2, R8, LSR #12
and A2, A2, #0xF
bl HEX_write_ASM
ldr A1, =HEX3
mov A2, R8, LSR #8
and A2, A2, #0xF
bl HEX_write_ASM
ldr A1, =HEX4
mov A2, R8, LSR #4
and A2, A2, #0xF
bl HEX_write_ASM
ldr A1, =HEX5
and A2, R8, #0xF
bl HEX_write_ASM

pop {R0-R3, R5, R6, LR}
b PB_clear_edgecp_ASM


