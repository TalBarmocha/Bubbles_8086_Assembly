.model small        
.stack 100h         

.data
;Graphics:
INCLUDE fontdata.asm
INCLUDE colors.asm
;INCLUDE manu.asm
location_x DW 05d
location_y DW 05d
background_color DB 100d
;Balls:
color_picker DW 0d
current_ball DB 0d
next_ball DB 0d
seed DW 1d
;Game:
score DW 0d  ; MAX score is ≈ 64K -> limit max score to 50K
lifes DB 5d

.code
GAME_START proc
    mov ax, @data               ; Load data segment address into AX
    mov ds, ax                  ; Move data segment address to DS
    ;set graphic mode
    mov ah, 00h
    mov al, 13h
    int 10h
    ;reload game
    call background
    call game_frame
    call print_score
    ;call manu
    ;draw initial ball lines
    mov cx,7d
    call get_sec_RTC
    game_lines:
        call draw_balls_line
        add location_y,12d
    loop game_lines

    ;draw player, lives and next ball
    call get_currBall_nxtBall
    ;Draw Player
    mov location_x, 119d
    mov location_y, 180d
    mov bl,current_ball
    call draw_ball
    ;Draw Next Ball
    mov location_x, 05d
    mov location_y, 180d
    mov bl,next_ball
    call draw_ball
    ;Draw lifes:
    mov cl,lifes
    mov bl,27d ;light gray
    mov location_x, 19d
    mov location_y, 180d
    print_lifes:
        call draw_ball
        add location_x,14d
    loop print_lifes
    
    ;wait for key press to continue 
    mov ah, 00h
    int 16h
    ;exit
    ;move back to taxt mode
    mov ah, 00h
    mov al, 03h
    int 10h
    mov ah, 4Ch                ; Terminate the program
    int 21h                    ; DOS interrupt to exit
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
            cmp al,99
            je num_continiue
            push cx
            mov ah,0Ch
            mov cx,location_x
            mov dx,location_y
            int 10h
            pop cx
            num_continiue:
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
;This procedure reads the RTC seconds and update the seed
;range of seed is: [0,89]
;==================================================
get_sec_RTC proc uses ax
    xor ax,ax
    mov al, 00h              ; Select RTC register for seconds
    out 70h, al             ; Set RTC register address
    in al, 71h              ; Read seconds value and store it in AL
    mov seed,ax
    ret
get_sec_RTC endp

;==================================================
;This procedure randomize a color set of 5 colors.
;and stores the number of the set in color_picker [0,120]
;using LCG algorithem to to pick a random color set.
;==================================================
random_picker proc uses ax dx bx
    ; Load seed  value into AX
    mov ax, seed
    ; a = 57, c = 17, m = 121
    ; result = (57 * ax + 17) % 121
    mov bx, 57
    mul bx          ; DX:AX = AX * 57
    add ax, 17       ; AX + 17
    ; Apply modulo 121 (m = 121)
    mov bx, 121
    div bx          ; AX = AX / 121, DX = remainder
    ; The result is in DX
    mov ax, dx      ; Move the result to AX is in range [0,120]
    check_ax:
    cmp ax, 120           ; Check if AX > 120d
    jae normalize           ; If so, normalize AX
    mov color_picker, ax
    mov seed,ax
    ret
    normalize:
    sub AX, 1            
    jmp check_ax           ; Continue checking
random_picker endp

;==================================================
;This procedure draws a  line of 20 balls
;==================================================
draw_balls_line proc uses bx cx dx si di
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
    mov al,[bx]         ;AL store the generated color
    cmp current_ball, 0d
    jne premote_balls
    mov current_ball,al
    mov al,[bx+1]
    mov next_ball,al
    ret
    premote_balls:
    mov bl, next_ball
    mov current_ball, bl
    mov next_ball,al
    ret
get_currBall_nxtBall endp

end GAME_START