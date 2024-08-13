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
shoot proc uses ax bx cx dx si di   
    ; Load the initial position of the ball (player's position)
    mov ax, init_player_x
    mov bx, init_player_y

    ; Calculate the direction (dx and dy)
    ; dx = (mouse_x - init_player_x)
    ; dy = (mouse_y - init_player_y)
    mov cx, mouse_x
    sub cx, init_player_x    ; cx = dx

    mov dx, mouse_y
    sub dx, init_player_y    ; dx = dy

    ; Start the animation loop
    AnimateBall:
    ; Erase the current ball location
    mov player_x, ax
    mov player_y, bx
    call erase_current_ball

    ; Update ball position
    add ax, cx  ; Update x-position (init_player_x + dx)
    add bx, dx  ; Update y-position (init_player_y + dy)
    
    ; Check for collision
    push ax
    push bx
    mov dx, bx
    call check_colision
    ; If a collision is detected, end the animation
    ; Replace 'CollisionDetected' with the actual flag/register check
    cmp bh, 1
    je EndAnimation
    pop bx
    pop ax

    ; Draw the ball in the new position
    mov location_x, ax
    mov location_y, bx
    call draw_ball

    ; Optional: Delay for the next frame
    mov cx,1000d
    delay:
    loop delay

    ; Loop to continue the animation
    jmp AnimateBall

    EndAnimation:
    pop bx
    pop ax
    ; Animation ends
    ret

shoot endp

;==================================================
; Input: AX = X coordinate, DX = Y coordinate
; Output: BH = 1 if there is colision and 0 if not (bool func)
;==================================================
check_colision proc uses di es si cx
    ; Load the base segment for video memory
    push ax
    mov ax, 0A000h
    mov es, ax
    pop ax
    ; Calculate the offset: (Y * 320) + X
    xor cx,cx
    mov bx, dx        ; BX = Y
    mov cl, 6d
    shl bx, cl        ; BX = Y * 64
    mov di, bx
    mov cl, 2d         ; DI = BX
    shl bx, cl        ; BX = Y * 256
    add di, bx        ; DI = Y * 320 (64 + 256 = 320)
    add di, ax        ; DI = Y * 320 + X
    ;row check
    mov bh, 1d ;setting the default value to be a colision.
    mov cx, 12d
    mov si, 0d
    row_check:
    push di
    add di, si
    mov bl, es:[di]   ; BL = color at (BX, DX)
    pop di
    cmp bl, background_color
    jne end_colision_check
    inc si
    loop row_check

    ; column check
    mov cx, 12d
    mov si, 0d
    col_check:
    push di
    add di, si
    mov bl, es:[di]   ; BL = color at (BX, DX)
    pop di
    cmp bl, background_color
    jne end_colision_check
    push di
    add di, si
    add di, 11d
    mov bl, es:[di]   ; BL = color at (BX, DX)
    pop di
    cmp bl, background_color
    jne end_colision_check
    add si,320d
    loop col_check

    mov bh, 0d ;if the proc got here then there is no colision
    end_colision_check:
    ret
check_colision endp

;==================================================
;This procedure earase the 12x12 pixels in location:
;player_x and player_y
;==================================================
erase_current_ball proc uses ax es bx di si cx
    ; Load the base segment for video memory
    mov ax, 0A000h
    mov es, ax
    ; Calculate the offset: (Y * 320) + X
    xor cx,cx
    mov bx, player_y   ; BX = Y
    mov cl, 6d
    shl bx, cl         ; BX = Y * 64
    mov di, bx         ; DI = BX
    mov cl, 2d
    shl bx, cl         ; BX = Y * 256
    add di, bx         ; DI = Y * 320 (64 + 256 = 320)
    add di, player_x   ; DI = Y * 320 + X
    ;row check
    mov cx, 12d
    col_erase:
        push cx
        mov cx, 12d
        mov si,0d
        row_erase:
            push di
            add di, si
            mov es:[di],background_color
            pop di
            inc si
        loop row_erase
        pop cx
        add di, 320d
    loop col_erase
    ret
erase_current_ball endp