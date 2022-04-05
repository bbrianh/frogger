#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Man Chon Ho, 1007467493
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10000000 (global data)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Two player mode (Control description written below)
# 2. Display score
# 3. Display remaining life
# 4. Add a timer to the game
# 5. Add a thrid row to each section
# 6. Objects in different rows move in different speed
#
# Any additional information that the TA needs to know:
# - Two player control: 
#	- wasd for p1, ijkl for p2
# - Collision detection:
#	- A frog is considered "crashed by a car" when one of its body part overlaps with a car
# - Drowning detection:
#	- A frog is considered "drown" when its main body is not fully on a log
# 	  (The limbs can be outside of the log)
# - Goal detection:
#	- A frog is considered "goal" when its main body is full inside the goal
#	  (The limbs can be outside the goal region)
# - Scoring rule:
#	- 10 points to a new step forward
#	- 50 base points + 20 * remaining time
#	  to the player who reaches an empty goal
# - Win condition:
#	- You win if your opponents lose all 3 lives
#	- If both players are alive when all 5 goals are filled
#	  the player who have the higher score wins
# - Timer:
#	- Designated time limit is set to be 30s (with time_update_freq = 47), but since there
#	  is a significant delay in this simulator, the timer may
# 	  not be accurate
#
# - object patterns:
#	- The object patterns can be modified by changing the corresponding bit flag
#	  in the data segment
#####################################################################
.data
displayAddress: .word 0x10000000
buffer:		.space 65536

line_pixel:	.word 128
line_offset:	.word 512

# colour codes
score_bg: 	.word 0x000000
score1_text: 	.word 0xffffff
score2_text:	.word 0xffffff
safe: 		.word 0x6a53b0
goal: 		.word 0x8eb056
road: 		.word 0x808080
water: 		.word 0x11275e
cars: 		.word 0xfdcc0d
logs: 		.word 0x6d4c40
p1_colour: 	.word 0x8bc34a
p1_eye_colour:	.word 0x9c27b0
p2_colour: 	.word 0xea06d2
p2_eye_colour:	.word 0x8bc34a

# object positions
p1_x_init: .word 29
p1_y_init: .word 109
p1_x: .word 29
p1_y: .word 109
p1_y_min: .word 109

p2_x_init: .word 85
p2_y_init: .word 109
p2_x: .word 85
p2_y: .word 109
p2_y_min: .word 109

water_1: .word 0xffffffff, 0x00000000, 0xffffffff, 0x00000000
water_2: .word 0x00000fff, 0xffff0000, 0xffffff00, 0x0fffff00
water_3: .word 0x000fffff, 0x00000fff, 0xffff0000, 0x0fffffff
road_1:	 .word 0xfffff000, 0x00000000, 0xffffffff, 0x00000000
road_2:  .word 0x00000000, 0x0fffff00, 0x00fffff0, 0x00000000
road_3:  .word 0xfffff000, 0x00000000, 0x00fffff0, 0x00000000

# object speed
water_1_freq: .word 1
water_2_freq: .word 2
water_3_freq: .word 3
road_1_freq: .word 3
road_2_freq: .word 2
road_3_freq: .word 1

water_1_timer: .word 0
water_2_timer: .word 0
water_3_timer: .word 0
road_1_timer: .word 10
road_2_timer: .word 10
road_3_timer: .word 10

# life and scores
p1_score: .word 0
p2_score: .word 0

p1_life: .word 3
p2_life: .word 3

time_limit: .word 38
p1_time: .word 38
p2_time: .word 38

time_update_freq: .word 20
p1_time_update_cd: .word 20
p2_time_update_cd: .word 20

# goal filled
goal_status: .byte 0,0,0,0,0
goal_filled: .word 0

.text			
main_loop:	# main loop
update_obj:	# update water_1
		lw $t7, water_1_timer
		bgtz $t7, end_w1_update
update_water_1:	la $a0, water_1
		li $a1, 1
		jal move_object
		lw $t7, water_1_freq
		sw $t7, water_1_timer
		# move the frog with the log
		# p1
		lw $t0, p1_y
		bne $t0, 32, end_shift_p1_w1
shift_p1_w1:	li $a0, 1
		li $a1, 1
		jal move_frog
end_shift_p1_w1:
		# p2
		lw $t0, p2_y
		bne $t0, 32, end_shift_p2_w1
shift_p2_w1:	li $a0, 2
		li $a1, 1
		jal move_frog
end_shift_p2_w1:
end_w1_update:	

		# update water_2
		lw $t7, water_2_timer
		bgtz $t7, end_w2_update
update_water_2:	la $a0, water_2
		li $a1, 0
		jal move_object
		lw $t7, water_2_freq
		sw $t7, water_2_timer
		# move the frog with the log
		# p1
		lw $t0, p1_y
		bne $t0, 43, end_shift_p1_w2
shift_p1_w2:	li $a0, 1
		li $a1, -1
		jal move_frog
end_shift_p1_w2:
		# p2
		lw $t0, p2_y
		bne $t0, 43, end_shift_p2_w2
shift_p2_w2:	li $a0, 2
		li $a1, -1
		jal move_frog
end_shift_p2_w2:
end_w2_update:	
		
		# update water_3
		lw $t7, water_3_timer
		bgtz $t7, end_w3_update
update_water_3:	la $a0, water_3
		li $a1, 1
		jal move_object
		lw $t7, water_3_freq
		sw $t7, water_3_timer
		# move the frog with the log
		# p1
		lw $t0, p1_y
		bne $t0, 54, end_shift_p1_w3
shift_p1_w3:	li $a0, 1
		li $a1, 1
		jal move_frog
end_shift_p1_w3:
		# p2
		lw $t0, p2_y
		bne $t0, 54, end_shift_p2_w3
shift_p2_w3:	li $a0, 2
		li $a1, 1
		jal move_frog
end_shift_p2_w3:
end_w3_update:	

		# update road_1
		lw $t7, road_1_timer
		bgtz $t7, end_r1_update
update_road_1:	la $a0, road_1
		li $a1, 1
		jal move_object
		lw $t7, road_1_freq
		sw $t7, road_1_timer
		
end_r1_update:	

		# update road_2
		lw $t7, road_2_timer
		bgtz $t7, end_r2_update
update_road_2:	la $a0, road_2
		li $a1, 0
		jal move_object
		lw $t7, road_2_freq
		sw $t7, road_2_timer
end_r2_update:	

		# update road_3
		lw $t7, road_3_timer
		bgtz $t7, end_r3_update
update_road_3:	la $a0, road_3
		li $a1, 0
		jal move_object
		lw $t7, road_3_freq
		sw $t7, road_3_timer
end_r3_update:

update_timer:	# update p1 timer
		lw $t7, p1_time_update_cd
		bgtz $t7, end_p1_time_update
p1_time_update:	lw $t7, p1_time
		addi $t7, $t7, -1
		sw $t7, p1_time
		lw $t7, time_update_freq
		sw $t7, p1_time_update_cd
end_p1_time_update:

		# update p2 timer
		lw $t7, p2_time_update_cd
		bgtz $t7, end_p2_time_update
