;==================================================
; loc_incode - Encode Coordinates to Pixel Location
; This procedure converts the X coordinate and Y coordinate
; to the pixel location in the screen array.
;
; Input: 
;   AX = X coordinate
;   DX = Y coordinate
;
; Output: 
;   AX = Y * 320 + X (pixel location in the screen array)
;
; Registers used:
;   - bx, cx, di (preserved by 'uses' directive)
;==================================================
loc_incode proc uses bx cx di
    ; Initialize CX to 0
    xor cx, cx
    
    ; Calculate Y * 320
    mov bx, dx        ; BX = Y
    mov cl, 6d        ; CL = 6 (used for shifting)
    shl bx, cl        ; BX = Y * 64

    mov di, bx        ; DI = Y * 64
    mov cl, 2d        ; CL = 2 (used for shifting)
    shl bx, cl        ; BX = Y * 256
    add di, bx        ; DI = Y * 320 (64 + 256 = 320)

    ; Add X to the calculated offset
    add di, ax        ; DI = Y * 320 + X

    ; Store the result in AX
    mov ax, di        ; AX = Y * 320 + X

    ret               ; Return from procedure
loc_incode endp



;==================================================
; loc_decode - Decode Pixel Location to Coordinates
; This procedure converts the pixel location in the
; screen array to the X coordinate and Y coordinate.
;
; Input: 
;   AX = Y * 320 + X (pixel location in the screen array)
;
; Output: 
;   AX = X coordinate
;   DX = Y coordinate
;
; Note: DX is altered in this procedure.
;
; Registers used:
;   - di (preserved by 'uses' directive)
;==================================================
loc_decode proc uses di
    xor dx, dx         ; Clear DX register (DX will hold the quotient after DIV)
    mov di, 320d       ; Load 320 (screen width) into DI

    ; Perform division to decode coordinates
    div di             ; AX / 320, quotient in AX (Y coordinate), remainder in DX (X coordinate)

    ; Swap AX and DX to get the desired output format
    mov di, ax         ; Move Y coordinate from AX to DI
    mov ax, dx         ; Move X coordinate from DX to AX
    mov dx, di         ; Move Y coordinate from DI to DX

    ret                ; Return from procedure
loc_decode endp
