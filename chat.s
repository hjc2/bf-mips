
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
        # addi $t1, $t1, 1 # Move code pointer to next instruction

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


pre_loop:
        addi $t1, $t1, 1 # Move code pointer to next instruction

        j execute

inc_ptr:
        addi $t0, $t0, 1  # Increment pointer
        sw $t0, ptr       # Save updated pointer
        j pre_loop        # Jump back to execute subroutine
dec_ptr:
        addi $t0, $t0, -1 # Decrement pointer
        sw $t0, ptr       # Save updated pointer
        j pre_loop        # Jump back to execute subroutine

inc_byte:
        lb $t5, ($t0)     # Load byte at current memory location
        addi $t5, $t5, 1  # Increment byte
        sb $t5, ($t0)     # Store updated byte back into memory
        jr pre_loop        # Jump back to execute subroutine

dec_byte:
        lb $t5, ($t0)     # Load byte at current memory location
        addi $t5, $t5, -1 # Decrement byte
        sb $t5, ($t0)     # Store updated byte back into memory
        j pre_loop        # Jump back to execute subroutine

output_byte:
        lb $a0, ($t0) # Load byte at current memory location
        li $v0, 11 # Set $v0 to 11 to indicate output
        syscall # Print byte to console
        j pre_loop # Jump back to execute subroutine

# FRONT BRACKET HANDLING


        # elif(code[instruction] == "["): // loop start
        #     if(tape[index] == 0): // front loop
        #         paren = 1
        #         while paren > 0: // open loop
        #             instruction += 1
        #             if(code[instruction] == "]"): #open front
        #                 paren -= 1
        #             elif(code[instruction] == "["): #close front
        #                 paren += 1


        #         instruction += 1 #end open
        #     else:
        #         instruction += 1

loop_start:
    #if tape index is 0
    lb $t5, ($t0)
    beq $t5, $zero, front
    j pre_loop


front:
    #set register 7 to 1
    li $t7, 1
    j open_loop

open_loop:
        
        beq $t7, $zero, pre_loop

        addi $t1, $t1, 1 # Move code pointer to next instruction
        lb $t2, ($t1)    # Load current instruction from code

        # Instruction: "["
        beq $t2, 91, open_front

        # Instruction: "]"
        beq $t2, 93, close_front

        j open_loop

open_front:
    addi $t7, $t7, -1
    j open_loop

close_front:
    addi $t7, $t7, 1
    j open_loop




# CLOSE BRACKET HANDLING

        # elif(code[instruction] == "]"):
        #     if(tape[index] != 0):
        #         paren = 1
        #         while paren > 0:
        #             instruction -= 1
        #             if(code[instruction] == "["):
        #                 paren -= 1
        #             if(code[instruction] == "]"):
        #                 paren += 1
        #     else:
        #         instruction += 1
        # else:
        #     instruction += 1

loop_end:
    #if tape index is 0
    lb $t5, ($t0)
    bne $t5, $zero, back
    j pre_loop

back:
    #set register 7 to 1
    li $t7, 1
    j rear_loop

rear_loop:
        ble $t7, $zero, pre_loop

        addi $t1, $t1, -1 # Move code pointer to next instruction
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
            tape: .space 30000 # allocate 30000 bytes for the tape
            ptr:    .word  0          # Pointer to current position in memory
            input:  .space 1          # Allocate 1 byte for user input
            output: .space 1          # Allocate 1 byte for program output
            # code: .asciiz "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
            # code: .asciiz "++++++++++[->+++>+++++++>++++++++++>+++++++++++>++++++++++++<<<<<]>>+++.<++.>>>++.<+++++.>++++.>+.<<<<.>>>.<-.---.<<.>>+.>-----..---.<<<+."
            code: .asciiz "+++++[->----[---->+<]>++.-[++++>---<]>.++.---------.+++.[++>---<]>--.++[->+++<]>.+++++++++..---.+++++++.+[-->+++++<]>-.<]"
            # code: .asciiz "+++++++++++>+>>>>++++++++++++++++++++++++++++++++++++++++++++>++++++++++++++++++++++++++++++++<<<<<<[>[>>>>>>+>+<<<<<<<-]>>>>>>>[<<<<<<<+>>>>>>>-]<[>++++++++++[-<-[>>+>+<<<-]>>>[<<<+>>>-]+<[>[-]<[-]]>[<<[>>>+<<<-]>>[-]]<<]>>>[>>+>+<<<-]>>>[<<<+>>>-]+<[>[-]<[-]]>[<<+>>[-]]<<<<<<<]>>>>>[++++++++++++++++++++++++++++++++++++++++++++++++.[-]]++++++++++<[->-<]>++++++++++++++++++++++++++++++++++++++++++++++++.[-]<<<<<<<<<<<<[>>>+>+<<<<-]>>>>[<<<<+>>>>-]<-[>>.>.<<<[-]]<<[>>+>+<<<-]>>>[<<<+>>>-]<<[<+>-]>[<+>-]<<<-]"