p2_time_update:	lw $t7, p2_time
		addi $t7, $t7, -1
		sw $t7, p2_time
		lw $t7, time_update_freq
		sw $t7, p2_time_update_cd
end_p2_time_update:

# check keyboard input
		lw $t0, 0xffff0000		# check keyboard input
		beqz $t0, no_input		# skip keyboard_input if $t8 is 0 
key_input:	lw $a0, 0xffff0004
		jal keyboard			# call input_action
no_input:	
	
main_draw:	jal draw_score		# draw score board
		jal draw_scence		# draw the scence
		jal draw_life		# draw the timer bar including lifes and timer
		jal draw_frogs		# draw the frogs according to their position

detect_timeout: 
p1_time_check:	lw $t0, p1_time
		beqz $t0, p1_timeout
		j end_p1_time_check
		
p1_timeout:	# reset p1 timer
		lw $t0, time_limit
		lw $t1, time_update_freq
		sw $t0, p1_time
		sw $t1, p1_time_update_cd
		# jump to p1_die
		j p1_die
end_p1_time_check:
		
p2_time_check:	lw $t0, p2_time
		beqz $t0, p2_timeout
		j end_p2_time_check

p2_timeout:	# reset p2 timer
		lw $t0, time_limit
		lw $t1, time_update_freq
		sw $t0, p2_time
		sw $t1, p2_time_update_cd
		# jump to p2_die
		j p2_die
end_p2_time_check:	
		
		
		
detect_collision:
p1_collcheck:
		lw $t0, p1_y
		beq $t0, 98, p1_check_crash
		beq $t0, 87, p1_check_crash
		beq $t0, 76, p1_check_crash
		beq $t0, 54, p1_check_drown
		beq $t0, 43, p1_check_drown
		beq $t0, 32, p1_check_drown
		beq $t0, 21, p1_check_goal
		j end_p1_collcheck
p1_check_crash:
		la $t0, buffer # get frog top left corner address to $t0
		lw $t1, p1_y
		lw $t2, line_offset
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		lw $t1, p1_x
		li $t2, 4
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1	# $t0 is the top left corner address now
		
		lw $t1, line_offset	
		add $t0, $t0, $t1	# move $t0 1px down
		lw $t1, 4($t0)		# get 1 and 12 pixel colour
		lw $t2, 48($t0)
		lw $t0, cars		# get colour of cars
		beq $t1, $t0, p1_die
		beq $t2, $t0, p1_die
		j end_p1_collcheck

p1_check_drown:
		la $t0, buffer # get frog top left corner address to $t0
		lw $t1, p1_y
		lw $t2, line_offset
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		lw $t1, p1_x
		li $t2, 4
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1	# $t0 is the top left corner address now
		
		lw $t1, line_offset	
		add $t0, $t0, $t1	# move $t0 1px down
		lw $t1, 16($t0)		# get 4 and 9 pixel colour
		lw $t2, 36($t0)
		lw $t0, water		# get colour of water
		beq $t1, $t0, p1_die
		beq $t2, $t0, p1_die
		j end_p1_collcheck

p1_check_goal:
		la $t0, buffer # get frog top left corner address to $t0
		lw $t1, p1_y
		lw $t2, line_offset
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		lw $t1, p1_x
		li $t2, 4
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1	# $t0 is the top left corner address now
		
		# check drown in goal zone
		lw $t1, line_offset	
		add $t0, $t0, $t1	# move $t0 1px down
		lw $t1, 16($t0)		# get 4 and 9 pixel colour
		lw $t2, 36($t0)
		lw $t0, goal		# get colour of goal
		beq $t1, $t0, p1_die
		beq $t2, $t0, p1_die
		
		# check goal number
		lw $t0, p1_x
		addi $t0, $t0, 9
		la $t1, goal_status
		li $t2, 1
		blt $t0, 15, p1_goal0
		blt $t0, 43, p1_goal1
		blt $t0, 71, p1_goal2
		blt $t0, 99, p1_goal3
		blt $t0, 127, p1_goal4
		
p1_goal0:	lb $t3, 0($t1)
		bnez $t3, p1_die
		sb $t2, 0($t1)
		j end_p1_goal
		
p1_goal1:	lb $t3, 1($t1)
		bnez $t3, p1_die
		sb $t2, 1($t1)
		j end_p1_goal
		
p1_goal2:	lb $t3, 2($t1)
		bnez $t3, p1_die
		sb $t2, 2($t1)
		j end_p1_goal
		
p1_goal3:	lb $t3, 3($t1)
		bnez $t3, p1_die
		sb $t2, 3($t1)
		j end_p1_goal
		
p1_goal4:	lb $t3, 4($t1)
		bnez $t3, p1_die
		sb $t2, 4($t1)
		j end_p1_goal

end_p1_goal:	# reset p1 pos
		lw $t0, p1_x_init
		lw $t1, p1_y_init
		sw $t0, p1_x
		sw $t1, p1_y
		sw $t1, p1_y_min	# reset p1_y_min
		# goal_filled ++
		lw $t0, goal_filled
		addi $t0, $t0, 1
		sw $t0, goal_filled
		# update p1_score
		lw $t0, p1_score
		addi $t0, $t0, 50	# 50 base points
		
		lw $t1, p1_time		# 20 points per 1 remaining second
		li $t2, 600
		mult $t1, $t2
		mflo $t1
		lw $t2, time_limit
		div $t1, $t1, $t2
		add $t0, $t0, $t1
		
		sw $t0, p1_score
		# reset p1 timer
		lw $t0, time_limit
		lw $t1, time_update_freq
		sw $t0, p1_time
		sw $t1, p1_time_update_cd
		j End
		
		

p1_die:		lw $t0, p1_x_init
		lw $t1, p1_y_init
		lw $t2, p1_life
		sw $t0, p1_x
		sw $t1, p1_y
		addi $t2, $t2, -1
		sw $t2, p1_life	
		j End
		
end_p1_collcheck:

p2_collcheck:
		lw $t0, p2_y
		beq $t0, 98, p2_check_crash
		beq $t0, 87, p2_check_crash
		beq $t0, 76, p2_check_crash
		beq $t0, 54, p2_check_drown
		beq $t0, 43, p2_check_drown
		beq $t0, 32, p2_check_drown
		beq $t0, 21, p2_check_goal
		j end_p2_collcheck
p2_check_crash:
		la $t0, buffer # get frog top left corner address to $t0
		lw $t1, p2_y
		lw $t2, line_offset
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		lw $t1, p2_x
		li $t2, 4
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1	# $t0 is the top left corner address now
		
		lw $t1, line_offset	
		add $t0, $t0, $t1	# move $t0 1px down
		lw $t1, 4($t0)		# get 1 and 12 pixel colour
		lw $t2, 48($t0)
		lw $t0, cars		# get colour of cars
		beq $t1, $t0, p2_die
		beq $t2, $t0, p2_die
		j end_p2_collcheck
		
