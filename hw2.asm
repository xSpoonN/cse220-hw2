########### Kevin Tao ############
########### ktao ################
########### 170154879 ################

###################################
##### DO NOT ADD A DATA SECTION ###
###################################

.text
.globl substr
substr:                                   # substr(str, lower, upper)
	slt $t1 $a1 $0                        # Checks if argument 1 is negative
	bnez $t1 substrerror                  # If negative, error
	slt $t1 $a2 $0                        # Checks if argument 2 is negative
	bnez $t1 substrerror                  # If negative, error
	move $t0 $a0                          # Moves str address into t0
	lb $t2 0($t0)                         # Loads first char 
	li $t3 0                              # String length counter
	substrloop:
		beqz $t2 substrdone               # On null terminater, exit loop
		addi $t3 $t3 1                    # Increment length counter
		addi $t0 $t0 1                    # Increment memory pointer
		lb $t2 0($t0)                     # Load next char into t2
		j substrloop 
	substrdone:
		addi $t3 $t3 1                    # less than
		slt $t1 $a1 $t3                   # Checks if lower bound is less than the string size
		beqz $t1 substrerror              # If it isn't less, error
		slt $t1 $a2 $t3                   # Checks if upper bound is less than the string size
		beqz $t1 substrerror              # If it isn't less, error
		addi $t3 $t3 -1                   # less than
		slt $t1 $a1 $a2                   # Checks if the lower bound is less than the upper bound
		beqz $t1 substrerror              # If it isn't less, error
		move $t0 $a0                      # Sets memory pointer to the start of substring.
		add $t0 $t0 $a1
		move $t4 $a0                      # Sets memory pointer to start of string.
		sub $t5 $a2 $a1                   # Substring length counter
	substrloop2:
		beqz $t5 substrdone2              # When all chars in substring are processed, exit loop
		lb $t2 0($t0)                     # Loads substring char
		sb $t2 0($t4)                     # Stores char into str.
		addi $t0 $t0 1                    # Increments substring pointer
		addi $t4 $t4 1                    # Increments string pointer
		addi $t5 $t5 -1                   # Decrements substring length counter
		j substrloop2
	substrdone2:
		sub $t5 $a2 $a1                   # Substring length counter
		sub $t5 $t3 $t5                   # Get remaining zeros counter
	substrloop3:
		beqz $t5 substrdone3              # When extra chars are zeroed, exit loop
		sb $0 0($t4)                      # Saves null terminators into the extra string indices.
		addi $t4 $t4 1                    # Increments string pointer
		addi $t5 $t5 -1                   # Decrements remaining zeros counter.
		j substrloop3
	substrdone3:
		li $v0 0
		jr $ra
substrerror:
	li $v0 -1
	jr $ra
	
.globl encrypt_block
encrypt_block:
	move $t0 $a0                          # Move "block" to t0
	move $t1 $a1                          # Move "key" to t1
	li $t3 0                              # Cleans register
	li $t4 0                              # Cleans register

	lb $t2 0($t0)                         # Loads char
	sll $t2 $t2 24                        # Shift to make them the most significant bits
	or $t3 $t3 $t2                        # Copies over bits to t3
	lb $t2 1($t0)                         # Loads char
	sll $t2 $t2 16                        # Shift 
	or $t3 $t3 $t2                        # Copies over bits to t3
	lb $t2 2($t0)                         # Loads char
	sll $t2 $t2 8                         # Shift 
	or $t3 $t3 $t2                        # Copies over bits to t3
	lb $t2 3($t0)                         # Loads char
	or $t3 $t3 $t2                        # Copies over bits to t3
	
	lb $t2 0($t1)                         # Loads char
	sll $t2 $t2 24                        # Shift to make them the most significant bits
	or $t4 $t4 $t2                        # Copies over bits to t3
	lb $t2 1($t1)                         # Loads char
	sll $t2 $t2 16                        # Shift 
	or $t4 $t4 $t2                        # Copies over bits to t3
	lb $t2 2($t1)                         # Loads char
	sll $t2 $t2 8                         # Shift 
	or $t4 $t4 $t2                        # Copies over bits to t3
	lb $t2 3($t1)                         # Loads char
	or $t4 $t4 $t2                        # Copies over bits to t3

	xor $v0 $t3 $t4                       # Performs xor on the two strings.
	jr $ra

