;==================================================
;This procedure handles the mouse interrupt
;==================================================
check_mouse proc uses ax bx cx dx
    ; Check for mouse click and get mouse position
    mov ax, 3
    int 33h
    test bx, 1          ; Check left button
    jz no_click         ; If not clicked, skip to no_click

    shr cx, 1           ; Divide CX by 2 to convert from 640x200 to 320x200
    mov mouse_x, cx
    mov mouse_y, dx

    wait_release:
    mov ax, 3
    int 33h
    test bx, 1          ; Check if the button is still pressed
    jnz wait_release    ; If pressed, wait for release

    ;stop counting time
    call IVT_return
    ; Check bounds (assuming 320x200 resolution)
    cmp mouse_x, 5      
    jbe no_click  
    cmp mouse_x, 245    
    jae no_click
    cmp mouse_y, 173
    jae no_click

    ;hide cursor
    mov ax, 2
    int 33h
    ;do function
    call shoot
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
    ;reset player_x and player_y location
    mov player_x, init_player_x
    mov player_y, init_player_y
    ;continue time check
    call IVT_change
    ;show cursor
    mov ax, 1
    int 33h

    no_click:
    ret
check_mouse endp

;==================================================
;This procedure creates the shoot animation
;==================================================
shoot proc uses ax bx cx dx si di
    ; Assume:
    ; player_x and player_y contain the current ball position
    ; mouse_x and mouse_y contain the mouse target position

    ;Calculate differences
    mov ax, mouse_x
    sub ax, player_x  ; AX = dx
    ;player_y >= mouse_y for evert y.
    mov bx, player_y
    sub bx, mouse_y   ; BX = dy (note the reversal here)

    ; Get absolute value of dx
    mov cx, ax
    cmp cx, 0
    jge abs_done
    neg cx
    abs_done:

    ; Compare |dx| with dy to find the larger difference
    cmp cx, bx
    jge use_cx
    mov cx, bx    ; If dy is larger, use it for normalization
    use_cx:
    ; CX = max{|dx|,|dy|}
    
    ; Normalize dx and dy to produce fractional steps
    ; Calculate si = dx * 256 / max{|dx|, |dy|}
    ; Calculate di = dy * 256 / max{|dx|, |dy|}
    mov di, 256  ; formatting to 8.8 float foramt
    
    ; Calculate dx step
    imul di    ; dx * 256
    idiv cx    ; dx_step = (dx * 256) / max_diff
    mov si, ax ; Save the dx step

    ; Calculate dy step
    mov ax, bx
    imul di    ; dy * 256
    idiv cx    ; dy_step = (dy * 256) / max_diff
    mov di, ax ; Save the dy step

    ;foramting to 8.8 AX and DX
    mov cl, 8
    mov ax, player_x
    shl ax, cl
    mov dx, player_y
    shl dx, cl
    mov player_x, ax
    mov player_y, dx

    move_ball:
    mov ax, player_x
    add ax, si
    mov dx, player_y
    sub dx, di
    ;AX = player_x + dx foramt 8.8
    ;DX = player_y + dy foramt 8.8
    
    ;check collision
    push ax
    push dx
    ;convert to normal
    mov cl, 8
    shr ax, cl
    shr dx, cl
    ;check collision
    call check_collision
    cmp colli_stat, 2
    jne no_wall_colli
    neg si  ; Reverse direction if collision detected
 
    no_wall_colli:
    cmp colli_stat, 1
    je end_anim
    call erase_current_ball
    cmp dx, 161d
    jb no_line_need
    call draw_limit_line
    no_line_need:
    mov location_x, ax
    mov location_y, dx
    mov bl, current_ball
    call draw_ball
    pop dx
    pop ax
    ;update player location
    mov player_x, ax
    mov player_y, dx

    ; Optional: Delay for the next frame
    mov cx,07FFFh
    delay:
    loop delay
    
    ; Loop to continue the animation
    jmp move_ball
    
    end_anim:
    ; Animation ends
    pop dx
    pop ax
    ;erasure the old ball
    call erase_current_ball
    ;arrangement of the ball's position in the grid
    call update_ball_front_grid
    call update_ball_back_grid
    ;drowing the new ball in the right location
    mov location_x, player_x
    mov location_y, player_y
    mov bl, current_ball
    call draw_ball

    ret
shoot endp

