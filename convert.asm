;==================================================
;This procedure converts the X coordinate and Y coordinate to 
;the pixel location in the screen array.
;Input: AX = X coordinate, DX = Y coordinate.
;Output: AX = Y * 320 + X.
;==================================================
loc_incode proc uses bx cx di
    ; Calculate the offset: (Y * 320) + X
    xor cx,cx
    mov bx, dx        ; BX = Y
    mov cl, 6d
    shl bx, cl        ; BX = Y * 64
    mov di, bx
    mov cl, 2d        ; DI = BX
    shl bx, cl        ; BX = Y * 256
    add di, bx        ; DI = Y * 320 (64 + 256 = 320)
    add di, ax        ; DI = Y * 320 + X
    mov ax, di
    ;AX = Y * 320 + X
    ret
loc_incode endp


;==================================================
;This procedure converts the pixel location in  
;the screen array to the X coordinate and Y coordinate.
;Input: AX = Y * 320 + X.
;Output: AX = AX = X coordinate, DX = Y coordinate
;==================================================
loc_decode proc uses di
    div 320
    mov di, ax
    mov ax, dx
    mov dx, di
    ret
loc_decode endp