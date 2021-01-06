loop:
copy adder+1 pointer # put the "pointer" address in adder argument
adder: add 0 _1      # increase the value at the address
add pointer _1       # move the pointer to the next address
jz pointer resetloop # reset loop if pointer has wrapped
jmp loop

resetloop:
copy pointer origpointer # reset the pointer
copy outputter+1 pointer # put the "pointer" address in outputter argument
outputter: out 0 0       # output whatever "pointer" points to
jmp loop

origpointer: membase
pointer: membase
_1: 1
membase:
