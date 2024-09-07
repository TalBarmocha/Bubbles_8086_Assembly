explosion proc uses si ax dx
    cmp scan_counter, 1
    jb end_explosion
    array_explo:
        mov si, scan_counter
        add si, scan_counter
        mov ax, balls_2_explo[si-2]
        call loc_decode
        mov location_x, ax
        mov location_y, dx
        call explosion_anim
        dec scan_counter
        cmp scan_counter, 0
    ja array_explo
    ;explode the player ball
    mov ax, player_x

    mov dx, player_y
    mov location_x, ax
    mov location_y, dx
    call explosion_anim

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
animation_frame proc uses cx di ax bx dx si
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
scan proc uses ax bx cx dx si
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
    mov si, ax
    sub si, 5d
    add si, 3200d
    mov cx, 20d
    left_scan:
        mov bl, es:[si]
        cmp bl, 15d
        jne left_next
        cmp es:[si+320], bl
        jz left_next
        cmp es:[si-320], bl
        jz left_next
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_left_scan
        push si
        sub si, 7d
        sub si, 960d
        mov bx, scan_counter
        add bx, scan_counter
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_left_scan
        
        left_next:
        mov bl, es:[si+1]
        cmp bl, 15d
        jne end_left_scan
        cmp es:[si+321], bl
        jz end_left_scan
        cmp es:[si-319], bl
        jz end_left_scan
        mov dl, current_ball
        cmp es:[si-319], dl
        jne end_left_scan
        push si
        sub si, 6d
        sub si, 959d
        mov bx, scan_counter
        add bx, scan_counter
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_left_scan

        end_left_scan:
        sub si, 320d
        dec cx
        cmp cx , 0d 
    jnz left_scan

    ;right
    mov si, ax
    add si, 19d
    add si, 3200d
    mov cx, 20d
    right_scan:
        mov bl, es:[si]   ; BL = color at (AX, DX)
        cmp bl, 15d
        jne right_next
        cmp es:[si+320], bl
        jz right_next
        cmp es:[si-320], bl
        jz right_next
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_right_scan
        push si
        sub si, 7d
        sub si, 960d
        mov bx, scan_counter
        add bx, scan_counter
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_right_scan
        
        right_next:
        mov bl, es:[si+1]
        cmp bl, 15d
        jne end_right_scan
        cmp es:[si+321], bl
        jz end_right_scan
        cmp es:[si-319], bl
        jz end_right_scan
        mov dl, current_ball
        cmp es:[si-319], dl
        jne end_right_scan
        push si
        sub si, 6d
        sub si, 959d
        mov bx, scan_counter
        add bx, scan_counter
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_right_scan
    
        end_right_scan:
        sub si, 320d
        dec cx
        cmp cx , 0d 
    jnz right_scan

    ;up
    mov si, ax
    sub si, 3d
    sub si, 2880d
    mov cx, 21d
    up_scan:
        mov bl, es:[si]   ; BL = color at (AX, DX)
        cmp bl, 15d
        jne up_next1
        cmp es:[si+320], bl
        jz up_next1
        cmp es:[si-320], bl
        jz up_next1
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_up_scan
        push si
        sub si, 7d
        sub si, 960d
        mov bx, scan_counter
        add bx, scan_counter
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_up_scan

        up_next1:
        mov bl, es:[si+320]
        cmp bl, 15d
        jne up_next2
        cmp es:[si+640], bl
        jz up_next2
        cmp es:[si], bl
        jz up_next2
        mov dl, current_ball
        cmp es:[si], dl
        jne end_up_scan
        push si
        add si, 313d
        sub si, 640d
        mov bx, scan_counter
        add bx, scan_counter
        mov balls_2_explo[bx],si
        pop si
        inc scan_counter
        jmp end_up_scan

        up_next2:
        mov bl, es:[si+640]   ; BL = color at (AX, DX)
        cmp bl, 15d
        jne end_up_scan
        cmp es:[si+960], bl
        jz end_up_scan
        cmp es:[si+320], bl
        jz end_up_scan
        mov dl, current_ball
        cmp es:[si+320], dl
        jne end_up_scan
        push si
        add si, 633d ;+640-7
        sub si, 320d ;+640-960
        mov bx, scan_counter
        add bx, scan_counter
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