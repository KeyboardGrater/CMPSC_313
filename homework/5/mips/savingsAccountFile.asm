.data


# Structures
# typedef struct {
#     unsigned int account_number;          # 4 bytes
#     double annual_interest_rate;          # 8 bytes
#     double savings_balance;               # 8 bytes
# } SavingsAccount;                         # 4 + 8 + 8 = 20 bytes

# Constrants
READ_FILE_AMMOUNT = 256


# Array
.align 2
decimal_array: .space 8                     # int * 2 = 8

# Buffers
read_buffer: .space READ_FILE_AMMOUNT 
sub_buffer: .space READ_FILE_AMMOUNT
temp_buffer: .space READ_FILE_AMMOUNT

str_A: .space READ_FILE_AMMOUNT
str_B: .space READ_FILE_AMMOUNT

# Switch statements
balance_loop_switch: .word bls_0 bls_1

# Paths
balance_file_path: .asciiz "/home/logan/Documents/classes/313_compsci/homework/5/mips/balance.txt"
transaction_file_path: .asciiz "/home/logan/Documents/classes/313_compsci/homework/5/mips/copy_transaction.txt"

# Constants continued
hundred_placed: .double 100.00

# Messages
open_balance_error_message: .asciiz "There was a issue when trying to open the balance file"

num_created_accounts_message: .asciiz "Accounts Created: "

test_message: .asciiz "THIS POINT HAS BEEN REACHED"


.text
.globl main
main:

    # --------------- 1. Setting up the accounts --------------- #

    # Open the balance file
    li $v0, 13                              # file_pointer = fopen(balance_file_path, "r");
    la $a0, balance_file_path
    la $a1, 0
    la $a2, 0
    syscall
    move $s0, $v0                           # Save the file descripter

    # Check to see if the file opened correctly
    blt $s0, $zero, open_balance_error
    
    # Create the accounts based off the balance file
    # SavingsAccount ** account = read_balance_file(file_pointer, &num_accounts, READ_FILE_AMMOUNT);
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $a0, $s0
    jal read_balance_file
    move $s1, $v0                           # s1 = account array pointer
    move $s2, $v1                           # s2 = num_accounts
    
    # Close the file 
    li $v0, 16
    move $a0, $s0
    syscall
    
    # List the number of created classes
    li $v0, 4
    la $a0, num_created_accounts_message
    syscall

    li $v0, 1
    move $a0, $s2
    syscall

    li $v0, 11
    la $a0, 0x0A
    syscall



    j end_program

new_account:
    # SavingsAccount * new_account (SavingsAccount * account_X, unsigned int account_number, double annaul_interest_rate, double savings_balance) 
    # Arguments: a0 = account_X_addr, a1 = account_id, f12 = annual_interest_rate, f14 = balance
    # t0 = account_X, t1 = account_number
    # f0 = annual_interest_rate, f2 = savings_balance

    # move arguments into temporay registers (fixed and floating point)
    move $t0, $a0
    move $t1, $a1
    mov.d $f0, $f12
    mov.d $f2, $f14

    # Fill in the values for account_X
    sw $t1, 0($t0)                          # save the account_number to the first segment of the struct
    s.d $f0, 4($t0)                         # save the yearly_interest_rate to the second segment of the struct (at base_addr + int = 0 + 4 = 4)
    s.d $f2, 12($t0)                        # save the balance to the third segment of the structure (at base_addr + int + double = 0 + 4 + 8 = 12)
    
    move $v0, $t0

    jr $ra


