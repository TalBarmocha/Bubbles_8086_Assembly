GAME_START proc
    ;reload game
    call background
    call game_frame
    call print_score
    call draw_timer
    ;draw initial ball lines
    mov cx,6d
    call get_sec_RTC
    call draw_balls_line
    game_lines:
        call shift_visual
        call draw_balls_line
    loop game_lines
    ;draw player, lives and next ball
    call get_currBall_nxtBall
    ;Draw Player
    mov location_x, init_player_x
    mov location_y, init_player_y
    mov bl,current_ball
    call draw_ball
    ;Draw Next Ball
    mov location_x, 278d
    mov location_y, 100d
    mov bl,next_ball
    call draw_ball
    ;Draw lifes:
    call draw_lifes
    call draw_limit_line
    ret
GAME_START endp


;==================================================
;This procedure fill the background in tilt color
;==================================================
background proc uses di ax cx
    ; Set the segment register to point to video memory
    mov ax, 0A000h
    mov es, ax

    ; Register initialization
    xor di, di                        ; di = 0, start at the beginning of the video memory
    mov al, background_color          ; al = 100d, the color to fill the screen with

    ; Calculate the total number of pixels (320 * 200 = 64000)
    mov cx, 32000             ; CX will be 32000, will iterate over 64000 bytes since 2 pixels are stored per iteration

    FillLoop:
        stosb                 ; Store AL into ES:[DI] and increment DI
        stosb                 ; Store AL into ES:[DI] and increment DI
    loop FillLoop             ; Decrement CX and loop if CX is not zero

    ret
background endp

;==================================================
;This procedure drew a 12x12 ball on the screen
;the color of the ball is in BL
;starting at location_x and location_y as the
;top left cornet of the ball
;==================================================
draw_ball proc uses cx di ax dx
    xor di, di          ; Initialize di (result index)
    mov cx, 12
    push location_y
    push location_x          
    ball_columns:
        push cx             ; Preserve cx (inner loop count)
        push location_x
        mov cx,12  
        ball_rows:
            mov al, ball[di]       
            cmp al,99
            je ball_continiue
            cmp al,98
            jne draw
            mov al,bl
            draw:
            push cx
            mov ah,0Ch
            mov cx,location_x
            mov dx,location_y
            int 10h
            pop cx
            ball_continiue:
            inc di                ; Move to next pixal in result matrix
            inc location_x
        loop ball_rows
        pop location_x
        inc location_y
        pop cx                  ; Restore cx (inner loop count)
    loop ball_columns
    pop location_x 
    pop location_y
    ret
draw_ball endp

;==================================================
;This procedure draw a 12x12 number stored in BL on the screen
;starting at location_x and location_y as the
;top left cornet of the number
;==================================================
draw_num proc uses cx di ax dx
    xor bh,bh
    xor di, di          ; Initialize di (result index)
    mov cx, 12
    ; Load address of number font
    mov dx, offset font_numbers
    mov si,bx
    add si,bx
    add si,dx                   ;SI = *font_numbers[bl]
    mov bx,[si]
    push location_x 
    push location_y         
    num_columns:
        push cx             ; Preserve cx (inner loop count)
        push location_x
        mov cx,12  
        num_rows:
            mov al,[bx+di]  
            push cx
            mov ah,0Ch
            mov cx,location_x
            mov dx,location_y
            int 10h
            pop cx
            inc di                ; Move to next pixal in result matrix
            inc location_x
        loop num_rows
        pop location_x
        inc location_y
        pop cx                  ; Restore cx (inner loop count)
    loop num_columns
    pop location_y
    pop location_x 
    ret
draw_num endp

;==================================================
;This procedure draws a line of 20 balls
;==================================================
draw_balls_line proc uses ax bx cx dx si di
    push location_x
    mov cx, 4d
    balls_line:
        call random_picker
        mov dx, offset color_addresses
        mov si,color_picker
        add si,si
        add si,dx                       
        mov bx,[si]         ;load the address of color#color_picker into BX           
        push cx
        mov cx, 5d
        xor di,di
        draw_color_set:
        push bx
        mov al,[bx+di]
        ;draw ball
        mov bl,al
        call draw_ball
        pop bx
        add location_x, 12d
        inc di
        loop draw_color_set
        pop cx
    loop balls_line
    pop location_x
    ret
draw_balls_line endp

