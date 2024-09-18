explosion proc uses si ax dx
    array_explo:
        mov si, scan_counter
        dec si
        shl si, 1 ; SI = (scan_counter - 1) * 2
        mov ax, balls_2_explo[si]
        call loc_decode
        mov location_x, ax
        mov location_y, dx
        call explosion_anim
        mov balls_2_explo[si],0
        dec scan_counter
        cmp scan_counter, 0
    ja array_explo

    ;explode the player ball
    mov ax, player_x
    mov dx, player_y
    mov location_x, ax
    mov location_y, dx
    call explosion_anim
    ret
explosion endp

;==================================================
;This procedure draw a 12x12 animation of explotion
;with delay
;starting at location_x and location_y as the
;top left cornet of the number
;==================================================
explosion_anim proc uses bx cx
    mov bl, 0
    animation_loop:
    call animation_frame
    inc bl

    ;add delay
    mov cx,0FFFFh
    animation_delay:
    loop animation_delay
    mov cx,00FFFh
    animation_delay1:
    loop animation_delay1
    
    cmp bl,6
    jb animation_loop
    ret
explosion_anim endp

;==================================================
;This procedure draw a 12x12 frame of explotion
;the number of the frame is stored in BL
;starting at location_x and location_y as the
;top left cornet of the number
;==================================================
animation_frame proc uses ax bx cx dx di si
    xor bh,bh
    xor di, di          ; Initialize di (result index)
    mov cx, 12
    ; Load address of number font
    mov dx, offset explosion_frames
    mov si,bx
    shl si,1
    add si,dx                   ;SI = *explosion_frames[bl]
    mov bx,[si]
    push location_x 
    push location_y         
    frame_col:
        push cx             ; Preserve cx (inner loop count)
        push location_x
        mov cx,12  
        frame_row:
            mov al,[bx+di]
            cmp al,99
            je skip_pixal  
            cmp al,98
            jne frame_continiue
            mov al,current_ball
            frame_continiue:
            push cx
            mov ah,0Ch
            mov cx,location_x
            mov dx,location_y
            int 10h
            pop cx
            skip_pixal:
            inc di                ; Move to next pixal in result matrix
            inc location_x
        loop frame_row
        pop location_x
        inc location_y
        pop cx                  ; Restore cx (inner loop count)
    loop frame_col
    pop location_y
    pop location_x 
    ret
animation_frame endp

