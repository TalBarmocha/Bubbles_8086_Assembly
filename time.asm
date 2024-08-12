;==================================================
;This procedure reads the RTC seconds and update the seed
;range of seed is: 60 numbers in the range [0,89]
;==================================================
get_sec_RTC proc uses ax
    xor ax,ax
    mov al, 00h              ; Select RTC register for seconds
    out 70h, al             ; Set RTC register address
    in al, 71h              ; Read seconds value and store it in AL
    mov seed,ax
    ret
get_sec_RTC endp

;==================================================
;This procedure handles the timer interrupt
;==================================================
new_Int1C proc far uses ax bx es si
    ;down a line
    int 80h                 ; Call DOS interrupt for timer
    iret                    ; Return from interrupt
new_Int1C endp

;==================================================
;This procedure changes the Interrupt Vector Table (IVT) for the timer
;==================================================
IVT_change proc uses ax es
    mov ax, 0h              ; Set segment address to 0
    mov es, ax
    cli                     ; Clear interrupts

    ; Copy old ISR 1C IP to free vector
    mov ax, es:[1Ch*4]     ; Get old ISR IP
    mov es:[80h*4], ax     ; Store IP at free vector
    ; Copy old ISR 1C CS to free vector
    mov ax, es:[1Ch*4+2]   ; Get old ISR CS
    mov es:[80h*4+2], ax   ; Store CS at free vector

    ; Copy IP of new_Int1C to IVT[1C]
    mov ax, offset new_Int1C ; Get new ISR IP
    mov es:[1Ch*4], ax     ; Set new IP in IVT
    ; Copy CS of new_Int1C to IVT[1C]
    mov ax, cs             ; Get new ISR CS
    mov es:[1Ch*4+2], ax   ; Set new CS in IVT

    sti                     ; Set interrupts
    ret
IVT_change endp

;==================================================
;This procedure restores the old Interrupt Vector Table (IVT) for the timer
;==================================================
IVT_return proc uses ax es
    mov ax, 0h              ; Set segment address to 0
    mov es, ax
    cli                     ; Clear interrupts

    ; Copy old ISR 1C IP to IVT[1C]
    mov ax, es:[80h*4]     ; Get old ISR IP from free vector
    mov es:[1Ch*4], ax     ; Set old IP in IVT
    ; Copy old ISR 1C CS to IVT[1C]
    mov ax, es:[80h*4+2]   ; Get old ISR CS from free vector
    mov es:[1Ch*4+2], ax   ; Set old CS in IVT

    sti                     ; Set interrupts
    ret
IVT_return endp