// -----------------------------------------------------------------------------
//  Title      : Reed-Solomon example
//  Project    : Mentoring
// -----------------------------------------------------------------------------
//  File       : rs_7_5.v
//  Author     : Simon Southwell
//  Created    : 2022-05-30
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This code is an encoder and decoder for a simple RS(7,5) Reed-Solomon code.
//  This is behavioural code for informative purposes only. It has not been
//  checked that it can be synthesised and doesn't, for instance, infer latches
//  etc. A practical implementation would have clocked state.
// -----------------------------------------------------------------------------
//  Copyright (c) 2022 Simon Southwell
// -----------------------------------------------------------------------------
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  It is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code. If not, see <http://www.gnu.org/licenses/>.
//
// -----------------------------------------------------------------------------

`timescale 1ns / 10ps

// ===============================================
// ENCODER
// ===============================================

module rs_7_5_encoder
(
  input [14:0] idata,
  output[20:0] ocode
);

wire [2:0] s [0:6];

integer idx;
reg [2:0] GF_log  [1:7];
reg [2:0] GF_alog [1:7];
reg [2:0] p_poly  [0:4];
reg [2:0] q_poly  [0:4];
reg [3:0] p_data  [0:4];
reg [3:0] q_data  [0:4];
reg [2:0] P, Q;

assign s[0] = idata[2:0];
assign s[1] = idata[5:3];
assign s[2] = idata[8:6];
assign s[3] = idata[11:9];
assign s[4] = idata[14:12];
assign s[5] = P;
assign s[6] = Q;

assign ocode = {s[6], s[5], s[4], s[3], s[2], s[1], s[0]};

initial
begin

  // Galois field for x3 + x + 1
  GF_alog[1] = 3'b010; GF_alog[2] = 3'b100;
  GF_alog[3] = 3'b011; GF_alog[4] = 3'b110;
  GF_alog[5] = 3'b111; GF_alog[6] = 3'b101;
  GF_alog[7] = 3'b001;

  // Inverse (log) Galois field for x3 + x + 1
  GF_log[1] = 3'b111; GF_log[2] = 3'b001;
  GF_log[3] = 3'b011; GF_log[4] = 3'b010;
  GF_log[5] = 3'b110; GF_log[6] = 3'b100;
  GF_log[7] = 3'b101;

  // Corrector polynomial: a6 + a + a2 + a5 + a3
  p_poly[0] = 6; p_poly[1] = 1; p_poly[2] = 2;
  p_poly[3] = 5; p_poly[4] = 3;

  // Locator polynomial: a2 + a3 + a6 + a4 + a
  q_poly[0] = 2; q_poly[1] = 3; q_poly[2] = 6;
  q_poly[3] = 4; q_poly[4] = 1;
end

always @(*)
begin
  P = 3'b000;
  Q = 3'b000;

  for (idx = 0; idx < 5; idx = idx + 1)
  begin
    // Calulate P
    p_data[idx] = p_poly[idx] + GF_log[s[idx]];      // a**k.s[idx] = a**(k + log(s[idx]))
    p_data[idx] = p_data[idx][2:0] + p_data[idx][3]; // Wrap result when > 7 (8->1, 9->2 etc.)
    p_data[idx] = GF_alog[p_data[idx]];              // antilog  result
    P           = P ^ p_data[idx];                   // XOR results

    // Calculate Q
    q_data[idx] = q_poly[idx] + GF_log[s[idx]];      // a**k.s[idx] = a**(k + log(s[idx]))
    q_data[idx] = q_data[idx][2:0] + q_data[idx][3]; // Wrap result when > 7 (8->1, 9->2 etc.)
    q_data[idx] = GF_alog[q_data[idx]];              // antilog  result
    Q           = Q ^ q_data[idx];                   // XOR results
  end
end

endmodule

// ===============================================
// DECODER
// ===============================================

module rs_7_5_decoder
(
  input  [20:0] icode,
  output [14:0] odata
);

reg [2:0] s [0:6];

integer idx;
reg  [2:0] GF_log  [1:7];
reg  [2:0] GF_alog [1:7];
reg  [3:0] S1_poly [0:6];
reg  [3:0] k;
reg  [2:0] S0;
reg  [2:0] S1;

assign odata = {s[4], s[3], s[2], s[1], s[0]};

initial
begin
  // Galois field for x3 + x + 1
  GF_alog[1] = 3'b010; GF_alog[2] = 3'b100;
  GF_alog[3] = 3'b011; GF_alog[4] = 3'b110;
  GF_alog[5] = 3'b111; GF_alog[6] = 3'b101;
  GF_alog[7] = 3'b001;

  // Inverse (log) Galois field for x3 + x + 1
  GF_log[1]  = 3'b111; GF_log[2]  = 3'b001;
  GF_log[3]  = 3'b011; GF_log[4]  = 3'b010;
  GF_log[5]  = 3'b110; GF_log[6]  = 3'b100;
  GF_log[7]  = 3'b101;
end

always @(icode)
begin
  // Split input code to symbols
  s[0] = icode[2:0];
  s[1] = icode[5:3];
  s[2] = icode[8:6];
  s[3] = icode[11:9];
  s[4] = icode[14:12];
  s[5] = icode[17:15];
  s[6] = icode[20:18];

  // S0 is XOR of all symbols
  S0   = s[0] ^ s[1] ^ s[2] ^ s[3] ^ s[4] ^ s[5] ^ s[6];

  // Default S1 to 0
  S1   = 3'b000;

  for (idx = 0; idx < 7; idx = idx + 1)
  begin
    S1_poly[idx] = (7 - idx) + GF_log[s[idx]];              // a**n.s[idx] (where n = 7-idx) => log(n) + log(s[idx])
    S1_poly[idx] = S1_poly[idx][2:0] + S1_poly[idx][3];     // Wrap if > 7
    S1_poly[idx] = s[idx] ? GF_alog[S1_poly[idx]] : 3'b000; // antilog(result). If s[idx] zero then a**n.s[idx] equals 0

    // S1 is XOR of all a**n.s[idx] results
    S1           = S1 ^ S1_poly[idx];
  end

  // If an error detected, update the symbol that was multiplied by a**k
  if (S0 != 3'b000)
  begin
    // Calculate k
    k      = GF_log[S1] - GF_log[S0];                       // Subtract logs of S1 and S0 (for S1/S0)
    k      = k[2:0] - k[3];                                 // Wrap on negative values
    k      = (k == 4'b0000) ? GF_log[3'b001] : k;           // If k equals 0, a**k == 1, k == log(1)

    // Correct indexed symbol with S0. (Note s[0] is data[0] multiplied by a**7,
    // data[1] by a**6 etc., so index is 7-k.
    s[7-k] = s[7-k] ^ S0;
  end
end

endmodule

// ===============================================
// TEST BENCH
//
// For a fixed data pattern, the test bench goes
// through all possible symbol error patterns over
// each symbol. The input data can be changed via
// the DATA_PATTERN parameter
//
// To run this test bench (on ModelSim) use:
//   vlib work  (if work does not already exist)
//   vlog +define+TEST_BENCH rs_7_5.v
//   vsim -gui tb 
//
//   for batch simulation:
//     vsim -c tb -gTEST_GUI=0
//
// ===============================================

`ifdef TEST_BENCH

