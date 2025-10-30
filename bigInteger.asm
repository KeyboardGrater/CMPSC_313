.data
# CONSTANTS
BIG_INT_MAX_SIZE = 41                       # 40 digits + size in the first spot = 41
RETURN_VALUES_MAX_SIZE = 41             

# Data and variables
BigInt1: .word 0                            # data type
         .space BIG_INT_MAX_SIZE            # length of it

#BigInt1: .word 4 8 3 9 1

BigInt2: .word 0
         .space BIG_INT_MAX_SIZE                  

#BigInt2: .word 4 8 3 9 2

Summation: .word 0
           .space RETURN_VALUES_MAX_SIZE    # for overflow reasons

Difference: .word 0
        .space RETURN_VALUES_MAX_SIZE

# Strings
inputPromptOne: .asciiz "Please enter the first number 1 - 40 digits:"
inputPromptTwo: .asciiz "Please enter the second number 1 - 40 digits: "
summationMessage: .asciiz "Sumation: "
resultMessage: .asciiz "Difference: "
newLine: .asciiz "\n"
falseMessage: .asciiz "False"
trueMessage: .asciiz "True"
greaterThanMessage: .asciiz "Greater than is "
greaterThanEqualMessage: .asciiz "Greater than or equal to is "
lessThanMessage: .asciiz "Less than is "
lessThanEqualMessage: .asciiz "Less than or equal to "
equalMessage: .asciiz "Equal is "
notEqualMessage: .asciiz "Not equal is "

buffer: .space 41                           # buffer for input

.text
.globl main
main:
    # Get user input
    
    # Get the first number
    li $v0, 4                           
    la $a0, inputPromptOne
    syscall

    # Get first number (in the form of a string)
    li $v0, 8
    la $a0, buffer
    la $a1, BIG_INT_MAX_SIZE
    syscall

    # Call conversion function
    la $a1, buffer
    la $a2, BigInt1
    jal string_conversion_to_int

    # Get the second number
    li $v0, 4
    la $a0, inputPromptTwo
    syscall

    # Get second number (in the form of a string)
    li $v0, 8
    la $a0, buffer
    la $a1, BIG_INT_MAX_SIZE
    syscall

    # Call conversion function for a second time
    la $a1, buffer
    la $a2, BigInt2
    jal string_conversion_to_int

    # Addition of the two BigInt structs
    la $a1, BigInt1
    la $a2, BigInt2
    la $a3, Summation
    jal bigint_add

    # Print Additon
    li $v0, 4
    la $a0, summationMessage
    syscall

    la $a1, Summation
    jal print_BigInt    

    # Subtraction
    #la $a1, BigInt1
    #la $a2, BigInt2
    #la $a3, Difference
    #jal bigInt_subtraction

    # greater than  
    la $a1, BigInt1
    la $a2, BigInt2
    jal greater_than
    
    move $a1, $v0

    li $v0, 4
    la $a0, newLine
    syscall

    li $v0, 4
    la $a0, greaterThanMessage
    syscall

    jal comparison_output

    # greater than or equal to
    la $a1, BigInt1
    la $a2, BigInt2
    jal greater_than_equal

    move $a1, $v0

    li $v0, 4
    la $a0, newLine
    syscall

    li $v0, 4
    la $a0, greaterThanEqualMessage
    syscall

    jal comparison_output

    # less than
    la $a1, BigInt1
    la $a2, BigInt2
    jal less_than

    move $a1, $v0

    li $v0, 4
    la $a0, newLine
    syscall

    la $v0, 4
    la $a0, lessThanMessage
    syscall

    jal comparison_output

    # less than or equal to
    la $a1, BigInt1
    la $a2, BigInt2
    jal less_than_equal

    move $a1, $v0

    li $v0, 4
    la $a0, newLine
    syscall

    la $v0, 4
    la $a0, lessThanEqualMessage
    syscall

    jal comparison_output

    # equal
    la $a1, BigInt1
    la $a2, BigInt2
    jal equal_check
    
    move $a1, $v0

    li $v0, 4
    la $a0, newLine
    syscall

    la $v0, 4
    la $a0, equalMessage
    syscall

    jal comparison_output

    # not equal
    la $a1, BigInt1
    la $a2, BigInt2
    jal not_equal_check

    move $a1, $v0

    li $v0, 4
    la $a0, newLine
    syscall

    la $v0, 4
    la $a0, notEqualMessage
    syscall
    
    jal comparison_output

    j endProgram

