


#t7 is the counter of the bracket delta

#
        .text
        .globl  main
main:
#
    #
        addi    $sp, $sp, -4
        sw      $ra, 0($sp)

        la $t0, tape
        sw $t0, ptr

        la $t1, code    # Load address of code into $t1
        jal execute     # Call execute subroutine

        j close


execute:
        lb $t2, ($t1)    # Load current instruction from code
        addi $t1, $t1, 1 # Move code pointer to next instruction

        # Switch statement to handle each Brainfuck instruction
        lw $t0, ptr      # Load current memory pointer into $t0
        la $t3, input    # Load address of input into $t3
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


        j close

inc_ptr:
        addi $t0, $t0, 1  # Increment pointer
        sw $t0, ptr       # Save updated pointer
        jr execute        # Jump back to execute subroutine
dec_ptr:
        addi $t0, $t0, -1 # Decrement pointer
        sw $t0, ptr       # Save updated pointer
        jr execute        # Jump back to execute subroutine

inc_byte:
        lb $t5, ($t0)     # Load byte at current memory location
        addi $t5, $t5, 1  # Increment byte
        sb $t5, ($t0)     # Store updated byte back into memory
        jr execute        # Jump back to execute subroutine

dec_byte:
        lb $t5, ($t0)     # Load byte at current memory location
        addi $t5, $t5, -1 # Decrement byte
        sb $t5, ($t0)     # Store updated byte back into memory

        jr execute        # Jump back to execute subroutine

output_byte:
        lb $a0, ($t0) # Load byte at current memory location
        li $v0, 11 # Set $v0 to 11 to indicate output
        syscall # Print byte to console
        jr execute # Jump back to execute subroutine

# LOOPING MECHANISMS

loop_start:
    #branch if the byte at the current memory location is zero
    beq     $t2, 0, front_loop

    jr execute
    

start_loop:
    jal incr_code
    j front_loop

front_loop:
        beq $t7, 0, execute

        lb $t2, ($t1)    # Load current instruction from code
        addi $t1, $t1, 1 # Move code pointer to next instruction

        # Instruction: "["
        beq $t2, 91, incr_code

        # Instruction: "]"
        beq $t2, 93, decr_code

        j front_loop



incr_code:
    addi $t7, $t7, 1
    jr front_loop

decr_code:
    addi $t7, $t7, -1
    jr front_loop


# END LOOPING STUFF

loop_end:
    #branch if the byte at the current memory location is zero
    beq     $t2, 0, execute

    j close_loop

    #branch if the byte at the current memory location is not zero


close_loop:

        beq $t7, 0, execute

        lb $t2, ($t1)    # Load current instruction from code
        addi $t1, $t1, -1 # Move code pointer to next instruction

    
        # Instruction: "["
        beq $t2, 91, incr_code

        # Instruction: "]"
        beq $t2, 93, decr_code

        j close_loop

close:

        #print over
        la $a0, over
        li $v0, 4
        syscall


    
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4
        jr      $ra
        .end    main

#
        .data
            over: .asciiz "\nover"
            newline:   .asciiz "\n"
            prompt: .asciiz "Enter a byte: "
            # code:   .asciiz "Hello World!"
            tape: .space 30 # allocate 30000 bytes for the tape
            ptr:    .word  0          # Pointer to current position in memory
            # code:   .asciiz "++>+++"  # Brainfuck code to execute
            input:  .space 1          # Allocate 1 byte for user input
            output: .space 1          # Allocate 1 byte for program output
            code: .asciiz "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."