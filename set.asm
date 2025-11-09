.data
# Global Varibales (Constant)
INTEGERSET_ARRAY_SIZE = 100                 # enum {INTEGERSET_ARRAY_SIZE = 100};


# Strings 

operation_prompt: .asciiz "Please pick a operation to perform.\n1: Union of two sets\n2: Intersection of two sets\n3: Insertion on a set\n4: Deletion on a set\n5: Print a set\n6: Check to see if two sets are equal\n7: Exit\n\n"
which_array_prompt: .asciiz "Which array would you like to chose.\nFor array one enter 1, for array two, enter 2. And if you would like to go back, enter 3.\n"
number_to_modify_prompt: .asciiz "Please pick a number between 0 - 99\n"
false_message: .asciiz "False\n"
true_message: .asciiz "True\n"


.text
.globl main


main:









# End program
endProgram:
    li $v0, 10
    syscall