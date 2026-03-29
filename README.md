# 5-Stage Pipelined RISC Processor

A fully pipelined 32-bit RISC processor designed and implemented in Verilog.

## How It Was Made

Designed from scratch in Verilog with a modular structure. The processor implements a classic 5-stage pipeline: Fetch, Decode, Execute (ALU), Memory Access, and Write-Back. The datapath and control path are separate. Pipeline registers connect each stage, and the control unit generates all necessary control signals based on the decoded opcode.

## Processor Specifications

- 32-bit instruction and word size
- 16 general-purpose 32-bit registers (R0–R15)
- R15 is hardwired as the Program Counter, R14 is the return address register
- Separate instruction and data memories, word addressable
- Single instruction format: 6-bit opcode, 4-bit Rd, 4-bit Rs, 4-bit Rt, 14-bit immediate

## Supported Instructions

OR, ADD, SUB, CMP, ORI, ADDI, LW, SW, LDW (load double word), SDW (store double word), BZ, BGZ, BLZ, JR, J, CLL

## Features

- Full 5-stage pipeline
- Double-word load/store (LDW/SDW) handled over two consecutive clock cycles with pipeline stalling
- Exception detection for LDW/SDW with odd register numbers
- Branch and jump support with PC-relative target address calculation
- Testbench with instruction memory initialization for simulation-based verification
