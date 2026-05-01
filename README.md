# BRAM
Verification of BRAM using UVM

## DUAL PORT BRAM – DESIGN SPECIFICATION

1. OVERVIEW

This module implements a **true dual-port Block RAM (BRAM)** optimized for FPGA synthesis.
Both ports operate independently with separate clocks and support concurrent read/write access.

The design follows **BRAM inference templates**, ensuring efficient mapping to FPGA block memory resources.

---

2. KEY FEATURES

* True dual-port BRAM (independent Port A & Port B)
* Separate clocks for each port
* Synchronous read operation
* Byte-enable support for partial writes
* BRAM inference friendly coding style
* Parameterized data width and depth
* Supports dual-clock operation

---

3. PARAMETERS

Parameter Name : DATA_WIDTH
Description    : Width of data bus in bits
Default Value  : 32

Parameter Name : ADDR_WIDTH
Description    : Address width (Depth = 2^ADDR_WIDTH)
Default Value  : 8

---

4. MEMORY ORGANIZATION

* Depth       : 2^ADDR_WIDTH
* Word Size   : DATA_WIDTH bits
* Byte Width  : DATA_WIDTH / 8

Memory declaration:
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

---

5. PORT INTERFACE

PORT A

clk_a   : Input  : Clock
en_a    : Input  : Enable
we_a    : Input  : Write enable
be_a    : Input  : Byte enable
addr_a  : Input  : Address
din_a   : Input  : Write data
dout_a  : Output : Read data

PORT B

clk_b   : Input  : Clock
en_b    : Input  : Enable
we_b    : Input  : Write enable
be_b    : Input  : Byte enable
addr_b  : Input  : Address
din_b   : Input  : Write data
dout_b  : Output : Read data

---

6. FUNCTIONAL BEHAVIOR

WRITE OPERATION

A write occurs on the rising edge of the clock when:
en_x = 1 and we_x = 1

* Byte enable controls per-byte updates
* Only enabled bytes are written

---

READ OPERATION

* Reads are synchronous
* Data appears after one clock cycle
* Read occurs when:
  en_x = 1

---

READ-DURING-WRITE BEHAVIOR

This implementation follows:

* If read and write occur to the same address:

  * Old data is returned on the output
  * New data is written to memory

---

7. CLOCKING SCHEME

* Port A and Port B operate on independent clocks
* Supports:

  * Same clock operation
  * Asynchronous dual-clock operation

---

8. CONCURRENT ACCESS BEHAVIOR

Different addresses:

* Fully independent operation

Same address, both read:

* Safe

Same address, one write:

* Output depends on BRAM mode (READ-FIRST here)

Same address, both write:

* Undefined behavior

---

9. BYTE ENABLE LOGIC

Byte-level write:

mem[addr][8*i +: 8] <= din[8*i +: 8] (if be[i] = 1)

Allows:

* Byte updates
* Half-word writes
* Efficient memory usage

---

10. RESET BEHAVIOR

* No reset implemented
* BRAM contents undefined at power-up unless initialized

---

11. SYNTHESIS NOTES

* Infers FPGA Block RAM (BRAM)

* Uses vendor-friendly coding style

* Attribute used:
  (* ram_style = "block" *)

* Tools supported:

  * Xilinx Vivado
  * Intel Quartus

---

12. LIMITATIONS

* No collision handling for same-address writes
* No ECC or parity support
* No initialization file

---

13. USE CASES

* FPGA memory buffers
* Register files
* AXI BRAM backends
* Dual-clock data sharing
* Cache storage

---

---

14. TIMING DIAGRAMS & WAVEFORMS

---

NOTE:

* All operations occur on rising clock edge
* BRAM mode = READ-FIRST (OLD DATA)

---

14.1 WRITE OPERATION (PORT A)

Condition: en_a = 1, we_a = 1

Time --->

clk_a    :  ***/‾‾‾_**/‾‾‾_*_
↑        ↑

en_a     :  ----1--------1------
we_a     :  ----1--------1------
addr_a   :  ----A0-------A1-----
din_a    :  ----D0-------D1-----

mem[A0]  :  ----OLD------D0-----
mem[A1]  :  --------OLD------D1-

dout_a   :  ----OLD------OLD----

Explanation:

* Write happens at clock edge
* Output still shows OLD data (READ-FIRST)

---

14.2 READ OPERATION

Condition: en_a = 1, we_a = 0

Time --->

clk_a    :  ***/‾‾‾_**/‾‾‾_*_
↑        ↑

addr_a   :  ----A0-------A1-----

mem      :       D0       D1

dout_a   :  ----X--------D0-----

Explanation:

* 1-cycle latency
* First output is undefined

---

14.3 READ-DURING-WRITE (SAME ADDRESS)

Condition: en_a = 1, we_a = 1

Time --->

clk_a    :  _**/‾‾‾_**
↑

addr_a   :  ----A0-----
din_a    :  ----DNEW---

mem[A0]  :  ----OLD----DNEW

dout_a   :  ----OLD----------

Explanation:

* Output shows OLD data
* Memory updated with NEW data

---

14.4 DUAL PORT PARALLEL ACCESS

Time --->

clk_a    :  ***/‾‾‾_***___
↑

clk_b    :  ___***/‾‾‾_***
↑

Port A: WRITE
addr_a   : ----A0-----
din_a    : ----D0-----

Port B: READ
addr_b   : ----B0-----

dout_b   : ----X---DATA(B0)

Explanation:

* True parallel operation
* No interference if addresses differ

---

14.5 WRITE COLLISION (SAME ADDRESS)

Time --->

clk_a    :  ___/‾‾‾\
clk_b    :  ___/‾‾‾\

addr_a   : ----A0-----
addr_b   : ----A0-----

din_a    : ----DA-----
din_b    : ----DB-----

mem[A0]  : ----UNKNOWN----

Explanation:

* Undefined result
* Must be avoided in design

---

14.6 BYTE ENABLE EXAMPLE

DATA_WIDTH = 32

be_a     : ----1010-----
din_a    : ----AABBCCDD-
mem[A0]  : ----11223344-

Result:
Final mem[A0] = AA 22 CC 44

Explanation:

* Only selected bytes updated

---

---

15. TIMING SUMMARY

---

## Operation Type        Latency        Behavior

Read                  1 cycle        Synchronous
Write                 0 cycle        On clock edge
Read-during-write     1 cycle        OLD data (READ-FIRST)
Dual-port access      0 cycle        Parallel
Same-address write    Undefined      Avoid

