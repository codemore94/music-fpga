// file: Clock48MHZ_tb.v
// 
// (c) Copyright 2008 - 2011 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 

//----------------------------------------------------------------------------
// Clocking wizard demonstration testbench
//----------------------------------------------------------------------------
// This demonstration testbench instantiates the example design for the 
//   clocking wizard. Input clocks are toggled, which cause the clocking
//   network to lock and the counters to increment.
//----------------------------------------------------------------------------

`timescale 1ps/1ps

`define wait_lock @(posedge LOCKED)

module Clock48MHZ_tb ();

  // Clock to Q delay of 100ps
  localparam  TCQ              = 100;


  // timescale is 1ps/1ps
  localparam  ONE_NS      = 1000;
  localparam  PHASE_ERR_MARGIN   = 100; // 100ps
  // how many cycles to run
  localparam  COUNT_PHASE = 1024;
  // we'll be using the period in many locations
  localparam time PER1    = 10.000*ONE_NS;
  localparam time PER1_1  = PER1/2;
  localparam time PER1_2  = PER1 - PER1/2;

  // Declare the input clock signals
  reg         CLK_IN1     = 1;

  // The high bits of the sampling counters
  wire [4:1]  COUNT;
  // Status and control signals
  wire        LOCKED;
  reg         COUNTER_RESET = 0;
wire [4:1] CLK_OUT;
//Freq Check using the M & D values setting and actual Frequency generated 
real period1;
real ref_period1;
localparam  ref_period1_clkin1 = (10.000*1*31.750*1000/15.250);
time prev_rise1;
real period2;
real ref_period2;
localparam  ref_period2_clkin1 = (10.000*1*8*1000/15.250);
time prev_rise2;
real period3;
real ref_period3;
localparam  ref_period3_clkin1 = (10.000*1*15*1000/15.250);
time prev_rise3;
real period4;
real ref_period4;
localparam  ref_period4_clkin1 = (10.000*1*103*1000/15.250);
time prev_rise4;

  reg [13:0]  timeout_counter = 14'b00000000000000;

  // Input clock generation
  //------------------------------------
  always begin
    CLK_IN1 = #PER1_1 ~CLK_IN1;
    CLK_IN1 = #PER1_2 ~CLK_IN1;
  end

  // Test sequence
  reg [15*8-1:0] test_phase = "";
  initial begin
    // Set up any display statements using time to be readable
    $timeformat(-12, 2, "ps", 10);
    $display ("Timing checks are not valid");
    COUNTER_RESET = 0;
    test_phase = "wait lock";
    `wait_lock;
    #(PER1*6);
    COUNTER_RESET = 1;
    #(PER1*19.5)
    COUNTER_RESET = 0;
    #(PER1*1)
    $display ("Timing checks are valid");
    test_phase = "counting";
    #(PER1*COUNT_PHASE);
    if ((period1 -ref_period1_clkin1) <= 100 && (period1 -ref_period1_clkin1) >= -100) begin
    $display("Freq of CLK_OUT[1] ( in MHz ) : %0f\n", 1000000/period1);
    end else 
    $display("ERROR: Freq of CLK_OUT[1] is not correct"); 
    if ((period2 -ref_period2_clkin1) <= 100 && (period2 -ref_period2_clkin1) >= -100) begin
    $display("Freq of CLK_OUT[2] ( in MHz ) : %0f\n", 1000000/period2);
    end else 
    $display("ERROR: Freq of CLK_OUT[2] is not correct"); 
    if ((period3 -ref_period3_clkin1) <= 100 && (period3 -ref_period3_clkin1) >= -100) begin
    $display("Freq of CLK_OUT[3] ( in MHz ) : %0f\n", 1000000/period3);
    end else 
    $display("ERROR: Freq of CLK_OUT[3] is not correct"); 
    if ((period4 -ref_period4_clkin1) <= 100 && (period4 -ref_period4_clkin1) >= -100) begin
    $display("Freq of CLK_OUT[4] ( in MHz ) : %0f\n", 1000000/period4);
    end else 
    $display("ERROR: Freq of CLK_OUT[4] is not correct"); 

    $display("SIMULATION PASSED");
    $display("SYSTEM_CLOCK_COUNTER : %0d\n",$time/PER1);
    $finish;
  end


   always@(posedge CLK_IN1) begin
      timeout_counter <= timeout_counter + 1'b1;
      if (timeout_counter == 14'b10000000000000) begin
         if (LOCKED != 1'b1) begin
            $display("ERROR : NO LOCK signal");
            $display("SYSTEM_CLOCK_COUNTER : %0d\n",$time/PER1);
            $finish;
         end
      end
   end

  // Instantiation of the example design containing the clock
  //    network and sampling counters
  //---------------------------------------------------------
  Clock48MHZ_exdes 
    dut
   (// Clock in ports
    .CLK_IN1            (CLK_IN1),
    // Reset for logic in example design
    .COUNTER_RESET      (COUNTER_RESET),
    .CLK_OUT            (CLK_OUT),
    // High bits of the counters
    .COUNT              (COUNT),
    // Status and control signals
    .LOCKED             (LOCKED));


// Freq Check 
initial
  prev_rise1 = 0;

always @(posedge CLK_OUT[1])
begin
  if (prev_rise1 != 0)
    period1 = $time - prev_rise1;
  prev_rise1 = $time;
end
initial
  prev_rise2 = 0;

always @(posedge CLK_OUT[2])
begin
  if (prev_rise2 != 0)
    period2 = $time - prev_rise2;
  prev_rise2 = $time;
end
initial
  prev_rise3 = 0;

always @(posedge CLK_OUT[3])
begin
  if (prev_rise3 != 0)
    period3 = $time - prev_rise3;
  prev_rise3 = $time;
end
initial
  prev_rise4 = 0;

always @(posedge CLK_OUT[4])
begin
  if (prev_rise4 != 0)
    period4 = $time - prev_rise4;
  prev_rise4 = $time;
end

endmodule
