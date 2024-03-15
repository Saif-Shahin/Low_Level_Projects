.equ    ARM_TIMER_LOAD,         0x00
.equ    ARM_TIMER_CONTROL,      0xFFFEC608
.equ    ARM_TIMER_RESET,        0x0C
.equ    ARM_TIMER_BASE,         0xFFFEC600
.equ HEX_ADDR, 0xFF200020
.equ HEX_ADDR1, 0xFF200030

.global _start

	
	ARM_TIM_config_ASM: //This subroutine is used to configure the timer. Use the arguments discussed above.
	LDR A3, =ARM_TIMER_BASE
			//MOV A1, #15
			MOV A2, #0x00000001
	STR A1, [A3]
	LDR A3, =ARM_TIMER_CONTROL
	MOV A4, #1
	orr A2, A2, #0x3     
	str A2, [A3]
	LDR A4, =0xFFFEC604
	LDR R12, [A4]
	cmp R12, #0
	bne HEX_write_ASM
	b HEX_write_ASM
	bx lr
	
	ARM_TIM_read_INT_ASM: 
	LDR A3, =ARM_TIMER_BASE
	LDR A1, [A3,  #0x0C]
	bx lr
	
	ARM_TIM_clear_INT_ASM:
	LDR A3, =ARM_TIMER_BASE
	b HEX_clear_ASM
	//MOV A2, #0x00000001
	LDR A2, [A3,  #0x0C]
	
	delay:
	b delay
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
	
HEX_clear_ASM:
    PUSH {LR}           // save the return address
    LDR A2, =HEX_ADDR
    MOV A1, #0          // clear the segments for the selected HEX displays
    STR A1, [A2, #0]    // write to the HEX display data register
    STR A1, [A2, #16]   // write to the HEX display control register
    POP {PC}            // return from subroutine
	
	
.equ    HEX3_HEX0_BASE,         0xff200020
.equ    HEX5_HEX4_BASE,         0xff200030

.equ SW_ADDR, 0xFF200040
.equ LED_ADDR, 0xFF200000

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



//Whack a mole interupts
.section .data
PB_int_flag:
    .word 0x0
tim_int_flag:
    .word 0x0

.section .vectors, "ax"
B _start
B SERVICE_UND
B SERVICE_SVC
B SERVICE_ABT_INST
B SERVICE_ABT_DATA
.word 0
B SERVICE_IRQ
B SERVICE_FIQ

.section .text
.global _start

_start:
    MOV R1, #0b11010010
    MSR CPSR_c, R1
    LDR SP, =0xFFFFFFFF - 3
    MOV R1, #0b11010011
    MSR CPSR, R1
    LDR SP, =0x3FFFFFFF - 3
    BL  CONFIG_GIC
    BL  enable_PB_INT_ASM
    BL  ARM_TIM_config_ASM
    MOV R0, #0b01010011
    MSR CPSR_c, R0
IDLE:
    start_game:
    /* initialize random seed */
    bl      init_random_seed
    /* set timer for 30 seconds */
    bl      set_timer_30s
    /* initialize score */
    mov     r5, #0
    /* start timer */
    bl      start_ARM_TIM
    /* initialize switches */
    bl      read_switches
    /* initialize pushbuttons */
    bl      clear_PB_edgecp_ASM

    /* main game loop */
loop:
    /* check if game is over */
    bl      is_game_over
    cmp     A1, #1
    beq     end_loop

    /* check if a mole is visible */
    bl      is_mole_visible
    cmp     A1, #1
    bne     no_mole_visible

    /* check if correct switch is pressed */
    bl      is_correct_switch_pressed
    cmp     A1, #1
    beq     add_score
	b loop

CONFIG_GIC:
    PUSH {LR}
    MOV R0, #73
    MOV R1, #1
    BL CONFIG_INTERRUPT
    MOV R0, #29
    MOV R1, #1
    BL CONFIG_INTERRUPT
    LDR R0, =0xFFFEC100
    LDR R1, =0xFFFF
    STR R1, [R0, #0x04]
    MOV R1, #1
    STR R1, [R0]
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}

CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}

SERVICE_UND: 
    b SERVICE_UND
SERVICE_SVC: 
	b SERVICE_SVC

SERVICE_ABT_DATA: 
    b SERVICE_ABT_DATA
	
SERVICE_ABT_INST: 
	b SERVICE_ABT_INST

SERVICE_IRQ:
    PUSH {R0-R7, LR}
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C]
    CMP R5, #73
    BEQ KEY_ISR
    CMP R5, #29
    BEQ ARM_TIM_ISR
    B UNEXPECTED
UNEXPECTED:
    B UNEXPECTED
EXIT_IRQ:
    STR R5, [R4, #0x10]
    POP {R0-R7, LR}
    SUBS PC, LR, #4
SERVICE_FIQ: 
	b SERVICE_FIQ
	
CHECK_KEY0:
    MOV R3, #0x1
    ANDS R3, R3, R1        // check for KEY0
    BEQ CHECK_KEY1
    MOV R2, #0b00111111
    STR R2, [R0]           // display "0"
    B END_KEY_ISR
CHECK_KEY1:
    MOV R3, #0x2
    ANDS R3, R3, R1        // check for KEY1
    BEQ CHECK_KEY2
    MOV R2, #0b00000110
    STR R2, [R0]           // display "1"
    B END_KEY_ISR
CHECK_KEY2:
    MOV R3, #0x4
    ANDS R3, R3, R1        // check for KEY2
    BEQ IS_KEY3
    MOV R2, #0b01011011
    STR R2, [R0]           // display "2"
    B END_KEY_ISR
IS_KEY3:
    MOV R2, #0b01001111
    STR R2, [R0]           // display "3"
END_KEY_ISR:
    BX LR

KEY_ISR:
    LDR R0, =0xFF200050
    LDR R1, [R0, #0xC]
    LDR R2, =PB_int_flag
    STR R1, [R2]
    MOV R2, #0xF
    STR R2, [R0, #0xC]
    B EXIT_IRQ

ARM_TIM_ISR:
    LDR R0, =tim_int_flag
    MOV R1, #1
    STR R1, [R0]
    LDR R0, =0xFFFEC108
    LDR R1, [R0]
    STR R1, [R0]
    B EXIT_IRQ
	
	
init_random_seed:
    PUSH {LR}
    LDR R0, =0x5555
    STR R0, [R7, #0x04]
    POP {PC}

set_timer_30s:
    PUSH {LR}
    LDR R0, =30
	b  ARM_TIM_config_ASM
    POP {PC}

start_ARM_TIM:
    PUSH {LR}
    b ARM_TIM_config_ASM
    //STR R1, [R0, #0x00]
    POP {PC}

read_switches:
    PUSH {LR}
	b read_PB_data_ASM
    POP {PC}

clear_PB_edgecp_ASM:
	b PB_clear_edgecp_ASM 
    POP {PC}

is_game_over:
    PUSH {LR}
    LDR R0, =0xff200044
    LDR R1, [R0]
    CMP R1, #0
    MOVNE A1, #0
    MOVEQ A1, #1
    POP {PC}

is_mole_visible:
    PUSH {LR}
    LDR R0, =0xff200044
    LDR R1, [R0]
    CMP R1, #0
    MOVNE A1, #0
    MOVEQ A1, #1
    POP {PC}

no_mole_visible:
    PUSH {LR}
    MOV A1, #0
    POP {PC}

is_correct_switch_pressed:
    PUSH {LR}
    LDR R0, =0xff200040
    LDR R1, [R0]
    LDR R0, =0xff000048
    LDR R2, [R0]
    AND R1, R1, R2
    CMP R1, #0
    MOVNE A1, #1
    MOVEQ A1, #0
    POP {PC}

add_score:
    PUSH {LR}
    LDR R0, =0xff200020
    LDR R1, [R0]
    ADD R1, #1
    STR R1, [R0]
    POP {PC}

end_loop:
    B end_loop
