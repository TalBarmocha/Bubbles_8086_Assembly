;==================================================
; random_picker - Randomize a Color Set
; This procedure randomizes a color set of 5 colors
; and stores the number of the set in color_picker [0,119].
; It uses the Linear Congruential Generator (LCG) algorithm
; to pick a random color set.
;
; LCG Parameters:
; - Multiplier (a) = 241
; - Increment (c) = 7
; - Modulus (m) = 120
;
; The LCG algorithm ensures that the generated sequence
; has a good distribution by adhering to these properties:
; - a - 1 is divisible by all prime factors of m
; - c is relatively prime to m (GCD(7, 120) = 1)
;
; Registers used:
;   - ax, dx, bx (preserved by 'uses' directive)
;==================================================
random_picker proc uses ax dx bx
    ; Load seed value into AX
    mov ax, seed

    ; LCG Algorithm: result = (a * seed + c) % m
    ; a = 241, c = 7, m = 120

    mov bx, 241       ; Load multiplier (a) into BX
    mul bx            ; DX:AX = AX * 241 (seed * a)

    add ax, 7         ; AX = AX + increment (c)

    ; Apply modulo 120 (m = 120)
    mov bx, 120       ; Load modulus (m) into BX
    div bx            ; AX = AX / 120, DX = remainder

    ; The result is in DX, range [0,119]
    mov color_picker, dx  ; Store the remainder in color_picker

    ; Update the seed for the next iteration
    mov seed, dx

    ret               ; Return from procedure

random_picker endp
