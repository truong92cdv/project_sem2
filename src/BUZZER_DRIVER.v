module BUZZER_DRIVER (
	input 		clk,       		// System clock
	input 		rst_n,       	// Reset signal
	output reg 	buzz  			// Buzzer output
);

	// Define the frequencies for the notes (in Hz)
	parameter C4 = 262;
	parameter D4 = 294;
	parameter E4 = 330;
	parameter F4 = 349;
	parameter G4 = 392;
	parameter A4 = 440;
	parameter B4 = 494;
	parameter C5 = 523;
	parameter D5 = 587;
	parameter E5 = 659;
	parameter F5 = 698;
	parameter G5 = 784;
	parameter A5 = 880;
	parameter B5 = 988;

	// Define the note durations (in clock cycles)
	parameter WHOLE = 100_000_000;
	parameter HALF = WHOLE / 2;
	parameter QUARTER = WHOLE / 4;
	parameter EIGHTH = WHOLE / 8;

	// Define the song notes and durations
	reg [31:0] note_freq [0:24];
	reg [31:0] note_duration [0:24];

	initial begin
		note_freq[0] = G4; note_duration[0] = QUARTER;
		note_freq[1] = G4; note_duration[1] = QUARTER;
		note_freq[2] = A4; note_duration[2] = HALF;
		note_freq[3] = G4; note_duration[3] = HALF;
		note_freq[4] = C5; note_duration[4] = HALF;
		note_freq[5] = B4; note_duration[5] = WHOLE;
		note_freq[6] = G4; note_duration[6] = QUARTER;
		note_freq[7] = G4; note_duration[7] = QUARTER;
		note_freq[8] = A4; note_duration[8] = HALF;
		note_freq[9] = G4; note_duration[9] = HALF;
		note_freq[10] = D5; note_duration[10] = HALF;
		note_freq[11] = C5; note_duration[11] = WHOLE;
		note_freq[12] = G4; note_duration[12] = QUARTER;
		note_freq[13] = G4; note_duration[13] = QUARTER;
		note_freq[14] = G5; note_duration[14] = HALF;
		note_freq[15] = E5; note_duration[15] = HALF;
		note_freq[16] = C5; note_duration[16] = HALF;
		note_freq[17] = B4; note_duration[17] = HALF;
		note_freq[18] = A4; note_duration[18] = WHOLE;
		note_freq[19] = F5; note_duration[19] = QUARTER;
		note_freq[20] = F5; note_duration[20] = QUARTER;
		note_freq[21] = E5; note_duration[21] = HALF;
		note_freq[22] = C5; note_duration[22] = HALF;
		note_freq[23] = D5; note_duration[23] = HALF;
		note_freq[24] = C5; note_duration[24] = WHOLE;
	end

	reg [31:0] clk_div;
	reg [31:0] note_index;
	reg [31:0] note_counter;

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			clk_div <= 0;
			note_index <= 0;
			note_counter <= 0;
			buzz <= 0;
		end else begin
			if (clk_div >= (100000000 / note_freq[note_index])) begin
				clk_div <= 0;
				buzz <= ~buzz;
			end else begin
				clk_div <= clk_div + 1;
			end

			if (note_counter >= note_duration[note_index]) begin
				note_counter <= 0;
				if (note_index < 24) begin
					note_index <= note_index + 1;
				end else begin
					note_index <= 0;
				end
			end else begin
				note_counter <= note_counter + 1;
			end
		end
	end
endmodule