p2_check_drown:
		la $t0, buffer # get frog top left corner address to $t0
		lw $t1, p2_y
		lw $t2, line_offset
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		lw $t1, p2_x
		li $t2, 4
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1	# $t0 is the top left corner address now
		
		lw $t1, line_offset	
		add $t0, $t0, $t1	# move $t0 1px down
		lw $t1, 16($t0)		# get 4 and 9 pixel colour
		lw $t2, 36($t0)
		lw $t0, water		# get colour of water
		beq $t1, $t0, p2_die
		beq $t2, $t0, p2_die
		j end_p2_collcheck

p2_check_goal:
		la $t0, buffer # get frog top left corner address to $t0
		lw $t1, p2_y
		lw $t2, line_offset
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		lw $t1, p2_x
		li $t2, 4
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1	# $t0 is the top left corner address now
		
		# check drown in goal zone
		lw $t1, line_offset	
		add $t0, $t0, $t1	# move $t0 1px down
		lw $t1, 16($t0)		# get 4 and 9 pixel colour
		lw $t2, 36($t0)
		lw $t0, goal		# get colour of goal
		beq $t1, $t0, p2_die
		beq $t2, $t0, p2_die
		
		# check goal number
		lw $t0, p2_x
		addi $t0, $t0, 9
		la $t1, goal_status
		li $t2, 2
		blt $t0, 15, p2_goal0
		blt $t0, 43, p2_goal1
		blt $t0, 71, p2_goal2
		blt $t0, 99, p2_goal3
		blt $t0, 127, p2_goal4
		
p2_goal0:	lb $t3, 0($t1)
		bnez $t3, p2_die
		sb $t2, 0($t1)
		j end_p2_goal
		
p2_goal1:	lb $t3, 1($t1)
		bnez $t3, p2_die
		sb $t2, 1($t1)
		j end_p2_goal
		
p2_goal2:	lb $t3, 2($t1)
		bnez $t3, p2_die
		sb $t2, 2($t1)
		j end_p2_goal
		
p2_goal3:	lb $t3, 3($t1)
		bnez $t3, p2_die
		sb $t2, 3($t1)
		j end_p2_goal
		
p2_goal4:	lb $t3, 4($t1)
		bnez $t3, p2_die
		sb $t2, 4($t1)
		j end_p2_goal

end_p2_goal:	# reset p2 pos
		lw $t0, p2_x_init
		lw $t1, p2_y_init
		sw $t0, p2_x
		sw $t1, p2_y
		sw $t1, p2_y_min	# reset p2_y_min
		# goal_filled ++
		lw $t0, goal_filled
		addi $t0, $t0, 1
		sw $t0, goal_filled
		# update p2_score
		lw $t0, p2_score
		addi $t0, $t0, 50	# 50 base points
		
		lw $t1, p2_time		# 20 points per 1 remaining time
		li $t2, 20
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		
		sw $t0, p2_score
		# reset p2 timer
		lw $t0, time_limit
		lw $t1, time_update_freq
		sw $t0, p2_time
		sw $t1, p2_time_update_cd
		j End

p2_die:	lw $t0, p2_x_init
		lw $t1, p2_y_init
		lw $t2, p2_life
		sw $t0, p2_x
		sw $t1, p2_y
		addi $t2, $t2, -1
		sw $t2, p2_life
		j End
end_p2_collcheck:

update_step_score:
p1_step:	lw $t0, p1_y_min
		lw $t1, p1_y
		blt $t1, $t0, p1_get_step_score	# if p1_y < p1_y_min
		j end_p1_step
p1_get_step_score:				
		sw $t1, p1_y_min		# p1_y_min = p1_y
		lw $t0, p1_score
		addi $t0, $t0, 10		# p1_score += 10
		sw $t0, p1_score
end_p1_step:

p2_step:	lw $t0, p2_y_min
		lw $t1, p2_y
		blt $t1, $t0, p2_get_step_score	# if p2_y < p2_y_min
		j end_p2_step
p2_get_step_score:
		sw $t1, p2_y_min		# p2_y_min = p2_y
		lw $t0, p2_score		
		addi $t0, $t0, 10		# p2_score += 10
		sw $t0, p2_score
end_p2_step:

		
timer_updates:	lw $t7, water_1_timer	# dcrease water_1_timer by 1
		addi $t7, $t7, -1
		sw $t7, water_1_timer
		
		lw $t7, water_2_timer	# dcrease water_2_timer by 1
		addi $t7, $t7, -1
		sw $t7, water_2_timer
		
		lw $t7, water_3_timer	# dcrease water_3_timer by 1
		addi $t7, $t7, -1
		sw $t7, water_3_timer
		
		lw $t7, road_1_timer	# dcrease road_1_timer by 1
		addi $t7, $t7, -1
		sw $t7, road_1_timer
		
		lw $t7, road_2_timer	# dcrease road_2_timer by 1
		addi $t7, $t7, -1
		sw $t7, road_2_timer
		
		lw $t7, road_3_timer	# dcrease road_3_timer by 1
		addi $t7, $t7, -1
		sw $t7, road_3_timer
		
		lw $t7, p1_time_update_cd	# dcrease p1_time_update_cd by 1
		addi $t7, $t7, -1
		sw $t7, p1_time_update_cd
		
		lw $t7, p2_time_update_cd	# dcrease p1_time_update_cd by 1
		addi $t7, $t7, -1
		sw $t7, p2_time_update_cd

End:		# check game end condition
		lw $t0, p1_life
		beqz $t0, Exit
		lw $t0, p2_life
		beqz $t0, Exit
		lw $t0, goal_filled
		beq $t0, 5, Exit
		
		# update display
		jal update_display
		
		li $v0, 32			# load 32 to $v0 which is the sleep operation
		li $a0, 0			# set $a0 to 1000 which represent 1 second
		syscall				# system call
		j main_loop

Exit:		# display winner
		lw $t0, p1_life
		beqz $t0, p2_win
		lw $t0, p2_life
		beqz $t0, p1_win
		
		lw $t0, p1_score
		lw $t1, p2_score
		bgt $t0, $t1, p1_win
		blt $t0, $t1, p2_win
		j end_winner_display
		
p1_win:		lw $t0, p1_colour
		sw $t0, score1_text
		jal draw_score
		j end_winner_display
		
p2_win:		lw $t0, p2_colour
		sw $t0, score2_text
		jal draw_score
		j end_winner_display
end_winner_display:
		# update display
		jal update_display
		li $v0, 10 # terminate the program gracefully
		syscall

####################################################################################
# Function:
# copy buffer to display
update_display:
		lw $t7, displayAddress
		la $t6, buffer
		addi $t5, $t6, 65536
copy_loop:	beq $t6, $t5, end_copy_loop
		lw $t4, 0($t6)
		sw $t4, 0($t7)
		addi $t6, $t6, 4
		addi $t7, $t7, 4
		j copy_loop
end_copy_loop:	jr $ra
		