string_conversion_to_int:
    # a1 = buffer address, a2 = BigInt address
    # Converts string input to digit array stored in reverse order

    
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $s0, $a1        # Buffer address
    move $s1, $a2        # BigInt address

    # First pass: find the end and count digits
    move $t0, $s0        # Start at beginning of buffer
    li $t2, 0            # Digit counter

    count_digits:
        lb $t3, 0($t0)
        # Check for end of input
        beq $t3, 0x0A, done_counting    # '\n'
        beq $t3, 0x00, done_counting    # '\0'
        beq $t3, 0x0D, done_counting    # '\r'
        beq $t3, 0x20, next_char        # Skip spaces
        
        # Check if it's a valid digit
        blt $t3, 48, next_char          # Less than '0'
        bgt $t3, 57, next_char          # Greater than '9'
        
        # It's a digit, count it
        addi $t2, $t2, 1
        
    next_char:
        addi $t0, $t0, 1
        j count_digits

    done_counting:
        # Store the size
        sw $t2, 0($s1)
        
        # Now convert: start from END of string, store in beginning of array
        addi $t0, $t0, -1               # Point to last char before newline
        addi $t1, $s1, 4                # Point to first storage position
        
    convert_loop:
        blt $t0, $s0, conversion_done   # If we've gone before start of buffer
        lb $t3, 0($t0)
        
        # Skip non-digits
        blt $t3, 48, skip_this_char
        bgt $t3, 57, skip_this_char
        
        # Convert ASCII to digit value (0-9)
        addi $t3, $t3, -48
        sb $t3, 0($t1)                  # Store in BigInt array
        addi $t1, $t1, 1                # Move to next position
        
    skip_this_char:
        addi $t0, $t0, -1               # Move backwards in buffer
        j convert_loop

    conversion_done:
        lw $s1, 8($sp)
        lw $s0, 4($sp)
        lw $ra, 0($sp)
        addi $sp, $sp, 12
        jr $ra


# Addition
bigint_add:
    # a1 = BigInt1_addr, a2 = BigInt2_addr, a3 = Summation_addr
    # t0, t1, t2, t3, t4, t5 = carry_flag , t6 =  , t7

    # Save the return address
    addi $sp, $sp, -4
    sw $ra 0($sp)   

    # Load the length of the structs
    lw $t3, 0($a1)                          # BigInt1_size
    lw $t4, 0($a2)                          # BigInt2_size

    # Create pointers
    addi $t1, $a1, 4                        # num1
    addi $t2, $a2, 4                        # num2
    addi $t0, $a3, 4                        # summation

    li $t5, 0                               # car
    li $t6, 0                               # i

    # Find the max length
    move $t7, $t3
    bge $t3, $t4, addition_loop             # Compares the number of digits in each one
    move $t7, $t4

    addition_loop:
        li $t8, 0
        li $t9, 0

        # Get digit from BigInt1 
        bge $t6, $t3, skip_num_1         # when BigInt_2_size < BigInt_2_size
        add $s0, $t1, $t6
        lb $t8, 0($s0)

        skip_num_1:
        # Get a digit from BigInt2
        bge $t6, $t4, skip_num_2
        add $s0, $t2, $t6
        lb $t9, 0($s0)

        skip_num_2:
        
        # Add the digits and then carray
        add $s0, $t8, $t9                   # s0 = t8 + t9
        add $s0, $s0, $t5                   # s0 = s0 (t8 +t9) + t5
        
        # Calculate the new carry and digit
        li $t5, 0
        blt $s0, 10 , dont_carry            # if s0 < 10, then no carry needed
        
        # else (Carry)
        addi $s0, $s0, -10                  # otherwise, subtract 10
        li $t5, 1                           # load that carried one

        dont_carry:
        
        # Store the result digit
        add $s1, $t0, $t6
        sb $s0, 0($s1)

        addi $t6, $t6, 1
        blt $t6, $t7, addition_loop

        # Add the carry to the left spot
        beq $t5, 0, addition_loop_exit
        add $s1, $t0, $t6
        sb $t5, 0($s1)
        addi $t6, $t6, 1
    
    addition_loop_exit:
        # Store the length in struct
        sw $t6, 0($a3)

        lw $ra, 0($sp)
        addi $sp, $sp, 4

    jr $ra

