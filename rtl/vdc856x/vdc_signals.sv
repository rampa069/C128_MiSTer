/********************************************************************************
 * Commodore 128 VDC
 * 
 * for the C128 MiSTer FPGA core, by Erik Scheffers
 ********************************************************************************/

module vdc_signals #(
	parameter VB_FRONT_PORCH = 2, // vertical blanking front porch (lines)
	parameter VB_BACK_PORCH  = 2  // vertical blanking back porch (lines)
)(
	input         clk,
	input         reset,
	input         init,
	input         enable0,
 
	input   [7:0] reg_ht,         // R0      7E/7F 126/127 Horizontal total (minus 1) [126 for original ROM, 127 for PAL on DCR]
	input   [7:0] reg_hd,         // R1         50 80      Horizontal displayed
	input   [7:0] reg_hp,         // R2         66 102     Horizontal sync position 
	input   [3:0] reg_vw,         // R3[7:4]     4 4       Vertical sync width
	input   [3:0] reg_hw,         // R3[3:0]     9 9       Horizontal sync width (plus 1)
	input   [7:0] reg_vt,         // R4      20/27 32/39   Vertical total (minus 1) [32 for NTSC, 39 for PAL]
	input   [4:0] reg_va,         // R5         00 0       Vertical total adjust
	input   [7:0] reg_vd,         // R6         19 25      Vertical displayed
	input   [7:0] reg_vp,         // R7      1D/20 29/32   Vertical sync position (plus 1) [29 for NTSC, 32 for PAL]
	input   [1:0] reg_im,         // R8          0 off     Interlace mode
	input   [4:0] reg_ctv,        // R9         07 7       Character Total Vertical (minus 1)
	input   [3:0] reg_cth,        // R22[7:4]    7 7       Character total horizontal (minus 1)
	input   [3:0] reg_cdh,        // R22[3:0]    8 8       Character displayed horizontal (plus 1 in double width mode)
	input   [4:0] reg_vss,        // R24[4:0]   00 0       Vertical smooth scroll
	input         reg_dbl,        // R25[4]      0 off     Pixel double width
	input   [3:0] reg_fg,         // R26[7:4]    F white   Foreground RGBI
	input   [3:0] reg_bg,         // R26[3:0]    0 black   Background RGBI
	input   [7:0] reg_deb,        // R34        7D 125     Display enable begin
	input   [7:0] reg_dee,        // R35        64 100     Display enable end

	output        fetchFrame,     // pulses at the start of a new frame
	output        fetchRow,       // pulses at the start of a new visible row
	output        fetchLine,      // pulses at the start of a new visible line
	output        newCol,         // pulses on first pixel of a column
	output        endCol,         // pulses on the last pixel of a column

	output  [7:0] col,            // current column
	output  [7:0] row,            // current row
	output  [4:0] pixel,          // current column pixel
	output  [4:0] line,           // current row line 

	output        hVisible,       // visible column
	output        vVisible,       // visible line
	output        blink[2],       // blink state. blink[0]=1/16, blink[1]=1/30

	output        hsync,          // horizontal sync
	output        vsync,          // vertical sync
	output        hblank,         // horizontal blanking
	output        vblank,         // vertical blanking
	output        frame,          // 0=first half, 1=second half
	output        display         // display enable
);

// horizontal timing
reg  [3:0] hsCount;     // horizontal sync counter
assign hsync = |hsCount;

wire lineStart    = newCol && col==0;
wire displayStart = endCol && col==7;
wire half1End     = endCol && col==(reg_ht/2)-1;
// wire half2Start   = newCol && col==reg_ht/2;
wire lineEnd      = endCol && col==reg_ht;

