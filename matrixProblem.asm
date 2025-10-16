.data
# variables

aMatrix: .word 1, 2, 3                      # int aMatrix [row1][column1] = {{1, 2, 3},{4, 5, 6}};
         .word 4, 5, 6

bMatrix: .word 7, 8                         #int bMatrix [row2][column2] = {{7,8},{9,10},{11,12}};
         .word 9, 10
         .word 11, 12

row1: .word 2                               # # define row1 2
column1: .word 3                            # # define column1 3
row2: .word 3                               # # define row2 3
column2: .word 2                            # # define column2 2

prodMatrix: .word 0, 0
            .word 0, 0

# constants
DATA_SIZE = 4

# strings
notPossibleMessage: .asciiz "The number of rows in matrix 1 is not equal to the number of columns in matrix 2, thus matrix multiplication cannot be performed"
spacingCharcter: .asciiz "   "
newLine: .asciiz "\n"


.text

.globl main

main:

# Check if row1 and column2 are the same size.


la $a0, row1            
lw $t0, 0($a0)

la $a0, column2
lw $t1, 0($a0)

bne $t0, $t1, Row1NotEqualColumn2
# else

# load the first array
la $a0, aMatrix                             # load matrix 1 into function
la $a1, bMatrix                             # load matrix 2 into function

# Since row1 == column2 (otherwise it would have branched earlier), only has to use one address register for row1 and column2
lw $a2, column1                             # load 
lw $a3, row2

# Save row1, to stack
lw $t0, row1                                # load the value for row 1 into temp variable
subu $sp, $sp, 8                            # get stack ready (size: return address + row1)
sw $ra, 4($sp)                              # save return address to stack
sw $t0, 0($sp)                              # save t0 (row 1 size) to top of stack

# CLEARING t0, and t1 for easy test and analysis
move $t0, $zero
move $t1, $zero

# call function
jal matrixMultiplication 

# TESTING
li $v0, 4
la $a0, newLine
syscall


printProductMatrix:
    li $t0, 0                               # i = 0;
    la $a0, row1
    lw $t2, 0($a0)
    la $a0, column2
    lw $t3, 0($a0)
    la $a1, prodMatrix
    outerLoop:
        bge $t0, $t2, exitOuterLoop
        li $t1, 0
        innerLoop:
            bge $t1, $t2, exitInnerLoop
            # rowIndex * numCol + colIndex
            mul $t7, $t0, $t3
            add $t7, $t7, $t1

            # previous * data_size
            mul $t7, $t7, DATA_SIZE

            #prodMatrix[i][j]_addr = baseAdd_A + above
            add $t7, $a1, $t7

            # load value at prodMatrix[i][j]
            lw $t6, 0($t7)

            # Print value at prodMatrix[i][j]
            li $v0, 1
            move $a0, $t6
            syscall

            # Print spacing between matrix values
            li $v0, 4
            la $a0, spacingCharcter
            syscall

            addi $t1, $t1, 1
            j innerLoop
        exitInnerLoop:

        # print new line
        li $v0, 4
        la $a0, newLine
        syscall

        addi $t0, $t0, 1
        j outerLoop
    exitOuterLoop:


j endProgram


Row1NotEqualColumn2:
li $v0, 4
la $a0, notPossibleMessage
syscall

j endProgram

# --- No longer in main ---

# a0 = matrix1 address, a1 = matrix2 address, a2 = column1, a3 = row2
# t0 = i, t1 = j, t2 = k, t3 = row1, t4 = row2, t5 = column1, t6 = column2, t7 = temp
# row2 is never used, replace t5's use with 
matrixMultiplication:
    # load the arguments (really just load stack (row1), then duplicate for column2)
    lw $t3, 0($sp)                  # MIGHT WANT TO DO SOMETHING WITH STACK AFTER THIS

    # create a local column2 variable
    move $t6, $t3
    # move column1 and row2 to temp variables
    move $t4, $a2
    #move $t5, $a3

    # load the product Matrix
    la $a2, prodMatrix

    # Outermost loop
    li $t0, 0                               # int i = 0;

    outerMostLoop:
        bge $t0, $t3, outerMostExit         # if (i >= row1) {break;}

        li $t1, 0                           # int j = 0;
        mediumLoop:
            bge $t1, $t6, mediumLoopExit

            li $t2, 0                       # int k = 0;

            deepestLoop:
                bge $t2, $t4, deepestLoopExit    # if (k >= column1) {break;}

                # int temp = aMatrix[i][k] * bMatrix[k][j];
                # Equation = addr = base_addr + (rowInd * numCol + colInd) + DATA_SIZE

                # find matrixA's address at aMatrix[i][k]
            
                # rowIndex * numCol + colIndex
                mul $t8, $t0, $t4
                add $t8, $t8, $t2

                # previous * data_size
                mul $t8, $t8, DATA_SIZE

                # aMatrix[i][k]_addr = baseAdd_A + above
                add $a3, $a0, $t8

                # load value at aMatrix[i][k]
                lw $t7, 0($a3)

                # find matrixB's address at bMatrix[k][j]

                # rowIndex * numCol + colIndex
                mul $t8, $t2, $t6
                add $t8, $t8, $t1

                # previous * DATA_SIZE
                mul $t8, $t8, DATA_SIZE

                # bMatrix[i][k]_addr = baseAdd_B + above
                add $a3, $a1, $t8

                # load value at bMatrix[i][k]
                lw $t8, 0($a3)

                # temp = aMatrix[i][k] * bMatrix[k][j];
                mul $t7, $t7, $t8



                # productMatrix[i][j] = productMatrix[i][j] + temp;

                # productMatrix address

                # rowIndex * numCol + colIndex
                mul $t8, $t0, $t6
                add $t8, $t8, $t1

                # previous * DATA_SIZE
                mul $t8, $t8, DATA_SIZE

                # prodMatrix[i][j]_addr = base_add + previous
                add $a3, $a2, $t8

                # prodMatrix[i][j] = prodMatrix[i][j] + temp;
                lw $t8, 0($a3)              # get/load value at prodMatrix[i][j]
                add $t8, $t8, $t7           # prodMatrix[i][j] + temp
                sw $t8, 0($a3)              # save prodMatrix[i][j] + temp to prodMatrix[i][j]
                

                addi $t2, $t2, 1            # k = k + 1;
            j deepestLoop
            deepestLoopExit:

            addi $t1, $t1, 1                # j = j + 1;
        j mediumLoop
        mediumLoopExit:

        addi $t0, $t0, 1                    # i = i + 1;
        j outerMostLoop
    outerMostExit:

# Include some way of return. Might not needed if everything was saved.
j printProductMatrix

# End program
endProgram:

li $v0, 10
syscall
