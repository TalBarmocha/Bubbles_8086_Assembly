check_mouse_and_shoot proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Check for mouse click
    mov ax, 3   ; Get mouse status
    int 33h
    test bx, 2  ; Check right button
    jz no_click

    ; Get mouse position
    mov ax, 3
    int 33h     ; Automatically enters coordinates for DX and CX
    shr cx, 1   ; Divide CX by 2 to convert from 640x200 to 320x200

    ; Store mouse position
    mov [mouse_x], cx
    mov [mouse_y], dx

    ; Set initial ball position
    mov [ball_x], 119d
    mov [ball_y], 180d

    shoot_loop:
        ; Calculate direction
        mov ax, [mouse_x]
        sub ax, [ball_x]    
        mov bx, [mouse_y]
        sub bx, [ball_y]

        ; Normalize direction (simple approach)
        cmp ax, 0
        jge check_y
        neg ax          ;In case the difference is negative
    check_y:
        cmp bx, 0
        jge continue
        neg bx
    continue:
        add ax, bx
        mov cx, ax  ; CX = |dx| + |dy|

        mov ax, [mouse_x]
        sub ax, [ball_x]
        imul ax, 2  ; Adjust speed here
        idiv cx
        mov [dx_ball], ax

        mov ax, [mouse_y]
        sub ax, [ball_y]
        imul ax, 2  ; Adjust speed here
        idiv cx
        mov [dy_ball], ax

        ; Move ball
        mov ax, [ball_x]
        add ax, [dx_ball]
        mov [next_ball_x], ax

        mov ax, [ball_y]
        add ax, [dy_ball]
        mov [next_ball_y], ax

        ; Check collision with edge pixels
        ; Check the 8 surrounding pixels of the ball's edge
        ; Assuming (next_ball_x, next_ball_y) is the center of the ball
        mov si, [next_ball_x]
        mov di, [next_ball_y]



        
        
        ; No collision, proceed to move the ball
        mov [ball_x], [next_ball_x]
        mov [ball_y], [next_ball_y]

        ; Draw ball at new position
        ;mov bl, [current_ball]
        ;mov cx, [ball_x]
        ;mov dx, [ball_y]
        ;call draw

        ; Small delay
        mov cx, 1000
    delay_loop:
        loop delay_loop

        jmp shoot_loop


    no_click:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
check_mouse_and_shoot endp