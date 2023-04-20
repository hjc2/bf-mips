.data
input_string: .space 20      # reserve space for input string
output_string: .asciiz "\nThe 4th character is: "  # message for output
output_string2: .asciiz "\nThe 7th character is: " # message for output

.text
main:
    li $v0, 8                  # system call to read string input
    la $a0, input_string       # load address of input string
    li $a1, 20                 # maximum length of input string
    syscall                    # call system to read input

    la $t0, input_string       # load address of input string into $t0
    addi $t1, $t0, 3           # add 3 to $t0 to get address of 4th character
    lbu $t2, ($t1)             # load the 4th character into $t2

    syscall                    # print message
    li $v0, 11                 # system call to print character
    move $a0, $t2              # load 4th character into $a0
    syscall                    # print the 4th character

    la $t3, input_string       # load address of input string into $t3
    addi $t4, $t3, 6           # add 6 to $t3 to get address of 7th character
    lbu $t5, ($t4)             # load the 7th character into $t5
    li $v0, 4                  # system call to print string
    la $a0, output_string2     # load address of output message
    syscall                    # print message
    li $v0, 11                 # system call to print character
    move $a0, $t5              # load 7th character into $a0
    syscall                    # print the 7th character

    li $v0, 10                 # system call to exit program
    syscall                    # exit
