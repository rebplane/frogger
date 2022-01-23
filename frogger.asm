#########################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#
# Which additional features have been implemented?
# 1. Display the number of lives remaining
# 2. Display a death animation each time the player loses a frog
# 3. After final player death, display a game over/retry screen. Restart the game if the "retry" option is chosen.
# 4. Add sound effects for movement, collisions, game end and reaching the goal area.
# 5. Two-player mode (two sets of inputs controlling two frogs at the same time).

.data
	displayAddress: .word 0x10008000
	livesColor: .word 0xac3232
	resetColor: .word 0x9e9aa0
	white: .word 0xffffff
	grass: .word 0x164e37 # stores the grass color
	water: .word 0x4c8cff # stores the water color
	land: .word 0xdf7126 # stores the land color
	black: .word 0x000000 # stores the road color
	frogGreen: .word 0x99e550 # stores the frog color
	vehicleColor: .word 0xd77bba # stores the vehicle color
	logColor: .word 0x8f563b
	turtleColor: .word 0xff0404
	winFrogColor: .word 0x6abe30
	frogX: .half 12 # stores the x location of the frog
	frogY: .half 28 # stores the y location of the frog
	frog2X: .half 20
	frog2Y: .half 28
	livesRemaining: .half 3
	lives: .half 3
	vehicleRow1: .space 512 # stores the pixels in the bottom row of vehicles
	vehicleRow2: .space 512 # stores the pixels in the top row of vehicles
	logRow1: .space 512 # stores the pixels in the bottom row of logs
	turtleRow: .space 512 # stores the pixels in the turtle row
	line: .space 512
	resetArray: .half 432, 460, 564, 584, 696, 700, 704, 708, 824, 828, 832, 836, 952, 956, 960, 964, 1080, 1084, 1088, 1092, 1204, 1224, 1328, 1356, 1556, 1560, 1564, 1684, 1692, 1812, 1816, 1940, 1948, 2068, 2076, 1572, 1576, 1700, 1828,1832, 1956, 2084, 2088, 1584, 1588, 1592, 1716, 1844, 1972, 2100, 1600, 1604, 1608, 1728, 1736, 1856, 1860, 1984, 1992, 2112, 2120, 1616, 1624, 1744, 1752, 1872, 1876, 1880, 2008, 2136, 2128, 2132, 2136, 1632, 1636, 1640, 1768, 1896, 1888, 1892, 1896, 2144, 2352, 2356, 2360, 2364, 2368, 2372, 2376, 2480, 2608, 2736, 2864, 2992, 3120, 3248, 2504, 2632, 2760, 2888, 3016, 3144, 3272, 3252, 3256, 3260, 3264, 3268, 2616, 2620, 2624, 2744, 2872, 3000, 2752, 2876, 3008
.text

main:
	addi $t0, $zero, 3
	sh $t0, livesRemaining
initializeVehicles:
	jal initializeVehicleRow1 # sets the registers for the bottom row of vehicles
	jal initializeRow # initializes the bottom row of vehicles
	jal initializeVehicleRow2
	jal initializeRow
	jal initializeLogRow1
	jal initializeRow
	jal initializeTurtleRow
	jal initializeRow
initializeBackground:
	add $t7, $zero, $zero # if t7 is zero, it will overwrite the safe area
	jal Background
	j updateObjects
drawBackground:
	addi $t7, $zero, 1 # if t7 is not zero, it will not overwrite the safe area
	jal Background
updateObjects:
	jal updateVehicleRow1
	jal updateRowRight
	jal updateLogRow1
	jal updateRowRight
	jal updateVehicleRow2
	jal updateRowLeft
	jal updateTurtleRow
	jal updateRowLeft
Frog: 
	jal drawFrog
	jal drawFrog2
drawObjects:
	lw $t9, displayAddress # base address for display
	jal drawVehicleRow1
	jal drawRow
	jal drawVehicleRow2
	jal drawRow
	jal drawLogRow1
	jal drawRow
	jal drawTurtleRow
	jal drawRow
	j collisionCheckFrog1
moveFrog: # if the frog has moved, come here instead
	jal Background
	li $v0, 31 # play a sound
	li $a0, 67
	li $a1, 300
	li $a2, 122
	li $a3, 100
	syscall
	lw $t9, displayAddress # base address for display
	jal drawVehicleRow1
	jal drawRowIgnoreFrog
	jal drawVehicleRow2
	jal drawRowIgnoreFrog
	jal drawLogRow1
	jal drawRowIgnoreFrog
	jal drawTurtleRow
	jal drawRowIgnoreFrog
	jal drawLives