calculate_monthly_interest:
    # void calculate_monthly_interest (SavingsAccount * account) {
    # double interest, balance, annual_interest_rate, monthly_interest

    # arguments: a0 = account
    # t0 = account_addr, t1 = temp
    # f0 = interest, f2 = balance, f4 = yearly_inter_rate, f6 = mon_inter, f8 = temp

    
    # move argument (account address) to temporary register
    move $t0, $a0

    # get annaul_interest_rate
    l.d $f0, 4($t0)
    # get balance
    l.d $f2, 12($t0)


    # calculate annual_interest = annual_interest_rate * balance
    mul.d $f0, $f0, $f2


    # calculate monthly interest
    li $t1, 12
    mtc1.d $t1, $f8
    cvt.d.w $f8, $f8

    div.d $f6, $f0, $f8

    # calculate the new balance (balance + monthly_interest)
    add.d $f2, $f2, $f6

    # Save to structure
    s.d $f2, 12($t0) 
    
    # Save return address to stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Call print_balance
    move $a0, $t0                           # load account_X_addr in to argument
    jal print_balance

    # Pop stack for return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

print_balance:
    # void print_balance (SavingsAccount * account)
    # double balance;

    # t0 = account_X_addr
    # f0 = balance

    # move account_addr to temp register
    move $t0, $a0

    # load the balance from struct into local balance
    l.d $f0, 12($t0)                         # balance offset = 12 (base + int + double = 0 + 4 + 8 = 12)

    # print the information
    li $v0, 4
    la $a0, new_balance_message
    syscall

    # Save return address to stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Call limit_decimal_numbers
    mov.d $f12, $f0
    jal limit_decimal_numbers

    # pop return address from stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    #li $v0, 3
    #mov.d $f12, $f0
    #syscall

    li $v0, 11
    la $a0, 0x0A
    syscall

    jr $ra

limit_decimal_numbers:
    # argument: f12

    # t0 = temp
    # f0 = number, f2 = double(100)

    # move into temporary register (floating-point)
    mov.d $f0, $f12

    # multiply the number by 100 (100'ths place is the max decimal value being kept)
    li $t0, 100                             # Convert int 100 to double 100                   
    mtc1.d $t0, $f2
    cvt.d.w $f2, $f2

    mul.d $f0, $f0, $f2

    # Convert the double into an integer and move it
    cvt.w.d $f0, $f0
    mfc1 $t0, $f0

    # Divide by 100, hi (modular) = decimal value, low = integer value
    div $t0, $t0, 100

    mflo $t0

    li $v0, 11
    la $a0, 0x24                            # Hex: 0x24 = '$'
    syscall

    li $v0, 1                               # print out everything to the left of the decimal    
    move $a0, $t0
    syscall

    li $v0, 11
    la $a0, 0x2E                            # Hex: 0x2E = '.'
    syscall 

    mfhi $t0

    # call converstion of integer to string function
    addi $sp, $sp, -4
    sw $ra 0($sp)

    move $a0, $t0
    jal int_to_string_print

    # restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

int_to_string_print:
    # arguments $a0
    # t0 = i, t1 = int_to_string, t2 = decimal_place_limit, t3 = num_to_print, t4 = divider

    # move arguments into temp reg
    move $t1, $a0
    
    # Initializations
    li $t0, 0                               # int i = 0
    li $t2, 2                               # decimal place limit
    li $t4, 10

    int_to_string_loop:
        # When to exit the loop
        beq $t0, $t2, int_to_string_loop_exit

        # print charcter at i
        div $t1, $t1, $t4
        mflo $t3                            # move the dividend to t3 (one being printed)
        mfhi $t1                            # move the remainder into t1

        li $v0, 1
        move $a0, $t3
        syscall
        
        # increment i
        addi $t0, $t0, 1
        j int_to_string_loop
    int_to_string_loop_exit:

    jr $ra

set_interest_rate:
    # a0 = arguments: account_addr, f12 = annual_interest_rate

    # t0 = account_addr
    # f0 = annual_interest_rate

    # move arguments into temporary registers
    move $t0, $a0
    mov.d $f0, $f12

    # update annaul interest rate
    s.d $f0, 4($t0)

    jr $ra

