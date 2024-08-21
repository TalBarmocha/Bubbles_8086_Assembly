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
    push ax
    imul di    ; dx * 256
    idiv cx    ; dx_step = (dx * 256) / max_diff
    mov si, ax ; Save the dx step
    pop ax

    ; Calculate dy step
    push ax
    imul di    ; dy * 256
    idiv cx    ; dy_step = (dy * 256) / max_diff
    mov di, ax ; Save the dy step
    pop ax

    move_ball:
    mov cl, 8
    mov ax, player_x
    shl ax, cl
    add ax, si
    shr ax, cl
    mov dx, player_y
    shl dx, cl
    sub dx, di
    shr dx, cl
    
    ;check collision
    call check_collision
    cmp bh, 2
    jne no_wall_collision
    neg si  ; Reverse direction if collision detected
 
    no_wall_collision:
    cmp bh, 1
    je end_anim
    mov location_x, ax
    mov location_y, dx
    
    call erase_current_ball

    mov bl, current_ball
    call draw_ball
    
    ;update player location
    mov player_x, ax
    mov player_y, dx
    
    ; Optional: Delay for the next frame
    mov cx,0AFFFh
    delay:
    loop delay

    ; Loop to continue the animation
    jmp move_ball
    
    end_anim:
    ; Animation ends
    ret

shoot endp

;==================================================
; Input: AX = X coordinate, DX = Y coordinate
; Output: BH = 1 if there is collision with bubles and 2 if there is collision with wall 0 if not (bool func)
;==================================================
check_collision proc uses di es si cx
    mov bh, 0
    cmp ax, 3      
    jbe out_of_range  
    cmp ax, 234   
    jae out_of_range 

    jmp end_wall_check

    out_of_range:
    sub ax, si
    mov bh, 2
 

    end_wall_check:
    ; Load the base segment for video memory
    ;push bx
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
    ;pop bx

    ;row check
    ;push si
    ;mov cx, 12d
    ;mov si, 0d
    ;row_check:
    ;    push di
    ;    add di, si
    ;    mov bl, es:[di]   ; BL = color at (BX, DX)
    ;    pop di
    ;    cmp bl, background_color
    ;    jne bubble_collision
    ;    inc si
    ;loop row_check
    ;pop si

    
    ; column check
    ;cmp si, 0
    ;jb right_col_check
    ;add di, 11 
    ;right_col_check:
    ;mov cx, 12d
    ;mov si, 0d
    ;col_check:
    ;    push di
    ;    add di, si
    ;    mov bl, es:[di]   ; BL = color at (BX, DX)
    ;    pop di
    ;    cmp bl, background_color
    ;    jne bubble_collision
    ;    add si,320d
    ;loop col_check
    

    ;cmp bh, 1
    ;jne end_collision_check

    ;bubble_collision:
    ;mov bh, 1

    end_collision_check:
    ret
check_collision endp

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