collisionCheckFrog1: # check if the first frog hit anything
	lw $t0, displayAddress # get the display address to store in t0 to use in getFrogPosition
	jal getFrogPosition # stores the frog's display address location in t2
	lw $t0, displayAddress # load display address again
	addi $t8, $zero, 1 # set t8 to 1
	addi $t3, $t0, 528 # 528 is safe area 1
	beq $t3, $t2, frogIsWin
	addi $t3, $t0, 560 # 560 is safe area 2
	beq $t3, $t2, frogIsWin
	addi $t3, $t0, 592 # 592 is safe area 3
	beq $t3, $t2, frogIsWin
	addi $t3, $t0, 624 # 624 is safe area 4
	beq $t3, $t2, frogIsWin
	addi $t3, $t0, 512
	beq $t2, $t3, frogIsDeadSafeArea
	addi $t3, $t0, 544
	beq $t2, $t3, frogIsDeadSafeArea
	addi $t3, $t0, 576
	beq $t2, $t3, frogIsDeadSafeArea
	addi $t3, $t0, 600
	beq $t2, $t3, frogIsDeadSafeArea
	lw $t1, vehicleColor
	add $t3, $t2, 128 # get the pixel underneath the frog's left arm
	add $t4, $t2, 140 # get the pixel underneath the frog's right arm
	lw $t3, 0($t3) # get the pixel's color underneath the frog's left arm
	lw $t4, 0($t4) # get the pixel's color underneath the frog's right arm
	lw $t1, vehicleColor
	beq $t3, $t1, frogIsDead # if this pixel is pink, then the frog hit a car and is dead
	beq $t4, $t1, frogIsDead # if this pixel is pink, then the frog hit a car and is dead
	lw $t1, water
	bne $t3, $t1, collisionCheckFrog2 # if this pixel is water, then check if the frog is completely in water, else go back for more input
	beq $t4, $t1, frogIsDead # if this pixel is water, then the frog hit a car and is dead
collisionCheckFrog2: # check if the second frog hit anything
	lw $t0, displayAddress # get the display address to store in t0 to use in getFrogPosition
	jal getFrogPosition2 # stores the second frog's display address location in t2
	lw $t0, displayAddress # load display address again
	addi $t8, $zero, 1 # set t8 to 1
	addi $t3, $t0, 528 # 528 is safe area 1
	beq $t3, $t2, frogIsWin
	addi $t3, $t0, 560 # 560 is safe area 2
	beq $t3, $t2, frogIsWin
	addi $t3, $t0, 592 # 592 is safe area 3
	beq $t3, $t2, frogIsWin
	addi $t3, $t0, 624 # 624 is safe area 4
	beq $t3, $t2, frogIsWin
	addi $t3, $t0, 512
	beq $t2, $t3, frogIsDeadSafeArea
	addi $t3, $t0, 544
	beq $t2, $t3, frogIsDeadSafeArea
	addi $t3, $t0, 576
	beq $t2, $t3, frogIsDeadSafeArea
	addi $t3, $t0, 600
	beq $t2, $t3, frogIsDeadSafeArea
	lw $t1, vehicleColor
	add $t3, $t2, 128 # get the pixel underneath the frog's left arm
	add $t4, $t2, 140 # get the pixel underneath the frog's right arm
	lw $t3, 0($t3) # get the pixel's color underneath the frog's left arm
	lw $t4, 0($t4) # get the pixel's color underneath the frog's right arm
	lw $t1, vehicleColor
	beq $t3, $t1, frogIsDead2 # if this pixel is pink, then the frog hit a car and is dead
	beq $t4, $t1, frogIsDead2 # if this pixel is pink, then the frog hit a car and is dead
	lw $t1, water
	bne $t3, $t1, keyboardInput # if this pixel is water, then check if the frog is completely in water, else go back for more input
	beq $t4, $t1, frogIsDead2 # if this pixel is water, then the frog hit a car and is dead
	lw $t0, displayAddress
	j keyboardInput # don't draw a dead frog if it's not dead...
