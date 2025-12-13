.data

# Constants
ONE: .double 1.00
TWO: .double 2.00
Precision: .double 0.00001


# Strings
input_prompt: .asciiz "Please enter a number to be square rooted\n"
print_sqrt_msg_1: .asciiz "The square root of "
print_sqrt_msg_2: .asciiz " is "

.text
.globl main

get_user_input:
    # Arguments: None

    # Prompt the user for input
    li $v0, 4
    la $a0, input_prompt
    syscall

    # Get the user input
    li $v0, 5
    syscall

    # Return the user input
    jr $ra

square_root:
    # Arguments $a0 = n
    # f0 = double(n), f2 = l, f4 = x, f6 = root, f8 = temp, f10 = 2.00
    # t0 = int(n)

    # move argument to temp register
    move $t0, $a0


    # conver from integer to double
    mtc1 $t0, $f4
    cvt.d.w $f0, $f4

    # Check if n is zero
    beq $t0, $zero, n_is_zero

    l.d $f10, TWO

    # x = n;
    mov.d $f4, $f0

    square_root_loop:
        # root = (x + (n/x)) / 2;
        div.d $f8, $f0, $f4
        add.d $f8, $f4, $f8
        div.d $f6, $f8, $f10
        
        # if (abs(root -x) < l) {break;}
        sub.d $f8, $f6, $f4
        abs.d $f8, $f8
        c.lt.d $f8, $f2
        bc1t square_root_loop_exit

        # x = root;
        mov.d $f4, $f6

        j square_root_loop
    square_root_loop_exit:
    
    # return root
    mov.d $f0, $f6
    jr $ra

    n_is_zero:
    jr $ra


print_sqrt:
    # Arguments: a0 = sqrt, f0 = org num
    move $t0, $a0

    li $v0, 4
    la $a0, print_sqrt_msg_1
    syscall

    li $v0, 1
    move $a0, $t0
    syscall

    li $v0, 4
    la $a0, print_sqrt_msg_2
    syscall

    li $v0, 3
    mov.d $f12, $f0
    syscall

    jr $ra

main:
    # Registers
    # f0 = user_input
    
    # get user input
    jal get_user_input
    move $t0, $v0

    # save to stack
    addi $sp, $sp, -4
    sw $t0, 0($sp)

    # Check if it is valid for sqrt
    move $a0, $t0
    tlt $t0, $zero

    # Calculate the square root
    l.d $f2, Precision
    move $a0, $t0
    jal square_root


    # Print the square root
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    move $a0, $t0
    jal print_sqrt

    j end_program

# End program
end_program:
    li $v0, 10
    syscall

# Exceptions
.ktext 0x80000180

    li $v0, 4
    la $a0, negative_number_error
    syscall

    # Load the end_program destination
    la $t0, end_program
    mtc0 $t0, $14

    eret

.kdata
    negative_number_error: .asciiz "Negative Number Detected. Ending the program\n"
