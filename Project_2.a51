ORG 00h  ; Start of the code
;------------------------------------------Start-----------------------------------------------
Mode_Check:
;mov p0, #00
;mov p2, #00
clr p3.2
clr p3.3
clr p3.4
clr p3.5
clr p3.6
clr p3.7

jb P3.0, Check_1
jb P3.1, mode_10_ljmp
jmp mode_00
;If both bit not set then by Default mode_1 will run

Check_1:
jnb P3.1, mode_01
Long_Jump_Mode4:
ljmp mode_11

mode_10_ljmp:
ljmp mode_10
sjmp $

;---------------------------------------Mode_1---------------------------------------------------
mode_00:
	mov b, r6
main_00:

    mov a, P1
    cjne a, b, process_and_delay_00
    jmp main_00
	
	process_and_delay_00:
	clr p3.2
	clr p3.3
	clr p3.4
	clr p3.5
	clr p3.6
	clr p3.7
	
    mov r0, p1
	
    mov a, r0 ;100t
    mov b, #100
    mul ab
    mov r1, a ;lowbyte
    mov r2, b ;highbyte
	
    mov a, r0 ;t^2
    mov b, a
    mul ab
    mov r3, b

    mov b, #5 ;low*5
    mul ab
    mov r4, a ;low
	mov r5,b
  
    mov a, r3 ;high*5
    mov b, #5
    mul ab
	mov b, r5
	add a,b
    mov r3, a ;high
    
	acall delay_00 ;delay

    mov a, r1 ;lowbyte
    mov b, r4
    subb a, b
    mov p0, a
    mov a, r2 ;highbyte
    mov b, r3
    subb a, b
    mov p2, a
	
	mov a, p2 ; Check for negative answer
	clr c
	rlc a
	jc set_high
	sjmp here12
	
	set_high:
	setb p3.3
	
	here12:
	jnb p2.7, SKIP_SET_P3_2_00 ;Check if the value exceeds 2 bytes 
    setb P3.2
	
	SKIP_SET_P3_2_00:
	mov r6,p1
    jmp mode_check

	delay_00:
		MOV R5, #12
		Loop00_1: MOV R4, #255
		Loop00_2: MOV R3, #244
		Loop00_3: DJNZ R3, Loop00_3
		DJNZ R4, Loop00_2
		DJNZ R5, Loop00_1
		nop
		ret
;-----------------------------------------Mode_2-----------------------------------------------

mode_01:
mov b, #255
main_01:
    mov a, P1
	cjne a, b, process_and_delay
    jmp main_01

process_and_delay:
	clr p3.2
	clr p3.3
	clr p3.4
	clr p3.5
	clr p3.6
	clr p3.7
	jnb p1.0, skip_set_p3_2
	setb p3.2
	skip_set_p3_2:
	jnb p1.1, skip_set_p3_3
	setb p3.3
	skip_set_p3_3:
	jnb p1.2, skip_set_p3_4
	setb p3.4
	skip_set_p3_4:
	jnb p1.3, skip_set_p3_5
	setb p3.5
	skip_set_p3_5:
	jnb p1.4, skip_set_p3_6
	setb p3.6
	skip_set_p3_6:
	jnb p1.5, skip_set_p3_7
	setb p3.7
	skip_set_p3_7:
	
    mov b, #5
    mul ab
    add a, #9
	mov r6,a
	mov b,p1
	acall delay_01
    anl a, #1
    jz even_result

    ; Display odd result on Port 0
	mov p2, #00
	mov a,r6
    mov P0, a
	jmp main_01
even_result:
    ; Display even result on Port 2
	mov p0,#00
	mov a ,r6
    mov P2, a
	jmp mode_check
	
delay_01:
mov r5, #10
loop01_1: mov r4, #255
loop01_2: mov r3, #234
loop01_3: djnz r3, loop01_3
djnz r4, loop01_2
djnz r5, loop01_1
ret
;--------------------------------Mode_3-----------------------------------------------------------	
Mode_10:
	mov p0, #00
	mov p2, #00
	mov p3, #00
	mov p1, #00
;Convert Celcius to Fahrenheit F = (9/5)C + 32
;Step 1: 9*C
mov a, P1	;Take Celcius input from P1
mov b, #9	;Store decimal 9 in b
MUL AB		;Multiply to get 9C

MOV R0,A	; Move Low byte to R0
MOV R1,B	; Move High byte to R1

