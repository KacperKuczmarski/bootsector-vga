; BOOT SECTOR FILE
[org 0x7C00] ; Strings have this offset for some reason

KERNEL_LOC equ 0x1000

text:
	db "Hello World!", 0x0a ; 0x0a is eol (\n)
xVar dw 0x0000
yVar dw 0x0000
cPixel dw 0x0000
activeColor db 0x00

mov al, 'S'
mov ah, 0x0e
int 0x10

jmp setGraphicMode
;mov bx, text ; move this text pointer to something we can manipulate with (bx) 

setGraphicMode:
	mov ah, 0x00 ; set video mode
	mov al, 0x13 ; Graphics 320x200, 256 colours
	int 0x10	 ; BIOS INT
	jmp writePixel

fillTheLine:	
	add word[xVar], 1   ; update X
	;add word[cPixel], 1 ; update overall pixel nr
	cmp word[xVar], 320 ; see if we finished the line 
	jne writePixel 
	; we got to the end of the line
	add word[yVar], 1 ; update Y
	mov word[xVar], 0 ; reset X
	cmp word[yVar], 200 ; see if we finished drawing screen
	jne fillTheLine

resetScreen:	; we get here when we finish filling screen
	mov word[xVar], 0x0000   ; clear X
	mov word[yVar], 0x0000   ; clear Y
	mov word[cPixel], 0x0000 ; reset pixel nr
	add byte[activeColor], 1 ; next color
	mov ax, [activeColor]
	cmp ax, 0xff  ; check if we went through all colors (TEST)
	call clearScreen
	jmp gotoProtectedMode;jmp fillTheLine 		 ; redo
	
jmp loop ; write pixel and move to end

writePixel:
	; To calculate the pixel position we can use:
	; PixelPos = yPos*320 + xPos 
	;mov word[cPixel], 0x0000 ; first we zero the pixel position
	mov ax, 320 	 ; move to ax 320 (screen width)
	mov bx, [yVar]	 ; move yPos to the bx so we can do multiplication on it
	mul bx		 	 ; Multiply ax with bx (yPos) (res in ax ax and dx)
	; we probably are able to use only ax result and not dx (dx will always be 0)
	add ax, [xVar]	 ; add to ax xVar so we have a full formula (offset) in ax
	mov di, ax;[cPixel] ; offset for video memory
	mov ax, 0xa000   ; video memory
	mov es, ax ; vga video memory segment
	mov al, [activeColor] ; set color
	mov es:[di], al ;write the color to the specified offset
	jmp fillTheLine ; exit 

;writePixelBIOSINT: ;old version using BIOS INT (too slow!)
;	mov cx, word[xVar] ; copy the X variable to cx
;	mov dx, word[yVar] ; copy the Y variable to dx
;	mov bx, 0x00 ; clear bx that we will use for page
;	mov ah, 0x0C ; write graphics pixel
;	mov al, byte[activeColor] ; set the color
;	;mov bh, byte[activePage] ; page number
;	int 0x10	 ; BIOS INT
;	jmp fillTheLine ; go back, because i dont know how to create subroutines

clearScreen:
	mov di, 0x0000 ; start offset 
	mov ax, 0xa000 ; VGA mem
	mov es, ax	   ; mov it to ptr
	mov al, 0xaa   ; black color
clearScreenLoop:
	mov es:[di], al ; set pixel
	inc di			; move to next pixel
	cmp di, 64000	; check if we've finished
	jne clearScreenLoop
	;jmp loop
	ret

;mov ah, 0x0e ; set function number of the interrupt 0x10 to display a char

;printString:
;	mov al, [bx]  ; move character to al (bracets means dereference)
;	cmp al, 0x0a  ; compare if it's eol
;	je loop		  ; if it is jump to end
; 	int 0x10	 ; call INT BIOS video service
;	inc bx ; increment pointer
;	jmp printString

loop:
	jmp $ ; infinite loop

gdt_start:

gdt_null:
	dd 0
	dd 0
gdt_code:
	dw 0xffff 	; first 16 bits of the limit (how much memory do we want to use)
	dw 0	  	; 
	db 0    	; this and above is 24 bits of the base (where memory start)
	db 0x9a		; some crazy flags
	db 0xcf  	; here also
	db 0x0	  	; last 8 bits of the base
gdt_data:		; DATA is the same but we have some different flags
	dw 0xffff
	dw 0
	db 0
	db 0x92
	db 0xcf
	db 0
gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1	; size of gdt structure
	dd gdt_start				; start of the structure

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

gotoProtectedMode:
	; TEST START
	mov ax, 0x10
	mov di, ax
	mov ax, 0xa000
	mov es, ax
	mov al, 0x01
	mov es:[di], al
	; TEST END
	;xor ax, ax
	;mov ds, ax
	;cld 		 	; those 3 lines clears some shit
	;mov ah, 0x02 	; function 2 of 13th BIOS INT
	;mov al, 64	 	; read 63 sectors
	;mov ch, 0	 	; from cylinder 0
	;mov cl, 2	 	; sector 2
	;mov dh, 0	 	; head 0
	;xor bx, bx
	;mov es, bx	 	; clear es
	;mov bx, 0x7e00  ; mov 512 bytes from the origin, so outside the bootsector
	;int 0x13	 	; BIOS INT

	cli				; disable interupts
	lgdt [gdt_descriptor]		; Some shit about Global Descriptor Table (GDT)
	mov eax, cr0
	or eax, 1		; Set Protection Enable bit in CR0 
	mov cr0, eax
	jmp CODE_SEG:b32 ;7e00		; jump to this sector

[bits 32]
b32:
	mov ax, DATA_SEG
	mov dx, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, 0x90000
	mov esp, ebp

	jmp KERNEL_LOC
	;mov dl, 0x06
	;mov eax, 0xa0000	
	;add dl, 1
;next_pixel:
	;mov [eax], dl
	;add eax, 1
	;cmp eax, 0xa0000 + 64000
	;je KERNEL_LOC	 ; if we're done with the screen go to kernel
	;jmp next_pixel


times 510-($-$$) db 0x00 ; 
db 0x55
db 0xAA 
