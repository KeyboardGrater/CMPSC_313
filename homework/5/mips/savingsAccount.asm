.data

# Structures
# typedef struct {
#     unsigned int account_number;          # 4 bytes
#     double annual_interest_rate;          # 8 bytes
#     double savings_balance;               # 8 bytes
# } SavingsAccount;                         # 4 + 8 + 8 = 20 bytes

# Test Data   
account_1_interest: .double 0.03
account_1_balance: .double 2000.00
account_2_interest: .double 0.03
account_2_balance: .double 3000.00

account_interest_update: .double 0.04



# Strings

.text
.globl main
main:
    # ---------------------- Initialization Part -----------------
    # Test Data: t0 (account_1.1) = 1, t1 (account_2.1) = 2
    # Test Data: f0 (account_1.2) = 0.03, f2 (account_1.3) = 2000.00, f4 (account_2.2) = 0.03, f6 (account_2.3) = 3000.00
    # Test Data: f8 (both interest rate change) = 0.04
    # s0 = account_1, s1 = account_2

    # load test_values
    li $t0, 1
    li $t1, 2
    
    l.d $f0, account_1_interest
    l.d $f2, account_1_balance
    l.d $f4, account_2_interest
    l.d $f6, account_2_balance

    # Declare the objects
    
    # account_1
    # Allocate memory (20 bytes = int + double + double = 4 + 8 + 8 = 20)
    li $v0, 9
    la $a0, 20
    syscall
    move $s0, $v0                           # save the starting addr of the struct to s0


    # Call constructor 
    move $a0, $s0                           # load account_1_addr into argument
    move $a1, $t0                           # load account_1's id into second argument              
    mov.d $f12, $f0                         # load account_1's annual_interest_rate into third argument
    mov.d $f14, $f2                         # load account_1's balance into fourth argument
    jal new_account

    # account_2
    # Allocate memory
    li $v0, 9
    la $a0, 20
    syscall
    move $s1, $v0

    # Call constructor
    move $a0, $s1
    move $a1, $t1
    mov.d $f12, $f4
    mov.d $f14, $f6
    jal new_account
    
# ------------------------------- Intalization End -------------------------------

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

# End program
end_program:
    li $v0, 10
    syscall