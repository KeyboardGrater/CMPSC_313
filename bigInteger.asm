.data

# Input Buffer
inputBuffer: .space 41

# BigInteger structure
.align 2
BigInt1: .space 41                          # 40 9's = fits into 2^133 in binary, convert to bytes. 2^17, (rounded up from 16.625), enough room in remainder (.625 < 1 - 1/8), so signed included already
BigInt2: .space 41
BigIntSum: .space 41 

# CONSTANTS
BIGINT_SIZE = 41

# Strings
inputPromptOne: .asciiz "Please give a number that has between and including 1-40 digits: "
inputPromptTwo: .asciiz "Please give a second number that has between and including 1-40 digits: "
newLine: .asciiz "\n"

.text
.globl main
main:

    # Get user input
    li $v0, 4
    la $a0, inputPromptOne
    syscall

    li $v0, 4
    la $a0, newLine
    syscall

    # Input buffer
    li $v0, 8
    la $a0, inputBuffer
    la $a1, BIGINT_SIZE
    syscall


    subu $sp, $sp, 8                        # for getting the size of both numbers                

    # Load input buffer into BigInt1
    la $a1, inputBuffer
    la $a2, BigInt1
    jal copyInput

    # Get BigInt2
    li $v0, 4
    la $a0, newLine
    syscall

    li $v0, 4
    la $a0, inputPromptTwo
    syscall

    li $v0, 4
    la $a0, newLine
    syscall

    li $v0, 8
    la $a0, inputBuffer
    la $a1, BIGINT_SIZE
    syscall

    li $v0, 4
    la $a0, newLine
    syscall

    # Load input buff into BigInt2
    la $a1, inputBuffer
    la $a2, BigInt2
    jal copyInput

    # ----- FOR TESTING ----- #
    j printTesting
    backToMainFromTesting:

    # ----- FOR TESTING ----- #


    # Fill array
    j fillSpace
    fillSpaceReturn1:

    # Adding
    la $a1, BigInt1
    la $a2, BigInt2
    jal bigIntAddition


    j endProgram

copyInput:
    # t0 = buffer adress, t1 = bigInt (1 or 2) address, t2 = i, t3 = current_address, t4 = loaded character
    # t5 = null character (0x00)
    move $t0, $a1                           # move buffer address to a temporary register
    move $t1, $a2                           # move BigInt (1 or 2)'s address to temporary register
    li $t2, 0                               # i = 0
    
# ---------------------- ACCOUNT FOR FIRST DIGIT, IE if negative --------------------------------
    copyLoop:
        # Get charcter at i of buffer
        add $t3, $t0, $t2                   # source_char = buffer_addr + i
        lb $t4, 0($t3)                      # save source_char to temp reg                 

        # Get the i of bigInt (1 or 2)
        add $t3, $t1, $t2
        
        # Check if null or new line
        li $t5, 0x00                        # null
        beq $t5, $t4, copyLoopExit          
        li $t5, 0x0A                        # new line
        beq $t5, $t4, copyLoopExit

        # Else
        addi $t4, $t4, -48

        sb $t4, 0($t3)

        addi $t2, $t2, 1
        j copyLoop

    copyLoopExit:

    # Save length of number (# of digits)
    addi $t2, $t2, -1                       # the last digit
    subu $sp, $sp, 4
    sw $t2, 0($sp)
    jr $ra



# ----- TEST PRINTING ----- #
printTesting:
    # a1 = BigInt1_address, a2 = BigInt2_address, t0 = (0 = BigInt1, 1 = BigInt2, 2 = Done), t1 = i, t2 = holder
    # t3 = stopper, t4
    li $v0, 11
    la $a0, '\n'
    syscall

    la $a1, BigInt1
    
    li $t0, 0
    li $t1, 0
    li $t4, 2

    printTestingLoop:
        add $t2, $a1, $t1
        lb $t2, 0($t2)

        li $t3, 0x00
        beq $t2, $t3, printTestingLoopExit
        li $t3, 0x0A
        beq $t2, $t3, printTestingLoopExit

        li $v0, 1
        move $a0, $t2
        syscall
        
        addi $t1, $t1, 1
        j printTestingLoop
    printTestingLoopExit:

    addi $t0, $t0, 1
    beq $t0, $t4, printTestingJump
    la $a1, BigInt2
    li $t1, 0

    li $v0, 11
    la $a0, '\n'
    syscall

    j printTestingLoop
    

    printTestingJump:
    j backToMainFromTesting

