

#
# template assembly file
#
        .text
        .globl  main
main:
#
# opening linkage (save return address)
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

        # Instruction: ","
        beq $t2, 44, input_byte

        # Instruction: "["
        beq $t2, 91, loop_start

        # Instruction: "]"
        beq $t2, 93, loop_end

        # Exit subroutine if instruction is not recognized
        jr $ra


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

input_byte:
        li $v0, 8 # Set $v0 to 8 to indicate input
        la $a0, input # Load address of input into $a0
        li $a1, 1 # Load size of input into $a1
        syscall # Read user input into input variable
        sb $a0, ($t0) # Store user input into current memory location
        jr execute # Jump back to execute subroutine

loop_start:
    lb $t5, ($t0) # Load byte at current memory location
    beq $t5, $zero, skip_loop

# Otherwise, push loop start address onto the stack and continue
    addi $sp, $sp, -4 # Allocate space on the stack for return address
    sw $t1, ($sp) # Store loop start address on the stack
    jr execute # Jump back to execute subroutine

skip_loop:
    li $t6, 1 # Set loop counter to 1

# Loop through code until matching loop end is found
loop:
    lb $t2, ($t1) # Load current instruction from code
    addi $t1, $t1, 1 # Move code pointer to next instruction
    # If instruction is another loop start, increment loop counter
    beq $t2, 91, inc_loop

    # If instruction is a loop end and the loop counter is 1, exit loop
    beq $t2, 93, exit_loop

# If instruction is a loop end and the loop counter is not 1, decrement loop counter
dec_loop:
  lb $t5, ($t0)   # Load byte at current memory location
  addi $t6, $t6, -1 # Decrement loop counter
  beq $t6, $zero, skip_loop # If loop counter is zero, exit loop
  jr loop         # Otherwise, continue looping

# If instruction is not a loop end, jump back to the beginning of the loop
inc_loop:
  beq $t2, 91, inc_loop
  addi $t6, $t6, 1 # Increment loop counter
  jr loop


exit_loop:
    lw $t1, ($sp) # Load loop start address from the stack
    addi $sp, $sp, 4 # Deallocate space on the stack
    jr execute # Jump back to execute subroutine

loop_end:
    lb $t5, ($t0) # Load byte at current memory location
    beq $t5, $zero, execute # If byte is zero, continue execution

    # Otherwise, jump back to loop start
    lw $t1, ($sp) # Load loop start address from the stack
    jr execute # Jump back to execute subroutine
    
# codes END here
#

#
# closing linkage (get return address and restore stack pointer)
#
close:
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4
        jr      $ra
        .end    main
#
# area for variables and constants
#
        .data
            newline:   .asciiz "\n"
            # code:   .asciiz "Hello World!"
            tape: .space 30000 # allocate 30000 bytes for the tape
            ptr:    .word  0          # Pointer to current position in memory
            code:   .asciiz "[->+<]"  # Brainfuck code to execute
            input:  .space 1          # Allocate 1 byte for user input
            output: .space 1          # Allocate 1 byte for program output
