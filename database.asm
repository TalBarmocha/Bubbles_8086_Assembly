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