####################################################################################
# Function:
# Draw frogs
#
draw_frogs:	addi $sp, $sp, -4		# move stack pointer a word
		sw $ra, 0($sp)			# store return address
		
		la $t0, buffer
		lw $t1, p1_y
		lw $t2, line_offset
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		lw $t1, p1_x
		li $t2, 4
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		move $a0, $t0
		li $a1, 1
		jal draw_frog
		
		la $t0, buffer
		lw $t1, p2_y
		lw $t2, line_offset
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		lw $t1, p2_x
		li $t2, 4
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1
		move $a0, $t0
		li $a1, 2
		jal draw_frog
		
		
		lw $ra, 0($sp)			# load return address from stack
		addi $sp, $sp, 4		# move stack pointer
		jr $ra				# return
####################################################################################
# Function:
# Draw Score board
#
draw_score:	addi $sp, $sp, -4		# move stack pointer a word
		sw $ra, 0($sp)			# store return address
		
		la $t0, buffer		# load bufferAddress to $t0
		move $a0, $t0			# set $a0 to bufferAddress
		li $a1, 128			#
		li $a2, 17			# Draw score board background
		lw $a3, score_bg		#
		jal draw_rect			#
		
draw_p1_score:	la $t0, buffer		# set $t0 to displayaddress
		lw $t1, line_offset		#
		add $t0, $t0, $t1		# Move $t0 1px down and 1 px right
		addi $t0, $t0, 4		#
		move $a0, $t0			# set $a0 to the current pos
		lw $a1, score1_text		# set $a1 to the colour of score 1 text
		jal draw_p			# draw the letter P
		addi $t0, $t0, 32		# move $t0 right 7 pixels
		move $a0, $t0			# set $a0 to $t0
		li $a1, 1			# load 1 to $a1
		lw $a2, score1_text		# load score1 colour
		jal draw_digit			# draw 1
		
		
		la $t0, buffer		#
		lw $t1, line_offset		#
		li $t2, 9			#
		mult $t1, $t2			#
		mflo $t1			#
		add $t0, $t0, $t1		# Move $t0 to the score position
		addi $t0, $t0, 4		#
		lw $t2, p1_score		# load p1_score
		
		ble $t2, 99999, end_set_score1	# set $t2 = 99999 if $t2 > 99999
set_score1:	li $t2, 99999			#
end_set_score1:
		li $t3, 10000			# set $t3 to 10000
digit_loop1:	beq $t3, 1, end_d_loop1		# end for loop if t3 = 1
		div $t2, $t3			# $t2 / $t3
		mflo $a1			# set $a0 to the quotient
		move $a0, $t0			# set $a0 to the current position
		lw $a2, score1_text		# set $a2 to the colour of score 1
		jal draw_digit			# draw the digit
		mfhi $t2			# set $t2 to the remainder
		div $t3, $t3, 10		# divide $t3 by 10
		addi $t0, $t0, 32		# move $t0 to the next digit position
		j digit_loop1			# continue loop
end_d_loop1:	move $a1, $t2			# 
		move $a0, $t0			# draw the last digit
		lw $a2, score1_text		# 
		jal draw_digit			#
		
draw_p2_score:	la $t0, buffer		# set $t0 to displayaddress
		lw $t1, line_offset		#
		add $t0, $t0, $t1		# Move $t0 1px down
		addi $t1, $t1, -60		# reserve 15 pixels for "P2"
		add $t0, $t0, $t1		# Move $t0 to the right for printing "P2"
		move $a0, $t0			# set $a0 to the current position
		lw $a1, score2_text		# set $a1 to the colour of score 2
		jal draw_p			# draw the letter p
		addi $t0, $t0, 32		# move $t0 right 7 pixels
		move $a0, $t0			# 
		li $a1, 2			#
		lw $a2, score2_text		# Draw the 2 next to P
		jal draw_digit			#
		
		la $t0, buffer		#
		lw $t1, line_offset		#
		li $t2, 9			#
		mult $t1, $t2			# 
		mflo $t1			#
		add $t0, $t0, $t1		# Move $t0 to line 9
		lw $t1, line_offset		#
		addi $t1, $t1, -156		# reserve 39 pixels for p2 score
		add $t0, $t0, $t1		#
		lw $t2, p2_score		# load p2_score
		
		ble $t2, 99999, end_set_score2	# set $t2 = 99999 if $t2 > 99999
set_score2:	li $t2, 99999			#
end_set_score2:
		li $t3, 10000			# set $t3 to 10000
digit_loop2:	beq $t3, 1, end_d_loop2		# end for loop if t3 = 1
		div $t2, $t3			# $t2 / $t3
		mflo $a1			# set $a1 to the quotient
		move $a0, $t0			# set $a0 to the current position
		lw $a2, score2_text		# load score_2 colour
		jal draw_digit			# draw the digit
		mfhi $t2			# set $t2 to the remainder
		div $t3, $t3, 10		# $t3 = $t3 // 10
		addi $t0, $t0, 32		# move $t0 right 8 pixels
		j digit_loop2			# continue loop
end_d_loop2:	move $a1, $t2			# 
		move $a0, $t0			# Draw the last digit
		lw $a2, score2_text		#
		jal draw_digit			# 

		lw $ra, 0($sp)			# load return address from stack
		addi $sp, $sp, 4		# move stack pointer
		jr $ra				# return
		
		
####################################################################################
# Function:
# Draw scence
#
draw_scence:	addi $sp, $sp, -4		# move stack pointer a word
		sw $ra, 0($sp)			# store return address
		
		jal draw_goal			# draw game scence
		
		la $t0, buffer	# move $t0 to the starting address of row 1
		lw $t1, line_offset
		li $t2, 32
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2	
		move $a0, $t0
		la $a1, water_1		# call draw_row to draw water_row 1
		lw $a2, water
		lw $a3, logs
		jal draw_row
		
		la $t0, buffer	# move $t0 to the starting address of row 2
		lw $t1, line_offset
		li $t2, 43
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		move $a0, $t0
		la $a1, water_2		# call draw_row to draw water_row 2
		lw $a2, water
		lw $a3, logs
		jal draw_row
		
		la $t0, buffer	# move $t0 to the starting address of row 3
		lw $t1, line_offset
		li $t2, 54
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		move $a0, $t0
		la $a1, water_3		# call draw_row to draw water_row 3
		lw $a2, water
		lw $a3, logs
		jal draw_row
		
		la $t0, buffer	# move $t0 to the starting address of the safe zone
		lw $t1, line_offset
		li $t2, 65
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		move $a0, $t0		# call draw_rect to draw the safe zone
		lw $a1, line_pixel
		li $a2, 11
		lw $a3, safe
		jal draw_rect
		
		la $t0, buffer	# move $t0 to the starting address of row 1
		lw $t1, line_offset
		li $t2, 76
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2	
		move $a0, $t0
		la $a1, road_1		# call draw_row to draw road row 1
		lw $a2, road
		lw $a3, cars
		jal draw_row
		
		la $t0, buffer	# move $t0 to the starting address of row 2
		lw $t1, line_offset
		li $t2, 87
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		move $a0, $t0
		la $a1, road_2		# call draw_row to draw road row 2
		lw $a2, road
		lw $a3, cars
		jal draw_row
		
		la $t0, buffer	# move $t0 to the starting address of row 3
		lw $t1, line_offset
		li $t2, 98
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		move $a0, $t0
		la $a1, road_3		# call draw_row to draw road row 3
		lw $a2, road
		lw $a3, cars
		jal draw_row
		
		la $t0, buffer	# move $t0 to the starting address of the safe zone
		lw $t1, line_offset
		li $t2, 109
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		move $a0, $t0		# call draw_rect to draw the safe zone
		lw $a1, line_pixel
		li $a2, 11
		lw $a3, safe
		jal draw_rect
		
		lw $ra, 0($sp)			# load return address from stack
		addi $sp, $sp, 4		# move stack pointer
		jr $ra				# return

