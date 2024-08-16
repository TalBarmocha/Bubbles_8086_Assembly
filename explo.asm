;==================================================
;This procedure draw a 12x12 animation of explotion
;with delay
;starting at location_x and location_y as the
;top left cornet of the number
;==================================================
explosion_func proc uses bx cx
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
explosion_func endp

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