# ----- TEST PRINTING ----- #

# Fill Space with zeros
fillSpace:
    li $t0, 0
    li $t1, BIGINT_SIZE
    #addi $t1, $t1, -1
    la $a0, BigIntSum

    fillLoop:
        beq $t0, $t1, fillLoopExit
        li $t2, 0
        sb $t2, 0($a0)
        addi $t0, $t0, 1
        
        j fillLoop

    fillLoopExit:
    j fillSpaceReturn1



# ADDING
bigIntAddition:
    # t0 = i, t1 = BigInt1_addr, t2 = BigInt2_addr, t3 = curr_addr_one, t4 = curr_addr_two, t5 = value_at_one, t6 = value_at_two
    # t7 = one_size/largest, t8 = two_size/ holder, t9 = carry
    move $t1, $a1
    move $t2, $a2


    # 0 0 0 0 4 5 6 7 8 9 1
    # 0 0 0 0 0 0 0 4 2 1 3

    lw $t8, 0($sp)
    addiu $sp, $sp, 4
    lw $t7, 0($sp)
    addiu $sp, $sp, 4
    
    bgt $t8, $t7, twoLargerThanOne          # changes t7 to be t8, else t7 stays the same
    twoLargerThanOneReturn:
    
    move $t0, $t8                           # make i = largest_num_of_digits

    additionLoop:
        blt $t0, $zero, additionLoopExit          # loop exit condition (if i == 0)
        #beqz $t0, additionLoopExit
        # Get the value of BigInt1[i]
        add $t3, $t1, $t0
        lb $t5, 0($t3)

        # Get the value of BigInt[i]
        add $t4, $t2, $t0
        lb $t6, 0($t4)

        # ----- TODO: ADD WHEN ONE IS LARGER THAN THE OTHER ----- #
        # ----- HOPEFULLY IT FILLS IN ZERO FOR THE REST OF THE DATA ---- #
        # ----- IF NOT I MIGHT HAVE TO ADD THOSE ZEROS ----- #

        # get value at i from new big int
        la $a1, BigIntSum
        add $t3, $a1, $t0                   # curr_addr_sum = base_addr_sum + i
        lb $t8 0($t3)

        add $t8, $t8, $t5                   # t8 += t5
        add $t8, $t6, $t8                   # t8 += t6, so: t8 = t8 + t5 + t6

        li $s1, 10
        bge $t8, $s1, carryOperation
        carryOperationReturn:

        # For newly created big int
        sb $t8, 0($t3)                      # save the sumation of BigInt1 at i, and BigInt2 at i to BigIntSum at i

        # ADD the carry
        beqz $t0, skipAddingCarray          # if the highest two are at that 40 size limit.


        addi $t4, $t0, -1                   # t4 = i - 1
        add $t3, $a1, $t4                   # left_addr = base_addr_sum + (i - 1)
        lb $t4 0($t3)                        # load the left_addr's value into a temp reg
        add $t4, $t4, $t9                   # if carried then t9 = 1, thus t4++, if not carried then t9 = 0, thus t4 = t4
        sb $t4 0($t3)                        # save the modifications to left_addr_value

        skipAddingCarray:

        li $t9, 0                           # reset the carry
        

        # ----- FOR TESTING ----- #
        li $v0, 4
        la $a0, newLine
        syscall

        li $v0, 1
        move $a0, $t8
        syscall
        # ----- FOR TESTING ----- #

        addi $t0, $t0, -1

        j additionLoop
    additionLoopExit:

    # for the last one

    

jr $ra

twoLargerThanOne:
    move $t8, $t9
    j twoLargerThanOneReturn

carryOperation:
    addi $t8, $t8, -10
    li $t9, 1
    j carryOperationReturn


endProgram:
# End program
li $v0, 10
syscall
