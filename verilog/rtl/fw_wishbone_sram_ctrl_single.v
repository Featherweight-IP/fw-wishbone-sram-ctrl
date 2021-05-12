/****************************************************************************
 * fw_wishbone_sram_ctrl_single.v
 ****************************************************************************/

`include "wishbone_tag_macros.svh"
`include "wishbone_amo_defines.svh"
`include "generic_sram_byte_en_macros.svh"
  
/**
 * Module: fw_wishbone_sram_ctrl_single
 * 
 * TODO: Add module documentation
 */
module fw_wishbone_sram_ctrl_single #(
		parameter ADR_WIDTH=32,
		parameter DAT_WIDTH=32
		) (
		input				clock,
		input				reset,
		`WB_TARGET_TAG_PORT(t_, ADR_WIDTH, DAT_WIDTH, 1, 1, 4),
		`GENERIC_SRAM_BYTE_EN_INITIATOR_PORT(i_, ADR_WIDTH, DAT_WIDTH)
		);

	reg[1:0] state;
	
	reg[DAT_WIDTH-1:0]		tmp_dat;
	reg[ADR_WIDTH-1:0]		sram_adr;
	reg						sram_we;
	
	assign i_write_en = (t_we);
	assign i_addr = (state==2'b00)?t_adr:sram_adr;
	assign i_write_data = t_dat_w;
	assign t_dat_r = i_read_data;
	assign i_write_en = (t_cyc && t_stb && t_we);
	assign i_read_en = (t_cyc && t_stb && ~t_we);
	assign i_byte_en = t_sel;
		
	assign t_ack = (state==2'b10);

	/*
	 * Note: assume SRAM registers address
	 * - Route adr directly to SRAM during state0
	 * - Route we directly to SRAM during state0 if not atomic
	 */
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			state <= 2'b0;
			sram_adr <= {ADR_WIDTH{1'b0}};
			sram_we <= 1'b0;
		end else begin
			case (state) 
				2'b00: begin
					if (t_cyc && t_stb) begin
						// Caught a cycle
						// TODO: sram is registered, right?
						sram_adr <= t_adr;
						if (|t_tgc) begin
							// atomic access, so first we ready
							sram_we <= 1'b0;
						end else begin
							sram_we <= t_we;
							state <= 2'b10;
						end
					end
				end
				
				2'b01: begin // Atomic phase1: read + operate on data
//					case (t_tgc) // synopsys parallel_case full_case
//						`WB_AMO_ADD: tmp_dat <= sram_dat_r + 
//					endcase
				end
				
				2'b10: begin // Complete
					state <= 2'b00;
				end
			endcase
			
		end
	end

endmodule


