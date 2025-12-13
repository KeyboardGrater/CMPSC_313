.data
file_input_path: .asciiz ""


.text
.globl main

.ent main
main:
    # Registers: t0 = buffer_size, t1 = file_addr, t2 = buffer_addr
# ----------------------------------- INITIALIZE LOCAL VARIABLES ----------------------------------- #
    # Initialize buffer_size
    li $t0, 256
    
# ----------------------------------- OPEN INPUT FILE ----------------------------------- #
    # Save local variables
    addi $sp, $sp, -4
    sw $t0, 0($sp)

    # Load argument, call function, then save return value
    la $a0, file_input_path                 # load base address of file_input_path string into argument 0
    jal open_file
    move $t1, $v0

    # Restore Arguments
    lw $t0, 0($sp)
    addi $sp, $sp, 4
# ----------------------------------- READ INPUT FILE ----------------------------------- #
    # Save local variables
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t1, 4($sp)

    # Load arguments, call function, and save result
    move $a0, $t1                           # buffer = read_file(file_poiner, buffer_size)
    move $a1, $t0
    jal read_file
    move $t2, $v0                           # Save result of read_file to buffer_addr

    # Restore the registers
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    addi $sp, $sp, 8

    # Close the read file
    li $v0, 16                              # fclose(file_pointer);
    move $a0, $t1
    syscall

# ----------------------------------- PRINT CONTENTS OF FILE TO SCREEN ----------------------------------- #
    # Print the file into the terminal
    addi $sp, $sp, -12
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)

    move $a0, $t2                           # print_file(buffer);
    jal print_file

    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)

    # Free memory allocated to buffer
    # free (buffer);    

    j end_program                           # return 0;

# End program
end_program:
    li $v0, 10
    syscall

.end main



.data   # For open_file

.text   # For open_file

.globl open_file
.ent open_file

open_file:
    # Arguments: a0 =file_path 
    # Registers: t0 = file_path, t1 =file descriptor

    # Move argument to temporary registers
    move $t0, $a0

    li $v0, 13
    move $a0, $t0                           # Load absolute path of the file to be opened
    la $a1, 0                               # The file that is open is in read mode
    la $a2, 0
    syscall
    move $t1, $v0                           # Save file_descriptor to t1

    # Check if there was any issues when opening the file
    tlt $t1, $zero                          # Checks if $t1 < 0 (if $t1 is negative), then an error has occured when opening file, thus throw error

    # Otherwise, return file descriptor
    move $v0, $t1                           # return file_descriptor
    jr $ra
.end open_file

.data 
null_byte: .byte 0
.text
.globl read_file
.ent read_file

