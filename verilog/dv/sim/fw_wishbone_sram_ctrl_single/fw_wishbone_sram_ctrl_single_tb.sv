/****************************************************************************
 * wb_wishbone_sram_ctrl_single_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ns
`endif

`include "generic_sram_byte_en_macros.svh"
`include "wishbone_amo_defines.svh"
`include "wishbone_tag_macros.svh"

  
/**
 * Module: wb_wishbone_sram_ctrl_single_tb
 * 
 * TODO: Add module documentation
 */
module fw_wishbone_sram_ctrl_single_tb(input clock);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r = 0;
	initial begin
		forever begin
`ifdef NEED_TIMESCALE
			#10;
`else
			#10ns;
`endif
			clock_r <= ~clock_r;
		end
	end
	assign clock = clock_r;
`endif
	
`ifdef IVERILOG
`include "iverilog_control.svh"
`endif
	
	reg reset = 0;
	reg[7:0] reset_cnt = 0;
	
	always @(posedge clock) begin
		if (reset_cnt == 20) begin
			reset <= 0;
		end else begin
			if (reset_cnt == 1) begin
				reset <= 1;
			end
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	localparam ADR_WIDTH = 32;
	localparam DAT_WIDTH = 32;
		
	
	`WB_TAG_WIRES(bfm2dut_, ADR_WIDTH, DAT_WIDTH, 1, 1, 4);
	`GENERIC_SRAM_BYTE_EN_WIRES(dut2bfm_, ADR_WIDTH, DAT_WIDTH);
	
	wb_tag_initiator_bfm #(
		.ADR_WIDTH  (ADR_WIDTH ), 
		.DAT_WIDTH  (DAT_WIDTH ), 
		.TGA_WIDTH  (1 ), 
		.TGD_WIDTH  (1 ), 
		.TGC_WIDTH  (4 )
		) u_wb_bfm (
		.clock      (clock     ), 
		.reset      (reset     ), 
		`WB_TAG_CONNECT( , bfm2dut_)
		);
	
	fw_wishbone_sram_ctrl_single #(
		.ADR_WIDTH     (ADR_WIDTH    ), 
		.DAT_WIDTH     (DAT_WIDTH    )
		) fw_wishbone_sram_ctrl_single (
		.clock         (clock        ), 
		.reset         (reset        ), 
		`WB_TAG_CONNECT(t_, bfm2dut_ ),
		`GENERIC_SRAM_BYTE_EN_CONNECT(i_, dut2bfm_)
		);
	
	generic_sram_byte_en_target_bfm #(
		.DAT_WIDTH  (DAT_WIDTH ),
		.ADR_WIDTH  (20        )
		) u_sram_bfm (
		.clock      (clock     ),
		.adr(dut2bfm_addr),
		.we(dut2bfm_write_en),
		.sel(dut2bfm_byte_en),
		.dat_r(dut2bfm_read_data),
		.dat_w(dut2bfm_write_data));

endmodule