frogIsWin:
	jal drawWinFrog
	li $v0, 31 # play a sound
	li $a0, 67
	li $a1, 700
	li $a2, 15
	li $a3, 100
	syscall
	li $v0, 32
	li $a0, 1000
	syscall
	addi $t0, $zero, 12 # frog's initial x position
	addi $t1, $zero, 28 # frog's initial y position
	sh $t0, frogX # reset frog's initial x position to starting position
	sh $t1, frogY # reset frog's intial y position to starting position
	addi $t0, $zero, 20 # second frog's initial x position
	addi $t1, $zero, 28 # second frog's initial y position
	sh $t0, frog2X
	sh $t1, frog2Y
	add $t7, $zero, $zero # set t7 to zero to not draw safe area
	j drawBackground
frogIsDeadSafeArea: # the frog dies on the land near the safe area
	add $t8, $zero, $zero # set t8 to zero if the frog dies on the land near the safe area
frogIsDead:
	addi $t7, $zero, 1 # set t7 to 1 to not draw safe area
	li $v0, 31 # play a sound
	li $a0, 67
	li $a1, 500
	li $a2, 126
	li $a3, 100
	syscall
	jal Background
	lw $t9, displayAddress # base address for display
	jal drawVehicleRow1
	jal drawRowIgnoreFrog
	jal drawVehicleRow2
	jal drawRowIgnoreFrog
	jal drawLogRow1
	jal drawRowIgnoreFrog
	jal drawTurtleRow
	jal drawRowIgnoreFrog
	jal drawDeadFrog
	li $v0, 32
	li $a0, 1000
	syscall
	addi $t0, $zero, 12 # frog's initial x position
	addi $t1, $zero, 28 # frog's initial y position
	sh $t0, frogX # reset frog's initial x position to starting position
	sh $t1, frogY # reset frog's intial y position to starting position
	addi $t0, $zero, 20 # second frog's initial x position
	addi $t1, $zero, 28 # second frog's initial y position
	sh $t0, frog2X
	sh $t1, frog2Y
	lh $t1, livesRemaining
	addi $t1, $t1, -1 # decrement the number of lives by 1
	sh $t1, livesRemaining # store t0 back into lives
	beq $t1, $zero, endGame # game over screen if the player has no more lives yet
	lw $t1, grass
	beq $t8, $zero, drawSquare # draw a square where the frog died if it died on the land near the safe area
	jal drawSquare
	j moveFrog
frogIsDead2:
	addi $t7, $zero, 1 # set t7 to 1 to not draw safe area
	li $v0, 31 # play a sound
	li $a0, 67
	li $a1, 500
	li $a2, 126
	li $a3, 100
	syscall
	jal Background
	lw $t9, displayAddress # base address for display
	jal drawVehicleRow1
	jal drawRowIgnoreFrog
	jal drawVehicleRow2
	jal drawRowIgnoreFrog
	jal drawLogRow1
	jal drawRowIgnoreFrog
	jal drawTurtleRow
	jal drawRowIgnoreFrog
	jal drawDeadFrog2
	li $v0, 32
	li $a0, 1000
	syscall
	addi $t0, $zero, 12 # frog's initial x position
	addi $t1, $zero, 28 # frog's initial y position
	sh $t0, frogX # reset frog's initial x position to starting position
	sh $t1, frogY # reset frog's intial y position to starting position
	addi $t0, $zero, 20 # second frog's initial x position
	addi $t1, $zero, 28 # second frog's initial y position
	sh $t0, frog2X
	sh $t1, frog2Y
	lh $t1, livesRemaining
	addi $t1, $t1, -1 # decrement the number of lives by 1
	sh $t1, livesRemaining # store t0 back into lives
	beq $t1, $zero, endGame # game over screen if the player has no more lives yet
	lw $t1, grass
	beq $t8, $zero, drawSquare # draw a square where the frog died if it died on the land near the safe area
	jal drawSquare
	j moveFrog
keyboardInput:
	lw $t8, 0xffff0000 # listen for keyboard input
	beq $t8, 1, keyboard_input # if a key was pressed, go to function keyboard_input
sleep:	
	li $v0, 32
	li $a0, 500
	syscall
	j updateObjects

keyboard_input:
	lw $t2, 0xffff0004 # get the key that was pressed
	beq $t2, 0x61, respond_to_A # if the A key was pressed, go to function respond_to_A
	beq $t2, 0x64, respond_to_D # if the D key was pressed, go to the function respond_to_D
	beq $t2, 0x73, respond_to_S # if the S key was pressed, go to the function respond_to_S
	beq $t2, 0x77, respond_to_W # if the W key was pressed, go to the function respond_to_W
	beq $t2, 0x68, respond_to_H # if the H key was pressed, go to function respond_to_H
	beq $t2, 0x6B, respond_to_K # if the K key was pressed, go to the function respond_to_K
	beq $t2, 0x6A, respond_to_J # if the J key was pressed, go to the function respond_to_J
	beq $t2, 0x75, respond_to_U # if the U key was pressed, go to the function respond_to_U
	j updateObjects

