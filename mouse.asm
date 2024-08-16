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

    ; Check bounds (assuming 320x200 resolution)
    cmp mouse_x, 3      
    jbe no_click  
    cmp mouse_x, 242    
    jae no_click 

    ;hide cursor
    mov ax, 2
    int 33h
    ;do function
    call shoot
    ;show cursor
    mov ax, 1
    int 33h

    no_click:
    ret
check_mouse endp

;==================================================
;This procedure creates the shoot animation
;==================================================
shoot proc uses ax bx cx dx   
    ; Assume:
    ; player_x and player_y contain the current ball position
    ; dx_ball and dy_ball will store the movement values
    
    ;Calculate differences
    mov ax, mouse_x
    sub ax, player_x  ; AX = dx
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
    
    ; Set dy_ball to our constant upward speed
    mov di, 1
    
    ; Calculate dx_ball
    imul di       ; Multiply by step size
    idiv cx       ; Divide by max difference
    mov si, ax
    

    move_ball:
    mov ax, player_x
    add ax, si
    mov dx, player_y
    sub dx, di
    
    ;check collision
    call check_colision
    cmp bh, 2
    jne no_wall_collision
    neg si  ; Reverse direction if collision detected

    
    no_wall_collision:
    cmp bh, 1
    je EndAnimation
    mov location_x, ax
    mov location_y, dx
    
    call erase_current_ball

    mov bl, current_ball
    call draw_ball
    
    ;update player location
    cmp bh, 2
    je skip_update
    mov player_x, ax
    mov player_y, dx
    
    skip_update:
    ; Optional: Delay for the next frame
    mov cx,0FFFFh
    delay:
    loop delay

    ; Loop to continue the animation
    jmp move_ball
    
    EndAnimation:
    ; Animation ends
    ret

shoot endp

;==================================================
; Input: AX = X coordinate, DX = Y coordinate
; Output: BH = 1 if there is colision and 0 if not (bool func)
;==================================================
check_colision proc uses di es si cx
    cmp ax, 3      
    jbe out_of_range  
    cmp ax, 242    
    jae out_of_range 

    jmp end_wall_check

    out_of_range:
    sub ax, si
    mov bh, 2
    jmp end_colision_check
 

    end_wall_check:
    mov bh, 1
    ; Load the base segment for video memory
    ;push ax
    ;mov ax, 0A000h
    ;mov es, ax
    ;pop ax
    ; Calculate the offset: (Y * 320) + X
    ;xor cx,cx
    ;mov bx, dx        ; BX = Y
    ;mov cl, 6d
    ;shl bx, cl        ; BX = Y * 64
    ;mov di, bx
    ;mov cl, 2d        ; DI = BX
    ;shl bx, cl        ; BX = Y * 256
    ;add di, bx        ; DI = Y * 320 (64 + 256 = 320)
    ;add di, ax        ; DI = Y * 320 + X

    ;row check
    ;mov bh, 1d ;setting the default value to be a collision
    ;mov cx, 12d
    ;mov si, 0d
    ;row_check:
    ;push di
    ;add di, si
    ;mov bl, es:[di]   ; BL = color at (BX, DX)
    ;pop di
    ;cmp bl, background_color
    ;jne end_colision_check
    ;inc si
    ;loop row_check

    ; column check
    ;mov cx, 12d
    ;mov si, 0d
    ;col_check:
    ;push di
    ;add di, si
    ;mov bl, es:[di]   ; BL = color at (BX, DX)
    ;pop di
    ;cmp bl, background_color
    ;jne end_colision_check
    ;push di
    ;add di, si
    ;add di, 11d
    ;mov bl, es:[di]   ; BL = color at (BX, DX)
    ;pop di
    ;cmp bl, background_color
    ;jne end_colision_check
    ;add si,320d
    ;loop col_check

    mov bh, 0d ;if the proc got here then there is no colision
    end_colision_check:
    ret
check_colision endp

;==================================================
;This procedure earase the 12x12 pixels in location:
;player_x and player_y
;==================================================
erase_current_ball proc uses cx di ax dx
    ; Load the base segment for video memory
    xor di, di          ; Initialize di (result index)
    mov cx, 12
    push player_y
    push player_x 
    mov al, background_color         
    erase_col:
        push cx             ; Preserve cx (inner loop count)
        push player_x
        mov cx,12  
        erase_row:
            push cx
            mov ah,0Ch
            mov cx,player_x
            mov dx,player_y
            int 10h
            pop cx
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