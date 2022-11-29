/********************************************************************************
 * Commodore 128 VDC
 * 
 * for the C128 MiSTer FPGA core, by Erik Scheffers
 *
 * - timings not yet verified
 ********************************************************************************/

module vdc_video #(
	parameter 		S_LATCH_WIDTH,
	parameter 		C_LATCH_WIDTH
)(
	input    [1:0] version,                    // 0=8563R7A, 1=8563R9, 2=8568
	input          debug,

	input          clk,
	input          reset,
	input          enable,

	input    [3:0] reg_cth,                    // character total horizontal                 
	input    [3:0] reg_cdh,                    // character displayed horizontal                 
	input    [4:0] reg_vss,                    // vertical smooth scroll
	input    [3:0] reg_hss,                    // horizontal smooth scroll
			   
	input    [4:0] reg_ul,                     // underline position
	input          reg_cbrate,                 // character blink rate
	input          reg_text,                   // text/bitmap mode
	input          reg_atr,                    // attribute enable
	input          reg_semi,                   // semi-graphics mode 
	input          reg_rvs,                    // reverse video
	input    [3:0] reg_fg,                     // foreground color
	input    [3:0] reg_bg,                     // background color

	input    [1:0] reg_cm,                     // cursor mode
	input    [4:0] reg_cs,                     // cursor line start
	input    [4:0] reg_ce,                     // cursor line end
	input   [15:0] reg_cp,                     // cursor position
				 
	input          newFrame,                   // start of new frame
	input          newLine,                    // start of new line
	input          newRow,                     // start of new visible row
	input          newCol,                     // start of new column
	input          endCol,                     // end of column
			   
	input          hVisible,                   // in visible part of display
	input          vVisible,                   // in visible part of display
	input          blank,                      // blanking
	input          blink[2],                   // blink rates
	input          rowbuf,                     // buffer # containing current screen info
	input    [7:0] col,                        // current column
	input    [4:0] line,                       // current line
	input    [7:0] scrnbuf[2][S_LATCH_WIDTH],  // screen codes for current and next row
	input    [7:0] attrbuf[2][S_LATCH_WIDTH],  // latch for attributes for current and next row
	input    [7:0] charbuf[C_LATCH_WIDTH],     // character data for current line
	input   [15:0] dispaddr,                   // address of current row

	output   [3:0] rgbi
);

wire [7:0] vcol = col - 8'd8;
wire [7:0] attr = vcol < S_LATCH_WIDTH ? attrbuf[rowbuf][vcol] : 8'd0;

wire [3:0] fg = reg_atr ? attr[3:0] : reg_fg;
wire [3:0] bg = reg_text && reg_atr ? attr[7:4] : reg_bg;
wire [2:0] ca = ~reg_text && reg_atr ? attr[6:4] : 3'b000;

always @(posedge clk) begin
	reg [7:0] bitmap;
	reg       crs, rvs;
	reg       stretch;

	if (reset) begin
		bitmap = 0;
		crs = 0;
	end
	else if (enable) begin
		if (!debug) begin
			if (vVisible && hVisible) begin
				if (newCol) begin
					// apply cursor
					crs = (
						~reg_text
						&& (dispaddr+vcol == reg_cp)
						&& (reg_cm == 2'b00 || reg_cm[1] && blink[reg_cm[0]]) 
						&& reg_cs <= line && line <= reg_ce
					);

					// get bitmap
					if (ca[0] && blink[reg_cbrate])
						bitmap = 8'h00;
					else if (ca[1] && line == reg_ul)
						bitmap = 8'hff;
					else
						bitmap = charbuf[vcol % C_LATCH_WIDTH];

					// reversed
					rvs = reg_rvs ^ ca[2] ^ crs;
					if (rvs) bitmap = ~bitmap;
				end
				else if (!(ca[1] && line == reg_ul))
					bitmap = {bitmap[6:0], reg_semi ? bitmap[0] : rvs};

				rgbi <= bitmap[7] ? fg : bg;
			end
			else if (blank) 
				rgbi <= 0;
			else
				rgbi <= reg_bg;
		end
		else begin
			if (newCol) begin
				// apply cursor
				crs = (
					~reg_text
					&& (dispaddr+vcol == reg_cp)
					&& (reg_cm == 2'b00 || reg_cm[1] && blink[reg_cm[0]]) 
					&& reg_cs <= line && line <= reg_ce
				);

				// get bitmap
				if (!(vVisible || hVisible))
					bitmap = charbuf[vcol % C_LATCH_WIDTH];
				else begin
					if (ca[0] && blink[reg_cbrate])
						bitmap = 8'h00;
					else if (ca[1] && line == reg_ul)
						bitmap = 8'hff;
					else
						bitmap = charbuf[vcol % C_LATCH_WIDTH];

					// reversed
					rvs = reg_rvs ^ ca[2] ^ crs;
					if (rvs) bitmap = ~bitmap;
				end
			end
			else if (!(ca[1] && line == reg_ul))
				bitmap = {bitmap[6:0], reg_semi ? bitmap[0] : rvs};

			if (vVisible && hVisible) 
				rgbi <= bitmap[7] ? fg : bg;
			else if (blank) 
				rgbi <= 0;
			else if (stretch) 
				rgbi <= rgbi;
			else if (newFrame)
				rgbi <= 4'b1111;
			else if (newRow) 
				rgbi <= 4'b0011;
			else if (newLine)
				rgbi <= 4'b0010;
			else if (bitmap[7])
				rgbi <= 0;
			else
				rgbi <= reg_bg ^ {~hVisible, ~vVisible, 2'b00};

			stretch <= newFrame | newCol | newLine;
		end
	end
end

endmodule
