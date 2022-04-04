# RISC-V_CPU

## Requirements

- Implement ALU and decoder module and make your codes be able to execute all RISC-V instructions.
- Verify the design using ModelSim

### Instruction Format

#### R-type

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/R-type.png">
</div>
<br>

#### I-type

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/I-type.png">
</div>
<br>

1. `Byte = 8 bits`
2. `Half-word = 16 bits`
3. LBU and LHU means load byte/half-word unsigned data.

#### S-type

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/S-type.png">
</div>
<br>
1. SB and SH means store lowest byte or half-word of rs2 to the memory

#### B-type

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/B-type.png">
</div>
<br>

#### U-type

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/U-type.png">
</div>
<br>

#### J-type

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/J-type.png">
</div>
<br>

### Homework Description

#### Module

##### top_tb module

“top_tb” is not a part of CPU, it is a file that controls all the program and verify the correctness of our CPU. The main features are as follows: send periodical signal CLK to CPU, set the initial value of IM, print the value of DM, end the program.

##### top module

“top” is the outmost module. It is responsible for connecting wires between CPU, IM and DM.
Here are the wires:
**※ The ordering of bytes is little-endian.**

- `instr_read` represents the signal whether the instruction should be read in IM.
- `instr_addr` represents the instruction address in IM.
- `instr_out` represents the instruction send from IM .
- `data_read` represents the signal whether the data should be read in DM.
- `data_write` has four signal, and every signal represents the byte of the data whether should be wrote in DM.
- `data_addr` represents the data address in DM.
- `data_in` represents the data which will be wrote into DM.
- `data_out` represents the data send from DM.

##### SRAM module

“SRAM” is the abbreviation of “Instruction Memory” (or “Data Memory”). This module saves all the instructions (or data) and send instruction (or data) to CPU according to request.

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/SRAM.png">
</div>
<br>

##### CPU module

“CPU” is responsible for connecting wires between modules, please design a RISC-V CPU by yourself. You can write other modules in other files if you need, but remember to include those files in CPU.v.

#### Reference Block Diagram

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/reference-block-diagram.png">
</div>
<br>

#### Register File

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/register-layout.png">
</div>
<br>

#### Test Instruction

##### Memory layout

<br>
<div align=center>
<img src="https://github.com/chiehwun/RISC-V_CPU/blob/main/img/memory-layout.png">
</div>
<br>

- `.text`: Store instruction code.
- `.init` & `.fini`: Store instruction code for entering & leaving the process.
- `.rodata`: Store constant global variable.
- `.bss` & `.sbss`: Store uninitiated global variable or global variable initiated as zero.
- `.data` & `.sdata`: Store global variable initiated as non-zero
- `.stack`: Store local variables

##### `setup.S`

This program start at “PC = 0”, execute function as followings:

1. Reset register file
2. Initial stack pointer and sections
3. Call main function
4. Wait main function return, then terminate program

##### `main.S`

This program start after setup.S, it will verify all RISC-V instructions (31 instructions).

##### `main0.hex` & `main1.hex` & `main2.hex` & `main3.hex`

Using the cross compiler of RISC-V to compile test program, and write result in verilog format. So you do not need to compile above program again.

#### Simulation Result
