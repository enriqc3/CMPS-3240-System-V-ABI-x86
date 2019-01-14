# CMPS-3240-System-V-ABI-x86
Introduction to System V ABI calling convention in x86 GAS assembly language

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

