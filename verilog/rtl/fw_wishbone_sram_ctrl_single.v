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

	reg[2:0] state;
	
	reg[DAT_WIDTH-1:0]		tmp_dat;
	reg[ADR_WIDTH-1:0]		sram_adr;
	reg						sram_we;
	
	assign i_addr = t_adr;
	reg[DAT_WIDTH-1:0]		write_data;
	assign i_write_data = write_data;
	
	always @* begin
		if (state == 3'b011 && t_tgc != `WB_AMO_SWAP) begin
			// AMO write-back state
			write_data = tmp_dat;
		end else begin
			write_data = t_dat_w;
		end
	end
	
	assign t_dat_r = (state == 3'b011)?tmp_dat:i_read_data;
	assign i_read_en = (t_cyc && t_stb && ~t_we);

	reg write_en;
	assign i_write_en = write_en;

	reg[(DAT_WIDTH/8)-1:0]		sel;
	assign i_byte_en = sel;
	
	always @* begin
		sel = {(DAT_WIDTH/8){1'b0}};
		if (t_cyc && t_stb) begin
			if (|t_tgc) begin
				// Write-back in state 3
				if (state == 2'b11) begin
					sel = {DAT_WIDTH/8{1'b1}};
				end else begin
					sel = {DAT_WIDTH/8{1'b0}};
				end
			end else begin
				sel = t_sel;
			end
		end
	end
		
	
	always @* begin
		write_en = 1'b0;
		if (t_cyc && t_stb) begin
			if (|t_tgc) begin
				// Write-back in state 3
				if (state == 2'b11) begin
					write_en = 1'b1;
				end else begin
					write_en = 1'b0;
				end
			end else begin
				write_en = t_we;
			end
		end
	end
		
	assign t_ack = (state==2'b10 || state == 2'b11);

	/*
	 * Note: assume SRAM registers address
	 * - Route adr directly to SRAM during state0
	 * - Route we directly to SRAM during state0 if not atomic
	 */
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			state <= 3'b0;
			sram_adr <= {ADR_WIDTH{1'b0}};
			sram_we <= 1'b0;
			tmp_dat <= {DAT_WIDTH{1'b0}};
		end else begin
			case (state) 
				3'b000: begin
					tmp_dat <= {DAT_WIDTH{1'b0}};
					if (t_cyc && t_stb) begin
						// Caught a cycle
						// TODO: sram is registered, right?
						sram_adr <= t_adr;
						if (|t_tgc) begin
							// atomic access, so first we ready
							sram_we <= 1'b0;
							state <= 2'b01;
						end else begin
							sram_we <= t_we;
							state <= 2'b10;
						end
					end
				end
				
				3'b001: begin // Atomic phase1: read + operate on data
					case (t_tgc) // synopsys parallel_case full_case
						`WB_AMO_SWAP: tmp_dat <= i_read_data;
						`WB_AMO_ADD: tmp_dat <= i_read_data + t_dat_w;
						`WB_AMO_AND: tmp_dat <= i_read_data & t_dat_w;
						`WB_AMO_OR:  tmp_dat <= i_read_data | t_dat_w;
						`WB_AMO_XOR: tmp_dat <= i_read_data ^ t_dat_w;
						`WB_AMO_MAXS: begin
							if ($signed(i_read_data) > $signed(t_dat_w)) begin
								tmp_dat <= i_read_data;
							end else begin
								tmp_dat <= t_dat_w;
							end
						end
						`WB_AMO_MAXU: begin
							if (i_read_data > t_dat_w) begin
								tmp_dat <= i_read_data;
							end else begin
								tmp_dat <= t_dat_w;
							end
						end
						`WB_AMO_MINS: begin
							if ($signed(i_read_data) < $signed(t_dat_w)) begin
								tmp_dat <= i_read_data;
							end else begin
								tmp_dat <= t_dat_w;
							end
						end
						`WB_AMO_MINU: begin
							if (i_read_data < t_dat_w) begin
								tmp_dat <= i_read_data;
							end else begin
								tmp_dat <= t_dat_w;
							end
						end						
					endcase
					state <= 2'b11;
				end
				
				3'b010: begin // Direct completion
					state <= 2'b00;
				end
				
				3'b011: begin // AMO completion
					state <= 2'b00;
				end
			endcase
			
		end
	end

endmodule


