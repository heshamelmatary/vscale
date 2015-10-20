//////////////////////////////////////////////////////////////////
//                                                              //
//  Instruction memory system                                   // 
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//   Instruction memory system is a wrapper for an IP core      //
//   or unit to be used as memory to embed MIPS instructions.   //
//   The contents of this file are target dependent.            //
//                                                              //
//  Author(s):                                                  //
//      - Hesham AL-Matary, heshamelmatary@gmail.com            //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2014 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

module Instruction_Memory
(
  input CLK,
  input[31:0] address,
  output[31:0] dout,
  input reset
);

wire[31:0] addr;
wire[31:0] BRAM_ADDR;

assign addr = ((address) & 32'hFFFFFFFC)/4 ;
assign BRAM_ADDR = (addr <= 512)? addr : 0;

reg[31:0] dout_reg = 0;

always @(posedge CLK)
begin
  case (address)
	32'h200: dout_reg <= 32'b000000000001_00000_000_00001_0010011; //ld x1, 1
	32'h204: dout_reg <= 32'b11111111111111110000_00010_0110111; // lui x2, 0xFFF0
	32'h208: dout_reg <= 32'b000100001000_00010_110_00010_0010011; // ori x2, 0x108
	32'h20C: dout_reg <= 32'b000000000001_00000_000_00001_0010011; //ld x1, 1
	32'h210: dout_reg <= 32'b000000000001_00000_000_00001_0010011; //ld x1, 1
	32'h214: dout_reg <= 32'b0000000_00001_00010_010_00000_0100011; // sw x1, 0(x2)
	
	default: dout_reg <= 0;
  endcase
end

assign dout = dout_reg;
/*
ROM32x512 ROM 
(
  .clka(CLK), // input clka
  .addra(BRAM_ADDR), // input [9 : 0] addra
  .douta(dout) // output [31 : 0] douta
);
*/
endmodule 