read_balance_file:
    # Arguments: a0 = file_description
    # t0 = i, t1 = bytes_read, t2 = current_charcter, t3 = count, t4 = j, t5 = id_or_balance, t6 = account_id
    # t8 = temp1, t9 = temp2
    # a1 = read_buffer, a2 = sub_buffer, a3 = temp_buffer
    # s1 = SavingsAccount ** account
    
    # Save registers we'll need to preserve
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)                          # s2 will store account count

    # Move the file description to t8 temporarily
    move $t8, $a0

    # Read the file and then store it into a buffer
    li $v0, 14
    move $a0, $t8
    la $a1, read_buffer
    li $a2, READ_FILE_AMMOUNT
    syscall
    move $t1, $v0                           # t1 = bytes_read
    
    # Initialize variables
    li $t0, 0                               # i = 0
    li $t3, 0                               # count = 0

    balance_memory_loop:
        # Exit conditional (i == bytes_read)
        beq $t0, $t1, balance_memory_loop_exit

        # Check if the current_charcter is a newline
        la $a1, read_buffer
        add $t2, $a1, $t0                   # curr_addr = base_addr + offset
        lb $t2, 0($t2)

        li $t9, 0x0A
        bne $t2, $t9, increment_count_branch_skip
        addi $t3, $t3, 1                    # count++
        
    increment_count_branch_skip:
        addi $t0, $t0, 1                    # i++
        j balance_memory_loop
        
    balance_memory_loop_exit:

    # Check to see if the last charcter in the buffer is not a newline
    li $t9, 0x0A
    beq $t2, $t9, balance_cc_ne_nl_skip
    
    # Add newline if last char isn't one
    la $a1, read_buffer
    add $t8, $a1, $t1                       # curr_addr = base_addr + bytes_read
    li $t9, 0x0A
    sb $t9, 0($t8)                          # read_buffer[bytes_read] = 0x0A
    addi $t1, $t1, 1                        # bytes_read++
    addi $t3, $t3, 1                        # count++
    