always @(posedge clk) begin
	if (reset || init) begin
		col <= 0;
		pixel <= 0;

		hsCount <= 0;

		newCol <= 0;
		endCol <= 0;
	end
	else if (enable0) begin
		newCol <= endCol;
		endCol <= pixel==(reg_cth-1'd1);

		if (endCol) begin
			pixel <= reg_dbl;
			if (col==reg_ht)
				col <= 0;
			else
				col <= col+8'd1;

			// hVisible
			if (col==7) hVisible <= 1;
			if (col==reg_hd+8'd7) hVisible <= 0;

			// hblank
			if (col==reg_deb || reg_deb>reg_ht) hblank <= 0;
			if (col==reg_dee) hblank <= 1;

			// hsync
			if (col==reg_hp-1) hsCount <= reg_hw;
			if (hsCount) hsCount <= hsCount-4'd1;
		end
		else
			pixel <= pixel+4'd1;
	end
end

// vertical timing

reg  [4:0] cline;
reg        updateBlink;
reg        vsstart;

function [4:0] correct_line(
	input ilmode, 
	input cframe, 
	input [4:0] vss,
	input [4:0] line
);
begin
	// correct line number for current frame and vertical scroll state
	return {line[4:1], ilmode ? cframe^vss[0] : line[0]};
end
endfunction

always @(posedge clk) begin
	reg       ilmode;
	reg       cframe;

	reg [4:0] ncline;
	reg [4:0] nsline;
	reg [7:0] nrow;

	if (reset || init) begin
		row <= 0;
		nrow <= 0;

		line <= reg_vss;
		ncline <= reg_vss;
		ilmode <= &reg_im;
		cframe <= 0;

		nsline <= 0;

		fetchLine <= 0;
		fetchRow <= 0;
		fetchFrame <= 0;
		updateBlink <= 0;
	end
  	else if (enable0) begin
		if (lineStart) begin
			vsstart <= 0;
			fetchRow <= 0;
			fetchFrame <= 0;
			updateBlink <= 0;

			if (reg_va 
				? (nrow==reg_vt+1 && nsline==correct_line(ilmode, cframe, 0, reg_va)) 
				: (nrow==reg_vt && nsline==correct_line(ilmode, cframe, 0, reg_ctv))
			) begin
				ilmode <= &reg_im;
				cframe <= &reg_im & frame;
				
				nsline <= (&reg_im & frame) ? 5'd1 : 5'd0;
				ncline <= (&reg_im & frame) ? (reg_vss==reg_ctv ? 5'd0 : reg_vss+5'd1) : reg_vss;

				nrow <= 0;
				if (reg_vp==0)
					vsstart <= 1;

				if (reg_vd==nrow) begin	
					fetchFrame <= 1;
					fetchLine <= 0;
				end
			end
			else begin
				// update row/line
				if (ncline==correct_line(ilmode, cframe, reg_vss, reg_ctv)) begin
					ncline <= correct_line(ilmode, cframe, reg_vss, 0);
					if (nrow<reg_vd)
						fetchRow <= 1;
				end
				else 
					ncline <= ncline+(ilmode ? 5'd2 : 5'd1);

				if (nsline==correct_line(ilmode, cframe, 0, reg_ctv)) begin
					nsline <= cframe ? 5'd1 : 5'd0;
				
					nrow <= nrow+8'd1;
					if (nrow==0) 
						fetchLine <= 1;

					if (reg_vp && (reg_vp-1==nrow))
						vsstart <= 1;

					if (reg_vp==nrow)
						updateBlink <= 1;

					if (reg_vd==nrow) begin	
						fetchFrame <= 1;
						fetchLine <= 0;
					end
				end
				else
					nsline <= nsline+(ilmode ? 5'd2 : 5'd1);
			end
		end

		if (displayStart) begin
			row <= nrow;
			cline <= ncline;
		end

		if (lineEnd) begin
			line <= cline;
			vVisible <= nrow && nrow<=reg_vd;
		end
	end
end

// vsync
wire [4:0] vswidth = 5'(|reg_vw ? reg_vw : 16);   // vsync width
reg  [4:0] vsCount;                               // vertical sync counter

assign vsync = |vsCount;

always @(posedge clk) begin
	if (reset || init) begin
		vsCount <= 0;
	end 
	else if (enable0) begin
		if (vsCount && (lineEnd || (reg_im[0] && half1End)))
			vsCount <= vsCount-5'd1;
		else if (vsstart && (frame ? half1End : lineEnd))
			vsCount <= vswidth;
	end
end

// vblank, frame & display enable
reg    [5:0] vbCount;      // vertical blanking counter
assign       display = 1;

always @(posedge clk) begin
	reg [9:0] vscnt, vbstart[2];
	reg       frame_n;

	if (reset || init) begin
		vscnt <= '1;
		vbstart <= '{'1, '1};
		frame <= 0;
		vblank <= 0;
	end
	else if (enable0) begin
		if (lineStart) begin
			if (&vscnt) begin
				vbstart <= '{'1, '1};
			end
			else begin
				vscnt <= vscnt+1'd1;
				vbstart[frame_n] <= vbstart[frame_n]-1'd1;
			end

			if (vbCount)
				vbCount <= vbCount-6'd1;

			if (vbstart[frame_n]==VB_FRONT_PORCH+1)
				vbCount <= '1;

			if (vsstart) begin
				vbstart[frame_n] <= vscnt;
				vscnt <= 0;
				frame_n <= ~frame_n & reg_im[0];
				vbCount <= 6'(VB_BACK_PORCH+vswidth-1);
			end
		end

		if (lineEnd) begin
			vblank <= |vbCount;
			if (vbstart[frame_n]==VB_FRONT_PORCH)
				frame <= frame_n;
		end
	end
end

// blinking
always @(posedge clk) begin
	reg [2:0] bcnt16;
	reg [3:0] bcnt30;

	if (reset || init) begin
		blink <= '{0, 0};
		bcnt16 <= 0;
		bcnt30 <= 0;
	end 
	else if (enable0 && updateBlink && lineEnd) begin
		{blink[0], bcnt16} <= 4'({blink[0], bcnt16}+1);

		bcnt30 <= bcnt30+1'd1;
		if (bcnt30==14) begin
			blink[1] <= ~blink[1];
			bcnt30 <= 4'd0;
		end
	end
end

endmodule