;Step 2:  (9/5) * C
;--------------------------------------------------
MOV A,R1	; Move High byte to A
MOV B,#5	; Move 5 to B
DIV AB		; Divide AB
jz low_byte_work
add a, #32	; Add 32 to high byte
mov r1, a	; Move the result value to R1

low_byte_work:
MOV A,R0	; Move Low byte to A
MOV B,#5	; Move 5 to B
DIV AB		; Divide AB
add a, #32	; Add 32 to low byte
mov r0, a	; Move the result value to R0
;--------------------------------------------------
;----------------------------------BCD Conversion & Condition Check-----------------------------------------
Check_High_byte:
mov a, r1
jz Check_low_byte
SJMP display_P2


check_low_byte:
mov a, r0
anl a, #0f0h
cjne a, #90h, display_port0
mov a, r0
anl a, #0fh
cjne a, #09h, display_port0

display_P2:
mov a, r1		;Store high byte value to A
mov b, #10		;Store 10d in b
div AB			;Divide A by B - Quotient is stored in A and remainder in B
;As per instructions, Remainder will be ignored.
Swap A
mov P2, A
call delay_10
mov P2, #00
jmp mode_check

display_port0:
mov a, r0		;Store low byte value to A
mov b, #10		;Store 10d in b
div AB			;Divide A by B - Quotient is stored in A and remainder in B
;As per instructions, Remainder will be ignored.
Swap A
mov P0, A
call delay_10
mov P0, #00
jmp mode_check

delay_10:
	MOV R5, #4
    Loop10_1: MOV R4, #255
    Loop10_2: MOV R3, #244
    Loop10_3: DJNZ R3, Loop10_3
    DJNZ R4, Loop10_2
    DJNZ R5, Loop10_1
	nop
	ret
;---------------------------------------------------Mode_4-----------------------------------------------------------
/*
Calculations:
Crystal Frequency = 12 MHz
80Hz = 0.0125s. Convert to microsecond => 12,500
*/

Mode_11:
	mov p0, #00
	mov p2, #00
	mov p3, #00
	mov p1, #00
Mode_4:
MOV R0, #00
MOV R1, #00
MOV R2, #00
MOV R3, #00
mov a, p1	;Read input from Port P1
jz zero_time

mov b, #49	; Move 45 to b
mul ab		; Multiply the value read from Port P1 with 45
;Send the high and low byte to register R1 and R0 respectively
mov r0, a
mov r1, b
mov r2, a
mov r3, b
;Subtracting 65535 that is #0ffffh from the high and low byte.

;------------------------------------High Time Calculations--------------------------------------
mov a, #0ffh
subb a, r0	;Subtract low byte from #0ffh
mov r0, a
mov a, #0ffh
subb a, r1	;Subtract high byte from #0ffh
mov r1, a
;Timer Initialization:
mov tmod, #11h

;Timer 1 - HIGH Time initialization
mov th1, r1	;Input high byte to th1
mov tl1, r0	;Input low byte to tl1

mov a, p1
mov p2, a
setb tr1
High_Time: jnb tf1, High_Time	;Run until timer overflow
clr tf1
clr tr1
mov a, p1
cjne a, #255, low_time_calculation
jmp mode_check
;------------------------------Low_Time Calculations--------------------------------------------
;Load the maximum value attained to generate a PWM signal of 80Hz at 12MHz Crystal Frequency
;#030D4H = 12500 in decimals
low_time_calculation:
mov p2, #00h
mov a, #0D4h
mov b, #30h

;Subtract the high time values from max value to get the Low Time value
subb a, r2
mov r0, a
mov a, b
subb a, r3
mov r1, a
mov a, #0ffh
subb a, r0	;Subtract low byte from #0ffh
mov r0, a
mov a, #0ffh
subb a, r1	;Subtract high byte from #0ffh
mov r1, a

;Move low time values to timer0 
mov th0, r1
mov tl0, r0
setb tr0
Low_Time: jnb tf0, Low_Time
clr tr0
clr tf0
ljmp mode_check
zero_time:
mov p2, #00
mov tmod, #10h
mov th1, #0cfh
mov tl1, #2bh
setb tr1

zero_loop: jnb tf1, zero_loop	;Run until timer overflow
clr tf1
clr tr1
ljmp Mode_check	;Jump back to Mode_check
END