balance_cc_ne_nl_skip:

    # Allocate array of pointers: account = malloc(count * 4)
    sll $a0, $t3, 2                         # count * 4 (size of pointer)
    li $v0, 9
    syscall
    move $s1, $v0                           # s1 = account array pointer
    move $s2, $t3                           # s2 = total count (save for later)

    # Initialize parsing variables
    li $t0, 0                               # i = 0
    li $t3, 0                               # count = 0 (reuse as array index)
    li $t4, 0                               # j = 0
    li $t5, 0                               # id_or_balance = 0
    la $a1, read_buffer
    la $a2, sub_buffer
    la $a3, temp_buffer

    # Loop over the buffer and parse the data
    read_balance_file_loop:
        # Exit condition (i == bytes_read)
        beq $t0, $t1, read_balance_file_loop_exit

        # Get current character: current_charcter = read_buffer[i]
        add $t8, $a1, $t0
        lb $t2, 0($t8)

        # Check if character is newline
        li $t9, 0x0A
        bne $t2, $t9, balance_charcter_is_newline_skip
        
        # Character is a newline
        # sub_buffer[j] = 0x00
        add $t8, $a2, $t4
        sb $zero, 0($t8)
        li $t4, 0                           # j = 0 (reset)

        # switch(id_or_balance)
        beqz $t5, bls_0                     # if id_or_balance == 0
        # else it's case 1
        j bls_1

        bls_0:
            # case 0: strcpy(temp_buffer, sub_buffer)
            # Save registers that might be overwritten
            addi $sp, $sp, -24
            sw $t0, 0($sp)
            sw $t1, 4($sp)
            sw $t2, 8($sp)
            sw $t3, 12($sp)
            sw $t4, 16($sp)
            sw $t5, 20($sp)
            
            move $a0, $a3                   # dest = temp_buffer
            move $a1, $a2                   # src = sub_buffer
            jal strcpy
            
            # Restore registers
            lw $t0, 0($sp)
            lw $t1, 4($sp)
            lw $t2, 8($sp)
            lw $t3, 12($sp)
            lw $t4, 16($sp)
            lw $t5, 20($sp)
            addi $sp, $sp, 24
            
            # Reload buffer addresses
            la $a1, read_buffer
            la $a2, sub_buffer
            la $a3, temp_buffer
            
            li $t5, 1                       # id_or_balance = 1
            j balance_iterator_update

        bls_1:
            # case 1: Parse account_id and balance, create account
            # Save all registers before function calls
            addi $sp, $sp, -32
            sw $t0, 0($sp)
            sw $t1, 4($sp)
            sw $t2, 8($sp)
            sw $t3, 12($sp)
            sw $t4, 16($sp)
            sw $t5, 20($sp)
            sw $a1, 24($sp)
            sw $a2, 28($sp)
            
            # account_id = atoi(temp_buffer)
            move $a0, $a3
            jal atoi
            move $t6, $v0                   # t6 = account_id
            
            # Restore a2 for strtod call
            lw $a2, 28($sp)
            
            # balance = strtod(sub_buffer, &double_ptr)
            move $a0, $a2
            jal strtod
            mov.d $f2, $f0                  # f2 = balance
            
            # Allocate memory for new SavingsAccount (20 bytes)
            li $v0, 9
            li $a0, 20
            syscall
            move $t7, $v0                   # t7 = new account pointer
            
            # Store account pointer in array: account[count] = new_account_ptr
            lw $t3, 12($sp)                 # restore count
            sll $t8, $t3, 2                 # count * 4
            add $t8, $s1, $t8               # account + (count * 4)
            sw $t7, 0($t8)                  # account[count] = new_account_ptr
            
            # Call new_account(account_ptr, account_id, -1.0, balance)
            move $a0, $t7                   # account pointer
            move $a1, $t6                   # account_id
            li $t8, -1
            mtc1 $t8, $f12
            cvt.d.w $f12, $f12              # f12 = -1.0
            mov.d $f14, $f2                 # f14 = balance
            jal new_account
            
            # Restore all registers
            lw $t0, 0($sp)
            lw $t1, 4($sp)
            lw $t2, 8($sp)
            lw $t3, 12($sp)
            lw $t4, 16($sp)
            lw $t5, 20($sp)
            lw $a1, 24($sp)
            lw $a2, 28($sp)
            addi $sp, $sp, 32
            
            # Reload buffer addresses
            la $a1, read_buffer
            la $a2, sub_buffer
            la $a3, temp_buffer
            
            addi $t3, $t3, 1                # count++
            li $t5, 0                       # id_or_balance = 0
            j balance_iterator_update

    balance_charcter_is_newline_skip:
        # Character is not newline
        # sub_buffer[j] = current_charcter
        add $t9, $a2, $t4
        sb $t2, 0($t9)
        addi $t4, $t4, 1                    # j++

    balance_iterator_update:
        addi $t0, $t0, 1                    # i++
        j read_balance_file_loop
        
    read_balance_file_loop_exit:

    # Return values
    move $v0, $s1                           # v0 = account array pointer
    div $s2, $s2, 2
    move $v1, $s2                           # v1 = num_accounts
    
    # Restore saved registers
    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    addi $sp, $sp, 12
    
    jr $ra

