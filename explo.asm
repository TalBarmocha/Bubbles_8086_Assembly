explosion proc uses si ax dx
    ;cmp scan_counter, 3
    ;jb end_explosion
    array_explo:
    mov si, scan_counter
    mov ax, balls_2_explo[si]
    call loc_decode
    mov location_x, ax
    mov location_y, dx
    call explosion_anim
    dec scan_counter
    cmp scan_counter, 0
    jle array_explo
    end_explosion:
    mov scan_counter, 0
    call init_array_explo
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
    mov cx,00FFFh
    animation_delay:
    loop animation_delay
    
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
animation_frame proc uses cx di ax dx
    xor bh,bh
    xor di, di          ; Initialize di (result index)
    mov cx, 12
    ; Load address of number font
    mov dx, offset explosion_frames
    mov si,bx
    add si,bx
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
scan proc uses ax bx cx dx di si
    mov ax, player_x
    mov dx, player_y
    push bx
    mov bx, 0A000h
    mov es, bx
    pop bx
    ; Calculate the offset: (Y * 320) + X
    call loc_incode
    ;AX = Y * 320 + X
    ;left
    mov di, ax
    sub di, 5d
    add di, 3200d
    mov cx, 20d
    left_scan:
        mov bl, es:[di]   ; BL = color at (AX, DX)
        cmp bl, 15d
        jne left_next
        cmp es[di+320], bl
        jz left_next
        cmp es[di-320], bl
        jz left_next
        cmp es[di-320], current_ball
        jne end_left_scan
        push di
        sub di, 7d
        sub di, 960d
        mov si, scan_counter
        mov balls_2_explo[si],di
        pop di
        inc scan_counter
        cmp cx, 12
        jb left_scan_end 
        sub cx, 12
        sub di, 3520d
        jmp end_left_scan
        left_scan_end:
        mov cx, 1d
        jmp end_left_scan
        
        left_next:
        mov bl, es:[di+1]
        cmp bl, 15d
        jne end_left_scan
        cmp es[di+320], bl
        jz end_left_scan
        cmp es[di-320], bl
        jz end_left_scan
        cmp es[di-320], current_ball
        jne end_left_scan
        push di
        sub di, 7d
        sub di, 960d
        mov si, scan_counter
        mov balls_2_explo[si],di
        pop di
        inc scan_counter
        cmp cx, 12
        jb left_scan_end 
        sub cx, 12
        sub di, 3521d
        jmp end_left_scan
        end_left_scan:
        sub di, 320d
    loop left_scan
    ;right
    mov di, ax
    add di, 18d
    add di, 3200d
    mov cx, 20d
    right_scan:
        mov bl, es:[di]   ; BL = color at (AX, DX)
        cmp bl, 15d
        jne right_next
        cmp es[di+320], bl
        jz right_next
        cmp es[di-320], bl
        jz right_next
        cmp es[di-320], current_ball
        jne end_right_scan
        push di
        sub di, 7d
        sub di, 960d
        mov si, scan_counter
        mov balls_2_explo[si],di
        pop di
        inc scan_counter
        cmp cx, 12
        jb right_scan_end 
        sub cx, 12
        sub di, 3520d
        jmp end_right_scan
        right_scan_end:
        mov cx, 1d
        jmp end_right_scan
        right_next:
        mov bl, es:[di+1]
        cmp bl, 15d
        jne end_right_scan
        cmp es[di+320], bl
        jz end_right_scan
        cmp es[di-320], bl
        jz end_right_scan
        cmp es[di-320], current_ball
        jne end_right_scan
        push di
        sub di, 7d
        sub di, 960d
        mov si, scan_counter
        mov balls_2_explo[si],di
        pop di
        inc scan_counter
        cmp cx, 12
        jb right_scan_end 
        sub cx, 12
        sub di, 3521d
        jmp end_right_scan
        end_right_scan:
        sub di, 320d
    loop right_scan
    ;up
    mov di, ax
    sub di, 3d
    sub di, 2880d
    mov cx, 20d
    up_scan:
        mov bl, es:[di]   ; BL = color at (AX, DX)
        cmp bl, 15d
        jne up_next
        cmp es[di+320], bl
        jz up_next
        cmp es[di-320], bl
        jz up_next
        cmp es[di-320], current_ball
        jne end_up_scan
        push di
        sub di, 7d
        sub di, 960d
        mov si, scan_counter
        mov balls_2_explo[si],di
        pop di
        inc scan_counter
        cmp cx, 12
        jb up_scan_end 
        sub cx, 12
        add di, 12d
        jmp end_up_scan
        up_scan_end:
        mov cx, 1d
        jmp end_up_scan
        up_next:
        mov bl, es:[di+320]
        cmp bl, 15d
        jne end_up_scan
        cmp es[di+320], bl
        jz end_up_scan
        cmp es[di-320], bl
        jz end_up_scan
        cmp es[di-320], current_ball
        jne end_up_scan
        push di
        sub di, 7d
        sub di, 960d
        mov si, scan_counter
        mov balls_2_explo[si],di
        pop di
        inc scan_counter
        cmp cx, 12
        jb up_scan_end 
        sub cx, 12
        sub di, 308d ;+12-320
        jmp end_up_scan
        end_up_scan:
        sub di, 320d
    loop up_scan
    ;call explosion
    call explosion
    ret
scan endp

init_array_explo proc uses cx si
    mov cx, 280
    array_explo_loop:
        mov si, cx
        mov balls_2_explo[si-1],0
    loop array_explo_loop
    ret
init_array_explo endp