respond_to_A:
	lh $t3, frogX # get the value in frogX and store it in t3
	addi $t3, $t3, -4 # decrement the frog's X position by -4 (shift it over by one 4x4 square to the left)
	bltz $t3, sleep # if the top left pixel is less than 0 (goes over left side of screen), go back to sleep
	sh $t3, frogX # put the decremented value back into frogX
	j moveFrog # go back and draw the background, frogs, and objects
	
respond_to_D:
	lh $t3, frogX # get the value in frogX and store it in t3
	addi $t3, $t3, 4 # increment the frog's X position by 4 (shift it over by one 4x4 square to the right)
	addi $t4, $t3, -30
	bgtz $t4, sleep # if the top left pixel is greater than 27 (goes over right side of the screen), go back to sleep
	sh $t3, frogX # put the incremented value
	j moveFrog

respond_to_S:
	lh $t3, frogY # get the value in frogY and store it in t3
	addi $t3, $t3, 4 # increment the frog's Y position by -4 (shift it down by one 4x4 square)
	addi $t4, $t3, -30  
	bgtz $t4, sleep # if the top left pixel is greater than 27 (goes over the bottom of screen), go back to sleep
	sh $t3, frogY
	j moveFrog
	
respond_to_W:
	lh $t3, frogY # get the value in frogY and store it in t3
	addi $t3, $t3, -4 # decrement the frog's Y position by 4 (shift it up by one 4x4 square)
	bltz $t3, sleep # if the otp left pixel is less than 0 (goes over top of screen), go back to sleep
	sh $t3, frogY
	j moveFrog

respond_to_H:
	lh $t3, frog2X # get the value in frogX and store it in t3
	addi $t3, $t3, -4 # decrement the frog's X position by -4 (shift it over by one 4x4 square to the left)
	bltz $t3, sleep # if the top left pixel is less than 0 (goes over left side of screen), go back to sleep
	sh $t3, frog2X # put the decremented value back into frogX
	j moveFrog # go back and draw the background, frogs, and objects
	
respond_to_K:
	lh $t3, frog2X # get the value in frogX and store it in t3
	addi $t3, $t3, 4 # increment the frog's X position by 4 (shift it over by one 4x4 square to the right)
	addi $t4, $t3, -30
	bgtz $t4, sleep # if the top left pixel is greater than 27 (goes over right side of the screen), go back to sleep
	sh $t3, frog2X # put the incremented value
	j moveFrog

respond_to_J:
	lh $t3, frog2Y # get the value in frogY and store it in t3
	addi $t3, $t3, 4 # increment the frog's Y position by -4 (shift it down by one 4x4 square)
	addi $t4, $t3, -30  
	bgtz $t4, sleep # if the top left pixel is greater than 27 (goes over the bottom of screen), go back to sleep
	sh $t3, frog2Y
	j moveFrog
	
respond_to_U:
	lh $t3, frog2Y # get the value in frogY and store it in t3
	addi $t3, $t3, -4 # decrement the frog's Y position by 4 (shift it up by one 4x4 square)
	bltz $t3, sleep # if the otp left pixel is less than 0 (goes over top of screen), go back to sleep
	sh $t3, frog2Y
	j moveFrog

updateVehicleRow1:
	la $t1, vehicleRow1
	jr $ra

updateLogRow1:
	la $t1, logRow1
	jr $ra
	
updateVehicleRow2:
	la $t1, vehicleRow2
	jr $ra

updateTurtleRow:
	la $t1, turtleRow
	jr $ra

updateRowRight: # shifts the objects to the right
	lw $t2, 508($t1) # take the last pixel of the row and store it in t2
	add $t3, $t1, $zero # store the offset of the row
	addi $t4, $t1, 508 # store the endpoint of the loop
	lw $t5, 0($t3) # load the color in the current pixel
updateRowRightLoop:	
	beq $t3, $t4, endUpdateRight
	lw $t6, 4($t3) # loads the next color into t6
	sw $t5, 4($t3) # store the color in the next pixel
	add $t5, $t6, $zero # load the old next color in the next pixel to draw
	addi $t3, $t3, 4 # increment counter
	j updateRowRightLoop
