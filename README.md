# jescpu

*You probably don't want this.*

This is a tiny CPU to teach me a bit about Verilog, FPGAs, and CPU design.

The `Makefile` is suitable for writing it to my iceFUN iCE40-HX8k, probably not for much else, I have no idea.
It is derived from the iceFUN examples.

Also included are a very simple assembler and virtual machine written in Perl, and a couple of example programs
for the CPU.

## CPU architecture

An 8-bit CPU, and 8-bit address space. This means there are only 256 bytes of memory available.

There are no register operands, no immediate mode operands, and no indirect addressing. All operands are direct
addresses. In particular this means that to use pointers you need self-modifying code (i.e. rewrite the address of
the instruction to match the address that your pointer points to).

In theory it supports input and output of 1 byte at a time to/from 256 devices each, but no devices are actually
implemented.

It does not support interrupts, DMA, virtual memory, or under-privileged modes.

## Instruction set

All opcodes and operands are 1 byte each.

| Opcode | Mnemonic | Psuedocode |
| :----- | :------- | :--------- |
| 0      | `nop`      |            |
| 1      | `copy a b` | mem[a] = mem[b] |
| 2      | `add  a b`  | mem[a] += mem[b] |
| 3      | `sub  a b`  | mem[a] -= mem[b] |
| 4      | `xor  a b`  | mem[a] ^= mem[b] |
| 5      | `and  a b`  | mem[a] &= mem[b] |
| 6      | `or   a b`   | mem[a] \|= mem[b] |
| 7      | `not  a`    | mem[a] = ~mem[a] |
| 8      | `jmp  a`    | PC = a      |
| 9      | `jz   a b`   | if (mem[a] == 0) PC = b |
| 10     | `out  a b`  | output mem[a] to port b |
| 11     | `in   a b`   | input from port a to mem[b] |

## Contact

You can email james@incoherency.co.uk