module tb
#(parameter
  CLK_FREQ_MHZ                         = 100,
  RESET_PERIOD                         = 10,
  DATA_PATTERN                         = 15'b111_100_010_100_101,
  TEST_GUI                             = 1
)
();

integer     count;
reg         clk;
wire        reset_n;

reg  [14:0] idata;
wire [20:0] ocode;
reg  [20:0] error;
wire [20:0] icode;
wire [14:0] odata;

// Flag error if input and output data miscompare
wire        cmp_error                  = (idata ^ odata) != 15'h0000;

// -----------------------------------------------
// Initialisation, clock and reset
// -----------------------------------------------

initial
begin
  count                                = -1;
  clk                                  = 1'b1;
  error                                = {3'b000, 3'b000, 3'b000, 3'b000, 3'b001};
  idata                                = DATA_PATTERN;
end

// Generate a clock
always #(500/CLK_FREQ_MHZ)
  clk                                  = ~clk;

// Increment the count each clock cycle
always @(posedge clk)
  count                                = count + 1;

// Generate a reset signal using count
assign reset_n                         = (count >= RESET_PERIOD) ? 1'b1 : 1'b0;


// -----------------------------------------------
// Input vector generation and TB control
// -----------------------------------------------

always @(posedge clk)
begin
  if ((count > RESET_PERIOD) && ((count-RESET_PERIOD)%4) == 3)
  begin
    // If last error in last symbol, and not last pattern, reset
    // error to be the next pattern
    if (error[20:18] != 3'b000 && error[20:18] != 3'b111)
    begin
      error[2:0]                       = error[20:18] + 1;
      error[20:18]                     = 3'b000;
    end
    else
    begin
       // Shift the error pattern by a symbol's width
       error                           = error << 3;
    end
  end

  // Terminate the simulation if all test patterns done, or on miscompare
  if (error == 0 || (reset_n && cmp_error))
  begin
    if (cmp_error)
    begin
      $display("***FAIL: comparison error");
    end
    else
    begin
      $display("No errors");
    end

    if (TEST_GUI)
      $stop;
    else
      $finish;
  end
end

// -----------------------------------------------
// UUT instantiation and channel error injection
// -----------------------------------------------
  
  // ~~~~~~~~~~~~~~
  // Encoder
  // ~~~~~~~~~~~~~~
  rs_7_5_encoder enc (idata, ocode);

  // Channel with injected errors
  assign icode                         = ocode ^ error;

  // ~~~~~~~~~~~~~~
  // Decoder
  // ~~~~~~~~~~~~~~
  rs_7_5_decoder dec (icode, odata);

endmodule

`endif