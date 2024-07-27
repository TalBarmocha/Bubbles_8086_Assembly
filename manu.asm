
manu proc far
    ; Set the position for the first message
    mov cx, 270    ; X coordinate for the first message
    mov dx, 50    ; Y coordinate for the first message

    ; Print the first message
    lea si, restart_text
    call print_string

    ; Set the position for the second message
    mov cx, 270    ; X coordinate for the second message
    mov dx, 70    ; Y coordinate for the second message

    ; Print the second message
    lea si, quit_text
    call print_string
    iret
manu endp

print_string proc far
    ; Print each character in the string
    print_next_char:
    lodsb               ; Load next byte from string into AL
    cmp al, '$'         ; Check for string terminator
    je print_done       ; If found, exit procedure

    ; Get the address of the character bitmap
    call get_char_bitmap

    ; Draw the character
    call draw_char

    ; Move to the next character position
    add cx, 8           ; Move to the next position (8 pixels wide)
    jmp print_next_char ; Repeat for next character
    print_done:
    iret
print_string endp

get_char_bitmap proc far
    ; Get the address of the character bitmap in AL
    sub al, 'R'
    mov bx, offset font_R
    add bx, ax
    mov di, bx
    iret
get_char_bitmap endp

draw_char proc far uses ax bx cx dx di
    ; Loop over each row of the character
    mov si, cx
    mov ax, dx
    mov bx, 8           ; 8 rows
    draw_next_row:
        mov cx, si          ; Reset X coordinate
        mov dl, byte ptr [di] ; Get row data
        add di, 1           ; Move to next row
        mov ch, 8           ; 8 columns
    draw_next_col:
        shl dl, 1           ; Shift left
        jc  pixel_on        ; If bit is set, plot pixel
        inc cx              ; Move to next column
        loop draw_next_col  ; Repeat for next column
        add ax, 1           ; Move to next row
        mov dx, ax
        dec bx
        jnz draw_next_row   ; Repeat for next row
    iret
    pixel_on:
        ; Plot pixel at CX, DX
        mov ah, 0Ch         ; BIOS function: Write pixel
        mov al, 0Fh         ; Color (white)
        int 10h
        inc cx              ; Move to next column
        loop draw_next_col
        jmp draw_next_row

draw_char endp