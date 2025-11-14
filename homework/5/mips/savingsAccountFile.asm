.data


# Structures
# typedef struct {
#     unsigned int account_number;          # 4 bytes
#     double annual_interest_rate;          # 8 bytes
#     double savings_balance;               # 8 bytes
# } SavingsAccount;                         # 4 + 8 + 8 = 20 bytes

# Array
decimal_array: .space 8                     # int * 2 = 8

# Test Data   

# Strings
new_balance_message: .asciiz "New Balance: "

.text
.globl main
main:
    # ---------------------- Initialization Part -----------------
    
    # First Open the file
    




    
    
# ------------------------------- Intalization End -------------------------------
    # s0 = account_1_addr, s1 = account_2_addr
    # f0 = new annual interest rate
    
    # Calculate the monthly interest

    # account 1
    move $a0, $s0
    jal calculate_monthly_interest

    # account 2
    move $a0, $s1
    jal calculate_monthly_interest

    # change annual interest rate
    l.d $f0, account_interest_update

    # save f0 to stack
    addi $sp, $sp, -4
    s.d $f0, 0($sp)

    move $a0, $s0
    mov.d $f12, $f0 
    jal set_interest_rate

    # pop stack for f0
    l.d $f0, 0($sp)
    addi $sp, $sp, 4

    move $a0, $s1
    mov.d $f12, $f0
    jal set_interest_rate

    # Print the new balances
    move $a0, $s0
    jal calculate_monthly_interest

    move $a0, $s1
    jal calculate_monthly_interest

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
    

# End program
end_program:
    li $v0, 10
    syscall