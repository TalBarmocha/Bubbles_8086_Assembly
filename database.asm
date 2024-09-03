shift_line_grid proc uses si bx cx
mov cx, 260d
shift_loop:
   mov si,cx
   dec si
   mov bl, bubble_grid[si]
   mov bubble_grid[si+20],bl
loop shift_loop
ret
shift_line_grid endp

update_ball_back_grid proc uses ax bx cx si
mov ax, player_y  
sub ax, 5
mov cx, 12
div cx
    
mov cx, 13
mul cx
mov bx, ax  ; BX = nurmal location_y * 13
    
mov ax, player_x
sub ax, 5
mov cx, 12
div cx      ; AX = nurmal location_x 
    
add bx, ax
mov si, bx
mov bl, current_ball
mov bubble_grid[si], bl

ret
update_ball_back_grid endp