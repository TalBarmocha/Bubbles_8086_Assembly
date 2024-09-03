;16x16 timer ball that 
timer_frame_0 DW 07C0h,1FF0h,3FF8h,7FFCh,7FFCh,0FFFEh,0FFFEh,0FFFEh,0FFFEh,0FFFEh,7FFCh,7FFCh,3FF8h,1FF0h,07C0h
timer_frame_1 DW 06C0h,1EF0h,3EF8h,7EFCh,7EFCh,0FEFEh,0FEFEh,0FFFEh,0FFFEh,0FFFEh,7FFCh,7FFCh,3FF8h,1FF0h,07C0h
;TODO - add more frames accoding to downloaded gif.
;TODO - down_time should be always 20d, the change should be in how we preceve a second
; clock_counter = 28 --> 30 sec round (slowest)
; clock_counter = 23 --> 25 sec round
; clock_counter = 19 --> 20 sec round
; clock_counter = 14 --> 15 sec round
; clock_counter = 9  --> 10 sec round
; clock_counter = 5  --> 5  sec round (fastest)