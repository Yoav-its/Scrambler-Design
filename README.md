# Scrambler-Design

&#x20;guided by iddo

# Scrambler Design Project



This repository contains the RTL (SystemVerilog) implementation of a hardware Scrambler system.



\## Motivation

The primary purpose of this project is to scramble (randomize) incoming data bits. In digital communication, it is crucial that the receiving component does not get a long, continuous string of identical bits (e.g., all zeros or all ones). Scrambling the bits prevents this, helping the receiver maintain proper clock synchronization.



\## Core Modules

The project is built hierarchically and includes the following main processing blocks:

\* \*\*`scrambler\_16bit`\*\*: Implements the scrambling logic for a 16-bit data path.

\* \*\*`scrambler\_64bit`\*\*: Implements the scrambling logic for a 64-bit data path.

\* \*\*`bit16to64`\*\*: A parallel-to-parallel converter module that acts as a bridge. It buffers the 16-bit output from the first stage and converts it into a 64-bit wide bus for the next stage.



\## Supporting Files

\* `scrambler\_top.sv` - The top-level wrapper integrating all modules.

\* `lfsr.sv`, `xor\_logic.sv` - Core scrambling logic components.

\* `input\_sampler.sv`, `clock\_divider.sv`, `enable\_logic.sv` - System timing, logic enables, and sampling control.

