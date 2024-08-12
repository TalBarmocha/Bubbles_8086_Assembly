;==================================================
;This procedure randomize a color set of 5 colors.
;and stores the number of the set in color_picker [0,120]
;using LCG algorithem to to pick a random color set.
;==================================================
random_picker proc uses ax dx bx
    ; Load seed  value into AX
    mov ax, seed
    ; a = 241, c = 7, m = 120
    ; a-1 = 240 which is divisible by all prime factors of m (2,3,5)
    ; c = 7 is relatively prime to m.(GCD(7,120)=1)
    ; result = (241 * ax + 7) % 120
    mov bx, 241
    mul bx          ; DX:AX = AX * 241
    add ax, 7       ; AX + 7
    ; Apply modulo 120 (m = 120)
    mov bx, 120
    div bx          ; AX = AX / 120, DX = remainder
    ; The result is in DX, the result is in range [0,119]
    mov color_picker, dx
    mov seed,dx
    ret
random_picker endp