endUpdateRight:
	sw $t2, 0($t1) # stores the last pixel we took before into the first pixel of the row
	jr $ra
	
updateRowLeft: # hardcoding vehicle row 2 first
	lw $t2, 0($t1) # take the first pixel of the row and store it in t2
	addi $t4, $t1, 512 # stores the offset of the row
	add $t3, $t1, $zero # stores the endpoint of the loop
	lw $t5, 508($t1)
updateRowLeftLoop:
	beq $t3, $t4, endUpdateRowLeft
	lw $t6, -4($t4) # loads the previous pixel color into t6
	sw $t5, -4($t4) # store sthe color in the previous pixel
	add $t5, $t6, $zero # load the old preivous color in the previous pixel to draw
	addi $t4, $t4, -4
	j updateRowLeftLoop
endUpdateRowLeft:
	sw $t2, 508($t1) # stores the first pixel we took into the last pixel of the row
	jr $ra

drawVehicleRow1: # sets the registers to draw the first (bottom) row of vehicles
	la $t1, vehicleRow1 # t1 holds the vehicle row base address
	addi $t0, $t9, 3072
	jr $ra

drawVehicleRow2:
	la $t1, vehicleRow2 # t1 holds the vehicle row base address
	addi $t0, $t9, 2560
	jr $ra

drawLogRow1:
	la $t1, logRow1
	addi $t0, $t9, 1536
	jr $ra

drawTurtleRow:
	la $t1, turtleRow
	addi $t0, $t9, 1024
	jr $ra

initializeVehicleRow1: # sets the registers to initialize the first (bottom) row of vehicles
	lw $t1, vehicleColor
	lw $t7, black 
	la $t0, vehicleRow1 # t0 stores the address for vehicleRow1
	jr $ra

initializeVehicleRow2: # sets the registers to initialize the second (top) row of vehicles)
	lw $t7, vehicleColor
	lw $t1, black 
	la $t0, vehicleRow2 # t0 stores the address for vehicleRow1
	jr $ra

initializeLogRow1: # sets the registers to initialize the second
	lw $t1, logColor
	lw $t7, water
	la $t0, logRow1
	jr $ra

initializeTurtleRow:
	lw $t7, turtleColor
	lw $t1, water
	la $t0, turtleRow
	jr $ra

drawRowIgnoreFrog:  # draws a row of vehicles/logs/turtles in the road/water, overwrites the frog
	add $t2, $t0, $zero # t2 holds the pixel to display's display address
	add $t3, $t1, $zero # t3 holds the offset for the vehicle address
	addi $t4, $t3, 512 # t4 holds the end address for vehicle to stop the loop
drawSegmentIgnoreFrog: # draws the vehicle/log/turtle segment by segment
	beq $t4, $t3, endDrawSegmentIgnoreFrog
drawSegmentPixelIgnoreFrog:
	lw $t8, 0($t3) # load the pixel from the vehicle address to t8
	sw $t8, 0($t2) # save the pixel in t3 to t2 (the display)
updateSegmentCounterIgnoreFrog:	
	add $t2, $t2, 4 # increment t2 by 4
	add $t3, $t3, 4 # increment t2 by 4
	j drawSegmentIgnoreFrog
endDrawSegmentIgnoreFrog:
	jr $ra

drawRow: # draws a row of vehicles/logs/turtles in the road/water, ignore places where the frog is
	add $t2, $t0, $zero # t2 holds the pixel to display's display address
	add $t3, $t1, $zero # t3 holds the offset for the vehicle address
	addi $t4, $t3, 512 # t4 holds the end address for vehicle to stop the loop
drawSegment: # draws the vehicle/log/turtle segment by segment
	beq $t4, $t3, endDrawSegment
	lw $t5, 0($t2) # t5 holds the current pixel's color
	lw $t7, frogGreen #t7 holds the frog's color
	beq $t5, $t7, updateSegmentCounter
drawSegmentPixel:
	lw $t8, 0($t3) # load the pixel from the vehicle address to t8
	sw $t8, 0($t2) # save the pixel in t3 to t2 (the display)
updateSegmentCounter:	
	add $t2, $t2, 4 # increment t2 by 4
	add $t3, $t3, 4 # increment t2 by 4
	j drawSegment
endDrawSegment:
	jr $ra

initializeRow:
	add $t2, $t0, $zero # t2 stores the location in memory
	addi $t3, $t2, 1024 # t3 holds t2 + 1024 (the end value of our loop)
