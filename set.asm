.data
# Global Variables (Constant)
INTEGERSET_ARRAY_SIZE = 100                 # enum {INTEGERSET_ARRAY_SIZE = 100};

# struct IntegerSet {int a[INTEGERSET_ARRAY_SIZE]; };   # int * 100 = 4 * 100 = 400 bytes

# jump tables
operation_switch: .word case_1, case_2, case_3, case_4, case_5, case_6, case_7
print_switch: .word ps_1, ps_2, ps_3

# strings
operation_prompt: .asciiz "Please pick a operation to perform.\n1: Union of two sets\n2: Intersection of two sets\n3: Insertion on a set\n4: Deletion on a set\n5: Print a set\n6: Check to see if two sets are equal\n7: Exit\n\n"
which_array_prompt: .asciiz "Which array would you like to chose.\nFor array one enter 1, for array two, enter 2. And if you would like to go back, enter 3.\n"
number_to_modify_prompt: .asciiz "Please pick a number between 0 - 99\n"
false_message: .asciiz "False\n"
true_message: .asciiz "True\n"

testMessage: .asciiz "Test Message"

.text
.globl main

main:
    # ------------------------ Initalization part ---------------------------- #
    # t0 = bytes to allocate ---> Done after both structs are created, t3 = temp
    # s1 = address_1, s2 = address_2, s3 = INTEGERSET_ARRAY_SIZE - 1

    # calaculate the number of bytes that need to be allocated.
    li $t0, 4                                # int = 4 bytes
    mul $t0, $t0, INTEGERSET_ARRAY_SIZE      # array_bytes = 4 * array_size = 4 * 100 = 400

    # Create objects array_1 and array_2
    
    # struct IntegerSet array_1;
    li $v0, 9                               # dynamically allocate
    move $a0, $t0                             # allocate $t0 number of bytes
    syscall                                 # allocated starting address is $v0
    move $s1, $v0                           # move array_1_addr to addr register

    # struct IntegerSet array_2;
    li $v0, 9
    move $a0, $t0
    syscall
    move $s2, $v0

    # last_index_of_array = INTEGERSET_ARRAY_SIZE - 1
    li $s3, INTEGERSET_ARRAY_SIZE
    addi $s3, $s3, -1

    # constructor(&array_1);
    move $a0, $s1                           # move to address register which simulates arguments
    jal constructor


    # constructor(&array_2);
    move $a0, $s2
    jal constructor


    # ----------------------------------- User Choice Section --------------------------
    # t1 = operation_choice , t2 = array_choice, t3 = temp, t4 = array_choice_offset
    # s1 = array_1, s2 = array_2

    user_choices_loop:
        # Get user input for what operation they want to do.
        
        # printf("Please pick a operation to perform.\n1: Union of two sets\n2: Intersection of two sets\n3: Insertion on a set\n4: Deletion on a set\n5: Print a set\n6: Check to see if two sets are equal\n7: Exit\n\n");
        li $v0, 4
        la $a0, operation_prompt
        syscall

        # scanf("%u", &operation_choice);
        li $v0, 5
        syscall
        move $t1, $v0

        # switch (operation_choice)
        
        # First check if the default condition was reached (bound checking)
        blt $t1, $zero, user_choices_loop             # (operation_choice < 0) Get input again
        
        li $t3, 7
        bgt $t1, $t3, user_choices_loop               # (operation_choice > 7)

        # Jump table lookup

        # Adjust for zero-based indexing (user enters 1-7, but array is only 0-6)
        addi $t1, $t1, -1

        # Find location of choice   
        la $t3, operation_switch                      # base_addr of operation_switch table
        mul $t1, $t1, 4                               # t1 = offset = t1 * sizeOf(int)
        add $t3, $t3, $t1                             # t3 = base_addr + offset = operation_switch_base_addr + (operation_choice * sizeof(int))
        
        # Go to choices case
        lw $t3, 0($t3)                                # Load the value at the address of t3 into t3, which is the address of the case
        jr $t3                                        # jump registers to the value of t3, which is the address of the case

        # Union
        case_1:
            # TODO
            j user_choices_loop
        # Intersection
        case_2:
            # TODO
            j user_choices_loop
        # Insert
        case_3:
            # TODO
            j user_choices_loop
        # Delete
        case_4:
            # TODO 
            j user_choices_loop
        # Print
        case_5:
            # Case 1, 2, 3, will all make the operations menu appear again. 1 and 2 does a action beforehand, while 3 does no actions.
            # The default case (when not 1, 2, nor 3) repeats the array_choice, but still within the print action choice.
            operation_choice_print_loop:
                # array_choice = which_array_to_choose();
                jal which_array_to_choose
                move $t2, $v0
                
                # switch (array_choice)
                
                # Account for zero-indexing
                addi $t2, $t2, -1

                # Find the location of the array choice
                la $t3, print_switch                  # Base address
                mul $t4, $t2, 4                       # array_choice * sizeOf(int)
                add $t3, $t3, $t4                     # t3 = base_addr + offset

                # Goto Case
                lw $t3, 0($t3)
                jr $t3

                ps_1:
                    # print_set(&array_1);
                    move $a0, $s1                     # load into argument array_1_addr 
                    move $a1, $s3                     # load last_index into arguments
                    jal print_set                     
                    j user_choices_loop               # Repeat the users operation options
                ps_2:
                    # print_set(&array_2);
                    move $a0, $s2
                    move $a1, $s3
                    jal print_set
                    j user_choices_loop
                ps_3:
                    j user_choices_loop               
        # Equals
        case_6:
            # TODO
            j user_choices_loop
        # Exit
        case_7:
            j user_choices_loop_exit
        # Default
        # --------------- Might not need this, because default is handel above ------------
        j user_choices_loop

    user_choices_loop_exit:         # Not nessicary, but just going to leave it here
    
    j endProgram

