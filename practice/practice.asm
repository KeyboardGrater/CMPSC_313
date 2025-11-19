.data
#variables
array: .word 1 2 3 4 5
#input: .word 

# strings
inputPrompt: .asciiz "Get Input"
newLine: .asciiz "\n"

.text

.globl main

main:

li $v0, 4
la $a0, inputPrompt
syscall

li $v0, 4
la $a0, newLine
syscall

li $t1, 0
li $t2, 4 
la $t3, array

printArray:
bgt $t1, $t2, exitPrintArray
    mul $t4, $t1, 4
    add $t5, $t3, $t4

    lw $t0, ($t5)

    li $v0, 1
    move $v0, $t0
    syscall

    addi $t1, $t1, 1
j printArray
exitPrintArray:

li $v0, 10
syscall