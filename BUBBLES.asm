.model small        
.stack 100h         

.data
;Graphics:
include fontdata.asm
include colors.asm
;include manu.asm
location_x DW 05d
location_y DW 05d
background_color equ 100d
;Balls:
color_picker DW 0d
current_ball DB 0d
next_ball DB 0d
seed DW 1d
;Game:
score DW 0d  ; MAX score is ≈ 64K -> limit max score to 50K
lifes DB 5d
init_player_x equ 119d
init_player_y equ 180d
player_x DW init_player_x
player_y Dw init_player_y
mouse_x DW 0d
mouse_y DW 0d

.code
include mouse.asm
include graphics.asm
include time.asm
include random.asm
main proc
    mov ax, @data               ; Load data segment address into AX
    mov ds, ax                  ; Move data segment address to DS
    call IVT_change
    ;set graphic mode
    mov ah, 00h
    mov al, 13h
    int 10h
    call GAME_START
    ;init cursor
    mov ax, 0h
    int 33h
    ;show cursor
    mov ax, 1
    int 33h
    main_loop:
    ; Check if a key is pressed
    call check_mouse
    
    mov ah, 1          ; Function 01h: Check for keystroke availability
    int 16h            ; BIOS keyboard interrupt
    jz main_loop       ; If no key is pressed, continue looping

    ; If a key is pressed, get the key
    mov ah, 0          ; Function 00h: Get keystroke
    int 16h            ; BIOS keyboard interrupt

    cmp al, 'q'        ; Compare the pressed key with 'q'
    je exit      ; If not 'q', continue looping
    cmp al, 'r'
    je restart
    jmp main_loop
    restart:
        mov score, 0d
        mov lifes, 5d
        mov color_picker, 0d
        mov current_ball, 0d
        mov next_ball, 0d
        mov location_x, 05d
        mov location_y, 05d
        call GAME_START
    jmp main_loop
    ;exit
    exit:
    call IVT_return
    mov ah, 00h
    mov al, 03h
    int 10h
    mov ah, 4Ch                ; Terminate the program
    int 21h                    ; DOS interrupt to exit
main endp 

end main