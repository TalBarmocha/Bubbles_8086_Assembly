;==================================================
; update_score - Update Score Based on Exploded Balls
; This procedure updates the player's score based on
; the number of balls that were exploded
; and updates the score on the screen accordingly. 
; 
; Scoring Rules:
; - 3 balls == 100 points.
; - For any ball that added +50 points.
; - 5 balls and more give +500 points for any ball that added.
; - For double successful explosions, x2 the score of the second explosion.
;
; Input: 
;   BX - Number of balls that were exploded
;
; Registers used: 
;   - ax, bx (preserved by 'uses' directive)
;==================================================
update_score proc uses bx ax
    xor ax, ax                     ; Clear AX register

    score_check:
    cmp bx, 5                      ; Compare BX with 5
    jb small_bonus                 ; If BX < 5, jump to small_bonus
    add ax, 500                    ; Add 500 points for balls >= 5
    jmp end_score_check            ; Jump to end_score_check
    
    small_bonus:
    cmp bx, 3                      ; Compare BX with 3
    je end_score_check             ; If BX == 3, jump to end_score_check
    add ax, 50                     ; Add 50 points for balls < 5 and != 3

    end_score_check:
    dec bx                         ; Decrement BX
    cmp bx, 3                      ; Compare BX with 3
    ja score_check                 ; If BX > 3, repeat score_check
    
    add ax, 100                    ; Add 100 points for exactly 3 balls

    ; Double bonus for consecutive explosions
    cmp last_explo_T_F, 1          ; Check if the last explosion was successful
    jne double_check               ; If not, jump to double_check
    shl ax, 1                      ; Double the score (shift left AX by 1)

    double_check:
    add score, ax                  ; Add the calculated score to the total score
    call print_score               ; Call procedure to print the updated score
    ret                            ; Return from procedure

update_score endp
