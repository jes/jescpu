loop:
copy fib2 fib1
add fib2 fib0
out fib2 0
copy fib0 fib1
copy fib1 fib2
jmp loop

fib0: 1
fib1: 1
fib2: 2
