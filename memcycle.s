loop:
copy adder+1 pointer
adder: add 0 _1      # increase the value at the address
add pointer _1       # move the pointer to the next address
jz pointer resetloop # reset loop if pointer has wrapped
jmp loop
resetloop:
copy pointer origpointer
jmp loop

origpointer: membase
pointer: membase
_1: 1
_255: 0xff
membase:
