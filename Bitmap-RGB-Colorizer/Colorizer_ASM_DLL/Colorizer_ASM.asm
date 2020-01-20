;definitions of three bit masks (every bit mask will be used every third different iteration)
.data
mask1:
	byte 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0 ;for 1st iteration for R colorizing, for 3rd iteration for G colorizing and for 2nd iteration for B colorizing (when pixels starts with B value)
mask2:
	byte 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0 ;for 2nd iteration for R colorizing, for 1st iteration for G colorizing and for 3rd iteration for B colorizing (when pixels starts with B value)
mask3:
	byte 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255 ;for 3rd iteration for R colorizing, for 2nd iteration for G colorizing and for 1st iteration for B colorizing (when pixels starts with B value)

.code

processBitmapInAsm proc
	cmp r9b, 82 ;check if R colorizing is chosen and pixels starts with value of B
	je RFirstB
	cmp r9b, 83 ;check if R colorizing is chosen and pixels starts with value of G
	je RFirstG
	cmp r9b, 84 ;check if R colorizing is chosen and pixels starts with value of R
	je RFirstR

	cmp r9b, 71 ;check if G colorizing is chosen and pixels starts with value of B
	je GFirstB
	cmp r9b, 72 ;check if G colorizing is chosen and pixels starts with value of G
	je GFirstG
	cmp r9b, 73 ;check if G colorizing is chosen and pixels starts with value of R
	
	cmp r9b, 66 ;check if B colorizing is chosen and pixels starts with value of B
	je BFirstB
	cmp r9b, 67 ;check if B colorizing is chosen and pixels starts with value of G
	je BFirstG
	cmp r9b, 68 ;check if B colorizing is chosen and pixels starts with value of R
	je BFirstR

RFirstB:
	movdqu xmm1, xmmword ptr [mask1]
	movdqu xmm2, xmmword ptr [mask2]
	movdqu xmm3, xmmword ptr [mask3]
	mov bl, 1
	jmp RColor
RFirstG:
	movdqu xmm1, xmmword ptr [mask2]
	movdqu xmm2, xmmword ptr [mask3]
	movdqu xmm3, xmmword ptr [mask1]
	mov bl, 2
	jmp RColor
RFirstR:
	movdqu xmm1, xmmword ptr [mask3]
	movdqu xmm2, xmmword ptr [mask1]
	movdqu xmm3, xmmword ptr [mask2]
	mov bl, 3
	jmp RColor	
RColor:
	mov r15d, 3
	jmp Prepare

GFirstB:
	movdqu xmm1, xmmword ptr [mask2]
	movdqu xmm2, xmmword ptr [mask3]
	movdqu xmm3, xmmword ptr [mask1]
	mov bl, 1
	jmp GColor
GFirstG:
	movdqu xmm1, xmmword ptr [mask3]
	movdqu xmm2, xmmword ptr [mask1]
	movdqu xmm3, xmmword ptr [mask2]
	mov bl, 2
	jmp GColor
GFirstR:
	movdqu xmm1, xmmword ptr [mask1]
	movdqu xmm2, xmmword ptr [mask2]
	movdqu xmm3, xmmword ptr [mask1]
	mov bl, 3
	jmp GColor
GColor:
	mov r15d, 2
	jmp Prepare

BFirstB:
	movdqu xmm1, xmmword ptr [mask3]
	movdqu xmm2, xmmword ptr [mask1]
	movdqu xmm3, xmmword ptr [mask2]
	mov bl, 1
	jmp BColor
BFirstG:
	movdqu xmm1, xmmword ptr [mask1]
	movdqu xmm2, xmmword ptr [mask2]
	movdqu xmm3, xmmword ptr [mask3]
	mov bl, 2
	jmp BColor
BFirstR:
	movdqu xmm1, xmmword ptr [mask2]
	movdqu xmm2, xmmword ptr [mask3]
	movdqu xmm3, xmmword ptr [mask1]
	mov bl, 3
	jmp BColor
BColor:
	mov r15d, 1
	jmp Prepare

Prepare:
	mov rax, rcx ;save pointer to bitmap
	mov rsi, rdx ;save beginning of the bitmap - second parameter passed to procedure, end of the bitmap - third parameter passed to procedure is stored in r8 register
	mov r14d, 0 ;initialize register with 0 - this value will be used to determine which iteration is currently (first, second or third) and which bit mask should be used
	cmp r8, 16 ;check if already less than 16 values should be processed
	jb editRemainingPixels
	sub r8, 16 ;substract 16 from end of the bitmap to be sure if every time 16 values from bitmap can be moved to xmm0 register
changePixels:
	inc r14d ;increment counter of iterations
	movdqu xmm0, xmmword ptr[rax + rsi] ;move from bitmap array 16 values (128 bits) to xmm0 register
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
	movdqu xmmword ptr[rax + rsi], xmm0 ;move processed values from xmm0 register back to bitmap array
	cmp r14d, 3 ;check if this is third iteration and if it is, jump to "zero" label
	je zero

continue:
	add rsi, 16 ;add 16 to beginning of the bitmap to process next 16 values
	cmp rsi, r8
	jb changePixels ;if end of bitmap not reached, process next pixels
	
	add r8, 16 ;add 16 back to end of the bitmap
	cmp rsi, r8
	je endProcessing ;if end of bitmap reached, end processing
	jb editRemainingPixels ;if not, remaining pixels should be processed

zero:
	mov r14d, 0
	jmp continue 


;for editing remaining pixels:

editRemainingPixels:
	mov r13b, 0 ;counter of iterations for remaining pixels
	
	cmp bl, 1 ;processing started with B value
	je startedWithB
	cmp bl, 2 ;processing started with G value
	je startedWithG
	cmp bl, 3 ;processing started with R value
	je startedWithR

startedWithB:
	cmp r14d, 0 
	je startFromB ;first remaining pixel will be B
	cmp r14d, 1
	je startFromG ;first remaining pixel will be G
	cmp r14d, 2
	je startFromR ;first remaining pixel will be R
startedWithG:
	cmp r14d, 0 
	je startFromG ;first remaining pixel will be G
	cmp r14d, 1
	je startFromR ;first remaining pixel will be R
	cmp r14d, 2
	je startFromB ;first remaining pixel will be B
startedWithR:
	cmp r14d, 0 
	je startFromR ;first remaining pixel will be R
	cmp r14d, 1
	je startFromB ;first remaining pixel will be B
	cmp r14d, 2
	je startFromG ;first remaining pixel will be G

startFromB:
	cmp r15d, 3
	je RColorizingWithFirstB ;R colorizing was chosen
	cmp r15d, 2
	je GColorizingWithFirstB ;G colorizing was chosen
	cmp r15d, 1
	je BColorizingWithFirstB ;B colorizing was chosen
RColorizingWithFirstB:
	mov r10b, 0 ;define three bit masks for this case
	mov r11b, 0
	mov r12b, 255
	jmp ProcessRemainingPixels
GColorizingWithFirstB:
	mov r10b, 0 ;define three bit masks for this case
	mov r11b, 255
	mov r12b, 0
	jmp ProcessRemainingPixels
BColorizingWithFirstB:
	mov r10b, 255 ;define three bit masks for this case
	mov r11b, 0
	mov r12b, 0
	jmp ProcessRemainingPixels

startFromG:
	cmp r15d, 3 
	je RColorizingWithFirstG ;R colorizing was chosen
	cmp r15d, 2
	je GColorizingWithFirstG ;G colorizing was chosen
	cmp r15d, 1
	je BColorizingWithFirstG ;B colorizing was chosen
RColorizingWithFirstG:
	mov r10b, 0 ;define three bit masks for this case
	mov r11b, 255
	mov r12b, 0
	jmp ProcessRemainingPixels
GColorizingWithFirstG:
	mov r10b, 255 ;define three bit masks for this case
	mov r11b, 0
	mov r12b, 0
	jmp ProcessRemainingPixels
BColorizingWithFirstG:
	mov r10b, 0 ;define three bit masks for this case
	mov r11b, 0
	mov r12b, 255
	jmp ProcessRemainingPixels

startFromR:
	cmp r15d, 3
	je RColorizingWithFirstR ;R colorizing was chosen
	cmp r15d, 2
	je GColorizingWithFirstR ;G colorizing was chosen
	cmp r15d, 1
	je BColorizingWithFirstR ;B colorizing was chosen
RColorizingWithFirstR:
	mov r10b, 255 ;define three bit masks for this case
	mov r11b, 0
	mov r12b, 0
	jmp ProcessRemainingPixels
GColorizingWithFirstR:
	mov r10b, 0 ;define three bit masks for this case
	mov r11b, 0
	mov r12b, 255
	jmp ProcessRemainingPixels
BColorizingWithFirstR:
	mov r10b, 0 ;define three bit masks for this case
	mov r11b, 255
	mov r12b, 0
	jmp ProcessRemainingPixels

;right algorithm for processing remaining pixels:

ProcessRemainingPixels:
	inc r13b ;increment iterations counter
	mov bl, byte ptr[rax + rsi] ;move value from bitmap array to r8b
	cmp r13b, 1
	je firstIteration
	cmp r13b, 2
	je secondIteration
	cmp r13b, 3
	je thirdIteration

firstIteration:
	and bl, r10b ;do logical AND on value from bitmap with bit mask in r10b
	jmp nextStep

secondIteration:
	and bl, r11b ;do logical AND on value from bitmap with bit mask in r11b
	jmp nextStep

thirdIteration:
	and bl, r12b ;do logical AND on value from bitmap with bit mask in r12b
	jmp nextStep

nextStep:
	mov byte ptr[rax + rsi], bl ;move processed value from r8b back to bitmap array
	cmp r13b, 3
	je zeroCounter

continueProcessing:
	inc rsi
	cmp rsi, r8
	je endProcessing ;if all remaining pixels was processed, end algorithm
	jmp ProcessRemainingPixels ;continue processing remaining pixels

zeroCounter:
	mov r13b, 0
	jmp continueProcessing

endProcessing:
	ret
processBitmapInAsm endp
end