print_BigInt:
    # a1 = BigInt_addr

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Load the length of the struct into a temporary register
    lw $t1, 0($a1)

    # pointers
    addi $t0, $a1, 4
    addi $t1, $t1, -1                       # start from the last index

    bigInt_print_loop:
        bltz $t1, bigInt_print_loop_exit
        add $t2, $t0, $t1
        lb $t3, 0($t2)
        # addi $t3, $t3, 48                 # convert to ascii, I dont think I need it. The simulator (Qt spim) might be causing this to not be nessicary.

        # Print the digit
        li $v0, 1
        move $a0, $t3
        syscall

        addi $t1, $t1, -1
        j bigInt_print_loop
    bigInt_print_loop_exit:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
#
## Subtraction
#bigInt_subtraction:
#    # a1 = BigInt1_addr, a2 = BigInt2_addr, a3 = Difference_addr
#    # t0 = i, t1, t2, t3 = BigInt1_size, t4 = BigInt2_size,
#    # t5 = one_value, t6 = two_value, t7 = largest_struct, t8 = furthest_non_zero
#    # s0 = diff_value
#
#    # Save the return address, because of greater than comparison
#    addi $sp, $sp, -4
#    sw $ra, 0($sp)
#
#    # Load the length of the sturcts
#    lw $t3, 0($a1)
#    lw $t4, 0($a2)
#
#    # Create the pointers
#    addi $t1, $a1, 4
#    addi $t2, $a2, 4
#    addi $t0, $a3, 4
#
#    li $t5, 0                               # iterator for 1
#    li $t6, 0                               # iterator for 2
#
#    # Figure out which is the largest
#    move $t7, $t3                           # assuming first is larger
#    beq $t3, $t4, structs_num_digits_equal  # for when the number of digits in struct 1 and 2 are the same

        # ------------------- Make a branch if it returns 1 (struct 1 is larger), returns 2 (struct 2 is larger), returns 0 (struct 1 and two are equal in both num digits and value).
#
#
#    # --- ASSUME FOR NOW THAT THEY ARE OF EQUAL NUM oF DIGITS --- #
#    # FIGURE OUT WHICH IS LARGER
#
#    # if (a < b) {swap(a,b); isNegative = true;} 
#
#    subtraction_loop:
#        bltz $t0, subtraction_loop_exit
#
#        # diff[i] = diff[i] + a[i] - b[i]
#
#        # calculate 
#        mult $t5, $t0, 4                    # for 1's address
#        add $t5, $a1, $t5
#
#        mult $t6, $t0, 4                    # for 2's address
#        add $t6, $a2, $t6
#
#        mult $s0, $t0, 4
#        add $s0, $a3, $s0
#
#        lw $t5, 0($a1)
#        lw $t6, 0($a2)
#        lw $s0, 0($a3)
#
#        add $s0, $s0, $t5                   # diff[i] + a[i]
#        add $s0, $s0, $t6                   # diff[i] + b[i]
#
#        # if (diff[i] < 0)
#        bltz $s0, difference_less_than_zero
#        
#        difference_less_than_zero_return:
#
#        bnez $t0, mark_as_furthest_non_zero
#
#        addi $t0, $t0, -1
#        subtraction_loop_exit:
#
#structs_num_digits_equal:
#    addi $sp, $sp, -8
#    subu $
#
#difference_less_than_zero:
#    #subu $sp, $sp, -4
#    #sw $ra, 0($sp)
#
#    addi $s0, $s0, 10                   # diff[i] = diff[i] + 10 
#    bgt $t0, $zero, i_is_greater_than_zero
#    
#    i_is_greater_than_zero_return:
#
#    j difference_less_than_zero_return
#
#    
#
#i_is_greater_than_zero:
#    mult $s1, $t0, 4
#    addi $s1, $s1, -4
#    addi $s1, $a3, $s1
#    move $a0, $s1
#
#    lw $s1, 0($a0)
#    addi $s1, $s1, -1
#    sw $s1, 0($a0)
#
#    j i_is_greater_than_zero_return
#
#mark_as_furthest_non_zero:
#    move $t8, $t0
#


