# Single-Cycle-MIPS
Single-Cycle 32-Bit MIPS processor implemented in verilog for school shits.


_______________________________________________________________________________________

--->      OpCode     ||   func. (for R-types)      ||       ALUop
          _______         ___________________               _____


i-types:    lw			        x	             010 (same as "add")
	    sw			        x		     010 (same as "add")
	    beq		              	x		     110 (same as "sub")

R-types:    and		              100100		     000
	    or		              100101		     001
	    add		              100000		     010
	    sub		              100010		     110

________________________________________________________________________________________