strtod:
    # Arguments: a0 = string (format: "XXX.YY" - always 2 decimal places)
    # Returns: f0 = double value
    # t0 = i, t1 = current_char, t2 = temp addr, t3 = counter for strB
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t0, 0                               # i = 0
    la $a1, str_A
    la $a2, str_B
    
    strtod_find_decimal_loop:
        # Load the current_character
        add $t1, $a0, $t0                       # curr_addr = base_addr + i
        lb $t1, 0($t1)                          # load character
        
        # Check if we hit decimal point
        beq $t1, 0x2E, strtod_find_decimal_loop_exit  # '.' = 0x2E
        beqz $t1, strtod_find_decimal_loop_exit # null terminator (shouldn't happen)
        
        # Save character into strA
        add $t2, $a1, $t0
        sb $t1, 0($t2)
        
        addi $t0, $t0, 1                        # i++
        j strtod_find_decimal_loop
        strtod_find_decimal_loop_exit:
   
    # Add null terminator to strA
    add $t2, $a1, $t0
    sb $zero, 0($t2)
    
    addi $t0, $t0, 1                        # Skip the decimal point
    li $t3, 0                               # counter for strB
    
    strtod_get_second_loop:
        # Load the current character
        add $t1, $a0, $t0
        lb $t1, 0($t1)
        
        # Check for null terminator, space, or newline
        beqz $t1, strtod_get_second_loop_exit
        beq $t1, 0x20, strtod_get_second_loop_exit  # space
        beq $t1, 0x0A, strtod_get_second_loop_exit  # newline
        
        # Save into strB
        add $t2, $a2, $t3
        sb $t1, 0($t2)
        
        # Increment counters
        addi $t0, $t0, 1
        addi $t3, $t3, 1
        j strtod_get_second_loop
        strtod_get_second_loop_exit:
        
    # Add null terminator to strB
    add $t2, $a2, $t3
    sb $zero, 0($t2)
    
    # Call atoi for strA (integer part)
    move $a0, $a1
    jal atoi
    move $t0, $v0                           # t0 = integer part
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)

    # Call atoi for strB (decimal part)
    move $a0, $a2
    jal atoi
    move $t1, $v0                           # t1 = decimal part
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4

    # Convert integer part to double
    mtc1 $t0, $f0
    cvt.d.w $f0, $f0
    
    # Convert decimal part to double
    mtc1 $t1, $f2
    cvt.d.w $f2, $f2
    
    # Divide by 100 (since always 2 decimal places)
    li $t5, 100
    mtc1 $t5, $f4
    cvt.d.w $f4, $f4
    div.d $f2, $f2, $f4
    
    # Add integer and decimal parts
    add.d $f12, $f0, $f2
    
    li $v0, 3
    syscall
    
    li $v0, 11
    la $a0, 0x0A
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    


strcpy:
    # Arguments: a0 = string to copy into, a1 = string to copy from
    
    
    move $v0, $a0                           # save original dest for return
    
strcpy_loop:
    lb $t8, 0($a1)                          # load byte from src
    sb $t8, 0($a0)                          # store byte to dest
    # beqz $t8, strcpy_return                 # if null terminator, done
    beq $t8, 0x00, strcpy_return
    addi $a0, $a0, 1                        # advance dest
    addi $a1, $a1, 1                        # advance src
    j strcpy_loop

strcpy_return:
    jr $ra


atoi:
    or		$v0 , $0, $0		# $v0  = $0 | $0
    or		$t1, $0, $0		# $t1 = $0 | $0
    lb		$t0, 0($a0)		# 
    bne		$t0, '+', .isp	# if $t0 != '+' then goto .isp
    addi	$a0, $a0, 1			# $a0 = $a0 + 1
.isp:
    lb		$t0, 0($a0)		# 
    bne		$t0, '-', .num	# if $t0 != '-' then goto .num
    addi	$t1, $0, 1			# $t1 = $0 + 1
    addi	$a0, $a0, 1			# $a0 = $a0 + 1
.num:
    lb		$t0, 0($a0)		# 
    slti	$t2, $t0, 58			# $t2 = ($t0 < 58) ? 1 : 0
    slti	$t3, $t0, '0'			# $t3 = ($t0 <'0'0) ? 1 : 0
    beq		$t2, $0, .done	# if $t2 == $0 then goto .done
    bne		$t3, $0, .done	# if $t3 != $0 then goto .done
    sll		$t2, $v0, 1			# $t2 = $v0 << 1
    sll		$v0, $v0, 3			# $v0 = $v0 << 3
    add		$v0, $v0, $t2		# $v0 = $v0 + $t2
    addi	$t0, $t0, -48			# $t0 = $t0 + -48
    add		$v0, $v0, $t0		# $v0 = $v0 + $t0
    addi	$a0, $a0, 1			# $a0 = $a0 + 1  num++
    j .num

.done:
    beq		$t1, $0, .out	# if $t1 == $0 then goto .out
    sub		$v0, $0, $v0		# $v0 = $t0- $t2
.out:
    jr $ra

open_balance_error:
    li $v0, 4
    la $a0, open_balance_error_message
    syscall

    j end_program


# End program
end_program:
    li $v0, 10
    syscall