# Greater than
comparison:
    # a1 = bigInt1_addr, a2 = bigInt2_addr
    # t0 = i, t1 = struct_1_size, t2 = struct_2_size. t3 = larger_of_structs, t4 = curr_struct_1_addr, t5 = curr_struct_2_addr
    # t6 = struct_1_curr_val, t7 = struct_2_curr_val

    lw $t1, 0($a1)                          # loads the length of the first structure
    lw $t2, 0($a2)                          # loads the length of the second structure

    li $t0, 1                               # (i = 1), Skips the first address because it is used for the size of the structure 

    # Check if one of the structs has a digit ammount that is larger than the other (i.e. not equal)
    li $t3, 1                                                                 # Assume t1, is the larger of the two
    bgt $t1, $t2, a_struct_has_more_digits_than_other                               # If num_digits in struct_1 is larger than num_digits in struct_2 skip down to destination
    bgt $t2, $t1, two_is_larger                                        # If struct2 is larger than struct1 than move t2 into t3, and skip down
                                                                                    # If both are equal than it wont skip below
    li $t3, 0                                                                       # Resets to zero, if neither one is 

    # Go left to right, cases covered (struct1 > struct2), (struct1 < struct2), (struct1 == struct2)
    # Loop to check when the struct_1_num_digits == struct_2_num_digits

    comparison_loop:
        # Condition when they are equal, than exit the loop
        bgt $t0, $t1, comparison_loop_exit 

        # load from memory first
    
        mul $t4, $t0, 4                                                            # t4 = i * 4
        add $t4, $a1, $t4                                                           # curr_addr_1 = base_addr_1 + i (offset)
        lw $t6, 0($t4)                                                              

        mul $t5, $t0, 4
        add $t5, $a2, $t5
        lw $t7, 0($t5)

        # Compare them        
        bgt $t6, $t7, loop_one_is_greater                  # causes t3 = t1, then exits loop
        bgt $t7, $t6, loop_two_is_greater                  # causes t3 = t2, then exits loop


        addi $t0, $t0, 1
        j comparison_loop
    comparison_loop_exit:


    a_struct_has_more_digits_than_other:
        
        # Load which ever is the larger one (value in t3) into the return.
        move $v1, $t3 
        jal $ra


# if struct 2 has more digits than first struct (and is being called from greater than)
two_is_larger:
    # Return the address of t1 since it is guaranteed to be bigger.
    # If this was negative another step would be added to check the head number if negative.
    li $t3, 2

    j a_struct_has_more_digits_than_other

#
loop_one_is_greater:
    li $t3, 1
    j comparison_loop_exit

loop_two_is_greater:
    li $t3, 2
    j comparison_loop_exit


# greater than comparison
greater_than:

    subu $sp, $sp, 4
    sw $ra, 0($sp)

    jal comparison
    
    li $t1, 1

    beq $v1, $t1, greater_than_is_true
    # Else
    li $v0, 0

    greater_than_is_true_return:

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

greater_than_is_true:
    li $v0, 1
    j greater_than_is_true_return

# GTE
greater_than_equal:

    subu $sp, $sp, 4
    sw $ra, 0($sp)

    jal comparison

    li $t1, 2

    beq $v1, $t1, greater_than_equal_is_false
    # Else
    li $v0, 1

    greater_than_equal_is_false_return:

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

greater_than_equal_is_false:
    li $v0, 0
    j greater_than_equal_is_false_return

# Less than
less_than:
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    jal comparison

    li $t1, 2

    beq $t1, $v1, less_than_is_true
    # Else
    li $v0, 0

    less_than_is_true_return:

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

less_than_is_true:
    li $v0, 1
    j less_than_is_true_return

# LTE
less_than_equal:
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    jal comparison

    li $t1, 1

    beq $t1, $v1, less_than_equal_is_false
    # Else
    li $v0, 1
    
    less_than_equal_is_false_return:

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

less_than_equal_is_false:
    li $v0, 0
    j less_than_equal_is_false_return

# Equal
equal_check:
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    jal comparison

    li $t1, 0

    beq $t1, $v1, equal_check_is_true
    # Else
    li $v0, 0

    equal_check_is_true_return:

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

equal_check_is_true:
    li $v0, 1
    j equal_check_is_true_return

# Not equal
not_equal_check:
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    jal comparison

    li $t1, 0
    
    beq $t1, $v1, not_equal_check_is_false
    # Else
    li $v0, 1

    not_equal_check_is_false_return:

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

not_equal_check_is_false:
    li $v0, 0
    j not_equal_check_is_false_return

# comparison_output
comparison_output:
    li $t1, 1

    beq $t1, $a1, comparison_output_true
    # Else (it is false)
    
    li $v0, 4
    la $a0, falseMessage
    syscall

    comparison_output_true_return:

    jr $ra


# comparison_output_true
    comparison_output_true:
    li $v0, 4
    la $a0, trueMessage
    syscall

    j comparison_output_true_return


endProgram:
# End program
li $v0, 10
syscall
