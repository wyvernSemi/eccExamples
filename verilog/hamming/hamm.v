// -----------------------------------------------------------------------------
//  Title      : Hamming code example
//  Project    : Mentoring
// -----------------------------------------------------------------------------
//  File       : hamm.v
//  Author     : Simon Southwell
//  Created    : 2022-05-18
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This code is an encoder and decoder for a simple hamming code. The code
//  is for 13 bit codes constructed from 8 bit bytes with 4 hamming parity bits,
//  and a detection party bit.
//
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
`timescale 1 ns / 1ps

// ===============================================
// ENCODER
// ===============================================

module hamming8_encoder
(
  input      [7:0]      data,
  output    [12:0]      code
);

// Calculate the even parity bits from relavant positions
wire p1               = data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[6];
wire p2               = data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[6];
wire p4               = data[1] ^ data[2] ^ data[3] ^ data[7];
wire p8               = data[4] ^ data[5] ^ data[6] ^ data[7];

// Construct Hamming codeword
wire [11:0] hamm_code = {data[7], data[6], data[5], data[4], p8, data[3],
                         data[2], data[1], p4,      data[0], p2, p1};

// Generate even parity bit from generated codeword
wire parity           = ^hamm_code;

// Export the complete code to the output
assign code           = {parity, hamm_code};

endmodule

// ===============================================
// DECODER
// ===============================================

module hamming8_decoder
(
  input     [12:0]      code,
  output     [7:0]      data,
  output                error
);

wire [3:0] e;

// Assign error parity bits from relavant input code bits
assign      e[0]        = code[0] ^ code[2] ^ code[4] ^ code[6]  ^ code[8] ^ code[10];
assign      e[1]        = code[1] ^ code[2] ^ code[5] ^ code[6]  ^ code[9] ^ code[10];
assign      e[2]        = code[3] ^ code[4] ^ code[5] ^ code[6]  ^ code[11];
assign      e[3]        = code[7] ^ code[8] ^ code[9] ^ code[10] ^ code[11];

// Generate a unary version of the error value
wire [15:0] flip_mask   = 16'h0001 << e;

// Flip the input code bit indexed by e, when in range 1 to 12, mapping to 0 thru 11.
// (0 is no error and 13 to 15 are invalid indexes
wire [11:0] corr_code   = code[11:0] ^ flip_mask[12:1];

// Generate the parity check on the corrected code
wire        corr_parity = ^{code[12], corr_code};

// Export the data from the extracted data bits in the corrected code
assign data             = {corr_code[11], corr_code[10], corr_code[9], corr_code[8],
                           corr_code[6],  corr_code[5],  corr_code[4], corr_code[2]};

// Error if parity on corrected code fails or index into codeword invalid (i.e. e > 12)
assign error            = (|e & corr_parity) | (|flip_mask[15:13]);

endmodule

// ===============================================
// Test bench
//
// The test bench goes through all possible data
// bytes with all possible zero, one or two bit
// errors.
//
// To run this test bench (on ModelSim) use:
//   vlib work  (if work does not already exist)
//   vlog +define+TEST_BENCH hamm.v
//   vsim -gui tb 
//
//   for batch simulation:
//     vsim -c tb -gTEST_GUI=0
//
// ===============================================

`ifdef TEST_BENCH

module tb
#(parameter
  CLK_FREQ_MHZ                       = 100,
  RESET_PERIOD                       = 10,
  TEST_GUI                           = 1
)
();

reg         clk;
wire        reset_n;
integer     count;

reg   [7:0] txdata;
reg  [13:0] chan_error1;
reg  [13:0] chan_error2;

wire [12:0] txcode;
wire  [7:0] rxdata;
wire        rxerror;

initial
begin
  count                              = 0;
  clk                                = 1'b1;
end

// Generate a clock
always #(500/CLK_FREQ_MHZ) clk       = ~clk;

assign reset_n                       = (count >= RESET_PERIOD) ? 1'b1 : 1'b0;

  // -------------------------
  // Instantiate the encoder
  // -------------------------
  hamming8_encoder enc (txdata, txcode);

// Create 0, 1 or 2 bit errors by combining the test single bit errors
wire [12:0] chan_error = chan_error1[13:1] | chan_error2[13:1];

// Add the channel errors to the transmitted code to generate the received code
wire [12:0] rxcode = txcode ^ chan_error;

  // -------------------------
  // Instantiate the decoder
  // ------------------------
  hamming8_decoder dec (rxcode, rxdata, rxerror);

// Synchronous process to generate stimulus
always @(posedge clk)
begin
  count  <= count + 1;

  // Cycle through all possible 256 bytes for the transmit byte
  txdata <= count % 256;

  // After each 256 byte sequence, shift the error bit for first error channel
  // (note, bit 0 set is the no error case).
  chan_error1 <= 14'h0001 << ((count / 256) % 14);

  // On last byte with chan_error1 top bit set, shift the error bit for second error channel
  // (note, bit 0 set is the no error case).
  chan_error2 <= (count == 0)                                 ? 14'h0001 :
                 (txdata == 8'hff && chan_error1 == 14'h2000) ? (chan_error2 << 1) :
                                                                chan_error2;

  // Check that if there or no errors, or just one error, the TX data
  // is the same as the RX data
  if (((chan_error & (chan_error - 1)) == 0) && txdata != rxdata)
  begin
    $display ("***FAIL***: single bit error at count == %d", count);
    if (TEST_GUI)
      $stop;
    else
      $finish;
  end
  // Check that if there are two bits in error, that the rxerror signal is asserted
  else if (chan_error != 0 && ((chan_error & (chan_error - 1)) != 0) && rxerror == 1'b0)
  begin
    $display ("***FAIL***: double bit error at count == %d", count);
    if (TEST_GUI)
      $stop;
    else
      $finish;
  end

  // Reached then end of the test if last byte and last bits set for the two
  // error channels.
  if (txdata == 8'hff && chan_error1 == 14'h2000 && chan_error2 == 14'h1000)
  begin
    $display("PASS");
    if (TEST_GUI)
      $stop;
    else
      $finish;
  end

end

`endif

endmodule
