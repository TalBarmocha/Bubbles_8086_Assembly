.model small        
.stack 100h         

.data
;Graphics:
include fontdata.asm
include colors.asm
include timer.asm
init_row_x equ 05d
init_row_y equ 05d
location_x DW init_row_x
location_y DW init_row_y
colli_stat DB 0d
background_color equ 100d
space_point DW 0d
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
down_time DB 20d
down_time_counter DB 0d
clock_counter DB 0d
end_game_T_F DB 0d
;search algo
scan_counter DW 0d
visted_ball DW 0 0 ;visted_ball[0] == x_position, visted_ball[1] == y_position
balls_2_explo DW 280 DUP(0)


.code
include mouse.asm
include graphics.asm
include time.asm
include random.asm
include explo.asm
include converting.asm
main proc
    mov ax, @data               ; Load data segment address into AX
    mov ds, ax                  ; Move data segment address to DS
    call IVT_change
    ;set graphic mode
    mov ah, 00h
    mov al, 13h
    int 10h
    RestartGame:
    call GAME_START
    ;init cursor
    mov ax, 0h
    int 33h
    ;show cursor
    mov ax, 1
    int 33h
    main_loop:
    ; Check if a key is pressed
    cmp end_game_T_F, 1
    je exit
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
    ;restart
    restart:
        xor ax, ax
        xor bx, bx
        xor cx, cx
        xor dx, dx
        xor di, di
        xor si, si
        mov score, 0d
        mov lifes, 5d
        mov color_picker, 0d
        mov current_ball, 0d
        mov next_ball, 0d
        mov location_x, 05d
        mov location_y, 05d
        mov player_x, init_player_x
        mov player_y, init_player_y
        mov down_time, 20d
        mov down_time_counter, 0d
        mov clock_counter, 0d
        mov end_game_T_F, 0d
        ;hide cursor
        mov ax, 2
        int 33h
        jmp RestartGame

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

; return BH = 0 if the game countines, BH = 1 if the line is covered
end_game_chck proc uses ax cx dx si di
    ;y = 173, x = 4
    xor bh, bh
    xor di,di
    mov ax, 0A000h
    mov es, ax
    mov di, 55044
    mov cx, 242
    end_game_loop:
    mov al,es:[di]
    cmp al, 78d
    ja no_touch
    mov cx, 1d
    mov bh, 1d
    no_touch:
    inc di
    loop end_game_loop
    mov end_game_T_F, bh
    ret
end_game_chck endp

end main