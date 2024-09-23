explosion proc uses si ax bx dx
    mov bx, scan_counter
    array_explo:
        mov si, scan_counter
        dec si
        shl si, 1 ; SI = (scan_counter - 1) * 2
        mov ax, balls_2_explo[si]
        call loc_decode
        mov location_x, ax
        mov location_y, dx
        call explosion_anim
        dec scan_counter
        cmp scan_counter, 0
    ja array_explo
    call update_score
    call draw_limit_line
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

;takes AX = (Y * 320 + X) and scans the radius of the ball
scan proc uses ax bx cx dx si di
    ;left
    mov si, ax
    sub si, 5d
    add si, 3200d
    mov cx, 15d
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
        call find
        cmp di, 1
        je is_in_arr1
        mov bx, scan_counter
        shl bx, 1
        mov balls_2_explo[bx],si
        inc scan_counter
        push ax
        mov ax, si
        call scan
        pop ax
        is_in_arr1:
        pop si
        end_left_scan:
        sub si, 320d
        dec cx
        cmp cx , 0d 
    jnz left_scan

    ;top left
    mov si, ax
    sub si, 5d
    sub si, 1600d ; 320 * 5 = 1600
    mov cx,4
    top_left:
        push cx
        mov cx,2
        loop_top_left:
            mov bl, es:[si]
            cmp bl, 15d
            jne end_top_left
            cmp es:[si+320], bl
            jz end_top_left
            cmp es:[si-320], bl
            jz end_top_left
            mov dl, current_ball
            cmp es:[si-320], dl
            jne end_top_left
            push si
            sub si, 7d
            sub si, 960d
            call find
            cmp di, 1
            je is_in_arr2
            mov bx, scan_counter
            shl bx, 1
            mov balls_2_explo[bx],si
            inc scan_counter
            push ax
            mov ax, si
            call scan
            pop ax
            is_in_arr2:
            pop si
            end_top_left:
            inc si
        loop loop_top_left
        pop cx
        sub si, 321 ;down one row
    loop top_left
    
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
        call find
        cmp di, 1
        je is_in_arr3 
        mov bx, scan_counter
        shl bx, 1 
        mov balls_2_explo[bx],si
        inc scan_counter
        push ax
        mov ax, si
        call scan
        pop ax
        is_in_arr3:
        pop si
        end_up_scan:
        inc si
        dec cx
        cmp cx , 0d 
    jnz up_scan

    ;top right
    mov si, ax
    add si, 19d
    sub si, 1600d
    mov cx, 4
    top_right:
        push cx
        mov cx,2
        loop_top_right:
            mov bl, es:[si]
            cmp bl, 15d
            jne end_top_right
            cmp es:[si+320], bl
            jz end_top_right
            cmp es:[si-320], bl
            jz end_top_right
            mov dl, current_ball
            cmp es:[si-320], dl
            jne end_top_right
            push si
            sub si, 7d
            sub si, 960d
            call find
            cmp di, 1
            je is_in_arr4
            mov bx, scan_counter
            shl bx, 1
            mov balls_2_explo[bx],si
            inc scan_counter
            push ax
            mov ax, si
            call scan
            pop ax
            is_in_arr4:
            pop si
            end_top_right:
            dec si
        loop loop_top_right
        pop cx
        sub si, 319 ;down one row
    loop top_right

    ;right
    mov si, ax
    add si, 19d
    add si, 3200d
    mov cx, 15d
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
        call find
        cmp di, 1
        je is_in_arr5
        mov bx, scan_counter
        shl bx, 1 
        mov balls_2_explo[bx],si
        inc scan_counter
        push ax
        mov ax, si
        call scan
        pop ax
        is_in_arr5:
        pop si
        end_right_scan:
        sub si, 320d
        dec cx
        cmp cx , 0d 
    jnz right_scan
    
    ;bottom right
    mov si, ax
    add si, 19d
    add si, 3520d
    mov cx, 4
    bottom_right:
        push cx
        mov cx,2
        loop_bottom_right:
            mov bl, es:[si]
            cmp bl, 15d
            jne end_bottom_right
            cmp es:[si+320], bl
            jz end_bottom_right
            cmp es:[si-320], bl
            jz end_bottom_right
            mov dl, current_ball
            cmp es:[si-320], dl
            jne end_bottom_right
            push si
            sub si, 7d
            sub si, 960d
            call find
            cmp di, 1
            je is_in_arr6
            mov bx, scan_counter
            shl bx, 1
            mov balls_2_explo[bx],si
            inc scan_counter
            push ax
            mov ax, si
            call scan
            pop ax
            is_in_arr6:
            pop si
            end_bottom_right:
            dec si
        loop loop_bottom_right
        pop cx
        add si, 321 ;down one row
    loop bottom_right
    
    ;down
    mov si, ax
    sub si, 1d
    add si, 4800d
    mov cx, 17d
    down_scan:
        mov bl, es:[si]   ; BL = color at (AX, DX)
        cmp bl, 15d
        jne end_down_scan
        cmp es:[si+320], bl
        jz end_down_scan
        cmp es:[si-320], bl
        jz end_down_scan
        mov dl, current_ball
        cmp es:[si-320], dl
        jne end_down_scan
        push si
        sub si, 7d 
        sub si, 960d
        call find
        cmp di, 1
        je is_in_arr7 
        mov bx, scan_counter
        shl bx, 1 
        mov balls_2_explo[bx],si
        inc scan_counter
        push ax
        mov ax, si
        call scan
        pop ax
        is_in_arr7:
        pop si
        end_down_scan:
        inc si
        dec cx
        cmp cx , 0d 
    jnz down_scan

    ;bottom left
    mov si, ax
    sub si, 5d
    add si, 3520d
    mov cx,4
    bottom_left:
        push cx
        mov cx,2
        loop_bottom_left:
            mov bl, es:[si]
            cmp bl, 15d
            jne end_bottom_left
            cmp es:[si+320], bl
            jz end_bottom_left
            cmp es:[si-320], bl
            jz end_bottom_left
            mov dl, current_ball
            cmp es:[si-320], dl
            jne end_bottom_left
            push si
            sub si, 7d
            sub si, 960d
            call find
            cmp di, 1
            je is_in_arr8
            mov bx, scan_counter
            shl bx, 1
            mov balls_2_explo[bx],si
            inc scan_counter
            push ax
            mov ax, si
            call scan
            pop ax
            is_in_arr8:
            pop si
            end_bottom_left:
            inc si
        loop loop_bottom_left
        pop cx
        add si, 319 ;down one row
    loop bottom_left

    ret
scan endp

update_lifes proc uses ax bx cx dx
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
    cmp lifes, 0
    jne end_life_update
        mov lifes, 5
        call draw_lifes
        cmp time_const_indx,0
        je end_life_update
        dec time_const_indx
    end_life_update:
    ret
update_lifes endp

;gets si and return boolian in di (1 == True , 0 == False)
;if si is in balls_2_explo
find proc uses bx cx
    mov cx, 280
    find_loop:
        mov bx, 280
        sub bx, cx
        cmp balls_2_explo[bx],si
        je end_find_true
        cmp balls_2_explo[bx],0
        je end_find_false
    loop find_loop
    end_find_false:
    mov di, 0
    ret
    end_find_true:
    mov di, 1
    ret

find endp 

;init balls array to 0
init_balls_2_explo proc uses bx cx
    mov cx, 280
    erase_arr_loop:
        mov bx, cx
        sub bx, 1
        mov balls_2_explo[bx],0
    loop erase_arr_loop
    ret
init_balls_2_explo endp 