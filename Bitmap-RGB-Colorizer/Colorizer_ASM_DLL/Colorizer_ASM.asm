;definitions of three bit masks (every bit mask will be used every third different iteration)
.data
mask1:
	byte 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0 ;for 1st iteration for R colorizing, for 3rd iteration for G colorizing and for 2nd iteration for B colorizing
mask2:
	byte 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0 ;for 2nd iteration for R colorizing, for 1st iteration for G colorizing and for 3rd iteration for B colorizing
mask3:
	byte 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255 ;for 3rd iteration for R colorizing, for 2nd iteration for G colorizing and for 1st iteration for B colorizing

.code

processBitmapInAsm proc

	cmp r9b, 82 ;check if R colorizing is chosen
	je RColor
	cmp r9b, 71 ;check if G colorizing is chosen
	je GColor
	cmp r9b, 66 ;check if B colorizing is chosen
	je BColor

Rcolor:    
	movdqu xmm1, xmmword ptr [mask1]
	movdqu xmm2, xmmword ptr [mask2]
	movdqu xmm3, xmmword ptr [mask3]
	jmp Prepare
GColor:
	movdqu xmm1, xmmword ptr [mask2]
	movdqu xmm2, xmmword ptr [mask3]
	movdqu xmm3, xmmword ptr [mask1]
	jmp Prepare
BColor:
	movdqu xmm1, xmmword ptr [mask3]
	movdqu xmm2, xmmword ptr [mask1]
	movdqu xmm3, xmmword ptr [mask2]
	jmp Prepare

Prepare:
	mov rdi, rdx ;save beginning of the bitmap - second parameter passed to procedure
	mov rsi, r8 ;save end of the bitmap - third parameter passed to procedure
	mov r14d, 0 ;initialize register with 0 - this value will be used to determine which iteration is currently (first, second or third) and which bit mask should be used
	sub rsi, 16 ;substract 16 from end of the bitmap to be sure if every time 16 values from bitmap can be moved to xmm0 register

changePixels:
	inc r14d ;increment counter of iterations
	movdqu xmm0, xmmword ptr[rcx + rdi] ;move from bitmap array (rcx - first argument passed to procedure) 16 values (128 bits) to xmm0 register
	cmp r14d, 1 ;if this is first iteration jump to "first" label
	je first
	cmp r14d, 2 ;if this is second iteration jump to "second" label
	je second
	cmp r14d, 3 ;if this is third iteration jump to "third" label
	je third

first:
	pand xmm0, xmm1 ;do logical AND on xmm0 register with bit mask in xmm1 register
	jmp next
second:
	pand xmm0, xmm2 ;do logical AND on xmm0 register with bit mask in xmm2 register
	jmp next
third:
	pand xmm0, xmm3 ;do logical AND on xmm0 register with bit mask in xmm3 register
	jmp next

next:
	movdqu xmmword ptr[rcx + rdi], xmm0 ;move processed values from xmm0 register back to bitmap array
	cmp r14d, 3 ;check if this is third iteration and if it is, jump to "zero" label
	je zero

continue:
	add rdi, 16 ;add 16 to beginning of the bitmap to process next 16 values
	cmp rdi, rsi
	jbe changePixels ;if end of bitmap not reached, process next pixels

	add rsi, 16
	cmp rdi, rsi
	je endProcessing ;if end of bitmap reached, end processing
	;jb editRemainingPixels ;if not, remaining pixels should be processed

zero:
	mov r14d, 0
	jmp continue 
	
endProcessing:
	ret
processBitmapInAsm endp
end