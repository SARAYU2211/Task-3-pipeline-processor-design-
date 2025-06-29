# 4-Stage Pipelined Processor (Verilog)

## Overview
This project implements a simple 4-stage pipelined processor in Verilog, supporting basic instructions: **ADD**, **SUB**, **AND**, and **LOAD**. The design demonstrates instruction pipelining, with explicit pipeline registers between each stage.

## Pipeline Stages
1. **IF (Instruction Fetch):** Fetches instruction from memory.
2. **ID (Instruction Decode):** Decodes instruction and reads operands from registers.
3. **EX (Execute):** Performs arithmetic/logic operation or calculates memory address.
4. **WB (Write Back):** Writes results to the register file.

## Supported Instructions
- `ADD`: Register addition
- `SUB`: Register subtraction
- `AND`: Bitwise AND
- `LOAD`: Load value from memory into register

## File Structure

- `pipelined_processor.v` – Main processor module
- `testbench.v` – Testbench for simulation
- `README.md` – Project documentation

## How to Simulate

1. **Open the files in your Verilog simulator (ModelSim, Vivado, Icarus Verilog, etc.).**
2. **Compile both `pipelined_processor.v` and `testbench.v`.**
3. **Run the simulation.**
4. **Observe the output to see the state of each pipeline stage and register values on each clock edge.**

## Sample Output

The simulation will print the state of the pipeline (IF, ID, EX, WB) and key register values at each clock cycle, letting you observe correct pipelined execution.

## Customization

- You can modify the initial values in the instruction or data memory in `pipelined_processor.v` to test different programs.
- Add more instructions or features as needed for your coursework or experiments