rowLoop:	
	beq $t2, $t3, endRow # exit loop when offset = 1024
	add $t4, $zero, $zero # t4 stores 0
	addi $t5, $zero, 32 # t5 stores 32
	addi $t6, $zero, 64 # t6 stores 64
drawSegmentOne:	 # draws the first 8 pixels of one color
	beq $t4, $t5, drawSegmentTwo # exit loop when t4 = 32, saves the 8 pixels of the vehicle
	sw $t1, 0($t2) # saves the vehicle pixel to the specified address
	add $t2, $t2, 4 # updates the offset
	add $t4, $t4, 4 # updates t4
	j drawSegmentOne
drawSegmentTwo: # draws the next 8 pixels of another color
	beq $t4, $t6, jumpRow # exit loop when t4 = 64, saves the 8 pixels of road
	sw $t7, 0($t2) # saves the road pixel to the specified address
	add $t2, $t2, 4 # updates the offset
	add $t4, $t4, 4 # updates t4
	j drawSegmentTwo
jumpRow:
	j rowLoop
endRow:
	jr $ra
	
Background: # start drawing the background
	lw $t0, displayAddress # $t0 stores the base address for display
	sw $ra, 0($sp)
	add $t2, $zero, $zero
	jal drawLives
	add $t2, $zero, $zero
	addi $t4, $zero, 512 # set t4 to the value 512 (the total number of pixels we'll draw per jump)
	add $t3, $t2, $t0 # stores the address for the pixel
	addi $t3, $t3, 508
	lw $t1, grass # stores grass color for use
	beq $t7, $zero, drawSafeAreaTrue
	addi $t3, $t3, 512 # skip the safe area pixels if t7 is not zero 
	j Water	
drawSafeAreaTrue:
	jal drawSafeArea
Water:
	addi $t3, $t3, 1024 # skip the water pixels
Land:
	lw $t1, land # Set the land color for use
	jal Rectangle
Road: 
	addi $t3, $t3, 1024 # skip the road pixels
Grass:
	lw $t1, grass
	jal Rectangle
	lw $ra, 0($sp)
	jr $ra # jump back to the initial ra

drawSafeArea:
	addi $t0, $t3, 4
	add $t2, $zero, $zero
drawSafeAreaSquare:
	beq $t2, $t4, endRectangle
	lw $t1, grass
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	lw $t1, water
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	j drawSafeAreaSquare	

Rectangle: 
	addi $t0, $t3, 4 # sets the display address
startRectangle:  # initializes the rectangle
	add $t2, $zero, $zero # initialize t2 to zero
drawRectangle: # draws the rectangle
	beq $t2, $t4, endRectangle
	add $t3, $t2, $t0 # stores the address for the pixel
	sw $t1, 0($t3) # paint the pixel
	addi $t2, $t2, 4
	j drawRectangle
endRectangle:
	jr $ra

drawDeadFrog:
	lw $t0, displayAddress # load display address into t0
	sw $ra, 0($sp)
	jal getFrogPosition # get the frog's position in displayaddress
	lw $t1, frogGreen # store frog color in t1
	sw $t1, 0($t2)
	sw $t1, 12($t2)
	sw $t1, 132($t2)
	sw $t1, 136($t2)
	sw $t1, 260($t2)
	sw $t1, 264($t2)
	sw $t1, 384($t2)
	sw $t1, 396($t2)
	lw $ra, 0($sp)
	jr $ra	
	
drawDeadFrog2:
	lw $t0, displayAddress # load display address into t0
	sw $ra, 0($sp)
	jal getFrogPosition2 # get the frog's position in displayaddress
	lw $t1, frogGreen # store frog color in t1
	sw $t1, 0($t2)
	sw $t1, 12($t2)
	sw $t1, 132($t2)
	sw $t1, 136($t2)
	sw $t1, 260($t2)
	sw $t1, 264($t2)
	sw $t1, 384($t2)
	sw $t1, 396($t2)
	lw $ra, 0($sp)
	jr $ra	

drawFrog:
	lw $t0, displayAddress # load displayAddress into t0
	sw $ra, 0($sp)
	jal getFrogPosition
	lw $t1, frogGreen # set the color to use as frog green in t1
	sw $t1, 0($t2)
	sw $t1, 4($t2)
	sw $t1, 8($t2)
	sw $t1, 12($t2)
	sw $t1, 132($t2)
	sw $t1, 136($t2)
	sw $t1, 256($t2)
	sw $t1, 260($t2)
	sw $t1, 264($t2)
	sw $t1, 268($t2)
	sw $t1, 384($t2)
	sw $t1, 396($t2)
	lw $ra, 0($sp)
	jr $ra	