.globl add_block
add_block:
	li $t0 4                              # Constant 4
	mul $t1 $a1 $t0                       # Multiplies bindex by 4
	add $t2 $a0 $t1                       # Moves to correct block in memory $t2 = Memory pointer
	move $t0 $a2                          # Moves "code" into t0 
	andi $t3 $t0 0x000000FF               # Bit mask
	sb $t3 0($t2)                         # Stores in memory
	srl $t0 $t0 8                         # Shift right
	addi $t2 $t2 1                        # Increment memory
	andi $t3 $t0 0x000000FF               # Bit mask
	sb $t3 0($t2)                         # Stores in memory
	srl $t0 $t0 8                         # Shift right
	addi $t2 $t2 1                        # Increment memory
	andi $t3 $t0 0x000000FF               # Bit mask
	sb $t3 0($t2)                         # Stores in memory
	srl $t0 $t0 8                         # Shift right
	addi $t2 $t2 1                        # Increment memory
	andi $t3 $t0 0x000000FF               # Bit mask
	sb $t3 0($t2)                         # Stores in memory
	
	jr $ra
	
.globl gen_key
gen_key:
	li $t0 4                              # Constant 4
	mul $t1 $a1 $t0                       # Multiplies bindex by 4
	add $t2 $a0 $t1                       # Moves to correct block in memory $t2 = Memory pointer
	li $t3 4                              # Counter for iterations
	genkloop:
		beqz $t3 genkdone                 # When done, exit loop.
		li $a1 128                        # Gen random char
		li $v0 42
		syscall
		sb $a0 0($t2)                     # Store random number into memory
		addi $t2 $t2 1                    # Increments memory counter
		addi $t3 $t3 -1                   # Decrement iteration counter.
		j genkloop
	genkdone:
		jr $ra

.globl encrypt
encrypt:          #a0 = base string address, #a1 = key string address, #a2 = final encrypted output, #a3 = string length
    #gen_key(key, bindex) give #a1, and increment bindex until nchars/4.
    #load blocks of a0 into a register. Load keys into another register. Call encrypt_block on the two registers.
    #Take the output of encrypt block, and put it into add_block(dest, bindex, code). Increment bindex, and set dest to the cipher text output location.
	#Divide nchars by 4, save remainder to use as counter and also add it to nchars to get total string length.
	addi $sp $sp -16                      # Allocate stack space
	sw $ra 12($sp)                        # Preserve return addr
	sw $s0 8($sp)                         # Preserve s0
	sw $s1 4($sp)                         # Preserve s1
	sw $s2 0($sp)                         # Preserve s2
	li $t0 4                              # Constant 4
	div $a3 $t0                           # Divide nchars by 4
	mfhi $t2                              # Get remainder
	sub $t0 $t0 $t2                       # Subtract from 4
	add $t2 $t0 $a3                       # Gets total length after padding
	move $t1 $a0                          # Copies over base string address
	add $t1 $t1 $a3                       # Goes to end of string
	move $t9 $a0                          # Preserves a0
	move $t8 $a1                          # Preserves a1
	encrpad:
		beqz $t0 encrpaddone              # When done, exit loop
		li $a1 128                        # Gen random char
		li $v0 42
		syscall
		sb $a0 0($t1)                     # Stores random char into memory.
		addi $t0 $t0 -1                   # Decrement remainder counter
		j encrpad
	encrpaddone:
		move $a0 $t9                      # Restores a0
		move $a1 $t8                      # Restores a1
		li $t0 4                          # Constant 4
		div $t2 $t0                       # Divide to get number of blocks
		mflo $t5                          # t5 = number of blocks
		move $t9 $a0                      # Preserves base string address
		move $a0 $a1                      # Moves a1 to a0 for gen_key function
		move $t8 $a1                      # Preserves a1
		li $t6 0                          # Counter for gen key blocks
	encrgenloop:
		beq $t5 $t6 encrgendone
		move $a1 $t6                      # bindex
		move $a0 $t8
		jal gen_key                       # Calls gen_key()
		addi $t6 $t6 1                    # Increment counter for gen key blocks
		j encrgenloop
	encrgendone:
		move $a1 $t8                      # Moves a0 back to a1
		move $a0 $t9                      # Moves OG a0 back to a0
		move $s0 $a0                      # Makes a copy of string memory pointer
		move $s1 $a1                      # Makes a copy of key memory pointer
		move $t7 $a2                      # Makes a copy of output memory pointer
		move $s2 $0                       # Block counter
	encrblockloop:
		beq $t5 $s2 encrblockdone
		move $a0 $s0                      # Loads block from mmeory
		move $a1 $s1                      # Loads key from memory
		jal encrypt_block                 # encrypt_block()
		move $a0 $t7                      # 1st arg dest
		move $a1 $s2                      # 2nd arg bindex
		move $a2 $v0
		jal add_block
		addi $s0 $s0 4                    # Increment block of string pointer
		addi $s1 $s1 4                    # Increment block of key pointer
		addi $s2 $s2 1                    # Increment counter for gen key blocks
		j encrblockloop
	encrblockdone:
		lw $ra 12($sp)                    # Restore return addr
		lw $s0 8($sp)                     # Restore s0
		lw $s1 4($sp)                     # Restore s1
		lw $s2 0($sp)                     # Restore s2
		addi $sp $sp 16                   # Deallocate Stack
		jr $ra

