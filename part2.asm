.model small
.stack 100h
.data
	screenPosition dw 2000d
	old_screenPosition dw 2000d
	pointPoistion dw 0d
.code
main proc
    mov ax, @data
    mov ds, ax
    mov es, ax

	D0: ;clear screen
	mov ax, 0B800h ;screen segment
	mov es, ax 
	mov ah, 0h ;setting up colors
	mov cx, 2000d
   
	D01: 
	mov es:[si], ax ;write to screen memory 
	add si, 2h
	
	loop D01
	
	;game initialization
	call draw_pixel
	call pointMaker

main_loop:
    call get_key
    ; call draw_pixel
	call draw_pixel
	;only call pointMaker if pointPoistion and screenPosition
	;are the same
	mov ax, screenPosition
	cmp ax, pointPoistion
	jne no_catch
	;call pointMaker
	no_catch:
	jmp main_loop	

get_key proc
   
	in al, 21h
	or al, 02h
	out 21h, al
	
	PollKeyboard:
	in al, 64h
    test al, 01
	jz PollKeyboard
	in al, 60h
	
    ; Compare scan codes for movement (key release codes are key press code + 80h)
	cmp al, 91h       ; W key release
    je move_up
    cmp al, 9Fh       ; S key release
    je move_down
    cmp al, 9Eh       ; A key release
    je move_left
    cmp al, 0A0h       ; D key release
    je move_right
    cmp al, 94h    ; T key to exit ;TODO: change to T
    je exit_program
    ret
;TODO: EDGES
move_up:
    sub screenPosition, 160
	call Erase_old_position
    ret

move_down:
    add screenPosition, 160
	call Erase_old_position
    ret

move_left:
    sub screenPosition, 2
	call Erase_old_position
    ret

move_right:
    add screenPosition,2
	call Erase_old_position
    ret
get_key endp

Erase_old_position proc
	mov ax, 0B800h ;screen segment
	mov es, ax 
	mov ah, 0h ;setting up color
	mov di, old_screenPosition
	mov es:[di], ax
	
	mov di, screenPosition
	mov old_screenPosition, di
	ret
Erase_old_position endp

draw_pixel proc ;TODO: use screen memory to print and not int
    ; Draw the pixel at current position
    mov ax, 0B800h
    mov es,ax
    mov di, screenPosition
	mov al, 'O'
	mov ah, 4
	mov es:[di],ax



    ret
draw_pixel endp

pointMaker proc
	call get_time 
	mov ax, 0B800h
	mov es,ax
	mov di, pointPoistion
	
	check_bound:
	cmp di, 4000d ;there are 4000 locations on screen
	jae fix_bound ;if di>= 4000d
	
	check_valid:
	test di, 1 ;only even locations are valid
	jz valid_position
	sub di, 1h
	jmp valid_position
	
	fix_bound:
	sub di, 4000d
	jmp check_bound
	
	valid_position:
	mov al, 'A'
	mov ah, 4
	mov es:[di],ax

	ret
		
pointMaker endp

get_time proc
;lower bit is al, high bit is ah? 
;get seconds ;dh is the high bit 
mov al, 00h
out 70h, al
in al, 71h
mov dh, al
;get minutes ;dl is the low bit
mov al, 02h
out 70h, al
in al, 71h
mov dl, al

mov pointPoistion, dx
ret
get_time endp


exit_program:
    ; Exit to DOS
	in al, 21h
	and al, 0FDh
	out 21h,al
	
    mov ax, 4C00h
    int 21h

main endp
end main