####################################################################################
# Function:
# Draw goal zone
#		
draw_goal:	addi $sp, $sp, -4		# move stack pointer a word
		sw $ra, 0($sp)			# store return address
		
		la $t0, buffer		# load $t0 with display address 
		lw $t1, line_offset		# load $t1 with line_offset
		li $t2, 17
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1		# move $t0 to the starting address of scence
		move $a0, $t0			# set a0 = t0
		lw $a1, line_pixel		# set a1 = 1 full line
		addi $a2, $zero, 4		# set a2 = 1
		lw $a3, goal			# load a3 = goal colour code
		jal draw_rect			# call draw_rect
		
		lw $t1, line_offset		# load line offset to $t1
		li $t2, 4			# set $t2 to 4
		mult $t1, $t2			# line_offset * 4
		mflo $t1
		add $t0, $t0, $t1		# move $t0 down 4 pixels
		
		move $a0, $t0			#
		li $a1, 1			#
		li $a2, 11			# Draw a line of the left of the goal zone
		lw $a3, goal			#
		jal draw_rect			#
		
		addi $t0, $t0, 4		# move $t0 right 1 pixel
		
		li $t1, 0			# set loop variable to 0
		la $t2, goal_status		# set $t2 to the addr of goal_status
goal_loop:	beq $t1, 9, end_goal_loop	# end loop if i = 9 (loop for 4 times)
		move $a0, $t0			# set $a0 to $t0
		li $a1, 14			# width = 14
		li $a2, 11			# height = 11
		li $t3, 2			# 
		div $t1, $t3			#
		mfhi $t3			# $t3 = $t1 % 2
		beqz $t3, place_water		# load_water if $t1 % 2 == 0, load_goal otherwise
place_goal:	lw $a3, goal			# load goal to $a3
		jal draw_rect			# draw goal zone
		j end_place			
place_water:	lw $a3, water			# load water to $a3
		jal draw_rect			# draw water
		lb  $t4, 0($t2)			# load $t2 to $t4
		beq $t4, 1, place_p1		# place p1 in goal if 
		beq $t4, 2, place_p2
		j end_place_p
place_p1:	move $a0, $t0			# set $a0 to current pos
		li $a1, 1			# set $a1 to 1
		jal draw_frog			# draw frog at $t0
		j end_place_p
place_p2:	move $a0, $t0			#
		li $a1, 2			# Draw player2 at $t0
		jal draw_frog			#
		j end_place_p
end_place_p:	addi $t2, $t2, 1			# move $t2 to the next byte
		j end_place
	
end_place:	addi $t0, $t0, 56		# move $t0 right 14 pixels
		addi $t1, $t1, 1		# increase i by 1
		j goal_loop			# continue loop

end_goal_loop:	move $a0, $t0			#
		li $a1, 1			#
		li $a2, 11			# Draw a line of the right of the goal zone
		lw $a3, goal			#
		jal draw_rect			#	 
		
		lw $ra, 0($sp)			# load return address from stack
		addi $sp, $sp, 4		# move stack pointer
		jr $ra				# return

####################################################################################
# Function:
# Draw row
# a0 = starting address, a1 = object bit flag addr, a2 = 0 colour, a3 = 1 colour
#
draw_row:	addi $sp, $sp, -4		# move stack pointer a word
		sw $ra, 0($sp)			# store return addr
		addi $sp, $sp, -4		# move stack pointer a word
		sw $s0, 0($sp)			# store s0
		addi $sp, $sp, -4		# move stack pointer a word
		sw $s1, 0($sp)			# store s1
		addi $sp, $sp, -4		# move stack pointer a word
		sw $s2, 0($sp)			# store s2
		addi $sp, $sp, -4		# move stack pointer a word
		sw $s3, 0($sp)			# store s3
		# srore arguments to s registers
		move $s0, $a0			# s0 is the starting address
		move $s1, $a1			# s1 is the bit flag address
		move $s2, $a2			# s2 is the 0 colour
		move $s3, $a3			# s3 is the 1 colour
		
		move $a0, $s0			#
		lw $a1, line_pixel		#
		li $a2, 1			# Draw top line
		move $a3, $s2			#
		jal draw_rect			#
		
		
		lw $t0, line_offset 		# load line_offset
		add $s0, $s0, $t0		# move s0 1 pixel down
		add $t0, $s0, $t0		# set $t0 to s0 + 1 line
row_loop:	beq $s0, $t0, end_row_loop	# end loop if s0 looped for 1 line

		li $t1, 0x80000000		# set first bit of t1 to 1 followed by 0s
word_loop:	beqz $t1, end_word_loop		# end lop if t1 is 0
		lw $t2, 0($s1)			# load s1
		and $t2, $t2, $t1		# t2 = ith bit of 0(s1)
		beqz $t2, ld_0			# load 0 colour if t2 is 0, load 1 colour otherwise
ld_1:		move $a3, $s3
		j end_ld_01
ld_0:		move $a3, $s2
		j end_ld_01
end_ld_01:	move $a0, $s0			# a0 = current pos
		li $a1, 1			# width = 1
		li $a2, 9			# hegith = 9
		jal draw_rect			# draw rect
		add $s0, $s0, 4			# move $s0 1 pixel right
		srl $t1, $t1, 1			# shift $t1 1 bit
		j word_loop			# continue loop
end_word_loop:	addi $s1, $s1, 4		# move $s1 to next word
		j row_loop			# continue loop
	 
end_row_loop:	lw $t0, line_offset
		li $t1, 8
		mult $t0, $t1
		mflo $t0
		add $s0, $s0, $t0
		
		move $a0, $s0			#
		lw $a1, line_pixel		#
		li $a2, 1			# Draw bottom line
		move $a3, $s2			#
		jal draw_rect			#
		
		
		
		lw $s3, 0($sp)			# load $s3 address from stack
		addi $sp, $sp, 4		# move stack pointer
		lw $s2, 0($sp)			# load $s2 address from stack
		addi $sp, $sp, 4		# move stack pointer
		lw $s1, 0($sp)			# load $s1 address from stack
		addi $sp, $sp, 4		# move stack pointer
		lw $s0, 0($sp)			# load $s0 address from stack
		addi $sp, $sp, 4		# move stack pointer
		lw $ra, 0($sp)			# load return address from stack
		addi $sp, $sp, 4		# move stack pointer
		jr $ra	