.globl decrypt_block
decrypt_block:
	move $t0 $a0                          # Move "block" to t0
	move $t1 $a1                          # Move "key" to t1
	li $t3 0                              # Cleans register
	li $t4 0                              # Cleans register

	lb $t2 0($t0)                         # Loads char
	sll $t2 $t2 24                        # Shift to make them the most significant bits
	or $t3 $t3 $t2                        # Copies over bits to t3
	lb $t2 1($t0)                         # Loads char
	sll $t2 $t2 16                        # Shift 
	or $t3 $t3 $t2                        # Copies over bits to t3
	lb $t2 2($t0)                         # Loads char
	sll $t2 $t2 8                         # Shift 
	or $t3 $t3 $t2                        # Copies over bits to t3
	lb $t2 3($t0)                         # Loads char
	or $t3 $t3 $t2                        # Copies over bits to t3
	
	lb $t2 3($t1)                         # Loads char
	sll $t2 $t2 24                        # Shift to make them the most significant bits
	or $t4 $t4 $t2                        # Copies over bits to t3
	lb $t2 2($t1)                         # Loads char
	sll $t2 $t2 16                        # Shift 
	or $t4 $t4 $t2                        # Copies over bits to t3
	lb $t2 1($t1)                         # Loads char
	sll $t2 $t2 8                         # Shift 
	or $t4 $t4 $t2                        # Copies over bits to t3
	lb $t2 0($t1)                         # Loads char
	or $t4 $t4 $t2                        # Copies over bits to t3

	xor $v0 $t3 $t4                       # Performs xor on the two strings.
	jr $ra

.globl decrypt
decrypt:          #a0 = base string address, #a1 = key string address, #a2 = string length, #a3 = final decrypted output
	addi $sp $sp -16                      # Allocate stack space
	sw $ra 12($sp)                        # Preserve return addr
	sw $s0 8($sp)                         # Preserve s0
	sw $s1 4($sp)                         # Preserve s1
	sw $s2 0($sp)                         # Preserve s2
	move $t0 $a2                          #
	move $a2 $a3                          # Interchanges the arguments
	move $a3 $t0                          #
	li $t0 4                          	  # Constant 4
	div $a3 $t0                           # Divide nchars by 4
	mflo $t5                              # Get block count
	move $s0 $a0                      	  # Makes a copy of string memory pointer
	move $s1 $a1                          # Makes a copy of key memory pointer
	move $t7 $a2                       	  # Makes a copy of output memory pointer
	move $s2 $0                           # Block counter
	decrblockloop:
		beq $t5 $s2 decrblockdone
		move $a0 $s0                      # Loads block from mmeory
		move $a1 $s1                      # Loads key from memory
		jal decrypt_block                 # encrypt_block()
		move $a0 $t7                      # 1st arg dest
		move $a1 $s2                      # 2nd arg bindex
		move $a2 $v0
		jal add_block
		addi $s0 $s0 4                    # Increment block of string pointer
		addi $s1 $s1 4                    # Increment block of key pointer
		addi $s2 $s2 1                    # Increment counter for gen key blocks
		j decrblockloop
	decrblockdone:
		lw $ra 12($sp)                    # Restore return addr
		lw $s0 8($sp)                     # Restore s0
		lw $s1 4($sp)                     # Restore s1
		lw $s2 0($sp)                     # Restore s2
		addi $sp $sp 16                   # Deallocate Stack
		jr $ra