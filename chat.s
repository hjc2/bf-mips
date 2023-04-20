

# t0 is the memory pointer
# t1 is the instruction pointer
# t2 is the current instruction
# t3 is the counter (only used when counting the length of the instruction string)
# t4 is the output pointer
# t5 is the current tape value
# t6 is the instruction delta
# t7 is the counter of the bracket delta

# s0 is the length of the string

        .text
        .globl  main
main:

        addi    $sp, $sp, -4
        sw      $ra, 0($sp)

        la $t0, tape
        sw $t0, ptr

        la $t1, code    # Load address of code into $t1
        la $t7, code
    
        # Initialize counter to 0
        li $t3, 0
        
        j loop

    # Loop through string until null terminator is found
loop:
        lb $t2, ($t7)       # Load byte from memory
        beqz $t2, done      # If byte is zero, exit loop
        addi $t7, $t7, 1    # Increment memory address
        addi $t3, $t3, 1    # Increment counter
        j loop              # Repeat loop

done:
        # Print length of string
        move $s0, $t3       # Load counter into argument register
        jal execute     # Call execute subroutine
        j close


# main loop for program control
execute:
        lb $t2, ($t1)    # Load current instruction from code

        # Switch statement to handle each Brainfuck instruction
        lw $t0, ptr      # Load current memory pointer into $t0
        la $t4, output   # Load address of output into $t4

        # Instruction: ">"
        beq $t2, 62, inc_ptr

        # Instruction: "<"
        beq $t2, 60, dec_ptr

        # Instruction: "+"
        beq $t2, 43, inc_byte

        # Instruction: "-"
        beq $t2, 45, dec_byte

        # Instruction: "."
        beq $t2, 46, output_byte

        # Instruction: "["
        beq $t2, 91, loop_start

        # Instruction: "]"
        beq $t2, 93, loop_end

        bge $t6, $s0, execute
        # # safe exit on unrecognized token

        j pre_loop
        # j pre_loop

pre_loop:
        addi $t1, $t1, 1 # Move code pointer to next instruction
        addi $t6, $t6, 1

        j execute

# move tape right ">"
inc_ptr:
        addi $t0, $t0, 1 # INCR
        sw $t0, ptr # save PTR
        j pre_loop 

# move tape left"<"
dec_ptr:
        addi $t0, $t0, -1 # DECR
        sw $t0, ptr # save PTR
        j pre_loop 

# INCR tape value "+"
inc_byte:
        lb $t5, ($t0)
        addi $t5, $t5, 1
        sb $t5, ($t0) # save tape
        jr pre_loop

# DECR tape value "-"
dec_byte:
        lb $t5, ($t0)
        addi $t5, $t5, -1 
        sb $t5, ($t0) # save tape
        j pre_loop

# OUTPUT tape value "."
output_byte:
        lb $a0, ($t0)
        li $v0, 11
        syscall
        j pre_loop

# OPEN BRACKET [

loop_start:
    lb $t5, ($t0) # load tape value
    beq $t5, $zero, front # in the case that the tape symbol is 0, initiate the loop
    j pre_loop # if not 0, continue to next instruction


front:
    #set register 7 to 1
    li $t7, 1
    j open_loop

open_loop:
        
        beq $t7, $zero, pre_loop # if brackets have been matched, exit loop

        addi $t1, $t1, 1 # move ptr to next instruction
        addi $t6, $6, 1 # increment counter
        lb $t2, ($t1)    # load the instruction

        # counting additional open bracket
        beq $t2, 91, open_front

        # counting additional close bracket
        beq $t2, 93, close_front

        j open_loop # if not a bracket, continue to next instruction

open_front: # adds to the counter of the bracket delta
    addi $t7, $t7, -1
    j open_loop

close_front: # subtracts from the counter of the bracket delta
    addi $t7, $t7, 1
    j open_loop


# CLOSE BRACKET ]

loop_end:
    lb $t5, ($t0)
    li $t7, 1
    bne $t5, $zero, rear_loop
    j pre_loop

rear_loop:
        ble $t7, $zero, pre_loop

        addi $t1, $t1, -1 # Move code pointer to next instruction
        addi $t6, $t6, -1 #move counter down
        lb $t2, ($t1)    # Load current instruction from code
        # Instruction: "["
        beq $t2, 91, open_back
        # Instruction: "]"
        beq $t2, 93, close_back
        j rear_loop

open_back:
    addi $t7, $t7, -1
    j rear_loop

close_back:
    addi $t7, $t7, 1 
    j rear_loop

close:
        #prints command that program has exited
        la $a0, over
        li $v0, 4
        syscall

        lw      $ra, 0($sp)
        addi    $sp, $sp, 4
        jr      $ra
        .end    main

        .data
            newline:   .asciiz "\n"
            over: .asciiz "\nexited"
            tape: .space 300000        # size of the tape memory
            ptr:    .word  0          # Pointer to current position in memory
            output: .space 1          # Allocate 1 byte for program output
        #     code: .asciiz "++++++++++[->+++>+++++++>++++++++++>+++++++++++>++++++++++++<<<<<]>>+++.<++.>>>++.<+++++.>++++.>+.<<<<.>>>.<-.---.<<.>>+.>-----..---.<<<+."
        #     code: .asciiz ">><<"
        #     code: .asciiz "+++++[->----[---->+<]>++.-[++++>---<]>.++.---------.+++.[++>---<]>--.++[->+++<]>.+++++++++..---.+++++++.+[-->+++++<]>-.<]"
            code: .asciiz "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>." #hello world