####################################################################################
# Function:
# Draw the bottom bar showing remaining lifes and time
#
draw_life:	addi $sp, $sp, -4		# move stack pointer a word
		sw $ra, 0($sp)			# store return address
		
		la $t0, buffer	# move $t0 to the starting address of the bottom bar
		lw $t1, line_offset
		li $t2, 120
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		move $a0, $t0
		lw $a1, line_pixel	# draw the background of the bar
		li $a2, 8
		lw $a3, score_bg
		jal draw_rect
		
		add $t0, $t0, $t1	# move $t0 1 px down
		add $t0, $t0, 4		# move $t0 1 px right
		
		
		lw $t2, p1_life		# load p1_life
		addi $t2, $t2, -1	# draw p1_life -1 mini frogs
		li $t3, 0			# loop variable
life_loop1:	beq $t3, $t2, end_life_loop1	# for loop, end whne i = life - 1
		move $a0, $t0			# draw a mini frog here
		li $a1, 1
		jal draw_life_icon
		addi $t0, $t0, 48
		addi $t3, $t3, 1
		j life_loop1

end_life_loop1:	la $t0, buffer	# move $t0 to the starting address of the bottom bar
		lw $t1, line_offset
		li $t2, 120
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		
		add $t0, $t0, $t1	# move two px down
		add $t0, $t0, $t1
		addi $t0, $t0, -48	# move 12 px backwards
		
		lw $t2, p2_life		# another loop for player 2
		addi $t2, $t2, -1
		li $t3, 0
life_loop2:	beq $t3, $t2, end_life_loop2
		move $a0, $t0
		li $a1, 2
		jal draw_life_icon
		addi $t0, $t0, -48	# move $t0 12 px backwards
		addi $t3, $t3, 1
		j life_loop2
end_life_loop2:
		la $t0, buffer	# move $t0 to the starting address of the bottom bar
		lw $t1, line_offset
		li $t2, 122
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		add $t0, $t0, 100
		move $a0, $t0		# draw the timer bar fro p1
		lw $a1, p1_time
		li $a2, 4
		lw $a3, score1_text
		jal draw_rect
		
		la $t0, buffer	# move $t0 to the starting address of the safe zone
		lw $t1, line_offset
		li $t2, 122
		mult $t1, $t2
		mflo $t2
		add $t0, $t0, $t2
		add $t0, $t0, 412
		lw $t3, p2_time
		sll, $t3, $t3, 2	# reserver p2_time px for the timer bar
		sub $t0, $t0, $t3
		move $a0, $t0		# draw p2 timer bar
		lw $a1, p2_time
		li $a2, 4
		lw $a3, score1_text
		jal draw_rect
		
		
		lw $ra, 0($sp)			# load return address from stack
		addi $sp, $sp, 4		# move stack pointer
		jr $ra	
####################################################################################
# Function:
# Move object
# $a0 = address of object bit flag
# if $a1 = 0, left rotate object bit flag 1 bit
# if $a1 = 1 , right rotate object bit flag 1 bit
move_object:	beq $a1, 1, move_right
		beq $a1, 0, move_left
		jr $ra				# return if $a1 value is incorrect
		
move_right:	# [0:31] bit
		lw $t7, 0($a0)			#
		lw $t3, 12($a0)			#
		srl $t7, $t7, 1			# right shift $t7 1 bit
		sll $t3, $t3, 31		# left shift $t3 31 bit
		or $t7, $t7, $t3		# set last bit of $t7
		# [32:63] bit
		lw $t6, 4($a0)			#
		lw $t3, 0($a0)			#
		srl $t6, $t6, 1			# right shift $t6 1 bit
		sll $t3, $t3, 31		# left shift $t3 31 bit
		or $t6, $t6, $t3		# set last bit of $t7
		# [64:95] bit
		lw $t5, 8($a0)			# 
		lw $t3, 4($a0)			# 
		srl $t5, $t5, 1			# right shift $t5 1 bit
		sll $t3, $t3, 31		# left shift $t3 31 bit
		or $t5, $t5, $t3		# set last bit of $t5
		# [96:127] bit
		lw $t4, 12($a0)			#
		lw $t3, 8($a0)			#
		srl $t4, $t4, 1			# right shift $t4 1 bit
		sll $t3, $t3, 31		# left shift $t3 31 bit
		or $t4, $t4, $t3		# set last bit of $t4
		# store words
		sw $t7 0($a0)
		sw $t6 4($a0)
		sw $t5 8($a0)
		sw $t4 12($a0)
		j end_move
		
move_left:	# [0:31] bit
		lw $t7, 0($a0)			#
		lw $t3, 4($a0)			#
		sll $t7, $t7, 1			# right shift $t7 1 bit
		srl $t3, $t3, 31		# left shift $t3 31 bit
		or $t7, $t7, $t3		# set last bit of $t7
		# [32:63] bit
		lw $t6, 4($a0)			#
		lw $t3, 8($a0)			#
		sll $t6, $t6, 1			# right shift $t6 1 bit
		srl $t3, $t3, 31		# left shift $t3 31 bit
		or $t6, $t6, $t3		# set last bit of $t7
		# [64:95] bit
		lw $t5, 8($a0)			# 
		lw $t3, 12($a0)			# 
		sll $t5, $t5, 1			# right shift $t5 1 bit
		srl $t3, $t3, 31		# left shift $t3 31 bit
		or $t5, $t5, $t3		# set last bit of $t5
		# [96:127] bit
		lw $t4, 12($a0)			#
		lw $t3, 0($a0)			#
		sll $t4, $t4, 1			# right shift $t4 1 bit
		srl $t3, $t3, 31		# left shift $t3 31 bit
		or $t4, $t4, $t3		# set last bit of $t4
		# store words
		sw $t7 0($a0)
		sw $t6 4($a0)
		sw $t5 8($a0)
		sw $t4 12($a0)
		j end_move
		
end_move:	jr $ra	
####################################################################################
#
# Function:
# Update position based on a given keyboard input $a0
#
keyboard:	beq $a0, 0x77, respond_w	# jump to respond_w if input is w
		beq $a0, 0x61, respond_a	# jump to respond_a if input is a
		beq $a0, 0x73, respond_s	# jump to repsond_s if input is s
		beq $a0, 0x64, respond_d	# jump to respond_d if input is d 
		beq $a0, 0x69, respond_i	# jump to respond_i if input is i
		beq $a0, 0x6a, respond_j	# jump to respond_j if input is j
		beq $a0, 0x6b, respond_k	# jump to repsond_k if input is k
		beq $a0, 0x6c, respond_l	# jump to respond_l if input is l 
		jr $ra				# return if no matches
		
respond_w:	lw $t7, p1_y			# load p1_y to $t7
		addi $t7, $t7, -11		# decrease $t7 (p1_y) by 11
		j update_p1y			# jump to update_y
		
respond_a:	lw $t7, p1_x			# load p1_y to $t7
		addi $t7, $t7, -14		# decrease $t7 (p1_y) by 11
		j update_p1x			# jump to update_y
		
respond_s:	lw $t7, p1_y			# load p1_y to $t7
		addi $t7, $t7, 11		# decrease $t7 (p1_y) by 11
		j update_p1y			# jump to update_y
		
respond_d:	lw $t7, p1_x			# load p1_y to $t7
		addi $t7, $t7, 14		# decrease $t7 (p1_y) by 11
		j update_p1x			# jump to update_y
		