;takes player_x and player_y and scans the radius of the ball
scan proc uses ax bx cx dx si
    mov scan_counter, 0
    mov ax, player_x
    mov dx, player_y
    ;Calculate the offset: (Y * 320) + X
    call loc_incode
    ;AX = Y * 320 + X
    ;left
    mov si, ax
    sub si, 5d
    add si, 3520d
    mov cx, 16d
    left_scan:
        mov bl, es:[si]
        cmp bl, 15d
        jne end_left_scan
        cmp es:[si+320], bl
        jz end_left_scan
        cmp es:[si-320], bl
        jz end_left_scan
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_left_scan
        push si
        sub si, 7d
        sub si, 960d
        mov bx, scan_counter
        shl bx, 1
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_left_scan

        end_left_scan:
        sub si, 320d
        dec cx
        cmp cx , 0d 
    jnz left_scan

    ;top left
    mov si, ax
    sub si, 5d
    sub si, 1600d
    mov cx,2
    top_left1:
        mov bl, es:[si]
        cmp bl, 15d
        jne end_top_left1
        cmp es:[si+320], bl
        jz end_top_left1
        cmp es:[si-320], bl
        jz end_top_left1
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_top_left1
        push si
        sub si, 7d
        sub si, 960d
        mov bx, scan_counter
        shl bx, 1
        mov balls_2_explo[bx],si
        pop si
        end_top_left1:
        inc si
    loop top_left1

    sub si, 322d  ;up one row and two pixels to the left
    mov cx,3
    top_left2:
        push cx
        push si
        mov cx,3
        trio_top_left:
            mov bl, es:[si]
            cmp bl, 15d
            jne end_top_left2
            cmp es:[si+320], bl
            jz end_top_left2
            cmp es:[si-320], bl
            jz end_top_left2
            mov dl, current_ball
            cmp es:[si-320], dl
            jne end_top_left2
            push si
            sub si, 7d
            sub si, 960d
            mov bx, scan_counter
            shl bx, 1
            mov balls_2_explo[bx],si
            pop si
            inc scan_counter
            end_top_left2:
            inc si
        loop trio_top_left
        pop si
        pop cx
        sub si, 319 ;up one row and one pixel to the right
    loop top_left2
    
    ;right
    mov si, ax
    add si, 19d
    add si, 3520d
    mov cx, 16d
    right_scan:
        mov bl, es:[si]
        cmp bl, 15d
        jne end_right_scan
        cmp es:[si+320], bl
        jz end_right_scan
        cmp es:[si-320], bl
        jz end_right_scan
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_right_scan
        push si
        sub si, 7d
        sub si, 960d
        mov bx, scan_counter
        shl bx, 1 
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_right_scan
    
        end_right_scan:
        sub si, 320d
        dec cx
        cmp cx , 0d 
    jnz right_scan
    
    ;top right
    mov si, ax
    add si, 19d
    sub si, 1600d
    mov cx,2
    top_right1:
        mov bl, es:[si]
        cmp bl, 15d
        jne end_top_right1
        cmp es:[si+320], bl
        jz end_top_right1
        cmp es:[si-320], bl
        jz end_top_right1
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_top_right1
        push si
        sub si, 7d
        sub si, 960d
        mov bx, scan_counter
        shl bx, 1
        mov balls_2_explo[bx],si
        pop si
        end_top_right1:
        dec si
    loop top_right1

    sub si, 318d  ;up one row and two pixels to the right
    mov cx,3
    top_right2:
        push cx
        push si
        mov cx,3
        trio_top_right:
            mov bl, es:[si]
            cmp bl, 15d
            jne end_top_right2
            cmp es:[si+320], bl
            jz end_top_right2
            cmp es:[si-320], bl
            jz end_top_right2
            mov dl, current_ball
            cmp es:[si-320], dl
            jne end_top_right2
            push si
            sub si, 7d
            sub si, 960d
            mov bx, scan_counter
            shl bx, 1
            mov balls_2_explo[bx],si
            pop si
            inc scan_counter
            end_top_right2:
            dec si
        loop trio_top_right
        pop si
        pop cx
        sub si, 321 ;up one row and one pixel to the left
    loop top_right2

    ;up
    mov si, ax
    sub si, 2d
    sub si, 2880d
    mov cx, 19d
    up_scan:
        mov bl, es:[si]   ; BL = color at (AX, DX)
        cmp bl, 15d
        jne end_up_scan
        cmp es:[si+320], bl
        jz end_up_scan
        cmp es:[si-320], bl
        jz end_up_scan
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_up_scan
        push si
        sub si, 7d 
        sub si, 960d 
        mov bx, scan_counter
        shl bx, 1 
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_up_scan

        end_up_scan:
        inc si
        dec cx
        cmp cx , 0d 
    jnz up_scan
    ;call explosion function 
    cmp scan_counter, 1
    jae no_explosion
    call update_lifes
    ret
    no_explosion:
    call explosion
    ;update points
    ret
scan endp

update_lifes proc uses ax bx cx
    dec lifes
    push location_x
    push location_y
    mov cl,lifes
    mov location_x, 278d
    mov location_y, 114d
    mov ax, 14
    mul cl
    add location_y, ax
    mov bl,100
    call draw_ball
    pop location_y
    pop location_x
    cmp lifes,0
    jne end_life_update
        dec time_const_indx
        mov lifes,5
        call draw_lifes
        cmp time_const_indx,0
        jne end_life_update
        mov end_game_T_F, 1
    end_life_update:
    ret
update_lifes endp