;==================================================
;This procedure handles the mouse interrupt
;==================================================
check_mouse proc uses ax bx cx dx
    ; Check for mouse click
    mov ax, 3   ; Get mouse status
    int 33h
    test bx, 1  ; Check left button
    jz no_click
    ; Get mouse position
    mov ax, 3
    int 33h     ; Automatically enters coordinates for DX and CX
    shr cx, 1   ; Divide CX by 2 to convert from 640x200 to 320x200
    click:
    test bx, 0 ;check if the button is lifted
    jne click
    ; Store mouse position
    mov mouse_x, cx
    mov mouse_y, dx
    call shoot
    no_click:
    ret
check_mouse endp


shoot proc uses ax bx cx dx si di   
    ; Calculate direction
    mov ax, mouse_x
    sub ax, player_x   
    mov bx, player_y
    sub bx, mouse_y
    ; Normalize direction (simple approach)
    cmp ax, 0
    jge shoot_continue
    neg ax          ;In case the difference is negative
    shoot_continue:
    add ax, bx
    mov cx, ax  ; CX = |dx| + |dy|
    ;SI = x step
    mov ax, mouse_x
    sub ax, player_x
    mov dx, 2
    imul dx
    idiv cx
    mov si, ax
    ;DI = y step
    mov ax, mouse_y
    sub ax, player_y
    mov dx, 2
    imul dx  ; Adjust speed here
    idiv cx
    mov di, ax
    shoot_loop:
        ; Move ball
        ;X in AX
        mov ax, player_x
        add ax, si
        ;Y in DX
        mov dx, player_y
        add dx, di
        
        ;Check for Colision
        call check_colision
        cmp bh, 1d
        je end_shoot
        
        ;erase current
        call erase_current_ball
        
        ; Draw ball at new position
        mov location_x, ax
        mov location_y, dx     
        call draw_ball

        ; Small delay
        mov cx, 1000
        delay_loop:
            loop delay_loop
    jmp shoot_loop

    end_shoot:
        ret

shoot endp

; Input: AX = X coordinate, DX = Y coordinate
; Output: BH = 1 if there is colision and 0 if not (bool func)
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
    jne end_shoot
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
            mov es:[di],background_color   ; BL = color at (BX, DX)
            pop di
            inc si
        loop row_erase
        pop cx
        add di, 320d
    loop col_erase
    ret
erase_current_ball endp


;==================================================
;This procedure handles the timer interrupt
;==================================================
new_Int1C proc far uses ax bx es si
    ;down a line
    int 80h                 ; Call DOS interrupt for timer
    iret                    ; Return from interrupt
new_Int1C endp

;==================================================
;This procedure changes the Interrupt Vector Table (IVT) for the timer
;==================================================
IVT_change proc uses ax es
    mov ax, 0h              ; Set segment address to 0
    mov es, ax
    cli                     ; Clear interrupts

    ; Copy old ISR 1C IP to free vector
    mov ax, es:[1Ch*4]     ; Get old ISR IP
    mov es:[80h*4], ax     ; Store IP at free vector
    ; Copy old ISR 1C CS to free vector
    mov ax, es:[1Ch*4+2]   ; Get old ISR CS
    mov es:[80h*4+2], ax   ; Store CS at free vector

    ; Copy IP of new_Int1C to IVT[1C]
    mov ax, offset new_Int1C ; Get new ISR IP
    mov es:[1Ch*4], ax     ; Set new IP in IVT
    ; Copy CS of new_Int1C to IVT[1C]
    mov ax, cs             ; Get new ISR CS
    mov es:[1Ch*4+2], ax   ; Set new CS in IVT

    sti                     ; Set interrupts
    ret
IVT_change endp

;==================================================
;This procedure restores the old Interrupt Vector Table (IVT) for the timer
;==================================================
IVT_return proc uses ax es
    mov ax, 0h              ; Set segment address to 0
    mov es, ax
    cli                     ; Clear interrupts

    ; Copy old ISR 1C IP to IVT[1C]
    mov ax, es:[80h*4]     ; Get old ISR IP from free vector
    mov es:[1Ch*4], ax     ; Set old IP in IVT
    ; Copy old ISR 1C CS to IVT[1C]
    mov ax, es:[80h*4+2]   ; Get old ISR CS from free vector
    mov es:[1Ch*4+2], ax   ; Set old CS in IVT

    sti                     ; Set interrupts
    ret
IVT_return endp