respond_i:	lw $t7, p2_y			# load p1_y to $t7
		addi $t7, $t7, -11		# decrease $t7 (p1_y) by 11
		j update_p2y			# jump to update_y
		
respond_j:	lw $t7, p2_x			# load p1_y to $t7
		addi $t7, $t7, -14		# decrease $t7 (p1_y) by 11
		j update_p2x			# jump to update_y
		
respond_k:	lw $t7, p2_y			# load p1_y to $t7
		addi $t7, $t7, 11		# decrease $t7 (p1_y) by 11
		j update_p2y			# jump to update_y
		
respond_l:	lw $t7, p2_x			# load p1_y to $t7
		addi $t7, $t7, 14		# decrease $t7 (p1_y) by 11
		j update_p2x			# jump to update_y
		
update_p1x:	blt $t7, 0, set_p1x_0
		bgt $t7, 114, set_p1x_114
		sw $t7, p1_x
		j end_key			# store $t7 to frog-x
		
update_p1y:	blt $t7, 21, end_key
		bgt $t7, 109, end_key
		sw $t7, p1_y	
		j end_key		# store $t7 to frog_y

set_p1x_0:	li $t7, 0
		sw $t7, p1_x		# store 0 to p1x
		j end_key
		
set_p1x_114:	li $t7, 114
		sw $t7, p1_x		# store 114 to p1x
		j end_key
		
update_p2x:	blt $t7, 0, set_p2x_0
		bgt $t7, 114, set_p2x_114
		sw $t7, p2_x
		j end_key			# store $t7 to frog-x
		
update_p2y:	blt $t7, 21, end_key
		bgt $t7, 109, end_key
		sw $t7, p2_y	
		j end_key		# store $t7 to frog_y

set_p2x_0:	li $t7, 0
		sw $t7, p2_x		# store 0 to p1x
		j end_key
		
set_p2x_114:	li $t7, 114
		sw $t7, p2_x		# store 114 to p1x
		j end_key

end_key:	jr $ra		

####################################################################################
# Function:
# move frog 1 px
# $a0 = player number
# $a1 = -1 if move left; 1 if move right
move_frog:	beq $a0, 1, ld_p1_x
		beq $a0, 2, ld_p2_x
		jr $ra
ld_p1_x:	lw $t0, p1_x
		add $t0, $t0, $a1
		blt $t0, 0, end_move_frog
		bgt $t0, 114, end_move_frog
		sw $t0, p1_x
		j end_move_frog
		
ld_p2_x:	lw $t0, p2_x
		add $t0, $t0, $a1
		blt $t0, 0, end_move_frog
		bgt $t0, 114, end_move_frog
		sw $t0, p2_x
		j end_move
		
end_move_frog:	jr $ra

####################################################################################
# Function:
# Draw a rectangle with a given top left corner pixel, width, height, colour code
# $a0 = start address, $a1 = width, $a2 = height, $a3 = colour
# $t7 = line address, $t6 = i, $t5 = j, $t4 = unit address
#
draw_rect:	add $t7, $a0, $zero		# set $t7 to the starting address
		add $t6, $zero, $zero		# set $t6 to 0
		lw $t3, line_offset		# set $t3 to line offset
draw_rect_loop:	beq $t6, $a2, end_draw_rect	# end outer loop when $t6 = width	
		add $t5, $zero, $zero 		# set $t5 to 0
		add $t4, $t7, $zero		# set $t4 to $t7
draw_line:	beq $t5, $a1, end_draw_line	# end inner loop when $t5 = height
		sw $a3, 0($t4)			# set $t7 to $a3 colour
		addi $t4, $t4, 4		# move $t7 to the right unit
		addi $t5, $t5, 1		# increase $t5 by 1
		j draw_line			# continue inner loop
end_draw_line:	addi $t6, $t6, 1		# increase $t6 by 1
		add $t7, $t7, $t3		# move $t7 to the next line
		j draw_rect_loop		# continue outer loop
end_draw_rect:	jr $ra				# return

####################################################################################
# Function:
# Draw digit
# $a0 = top left corner address, $a1 = digit (0 to 9), $a2 = colour
#
draw_digit:	move $t7, $a0			# set $t7 to the starting address
		move $t6, $a2			# set $t6 to the text colour
		lw $t5, line_offset		# set $t5 to pixels in a whole line
		beq $a1, 0, draw_0		# 
		beq $a1, 1, draw_1		#
		beq $a1, 2, draw_2		#
		beq $a1, 3, draw_3		#
		beq $a1, 4, draw_4		# Branch to the correct draw digit
		beq $a1, 5, draw_5		#
		beq $a1, 6, draw_6		#
		beq $a1, 7, draw_7		#
		beq $a1, 8, draw_8		#
		beq $a1, 9, draw_9		#
		jr $ra				# return if no case is matched