read_file:
    # Arguments: a0 = file_desc, a1 = buffer_size
    # Registers: t0 = file_desc, t1 = buffer_size, t2 = buffer_addr
    # t3 = bytes_just_read, t4 = total_bytes_read, t5 = old_buffer_addr
    # t6 = bytes_to_read
    # t8 = temp_1, t9 = temp_2

    # Move arguments into temporary registers
    move $t0, $a0
    move $t1, $a1

    # Allocate memory for the buffer
    li $v0, 9
    move $a0, $t1
    syscall
    move $t2, $v0

    # Error Testing    
    tlt $t2, $zero                          # Error when allocating memory

    # Read the file 
    li $v0, 14
    move $a0, $t0
    move $a1, $t2
    move $a2, $t1
    syscall
    move $t3, $v0

    # Check for file reading error
    tlt $t3, $zero

    # Update total_bytes_read
    move $t4, $t3
    
    # Check if the EOF was reached (if feof(file_pointer) == 0)
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    
    move $a0, $t0
    move $a1, $t2
    move $a2, $t1
    #jal feof
      
    #move $t8, $v0
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    addi $sp, $sp, 24

    #beq $t8, $zero, read_file_EOF_reached
    beq $t4, $zero, read_file_EOF_reached

    # Else, loop, creating new buffers and reading
    read_file_loop:
        # Allocate new buffer and then copy old buffer into the new buffer
        move $t5, $t2                       # old_buffer = buffer; (Saving buffer_addr to old_buffer_addr)
        sll $t1, $t1, 1                     # buffer_size = buffersize << 1; (Doubles buffer_size)
        
        li $v0, 9                           # buffer = (char *) malloc (buffer_size + 1)
        addi $t8, $t1, 1                    # buffer_size + 1 (from above)
        move $a0, $t8
        syscall

        move $t8, $v0
        blt $t8, $zero, read_file_buffer_eq_null

        addi $sp, $sp, -28                  # strcpy_func(old_buffer, buffer, buffer_size);
        sw $ra, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        sw $t2, 12($sp)
        sw $t3, 16($sp)
        sw $t4, 20($sp)
        sw $t5, 24($sp)                     # Dont need to save $t8

        move $a0, $t5
        move $a1, $t2
        move $a2, $t1
        jal strcpy_func

        lw $ra, 0($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        lw $t2, 12($sp)
        lw $t3, 16($sp)
        lw $t4, 20($sp)
        lw $t5, 24($sp)
        addi $sp, $sp, 28

        # Release the old_buffer memory
        # Not possible to do in qtspim

        # Calculate the bytes to read
        sub $t6, $t1, $t4                   # bytes_to_read = buffer_size - total_bytes_read;

        # Read the file     
        li $v0, 14                          # bytes_just_read = fread(buffer + total_bytes_read, 1, bytes_to_read, file_pointer);
        move $a0, $t0
        add $a1, $t2, $t4                   # a1 = buffer_addr + total_bytes (from above)
        move $a2, $t6
        syscall
        move $t3, $v0                       # bytes_just_read = fread(...);

        # Update total_bytes_read
        add $t4, $t4, $t3                   # total_bytes_read = total_bytes_read + bytes_just_read;

        # Exit conditional: if (bytes_just_read < bytes_to_read) {break;}
        blt $t3, $t6, read_file_EOF_reached
        
        j read_file_loop
    read_file_EOF_reached:
    
    # Add a null terminator to the end of the buffer
    la $t8, null_byte
    lb $t8, 0($t8) 
    add $t9, $t2, $t4                       # buffer_addr + offset (total_bytes_read)
    sb $t8, 0($t9)                          # buffer[total_bytes_read] = '\0';    

    # Return the buffer
    move $v0, $t2                           # return buffer;
    jr $ra              

    read_file_buffer_eq_null:
        # Branch
        # if (buffer == NULL) { free(old_buffer); return(NULL);}
        lb $v0, 0x00
        jr $ra

feof:

    # Arguments: a0 = file_desc, a1 = buffer_size
    # Local: t0 = file_desc, t1 = buffer_size
    # t2 = byte_buffer_addr, t3 = 
    #  = number of charcters read / result

    # Read file, if $v0 returns zero then the end of the file has been reached
    # Arguments are already in proper registers

    # This works because it save the location of where it was in the file when it read it last,
    # thus if the file is read again and it comes back with zero bytes read, then it is at the EOF
    
    # Move arguments to temp register
    move $t0, $a0
    move $t1, $a1
    
    # Allocate a single byte buffer
    li $v0, 9
    la $a0, 1
    syscall
    move $t2,$v0

    # Read the file with the byte_buffer
    li $v0, 14
    move $a0, $t0
    move $a1, $t2
    la $a2, 1
    syscall
    move $t3, $v0
    
     
    
strcpy_func:
    # Function data_type: void
    # Arguments a0 = old_buffer_addr, a1 = new_buffer_addr, a2 = buffer_size
    # Local: t0 = new_buffer_addr, t1 = old_buffer_addr, t2 = buffer_size
    # t3 = i, t4 = char_holder, t5 = get_value_at_this_location
    
    # Move arguments into temp registers
    move $t0, $a1
    move $t1, $a0
    move $t2, $a2

    # int i = 0;
    li $t3, 0

    # Half the buffer size, so buffer_size is the old buffer size
    srl $t2, $t2, 1                         # buffer_size = buffer_size >> 1;

    strcpy_func_loop:
        # Exit conditional: uf (i == buffer_size) {break;}
        beq $t3, $t2, strcpy_func_loop_exit

        # Copy from old buffer to new buffer
        add $t5, $t1, $t3                   # temp = old_buffer[i];  
        lb $t4, 0($t5)

        add $t5, $t0, $t3                   # new_buffer[i] = temp;
        sb $t4, 0($t5)

        # Increment iterator
        addi $t3, $t3, 1

        j strcpy_func_loop
    strcpy_func_loop_exit:

    # Return
    jr $ra


.end read_file

.text
.globl print_file
.ent print_file
print_file:
    # Argument: a0 = buffer_addr
    # Function Data_type: void

    li $v0, 4
    syscall

    jr $ra

.end print_file

# Exception handler
.ktext 0x80000180
    
    # Save the registers
    move $k0, $a0
    move $k1, $v0

    # Print generic error messgae
    li $v0, 4
    la $a0, error_message
    syscall

    # load address of end_program label
    la $k0, end_program
    
    mtc0 $k0, $14

    eret

.kdata
    error_message: .asciiz "An error has occured.\nNow ending the program.\n"

