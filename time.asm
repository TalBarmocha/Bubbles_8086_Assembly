;==================================================
;This procedure reads the RTC seconds and update the seed
;range of seed is: 60 numbers in the range [0,89]
;==================================================
get_sec_RTC proc uses ax
    xor ax,ax
    mov al, 00h             ; Select RTC register for seconds
    out 70h, al             ; Set RTC register address
    in al, 71h              ; Read seconds value and store it in AL
    mov seed,ax
    ret
get_sec_RTC endp

;==================================================
; new_Int1C - Timer Interrupt Handler Procedure
; This procedure handles the timer interrupt, which
; is responsible for timing and managing game events.
; 
; time_constent array:
;   Index 0: 28  -> around 30 sec (slowest)
;   Index 1: 19  -> around 20 sec
;   Index 2: 9   -> around 10 sec
;   Index 3: 5   -> around 5 sec (fastest)
;
; Registers used: 
;   - ax, bx (preserved by 'uses' directive)
;==================================================
new_Int1C proc far uses ax bx
    inc clock_counter               ; Increment clock counter
    
    xor bh, bh                      ; Clear BH register
    mov bl, time_const_indx         ; Load the time constant index into BL
    mov al, time_constent[bx]       ; Get the time constant from the array
    
    cmp clock_counter, al           ; Compare clock counter with time constant
    jl clock_advance                ; If clock counter < time constant, jump to clock_advance
    
    inc down_time_counter           ; Increment down time counter
    call draw_timer                 ; Call procedure to update the timer display
    
    mov clock_counter, 0d           ; Reset clock counter to 0
    
    cmp down_time_counter, 20       ; Check if down time counter >= 20
    jb clock_advance                ; If less, jump to clock_advance
    
    mov location_x, init_row_x      ; Reset location_x to initial row x-coordinate
    mov location_y, init_row_y      ; Reset location_y to initial row y-coordinate
    
    call shift_visual               ; Call procedure to shift visual elements
    call draw_balls_line            ; Call procedure to draw a line of balls
    
    mov down_time_counter, 0d       ; Reset down time counter to 0
    call draw_timer                 ; Call procedure to update the timer display
    
    ; Continue to the next clock advance step
clock_advance:
    int 80h                         ; Call DOS interrupt for timer (adjust this as needed)
    iret                            ; Return from interrupt
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