# CMPS-3240-System-V-ABI-x86
Introduction to System V ABI calling convention in x86 GAS assembly language

# Introduction

## Objectives

* Learn how to pass arguments in x86
* Learn how to set up a stack for a callee subroutine in x86


## Prerequisites

* Knowledge of how x86 registers are structured (`rax` vs. `eax` vs. `ax`, etc.)
* Jumping and `cmp` instructions in x86

## Requirements

### General

* A recursive solution to Fibonacci (not iterative)

### Software

This lab requires `gcc`, `make`, and `git`.

### Compatability

| Linux | Mac | Windows |
| :--- | :--- | :--- |
| `odin.cs.csubak.edu`<sup>*</sup> | No | No |

<sup>*</sup>Different OS (kernel versions) and compilers will generate different assembly codes. You must use the departmental server for this lab.

## Background

Clone the lab and change into the directory:

```shell
$ https://github.com/DrAlbertCruz/CMPS-3240-System-V-ABI-x86.git
$ cd CMPS-3240-System-V-ABI-x86
```

The makefile will create three files, some x86 assembly code to understand how arguments are passed between function calls, and a working executable to calculate 13!. Execute the all target in the makefile, and take a look at `example_arguments.s`:

```shell
$ make
...
$ vim example_arguments.s
```

A *calling convention* is a convention that defines how arguments are passed between function calls, how the stack should be ordered, and which registers should be used for what. Linux uses something called *System V ABI*. When calling a function the *caller* does the following:

1. Places arguments in the registers, in an order according to the calling convention. If there are not enough registers, the arguments are placed in order onto the stack before jumping.
1. Jump to the function

The function that is called, called the *callee*, does the following:

1. Creates stack space for the scope of the function call
1. Shadows the input arguments onto the stack (this may or may not happen according to the compiler or the calling convention)
1. Completes its intended purpose
1. Reverts the values of any registers that are deemed *saved*. Saved registers are defined by the calling convention, and should hold there value before and after a function call. It is up to the callee to revert any changes to saved registers. We may not need saved registers for this lab.
1. Pop the stack. If this is `main()`, use `leave`, otherwise manually restore the stack and base pointers with addition commands.

We will be most concerned with how arguments are passed back and forth between calls. The function in `example_arguments.s` has a function that takes 10 arguments. Only 6 registers are defined as argument registers, so the other 4 arguments must be placed onto the stack. Study the code, and the following table that explains where the arguments are located:

| Argument | R or S? | Location in x86 |
| :--- | :--- | :--- |
| First | Register | `%edi` (Based on size) |
| Second | Register | `%esi` |
| Third | Register | `%edx` |
| Fourth | Register | `%ecx` |
| Fifth | Register | `%r8d`<sup>*</sup> |
| Sixth | Register | `%r9d`<sup>*</sup> |
| Seventh | Register | `40(%rbp)` |
| Eighth | Register | `32(%rbp)` |
| Nineth | Register | `24(%rbp)` |
| Tenth | Register | `16(%rbp)` |

<sup>*</sup>See https://stackoverflow.com/questions/1753602/what-are-the-names-of-the-new-x86-64-processors-registers for an explanation of how the naming convention changes with registers r8-r15

Note that once you exceed the capacity of the registers, arguments are passed on the stack but in *reverse* order. Once you're comfortable with the idea of passing arguments through registers, move on to the next section.

# Approach

## Part 1 - Recursive factorial

First, a stack is created:

```x86
pushq   %rbp
movq    %rsp, %rbp
subq    $16, %rsp
```

at this point, `$16` is a very common literal. This must be an operating system requirement to either increment by at least 16 bytes, or have the stack aligned in units of 16 bytes. Note that the argument `arg` is passed through `%edi`, and it's value is saved onto the stack (as one of the first instructions):

```x86
movl    %edi, -4(%rbp)
```

This was not given at the C-language-level, but it makes sense given that the idea of scope should persist before and after a call to `my_fact`. Each call will have it's own version of the input argument. The argument will now be located in `-4(%rbp)` for the remainder of the function call. The first C-language-level code that we specified was a check to see if the input argument was less than or equal to 1:

```x86
cmpl    $1, -4(%rbp)
jg  .L4
```

This code compares the argument we shadowed into `-4(%rbp)`. *You could have also used `%edi` as the second argument at this point but the compiler either chose to or did not do this optimization.* `cmpl` carries out the comparison and `jg` jumps if it is greater. In this case, a jump is performed if the input argument is greater than `$1`. Thus, the fall-through block is the block that must `return 1`:

```x86
movl    $1, %eax
jmp .L5
```

By convention all return values are passed through the `%eax` register according to System V ABI. `jmp` is an unconditional jump, so `.L5` must be some clean up instructions to return to the callee that are shared by both the `if` and `else` blocks. We will cover that when we get to it. `.L4` must be the start of the else block that contains a recursive call to `my_fact`:

```x86
.L4:
movl    -4(%rbp), %eax
subl    $1, %eax
movl    %eax, %edi
call    my_fact
imull   -4(%rbp), %eax
```

This block of code is a prime example of how the compiler does not optimize the code well:
* The input argument is shadowed into `%eax`
* `%eax` is decremented by 1
* `%eax` is copied into the argument register `%edi`
* Call to `my_fact`
* Multiply `-4(%rbp)` (the argument) with `%eax` (result of call to `my_fact( arg - 1 )`)
It would have been better to copy `-4(%rbp)` directly into `%edi` rather than waste an instruction on `%eax`.

The last few lines of code are:

```x86
.L5:
leave
ret
```

Recall that `leave` will pop the stack for you. In MIPS, you have to do this manually with an `add` instruction.

## Part 2 - Recursive Fibonacci

Your task for this lab is to modify the code at the assembly level to calculate fibonacci numbers, rather than factorials.

* You must have done this in x86
* The makefile is missing the target to assemble something from a `.s` file, so borrow that from the appropriate lab
* I recommend the following logic for the base cases:
```c
if ( arg < 1 )
   return 1;
else
   return fib( n - 1 ) + fib ( n - 2 );
```
but you can do this lab however you like so long as it works.

# Check off

Demonstrate that the function now returns the 13-th Fibonacci number instead. This must have been completed in x86.