constructor:
    # void constructor (struct IntegerSet * set_pointer)

    # t0 = i, t1 = LAST_INDEX, t2 = byte offset, t3 = curr_addr, t4 = 0
    # a0 = struct IntegerSet * set_pointer 

    # int i = 0
    li $t0, 0
    li $t4, 0

    # const unsigned int LAST_INDEX = INTEGERSET_ARRAY_SIZE - 1;
    addi $t1, INTEGERSET_ARRAY_SIZE, -1

    # Loop across and fill in the arrays with zero
    constructor_loop:
        
        # if (i > LAST_INDEX) {break;}
        bgt $t0, $t1, constructor_loop_exit            

        # set_pointer -> a[i] = 0;
        mul $t2, $t0, 4                     # t2 = byte_offset = i * (sizeof(int))
        add $t3, $a0, $t2                   # accesses_location = base_addr + offset
        sw $t4, 0($a0)                      # save the value in t4 to the accesses_location

        # i = i + 1;
        addi $t0, $t0, 1
        j constructor_loop
    constructor_loop_exit:

    jr $ra


which_array_to_choose:
    # Arguments: None
    # t1 = array_to_modify, t2 = lower bounds, t3 = upper bounds 

    li $t2, 1
    li $t3, 3

    # Get user input for which array they would like to modify.
    which_array_to_choose_loop:
        # printf("Which array would you like to chose.\nFor array one enter 1, for array two, enter 2. And if you would like to go back, enter 3.\n"); 
        li $v0, 4
        la $a0, which_array_prompt
        syscall

        li $v0, 5
        syscall
        move $t1, $v0

        # Check if within acceptable bounds
        blt $t1, $t2, which_array_to_choose_loop      # if (t1 < 1) {redo loop}
        bgt $t1, $t3, which_array_to_choose_loop      # if (t1 > 3) {redo loop}

        # When in the bounds
        move $v0, $t1

    jr $ra

print_set:
    # Arguments: a0 = struct Integer Set * set_pointer, a1 = unsigned int last_index
    # t0 = i, t1 = last_index, t2 = offset, t3 = curr_addr, t4 = base_addr
    # a0 = curr_val

    li $t0, 0                               # int i = 0;
    move $t4, $a0
    move $t1, $a1                           

    # Loop over set and print at index
    print_set_loop:
        # Conditional to check if we should exit
        bgt $t0, $t1, print_set_loop_exit
        
        # unsigned int value_at_index = set_pointer -> a[i];
        # Get value at i
        mul $t2, $t0, 4                     # offset = t2 = i * 4
        add $t3 , $t4, $t2                  # curr_addr = base_addr + offset
        lw $a0, 0($t3)                      # load value at address t3 into a0

        #printf("%u", value_at_index);                          
        # Print value
        li $v0, 1
        syscall
        
        # Print spaces in between numbers
        li $v0, 11
        la $a0, 20                          
        syscall

        # increment the iterator
        addi $t0, $t0, 1

        j print_set_loop
    print_set_loop_exit:

    jr $ra

# End Program
# endProgram:
endProgram:
    li $v0, 10
    syscall
