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

.set outMask = 0xFF
.set fullPat = 0xFF
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
		delayB
		dec c
		brne while
.endmacro

.macro checkButton
	lds input, PINK
	cpi input, 0xFF
	breq midDest
	delayForPress
	lds input, PINK
	cpi input, 0xFF
	breq dest
	sbrc input, 6
	rjmp shut
	andi input, 1
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
		ldi temp, pat1
		out PORTC, temp
		rjmp dest
	second:
		ldi temp, pat2
		out PORTC, temp
		rjmp dest
	third:
		ldi temp, pat3
		out PORTC, temp
		rjmp dest
	shut:
		clr temp
		out PORTC, temp
		clr count
	dest:
		jmp end
	fourth:
	fourPress
	end:
.endmacro

.macro fourPress
	while:
		lds input, PINK
		cpi input, 0xFF
		breq cont
		delayForPress
		lds input, PINK
		cpi input, 0xFF
		breq cont
		sbrc input, 6
		rjmp shut
	cont:
		ldi temp, pat1
		out PORTC, temp
		delayC
		ldi temp, pat2
		out PORTC, temp
		delayC
		ldi temp, pat3
		out PORTC, temp
		delayC
		rjmp while
	shut:
		clr temp
		out PORTC, temp
		clr count
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
	ldi temp, fullPat
	WhileCheck:
		checkButton
		rjmp WhileCheck
end:
	rjmp end