drawFrog2:
	lw $t0, displayAddress # load displayAddress into t0
	sw $ra, 0($sp)
	jal getFrogPosition2
	lw $t1, frogGreen # set the color to use as frog green in t1
	sw $t1, 0($t2)
	sw $t1, 4($t2)
	sw $t1, 8($t2)
	sw $t1, 12($t2)
	sw $t1, 132($t2)
	sw $t1, 136($t2)
	sw $t1, 256($t2)
	sw $t1, 260($t2)
	sw $t1, 264($t2)
	sw $t1, 268($t2)
	sw $t1, 384($t2)
	sw $t1, 396($t2)
	lw $ra, 0($sp)
	jr $ra

drawWinFrog: # draws a winning frog, t2 is already set to be the frog's position
	lw $t0, displayAddress
	lw $t1, winFrogColor
	sw $t1, 0($t2)
	sw $t1, 4($t2)
	sw $t1, 8($t2)
	sw $t1, 12($t2)
	sw $t1, 132($t2)
	sw $t1, 136($t2)
	sw $t1, 256($t2)
	sw $t1, 260($t2)
	sw $t1, 264($t2)
	sw $t1, 268($t2)
	sw $t1, 384($t2)
	sw $t1, 388($t2)
	sw $t1, 392($t2)
	sw $t1, 396($t2)
	jr $ra
	
drawLives:
	lh $t3, livesRemaining # t3 stores the current number of lives
	lw $t0, displayAddress # t0 is the display address
	sw $ra, 4($sp)
	add $t4, $zero, $zero # set t4 to zero
	beq $t3, $t4, drawZeroHearts # if there are zero lives, draw no hearts
	addi $t4, $t4, 1
	beq $t3, $t4, drawOneHearts # if there is one lives, draw one heart
	addi $t4, $t4, 1
	beq $t3, $t4, drawTwoHearts # if there are two lives, draw two hearts
	j drawThreeHearts # else there are three hearts
drawZeroHearts:
	lw $t1, grass
	add $t2, $t0, $zero # the top left pixel
	jal drawSquare
	addi $t2, $t2, 16 # 4 to the right
	jal drawSquare
	addi $t2, $t2, 16 # 4 to the right
	jal drawSquare
	j endDrawLives
drawOneHearts:
	lw $t1, livesColor
	add $t2, $t0, $zero # the top left pixel
	jal drawHeart # draw one heart
	lw $t1, grass
	addi $t2, $t2, 16
	jal drawSquare
	addi $t2, $t2, 16
	jal drawSquare
	j endDrawLives
drawTwoHearts:
	lw $t1, livesColor
	add $t2, $t0, $zero # the top left pixel
	jal drawHeart # draw one heart
	addi $t2, $t2, 16
	jal drawHeart
	addi $t2, $t2, 16
	lw $t1, grass
	jal drawSquare
	j endDrawLives
drawThreeHearts:
	lw $t1, livesColor
	add $t2, $t0, $zero # the top left pixel
	jal drawHeart # draw one heart
	addi $t2, $t2, 16
	jal drawHeart
	addi $t2, $t2, 16
	jal drawHeart
	j endDrawLives
endDrawLives: # draw the rest of the 4 rows
	addi $t2, $t2, 16
	lw $t1, grass
	jal drawSquare
	addi $t2, $t2, 16
	jal drawSquare
	addi $t2, $t2, 16
	jal drawSquare
	addi $t2, $t2, 16
	jal drawSquare
	addi $t2, $t2, 16
	jal drawSquare
	lw $ra, 4($sp)
	jr $ra
	
drawSquare: # draws a square, t2 is the top left of where we want to draw, t1 is the color
	add $t3, $zero, $zero # t3 stores zero, loop iterator
	addi $t4, $zero, 4 # t4 stores 4
	add $t5, $t2, $zero
drawSquareLoop:
	beq $t3, $t4, endDrawSquare # each loop through draws a row of 4 pixels
	addi $t3, $t3, 1
	sw $t1, 0($t5)
	sw $t1, 4($t5)
	sw $t1, 8($t5)
	sw $t1, 12($t5)
	addi $t5, $t5, 128 # add 128 to t2 (go to next row)
	j drawSquareLoop
