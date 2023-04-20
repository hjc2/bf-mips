.data
my_string: .asciiz "Hello, world!"

.text
main:
    # Load address of string into register $t1
    la $t1, my_string
    
    # Initialize counter to 0
    li $t3, 0
    
    # Loop through string until null terminator is found
loop:
    lb $t2, ($t1)       # Load byte from memory
    beqz $t2, done      # If byte is zero, exit loop
    addi $t1, $t1, 1    # Increment memory address
    addi $t3, $t3, 1    # Increment counter
    j loop              # Repeat loop

done:
    # Print length of string
    move $a0, $t3       # Load counter into argument register
    li $v0, 1           # Load print integer syscall number
    syscall             # Print length of string
    
    # Exit program
    li $v0, 10          # Load exit syscall number
    syscall             # Exit program