;==================================================
;This procedure prints the frame of the board
;==================================================
game_frame proc uses ax cx dx si di
    xor di,di
    mov ax, 0A000h
    mov es, ax
    mov cx, 246
    top:
    mov al, 0d
    mov es:[di], ax
    mov si,320d
    add si,di
    mov al, 8d
    mov es:[si], ax
    mov al, 7d
    add si,320d
    mov es:[si], ax
    add si,320d
    mov al, 0d
    mov es:[si], ax
    inc di
    loop top
    
    mov di,62720d
    mov ax, 0A000h
    mov es, ax
    mov cx, 246
    bottom:
    mov al, 0d
    mov es:[di], ax
    mov si,320d
    add si,di
    mov al, 8d
    mov es:[si], ax
    mov al, 7d
    add si,320d
    mov es:[si], ax
    add si,320d
    mov al, 0d
    mov es:[si], ax
    inc di
    loop bottom
    
    xor di,di
    mov ax, 0A000h
    mov es, ax
    mov cx, 200
    left:
    mov al, 0d
    mov es:[di], ax
    mov si,1d
    add si,di
    mov al, 8d
    mov es:[si], ax
    mov al, 7d
    add si,1d
    mov es:[si], ax
    add si,1d
    mov al, 0d
    mov es:[si], ax
    add di, 320d
    loop left

    mov di, 246
    mov ax, 0A000h
    mov es, ax
    mov cx, 200
    right:
    mov al, 0d
    mov es:[di], ax
    mov si,1d
    add si,di
    mov al, 7d
    mov es:[si], ax
    mov al, 8d
    add si,1d
    mov es:[si], ax
    add si,1d
    mov al, 0d
    mov es:[si], ax
    add di, 320d
    loop right

    mov di,4d
    mov si,4d
    fixes_left:
    mov al,100d
    mov ah,0Ch
    mov cx,di
    mov dx,si
    int 10h
    inc si
    cmp si,196d
    jb fixes_left 

    mov di,250d
    mov si,0d
    fixes_right:
    mov al,100d
    mov ah,0Ch
    mov cx,di
    mov dx,si
    int 10h
    inc si
    cmp si,200d
    jb fixes_right 

    ret                         ; Return from procedure
game_frame endp

;==================================================
;This procedure prints the score to the screen
;==================================================
print_score proc uses ax bx cx dx
    push location_x
    push location_y
    mov location_x, 300d
    mov location_y, 25d
    mov ax, score
    mov cx,5
    draw_score:
    xor dx,dx
    mov bx, 10d
    div bx      ;AX = AX / BX(10) , DX = Remainder
    xor bx,bx
    mov bl,dl
    call draw_num
    sub location_x, 11d
    loop draw_score
    pop location_y
    pop location_x
    ret
print_score endp

;==================================================
;This procedure determans the color of the current ball and the next ball
;==================================================
get_currBall_nxtBall proc uses ax bx dx si
    call random_picker
    mov dx, offset color_addresses
    mov si,color_picker
    add si,si
    add si,dx                       
    mov bx,[si]         ;load the address of color#color_picker into BX          
    mov al,[bx+4]         ;AL store the generated color
    cmp current_ball, 0d
    jne premote_balls
    mov current_ball,al
    mov al,[bx+3]
    mov next_ball,al
    ret
    premote_balls:
    mov bl, next_ball
    mov current_ball, bl
    mov next_ball,al
    ret
get_currBall_nxtBall endp

;==================================================
;This procedure prints the limit line of the game
;==================================================
draw_limit_line proc uses ax cx dx si di
    ;y = 173, x = 4
    xor di,di
    mov ax, 0A000h
    mov es, ax
    mov di, 55364
    mov cx, 242
    limit_line:
    mov al, 78d
    mov es:[di], ax
    inc di
    loop limit_line
    ;fix last pixel
    mov al, 0d
    mov ah, 0Ch
    mov cx, 246d
    mov dx, 173d
    int 10h
    ret
draw_limit_line endp

shift_visual proc uses es si di ax bx cx dx
    ;5 < y < 161, 5< x < 245 ; move 3840 pixel to shift 12 lines down
    ;start pixel 51765
    ;hide cursor
    mov ax, 2
    int 33h
    ;start shift
    mov ax, 0A000h
    mov es, ax
    mov si, 3840d
    mov cx, 157d
    mov bx, 51445d
    y_down_loop:
        push cx
        mov cx, 243d
        shift_down:
            mov di, si
            add di, bx
            mov dl, es:[bx]
            mov es:[di],dl
            dec bx
        loop shift_down
        sub bx, 77
        pop cx
    loop y_down_loop
    call end_game_chck
    ;show cursor
    mov ax, 1
    int 33h
    ;return
    ret
shift_visual endp

;==================================================
;This procedure draw a 16x16 frame of timer
;the number of the frame is stored in down_time_counter
;starting at location_x and location_y as the
;top left cornet of the number
;==================================================
draw_timer proc uses ax bx cx dx di
    xor bh,bh
    mov bl,down_time_counter
    push location_x 
    push location_y 
    xor di, di          ; Initialize di (result index)
    mov cx, 16
    ; Load address of number font
    mov dx, offset clock_frames
    mov si,bx
    add si,bx
    add si,dx                   ;SI = clock_frames[bl]
    mov bx,[si]
    mov location_x, 278d
    mov location_y, 60d       
    timer_col:
        push cx             ; Preserve cx (inner loop count)
        push location_x
        mov cx,16  
        timer_row:
            mov al,[bx+di]  
            cmp al, 1
            jne timer_continiue
            mov al, 42d
            timer_continiue:
            cmp al, 0
            jne t_draw
            mov al, 100d
            t_draw:
            push cx
            mov ah,0Ch
            mov cx,location_x
            mov dx,location_y
            int 10h
            pop cx
            inc di                ; Move to next pixal in result matrix
            inc location_x
        loop timer_row
        pop location_x
        inc location_y
        pop cx                  ; Restore cx (inner loop count)
    loop timer_col
    pop location_y
    pop location_x 
    ret
draw_timer endp

draw_lifes proc uses cx bx
    xor ch, ch
    push location_x
    push location_y
    mov cl,lifes
    mov bl,27d ;light gray
    mov location_x, 278d
    mov location_y, 114d
    print_lifes:
        call draw_ball
        add location_y,14d
    loop print_lifes
    pop location_y
    pop location_x
    ret
draw_lifes endp