;==================================================
; Input: AX = X coordinate, DX = Y coordinate
; Output: colli_stat = 1 if there is collision with bubles and 2 if there is collision with wall 0 if not (bool func)
;==================================================
check_collision proc uses di es si cx
    mov colli_stat, 0
    cmp ax, 4      
    jbe out_of_range  
    cmp ax, 234   
    jae out_of_range 

    jmp end_wall_check

    out_of_range:
    mov colli_stat, 2
    jmp wall_end
 

    end_wall_check:
    ; Load the base segment for video memory
    push bx
    mov bx, 0A000h
    mov es, bx
    ; Calculate the offset: (Y * 320) + X
    push di
    xor cx,cx
    mov bx, dx        ; BX = Y
    mov cl, 6d
    shl bx, cl        ; BX = Y * 64
    mov di, bx
    mov cl, 2d        ; DI = BX
    shl bx, cl        ; BX = Y * 256
    add di, bx        ; DI = Y * 320 (64 + 256 = 320)
    add di, ax        ; DI = Y * 320 + X
    mov space_point, di
    pop di
    pop bx

    ; save DX and AX 
    push ax
    push dx
    mov cl, 8d
    mov si, player_x
    shr si, cl
    sub ax, si
    mov di, player_y
    shr di, cl
    sub di, dx
    mov dx, di
    ;result: 
    ;ax = number of pixels moved in X axis
    ;dx = number of pixels moved in Y axis
    mov di, space_point
    ;row check
    cmp dx, 0
    je colchck
    add di, 2d
    mov cx, 8d
    xor si, si
    row_check:
        push di
        add di, si
        mov bl, es:[di]   ; BL = color at (AX, DX)
        pop di
        cmp bl, 48d
        jbe bubble_collision
        inc si
    loop row_check
    
    mov di, space_point
    colchck:
    ; column check
    cmp ax, 0
    je end_colli_chck
    jl left_col_check
    add di, 11
    left_col_check:
    add di, 640d
    mov cx, 8d
    xor si,si
    col_check:
        push di
        add di, si
        mov bl, es:[di]   ; BL = color at (AX, DX)
        pop di
        cmp bl, 48d
        jbe bubble_collision
        add si, 320d
    loop col_check
    

    cmp colli_stat, 1
    jne end_colli_chck

    bubble_collision:
    mov colli_stat, 1

    end_colli_chck:
    pop dx
    pop ax
    wall_end:
    ret
check_collision endp

;==================================================
;This procedure earase the 12x12 pixels in location:
;player_x and player_y
;==================================================
erase_current_ball proc uses cx di ax dx
    ; Load the base segment for video memory
    push player_y
    push player_x
    mov cl, 8
    mov ax, player_x
    mov dx, player_y
    shr ax ,cl
    shr dx ,cl
    mov player_x ,ax
    mov player_y ,dx
    xor di, di          ; Initialize di (result index)
    mov cx, 12       
    erase_col:
        push cx             ; Preserve cx (inner loop count)
        push player_x
        mov cx,12  
        erase_row:
            mov al, ball[di]       
            cmp al,99
            je erase_continiue
            mov al, background_color  
            push cx
            mov ah,0Ch 
            mov cx,player_x
            mov dx,player_y
            int 10h
            pop cx
            erase_continiue:
            inc di                ; Move to next pixal in result matrix
            inc player_x
        loop erase_row
        pop player_x
        inc player_y
        pop cx                  ; Restore cx (inner loop count)
    loop erase_col
    pop player_x 
    pop player_y
    ret
erase_current_ball endp

;==================================================
;This procedure adjusts the corrected position of the ball relative to the grid
;player_x
;==================================================
update_ball_front_grid proc uses ax bx dx
    mov ax, player_x
    
    ; Apply modulo 12
    mov bx, 12
    div bx          ; AX = AX / 12, DX = remainder
    ; The result is in DX, the result is in range [0,11]
    
    cmp dx, 11
    jne stick_left
    cmp dx, 5
    jae stick_left
    
    ; Stick_right
    sub dx, 6
    cmp dx, 0
    jge abs_dx_done
    neg dx
    abs_dx_done:
    add ax, dx
    mov player_x, ax
    jmp end_new_grid
    
    ; Stick_left
    stick_left:
    sub dx, 6
    cmp dx, 0
    jge abs_dx_done
    neg dx
    abs_dx_done:
    sub ax, dx
    mov player_x, ax

    end_new_grid:
    ret
update_ball_front_grid endp