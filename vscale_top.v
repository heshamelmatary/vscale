//////////////////////////////////////////////////////////////////
//                                                              //
//  Top level module for Edge project on Atlys board            //               
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//   Top level module conatining Edge core, data memory,        //
//   instruction memory, uart controller and others to run on   //
//   Atyls board.                                               //
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

module vscale_top
#
(
  parameter N=32,
  parameter M=5
)
(
  input CLK,
  input RESET,
  output[7:0] LED,
  output wire UART_TXD // UART send data
);

wire CLK_2x;
wire CLK_50MHz;
//wire reset;
//reg CLK;
//reg reset;
/* Insruction Memory in-out wires */
wire[N-1:0] pc_toIMemory;
wire[N-1:0] instr_fromIMemory;

/* Data Memory in-out wires */
wire[N-1:0] Address_toDMemory, WriteData_toDMemory;
wire MemWrite_toDMemory;
wire[N-1:0] RD_fromDMemory;
wire UART_VALID;
wire[N-1:0] UART_TX;
wire UART_READY;
wire StallDataMemory;
wire[1:0] MemRefSize;
wire CP0_TimerIntMatch;
wire IO_TimerIntReset;

reg[31:0] UART_CTRL = 0;
wire[31:0] UART_CTRL_TO_DMEM;

wire	ddr2_if_clk;
wire	ddr2_if_rst;

wire  clk_100mhz;

/* CLOCK GENERATOR FOR SIMULATION */
/*initial CLK = 0;
initial reset = 1;
always 
begin
#10 CLK = ~CLK; 
end
*/
/*always
#20 reset = 0;
*/
clock_manager
#
(
  .CLK_OUT(100000000/2)
)
clk_divider
(
  .clk_in(CLK),
  .clk_out(CLK_50MHz)
);

clock_manager
#(.CLK_OUT(100000000/2)
  )
clk_div2x(
   .clk_in(CLK),
   .clk_out(CLK_2x)
);

reset_logic reset_logic
(
  //.reset_interrupt(reset),
  .reset_interrupt(RESET),
  .clk(CLK_50MHz),
  .reset(reset)
);

  /* Instantiate the Unit Under Test (UUT) */

wire dmem_en;

vscale_pipeline vscale_core (
	.clk(CLK_50MHz),
	//.clk(CLK),
   .reset(reset),
   .imem_wait(1'b0), /* FIXME */
   .imem_addr(pc_toIMemory),
   .imem_rdata(instr_fromIMemory),
   .imem_badmem_e(1'b0), /* FIXME */
	
   .dmem_wait(1'b0), /* FIXME */
   .dmem_en(dmem_en), /* FIXME */
   .dmem_wen(MemWrite_toDMemory),
   .dmem_size(MemRefSize), /* FIXME?? */
   .dmem_addr(Address_toDMemory),
   .dmem_wdata_delayed(WriteData_toDMemory), /* FIXME */
   .dmem_rdata(RD_fromDMemory),
   .dmem_badmem_e(1'b0) /* FIXME */
   );
							  
/*Edge_Core Edge 
(
  .clk(CLK_50MHz), 
  .reset(reset),
  .pc_toIMemory(pc_toIMemory),
  .instr_fromIMemory(instr_fromIMemory),
  
  .Address_toDMemory(Address_toDMemory), 
  .WriteData_toDMemory(WriteData_toDMemory),
  .MemWrite_toDMemory(MemWrite_toDMemory),
  .MemRefSize(MemRefSize),
  .RD_fromDMemory(RD_fromDMemory),
  .StallDataMemory(StallDataMemory),
  
  .CP0_TimerIntMatch(CP0_TimerIntMatch),
  .IO_TimerIntReset(IO_TimerIntReset)
);*/
  
 
/* Instantiate Insturction Memory */
Instruction_Memory ins_mem
(
  //.CLK(clk_100mhz),
  .CLK(CLK_50MHz),
  //.CLK(CLK),
  .reset(reset),
  .address(pc_toIMemory),
  .dout(instr_fromIMemory)
);

/* Instantiate Data Memory */
Memory_System mem_io
(
  .clk(CLK_50MHz),
  //.clk(CLK),
  .ProcessorAddress(Address_toDMemory), 
  .WriteData(WriteData_toDMemory),
  .WE(MemWrite_toDMemory),
  .RD(RD_fromDMemory),
  
  .UART_TX(UART_TX),
  .UART_VALID(UART_VALID),
  .UART_CTRL(UART_CTRL_TO_DMEM),
  .CP0_TimerIntMatch(CP0_TimerIntMatch),
  .StallBusy(StallDataMemory),
  .MemRefSize(MemRefSize),
  .LEDs(LED),
  .IO_TimerIntReset(IO_TimerIntReset)
);
  
/* UART Transmitter to PC */
UART_TX_CTRL serial_tty
(
  .SEND(UART_VALID),
  .DATA(UART_TX[7:0]),
  .CLK(CLK_50MHz),
  //.CLK(CLK),
  .READY(UART_READY),
  .UART_TX(UART_TXD)
);

always @(posedge CLK_50MHz)
  if(UART_READY)
    UART_CTRL[0] = 1;
  else
    UART_CTRL[0] = 0;

assign UART_CTRL_TO_DMEM = UART_CTRL;

endmodule