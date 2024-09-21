;3 balls == 100 points.
;for any ball that added +50.
;5 balls and more give +500 for any ball that added.
;for double succesful explotions x2 the score of the second expload.

;gets BX as the numbers of ball that were exploaded.
update_score proc uses bx ax
    xor ax, ax
    score_check:
    cmp bx, 5
    jb small_bonus
    add ax, 500
    jmp end_score_check
    small_bonus:
    cmp bx, 3
    je end_score_check
    add ax, 50
    end_score_check:
    dec bx
    cmp bx, 3
    ja score_check
    add ax, 100
    ;double bonus
    cmp last_explo_T_F, 1
    jne double_check
    shl ax, 1
    double_check:
    add score, ax
    call print_score
    ret
update_score endp