endDrawSquare:
	jr $ra

drawHeart: # draws a heart, t2 is the top left of where we want to draw, t1 is the color
	sw $t1, 0($t2)
	lw $t8, grass
	sw $t8, 4($t2)
	sw $t1, 8($t2)
	sw $t8, 12($t2)
	sw $t1, 128($t2)
	sw $t1, 132($t2)
	sw $t1, 136($t2)
	sw $t8, 140($t2)
	sw $t8, 256($t2)
	sw $t1, 260($t2)
	sw $t8, 264($t2)
	sw $t8, 268($t2)
	sw $t8, 384($t2)
	sw $t8, 388($t2)
	sw $t8, 392($t2)
	sw $t8, 396($t2)
	jr $ra

getFrogPosition:
	lh $t3, frogX
	sll $t3, $t3, 2
	lh $t4, frogY
	sll $t4, $t4, 7
	add $t3, $t3, $t4
	add $t2, $t0, $t3 # set the initial address of the frog
	jr $ra
	
getFrogPosition2:
	lh $t3, frog2X
	sll $t3, $t3, 2
	lh $t4, frog2Y
	sll $t4, $t4, 7
	add $t3, $t3, $t4
	add $t2, $t0, $t3 # set the initial address of the frog
	jr $ra

drawResetScreen:
	lw $t0, displayAddress
	lw $t1, resetColor
	addi $t2, $t0, 272 # t2 has address of the top left pixel of the reset screen
	add $t3, $zero, $zero # set t3 to 0
	addi $t4, $zero, 25 # set t4 to 27, so the loop will go 28 times
drawResetScreenBackground:	
	beq $t3, $t4, drawSkull # if t3 == t4, then the background is done drawing so draw the next part of background
	add $t5, $t2, $zero  # t5 will be the one we use to draw the pixel, set it to t2 (left most pixel of row)
	addi $t6, $t2, 96 # after drawn 24 pixels, stop drawing the background
drawResetScreenBackgroundLine:
	beq $t5, $t6, nextResetLine
	sw $t1, 0($t5)
	addi $t5, $t5, 4  # increment t5 by 4 (1 pixel)
	j drawResetScreenBackgroundLine
nextResetLine:
	addi $t3, $t3, 1 # increment t3 by 1
	addi $t2, $t2, 128
	j drawResetScreenBackground
drawSkull:
	lw $t1, white
	la $t2, resetArray
	add $t3, $zero, $zero
	add $t5, $zero, 468 # 117x4 = 468, as there are 468 elements in resetArray
skullLoop:
	beq $t3, $t5, skullEyes # loop through the elements in resetArray
	lh $t4, 0($t2) # t4 stores the integer number from the place in the resetArray
	add $t4, $t4, $t0 # t4 is now the display address of the pixel
	sw $t1, 0($t4) # display the pixel
	addi $t2, $t2, 2
	addi $t3, $t3, 4
	j skullLoop 
skullEyes:
	lw $t1, black
	addi $t2, $t0, 952
	sw $t1, 0($t2)
	addi $t2, $t0, 964
	sw $t1, 0($t2)
	jr $ra
	
endGame:
	jal drawLives
	jal drawResetScreen
	li $v0, 31 # play a sound
	li $a0, 64
	li $a1, 1000
	li $a2, 15
	li $a3, 100
	syscall
	li $v0, 31
	li $a0, 1000	
	syscall
	li $a0, 63
	li $a1, 1000
	li $a2, 15
	li $a3, 100
	syscall
	li $v0, 31
	li $a0, 1000
	syscall
	li $a0, 62
	li $a1, 2000
	li $a2, 15
	li $a3, 100
	syscall
keyboardInputResetListen:
	lw $t8, 0xffff0000 # listen for keyboard input
	beq $t8, 1, keyboardInputReset # if a key was pressed, go to function keyboard_input
sleepReset:	
	li $v0, 32
	li $a0, 17
	syscall
	j keyboardInputResetListen

keyboardInputReset:
	lw $t2, 0xffff0004 # get the key that was pressed
	beq $t2, 0x72, respond_to_R
	j keyboardInputResetListen

respond_to_R:
	addi $t0, $zero, 12 # frog's initial x position
	addi $t1, $zero, 28 # frog's initial y position
	sh $t0, frogX # reset frog's initial x position to starting position
	sh $t1, frogY # reset frog's intial y position to starting position
	j main
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall	