draw_0:		sw $t6, 4($t7)			# line 0 
		sw $t6, 8($t7)			# 1,2,3,4
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 0($t7)			# line 1
		sw $t6, 4($t7)			# 0,1, 4,5
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 0($t7)			# line 2
		sw $t6, 4($t7)			# 0,1, 4,5
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 0($t7)			# line 3
		sw $t6, 4($t7)			#0,1, 4,5
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 0($t7)			# line 4
		sw $t6, 4($t7)			# 0,1, 4,5
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 0($t7)			# line 5
		sw $t6, 4($t7)			# 0,1, 4,5
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 6 
		sw $t6, 8($t7)			# 1,2,3,4
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		jr $ra
draw_1:		sw $t6, 8($t7)			#line 0 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 4($t7)			# line 1 (1,2,3)
		sw $t6, 8($t7)			#line 0 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 8($t7)			#line 2 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 8($t7)			#line 3 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 8($t7)			#line 4 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5 		# move $t7 to next line
		sw $t6, 8($t7)			#line 5 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 6 
		sw $t6, 8($t7)			# 1,2,3,4
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		jr $ra
draw_2:		sw $t6, 4($t7)			# line 0 (1,2,3,4)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 1 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 2 (4,5)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 8($t7)			# line 3 (2,3,4)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 4 (1,2)
		sw $t6, 8($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 5 (0,1)
		sw $t6, 4($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 6 (0,1,2,3,4,5)
		sw $t6, 4($t7)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)	
		sw $t6, 20($t7)
		jr $ra
draw_3:		sw $t6, 4($t7)			# line 0 (1,2,3,4)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 1 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 2 (4,5)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 8($t7)			# line 3 (2,3,4)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 4 (4,5)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 5 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 6 (1,2,3,4)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		jr $ra
draw_4:		sw $t6, 0($t7)			# line 0 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 1 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 2 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 3 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 4 (1,2,3,4,5)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 5 (4,5)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 5 (4,5)
		sw $t6, 20($t7)
		jr $ra
draw_5:		sw $t6, 0($t7)			# line 0 (1,2,3,4,5)
		sw $t6, 4($t7)			
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 1 (0,1)
		sw $t6, 4($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 2 (0,1,2,3,4)
		sw $t6, 4($t7)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 3 (4,5)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 4 (4,5)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 5 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 6 (1,2,3,4)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		jr $ra
draw_6:		sw $t6, 4($t7)			# line 0 (1,2,3,4,5)		
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 1 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 2 (0,1)
		sw $t6, 4($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 3 (0,1,2,3,4)
		sw $t6, 4($t7)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 4 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 5 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 6 (1,2,3,4)
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		jr $ra
draw_7:		sw $t6, 0($t7)			# line 0 (0,1,2,3,4,5)
		sw $t6, 4($t7)		
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 1 (4,5)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 12($t7)			# line 2 (3,4)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 8($t7)			# line 3 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 8($t7)			# line 4 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 8($t7)			# line 5 (2,3)
		sw $t6, 12($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 8($t7)			# line 6 (2,3)
		sw $t6, 12($t7)
		jr $ra
draw_8:		sw $t6, 4($t7)			# line 0 (1,2,3,4)	
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 1 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 2 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 3 (1,2,3,4)	
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 4 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 5 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 6 (1,2,3,4)	
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		jr $ra
draw_9:		sw $t6, 4($t7)			# line 0 (1,2,3,4)	
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 1 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 2 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 3 (1,2,3,4,5)	
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 16($t7)			# line 4 (4,5)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 0($t7)			# line 5 (0,1,4,5)
		sw $t6, 4($t7)
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5		# move $t7 to next line
		sw $t6, 4($t7)			# line 6 (1,2,3,4)	
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		jr $ra

####################################################################################
# Function: draw P
# $a0 = top left corner address, $a1 = colour
#
draw_p:		move $t7, $a0		# set $t7 to top left corner adderess
		move $t6, $a1		# load score text colour
		lw $t5, line_offset	# load line offset
		sw $t6, 0($t7)		# line 0
		sw $t6, 4($t7)		# 0, 1, 2, 3, 4
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5 	# move $t7 to next line
		sw $t6, 0($t7)		# line 1
		sw $t6, 4($t7)		# 0,1, 4,5
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5 	# move $t7 to next line
		sw $t6, 0($t7)		# line 2
		sw $t6, 4($t7)		# 0,1, 4,5
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5 	# move $t7 to next line
		sw $t6, 0($t7)		# line 2
		sw $t6, 4($t7)		# 0,1, 4,5
		sw $t6, 16($t7)
		sw $t6, 20($t7)
		add $t7, $t7, $t5 	# move $t7 to next line
		sw $t6, 0($t7)		# line 4
		sw $t6, 4($t7)		# 0, 1, 2, 3, 4
		sw $t6, 8($t7)
		sw $t6, 12($t7)
		sw $t6, 16($t7)
		add $t7, $t7, $t5 	# move $t7 to next line
		sw $t6, 0($t7)		# line 5
		sw $t6, 4($t7)		# 0, 1
		add $t7, $t7, $t5 	# move $t7 to next line
		sw $t6, 0($t7)		# line 6
		sw $t6, 4($t7)		# 0, 1
		jr $ra
		
	
####################################################################################
# Function:
# Draw a frog with a given top left pixel
# if a1 = 1 draw player 1
# if a1 = 2 draw player 2
#
draw_frog:	beq $a1, 2, ld_player2		# select the correct colour
		beq $a1, 1, ld_player1
		jr $ra				# return if $a1 is a wrong option
		
ld_player1:	lw $t7, p1_colour		# load p1_colour
		lw $t4, p1_eye_colour		# load p1_eye_colour
		j end_ld_p
ld_player2:	lw $t7, p2_colour		# load p2_colour
		lw $t4, p2_eye_colour		# load p1_eye_colour
		j end_ld_p
		
end_ld_p:	lw $t6 line_offset		# load line_offset
		add $t5, $a0, $t6		# move $t5 to 1 pixel below $a0
		sw $t7, 8($t5)			# line 1 (2,5,6,7,8,11)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 44($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 4($t5)			# line 2 (1,2,5,6,7,8,11,12)
		sw $t7, 8($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 44($t5)
		sw $t7, 48($t5)
		sw $t4, 16($t5)			# draw eyes
		sw $t4, 36($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 8($t5)			# line 3 (2,4,5,6,7,8,9,11)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 36($t5)
		sw $t7, 44($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 8($t5)			# line 4 (2,3,4,5,6,7,8,9,10,11)
		sw $t7, 12($t5)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 36($t5)
		sw $t7, 40($t5)
		sw $t7, 44($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 16($t5)			# line 5 (4,5,6,7,8,9)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 36($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 8($t5)			# line 6 (2,3,4,5,6,7,8,9,10,11)
		sw $t7, 12($t5)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 36($t5)
		sw $t7, 40($t5)
		sw $t7, 44($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 8($t5)			# line 7 (2,4,5,6,7,8,9,11)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 36($t5)
		sw $t7, 44($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 4($t5)			# line 8 (1,2,5,6,7,8,11,12)
		sw $t7, 8($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 44($t5)
		sw $t7, 48($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 8($t5)			# line 9 (2,11)
		sw $t7, 44($t5)
		jr $ra				#return
####################################################################################
#
# Function
# Draw life icon
# $a0 = topleft corner address
# if a1 = 1 draw player 1
# if a1 = 2 draw player 2
#
draw_life_icon:	beq $a1, 2, ld_player2_m	# select the correct colour
		beq $a1, 1, ld_player1_m
		jr $ra				# return if $a1 is a wrong option
ld_player1_m:	lw $t7, p1_colour		# load p1_colour
		lw $t4, p1_eye_colour		# load p1_eye_colour
		j end_ld_pm
ld_player2_m:	lw $t7, p2_colour		# load p2_colour
		lw $t4, p2_eye_colour		# load p1_eye_colour
		j end_ld_pm
end_ld_pm:	lw $t6, line_offset		# load line_offset
		move $t5, $a0			# set $$t7 = $a0
		sw $t7, 4($t5)			# line 0 (1,4,5,6,9)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 36($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 0($t5)			# line 1 (0,1,4,5,6,9,10)
		sw $t7, 4($t5)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 36($t5)
		sw $t7, 40($t5)
		sw $t4, 12($t5)			# draw eyes
		sw $t4, 28($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 4($t5)			# line 2 (1,2,3,4,5,6,7,8,9)
		sw $t7, 8($t5)
		sw $t7, 12($t5)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 36($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 12($t5)			# line 3 (3,4,5,6,7)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 4($t5)			# line 4 (1,2,3,4,5,6,7,8,9)
		sw $t7, 8($t5)
		sw $t7, 12($t5)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 28($t5)
		sw $t7, 32($t5)
		sw $t7, 36($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 0($t5)			# line 5 (0,1,4,5,6,9,10)
		sw $t7, 4($t5)
		sw $t7, 16($t5)
		sw $t7, 20($t5)
		sw $t7, 24($t5)
		sw $t7, 36($t5)
		sw $t7, 40($t5)
		add $t5, $t5, $t6		# move $t5 1 pixel down
		sw $t7, 4($t5)			# line 6 (1,9)
		sw $t7, 36($t5)
		jr $ra
