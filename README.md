#  Scrambler Design Project



![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-000080.svg)

![Quartus Prime](https://img.shields.io/badge/Synthesis-Quartus\_Prime-blue.svg)



This repository contains the RTL (SystemVerilog) implementation of a hardware Scrambler system. 



## 🎯 Motivation

The primary purpose of this project is to scramble (randomize) incoming data bits. In digital communication, it is crucial that the receiving component does not get a long, continuous string of identical bits (e.g., all zeros or all ones). Scrambling the bits prevents this, helping the receiver maintain proper clock synchronization.



## 🧩 Core Modules

The project is built hierarchically and includes the following main processing blocks:



* **`scrambler_16bit`**: Implements the scrambling logic for a 16-bit data path.

* **`scrambler_64bit`**: Implements the scrambling logic for a 64-bit data path.

* **`bit16to64`**: A parallel-to-parallel converter module that acts as a bridge. It buffers the 16-bit output from the first stage and converts it into a 64-bit wide bus for the next stage.



## 📁 Supporting Files

* **`scrambler_top.sv`**: The top-level wrapper integrating all modules securely.

* **`lfsr.sv`, `xor_logic.sv`**: Core scrambling logic components.

* **`input_sampler.sv`, `clock_divider.sv`, `enable_logic.sv`**: System timing, logic enables, and sampling control.



## 🛠️ Synthesis \& Verification

The design has been successfully compiled and synthesized using \*\*Quartus Prime\*\* with zero errors. 

* **Timing Analysis**: Constraints were applied via an SDC file to verify maximum frequency (Fmax) capabilities, ensuring the critical path is highly efficient.

* **RTL Verification**: The hardware translation was deeply analyzed using the Quartus RTL Viewer to ensure components like shift registers, multiplexers, and XOR logic blocks were synthesized precisely as intended.

