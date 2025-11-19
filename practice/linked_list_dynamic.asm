.data

# Struct:
# data: .word 1
# next: .word node_2



.text
.globl main
main:
    # Create Head Node            
    li $t0, 1

    jal create_linked_list                      
    move $s0, $v0

    # Print linked list
    move $a0, $s0
    jal print_linked_list

    li $t0, 2

    move $a0, $s0
    move $a1, $t0
    jal append

    # Print linked list
    move $a0, $s0
    jal print_linked_list


    j end_program


create_linked_list:
    # arguments: a0 = data
    # t0 = address, t1 = data
    move $t1, $a0

    # Dynamically allocate memory
    li $v0, 9
    la $a0, 8
    syscall
    move $t0, $v0

    # node->data = data
    sw $t1, 0($t0)

    # node->next = null
    la $a0, 0x00
    move $t2, $a0
    sw $t2, 0($t0)

    move $v0, $t0

    jr $ra

append:
    # a0 = base_addr, a1 = data
    # t0 = base_addr, t1 = data
    # t0 = curr_tail, t1 = data, t2 = new_tail, t3 = temp

    move $t0, $a0
    move $t1, $a1


    # Traverse the list
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    addi $sp, $sp, -4
    sw $t1, 0($sp)

    jal traverse_list_to_tail
    move $t0, $v0

    # Load stuff
    lw $t1, 0($sp)
    addi $sp, $sp, 4

    # Dynamically allocate the new tail
    li $v0, 9
    la $a0, 8
    syscall
    move $t2, $v0

    # Save the data to the newly allocated memory (curr->data = data)
    sw $t1, 0($t2)
    # Make the next of the newly allocated memory null (curr->next = NULL)
    li $t3, 0x00
    sw $t3, 4($t2)                          # next offset

    # Save the addr of the new tail (t2) into the next of the curr_tail
    sw $t2, 4($t0)                          # next offset

    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

traverse_list_to_tail:
    # a0 = base_addr

    # move a to t
    move $t2, $a0

    li $t0, 0                               # int i = 0
    li $t3, 0x00                            # null terminator

    traverse_list_loop:
        # Get the next at the current

        
        mul $t4, $t0, 8                     # offset
        add $t4, $t2, $t4                   # curr = base + offset

        # load next
        lw $t1, 4($t4)

        # Check for null terminator
        beq $t1, $t3, traverse_list_loop_exit

        addi $t0, $t0, 1
        j traverse_list_loop
    traverse_list_loop_exit:
    
    # Get the tail of the list
    move $v0, $t4
    jr $ra


print_linked_list:
    # a0 = base_addr_of_linked_list
    move $t2, $a0

    li $t0, 0                               # int i = 0
    li $t3, 0x00                            # null terminate varibale 
    
    print_linked_list_loop:
         
        # offset = i * size_of_struct
        mul $t4, $t0, 8
        add $t4, $t2, $t4                   # curr = base + offset

        # Print the data
        lw $t1, 0($t4)                      # 0 is data offset

        li $v0, 1
        move $a0, $t1
        syscall

        li $v0, 11
        la $a0, 0x0A
        syscall

        # Check for null terminator
        lw $t1, 4($t4)                      # 4 is the next offset

        beq $t1, $t3, print_linked_list_loop_exit

        # Increment iterator
        addi $t0, $t0, 1

        j print_linked_list_loop
    print_linked_list_loop_exit:

    jr $ra    


# End program
end_program:
    li $v0, 10
    syscall
