module v_divider #(parameter width) (
	input logic clock,
	input logic reset_n,
	input logic[width-1:0] divisor,
	output logic clock_out
);

	logic direct;
	assign direct = (divisor == 0) | (divisor == 1);
	logic[width-1:0] cntValue;
	assign cntValue = direct ? 0 : divisor - 1;

	logic clock_n;
	assign clock_n = ~ clock;

	logic[width-1:0] count_pos;
	
	always_ff @(posedge clock or negedge reset_n) begin
		if (~ reset_n) begin
			count_pos <= 0;
		end else begin
			if (count_pos >= cntValue) begin
				count_pos <= 0;
			end else begin
				count_pos <= count_pos + 1;
			end
		end
	end

	logic[width-1:0] count_neg;
	always_ff @(posedge clock_n or negedge reset_n) begin
		if (~ reset_n) begin
			count_neg <= 0;
		end else begin
			if (count_neg >= cntValue) begin
				count_neg <= 0;
			end else begin
				count_neg <= count_neg + 1;
			end
		end
	end

	logic clock_pos;
	always_ff @(posedge clock or negedge reset_n) begin
		if (~ reset_n) begin
			clock_pos <= 0;
		end else if ((count_pos == (cntValue >> 1)) || (count_pos == cntValue)) begin
			clock_pos <= ~ clock_pos;
		end
	end

	logic clock_neg;
	always_ff @(posedge clock_n or negedge reset_n) begin
		if (~ reset_n) begin
			clock_neg <= 0;
		end else if ((count_neg == (cntValue >> 1)) || (count_neg == cntValue)) begin
			clock_neg <= ~ clock_neg;
		end
	end

	assign clock_out = direct ? clock : (divisor[0] ? (clock_pos | clock_neg) : clock_pos);

endmodule
