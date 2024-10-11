;
; AssemblerApplication9.asm
;
; Created: 10/9/2024 9:25:05 PM
; Author : szlsl
;


; Replace with your application code
.include "m2560def.inc"

.def temp = r16
.def count = r17
.def a = r18
.def b = r19
.def c = r20
.def d = r21
.def input = r22
.def turnoff = r6
.def flag = r23

.set outMask = 0xFF
.set pat1 = 0b11000000
.set pat2 = 0b00110000
.set pat3 = 0b00001100

.macro delayA ; approx 0.015ms
	ser a
	while:
		dec a
		brne while 
.endmacro

.macro delayB
	ser b
	while:
		delayA
		dec b
		brne while
.endmacro

.macro delayForPress
	ldi temp, 6
	debounce:
		cpi temp, 0
		breq enddebounce
		delayB
		dec temp
		rjmp debounce
	enddebounce:
.endmacro

.macro delayC
	ldi c, 0b00111111
	while:
		readInput
		cpi flag, 0
		brne end 
		delayB
		dec c
		brne while
	end:
.endmacro

.macro readInput
	clr flag
	lds input, PINK
	cpi input, 0xFF
	breq end
	delayForPress
	lds input, PINK
	cpi input, 0xFF
	breq end
	sbrc input, 6
	rjmp shut
	ldi flag, 2
	rjmp end
	shut:
	ldi flag, 1
	end:
.endmacro

.macro checkButton
	readInput
	cpi flag, 0
	breq dest
	cpi flag, 1
	breq shut
	inc count
	cpi count, 1
	breq first
	cpi count, 2
	breq second
	cpi count, 3
	breq third
	cpi count, 4
	clr count
	rjmp fourth
	midDest:
		rjmp dest
	first:
		clr flag
		ldi temp, pat1
		out PORTC, temp
		rjmp dest
	second:
		clr flag
		ldi temp, pat2
		out PORTC, temp
		rjmp dest
	third:
		clr flag
		ldi temp, pat3
		out PORTC, temp
		rjmp dest
	shut:
		clr flag
		clr temp
		out PORTC, temp
		clr count
	dest:
		jmp end
	fourth:
	clr flag
	clr count
	fourPress
	cpi flag, 2
	breq first_jmp
	jmp shut
	first_jmp:
	inc count
	jmp first
	end:
.endmacro

.macro fourPress
	while:
		ldi temp, pat1
		out PORTC, temp
		delayC
		cpi flag, 0
		breq cont
		jmp endWhile
		cont:
		ldi temp, pat2
		out PORTC, temp
		delayC
		cpi flag, 0
		brne endWhile
		ldi temp, pat3
		out PORTC, temp
		delayC
		cpi flag, 0
		brne endWhile
		rjmp while
	endWhile:
	
.endmacro

start:
	clr temp
	mov turnoff, temp; set turn off pattern
	clr temp;
	sts DDRK, temp ;set port K as input
	ldi temp, 0xFF
	sts PORTK, temp; turn on pull-up resistor
	out DDRC, temp; set port c as output
	clr count
	WhileCheck:
		checkButton
		rjmp WhileCheck
end:
	rjmp end
