###############################################
# MCOM-Labor: Vorlage fuer Assemblerprogramm
# Edition History:
# 28-04-2009: Getting Started - ms
# 12-03-2014: Stack organization changed - ms
###############################################

###############################################
# Definition von symbolen Konstanten
###############################################
	.equ STACK_SIZE, 0x400	# stack size
	.equ PUSH_r3_1, subi sp, sp, 4
	.equ PUSH_r3_2, stw r3, (sp)
	.equ POP_r3_1, ldw r3, (sp)
	.equ POP_r3_2, addi sp, sp, 4
###############################################
# DATA SECTION
# assumption: 12 kByte data section (0 - 0x2fff)
# stack is located in data section and starts
# directly behind used data items at address
# STACK_END.
# Stack is growing downwards. Stack size
# is given by STACK_SIZE. A full descending
# stack is used, accordingly first stack item
# is stored at address STACK_END+(STACKSIZE).
###############################################	
	.data
TST_PAK1:
	.word 0x11112222	# test data

STACK_END:
	.skip STACK_SIZE	# stack area filled with 0

###############################################
# TEXT SECTION
# Executable code follows
###############################################
	.global _start
	.text
_start:
	#######################################
	# stack setup:
	# HAVE Care: By default JNiosEmu sets stack pointer sp = 0x40000.
	# That stack is not used here, because SoPC does not support
	# such an address range. I. e. you should ignore the STACK
	# section in JNiosEmu's memory window.
	
	movia	sp, STACK_END		# load data section's start address
	addi	sp, sp, STACK_SIZE	# stack start position should
					# begin at end of section
START:
	mov r2, r0			# COUNTER init
LOOP:
	call read_INCREM_BUTTON		# subroutine read_COUNT_BUTTON is called 
	call read_DECREM_BUTTON		# subroutine read_DECREM_BUTTON is called 
	call read_CLEAR_BUTTON		# subroutine read_CLEAR_BUTTON is called
	call write_LED		# subroutine write_LED is called
	br LOOP		# check for the key pressed again

read_INCREM_BUTTON:
	subi sp, sp, 4		# PUSH_r3_1
	stw r3, (sp)		# PUSH_r3_2
	movia r3, 0x840		# r3 <- 0x840
	ldw r3, (r3)		# r3 <- (0x840)
	andi r3, r3, 0x1	# r3 <- masked value of (0x840)
	beq r3, r0, return_INCREM_BUTTON	# if r3==0 => goto return_INCREM_BUTTON 
	addi r2, r2, 1		# COUNTER++ 
return_INCREM_BUTTON:
	ldw r3, (sp)		# POP_r3_1
	addi sp, sp, 4		# POP_r3_2
	ret			# return

read_DECREM_BUTTON:
	subi sp, sp, 4		# PUSH_r3_1
	stw r3, (sp)		# PUSH_r3_2
	movia r3, 0x840		# r3 <- 0x840
	ldw r3, (r3)		# r3 <- (0x840)
	andi r3, r3, 0x2	# r3 <- masked value of (0x840)
	beq r3, r0, return_DECREM_BUTTON	# if r3==0 => goto return_DECREM_BUTTON 
	subi r2, r2, 1		# COUNTER-- 
return_DECREM_BUTTON:
	ldw r3, (sp)		# POP_r3_1
	addi sp, sp, 4		# POP_r3_2
	ret			# return

read_CLEAR_BUTTON:
	subi sp, sp, 4		# PUSH_r3_1
	stw r3, (sp)		# PUSH_r3_2
	movia r3, 0x840		# r3 <- 0x840
	ldw r3, (r3)		# r3<- (0x840)
	andi r3, r3, 0x8	# r3 <- masked value of (0x840)
	beq r3, r0, return_CLEAR_BUTTON	# if r3==0 => goto return_CLEAR_BUTTON 
	mov r2, r0		# COUNTER=0
return_CLEAR_BUTTON:
	ldw r3, (sp)		# POP_r3_1
	addi sp, sp, 4		# POP_r3_2
	ret			# return

write_LED:
	subi sp, sp, 4		# PUSH_r3_1
	stw r3, (sp)		# PUSH_r3_2
	movia r3, 0x810		# r3 <- 0x810=output_register_address
	stw r2, (r3)		# r2 -> (r3) parameter -> output_register
	ldw r3, (sp)		# POP_r3_1
	addi sp, sp, 4		# POP_r3_2
ret

endloop:
	br endloop		# that's it
###############################################
	.end
	
