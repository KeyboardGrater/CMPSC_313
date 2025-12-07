.data
# Constants
lower_limit = 1
upper_limit = 100

# Strings
input_prompt: .asciiz "Please enter ten different numbers\n"
acceptance_message: .asciiz "All the numbers are above the lower limit, below the upper limit, and all greater than the last."

.text
.globl main

print_acceptance:
    # Arguments: None

    li $v0, 4
    la $a0, acceptance_message
    syscall

    jr $ra

read_number:
    # Arguments: a0 = lower_limit, a1 = upper_limit
    # Registers: t0 = lower_limit, t1 = upper_limit, t2 = current_input, t3 = previous_input, t4 = 10, t5 = i

    # Move arguments into temporary registers 
    move $t0, $a0                          
    move $t1, $a1

    # Set previous_input == lower_limit, because the inital input will never have a previous_input
    move $t3, $t0

    # Set t4 (the loop stopping point), and t5 (the iterator)
    li $t4, 10
    li $t5, 0

    read_number_loop:
        # Conditional Exit 
        bge $t5, $t4, read_number_loop_exit

        # Get user input
        li $v0, 5
        syscall
        move $t2, $v0

        # Check if the number is less than or equal to  lower_limit 
        tlt $t2, $t0                        # Trap if $t2 < $t0
        teq $t2, $t0                        # Trap if $t2 == $t0
        # Check if the number is greater than or equal to upper_limit   
        tge $t2, $t1                        # Trap if $t2 >= $t1
        # Check if the previous number is less than or equal to current number
        tlt $t2, $t3                        # Trap if $t2 < $t3
        teq $t2, $t3                        # Trap if $t2 == $t3

        # Set the current_input as the previous_input
        move $t3, $t2

        # Increment the iterator
        addi $t5, $t5, 1
        j read_number_loop
    read_number_loop_exit:

    # If no error's were thrown then print message
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal print_acceptance 
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

main:
    # Get constants
    li $t0, lower_limit
    li $t1, upper_limit

    # Prompt user input
    li $v0, 4
    la $a0, input_prompt
    syscall

    # Call function
    move $a0, $t0
    move $a1, $t1
    jal read_number
    input_error_return:

    j end_program

# End program
end_program:
    li $v0, 10
    syscall

# Exception handler
.ktext 0x80000180

    # Save $a0, and $v0
    move $k0, $a0
    move $k1, $v0

    # Print the error message
    li $v0, 4
    la $a0, error_message
    syscall

    # Get the location that the program is supposed to return to
    la $t0, input_error_return
    mtc0 $t0, $14

    # Restore the registers
    move $a0, $k0
    move $v0, $k1

    # Return the state and go to the designated location
    eret     
    
.kdata
    error_message: .asciiz "An Error has occured"