`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:36:04 07/16/2023 
// Design Name: 
// Module Name:    AD9288 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AD9288(
  input wire clk,
  input wire rst_n,
  inout wire [7:0] adc_data,
  output reg adc_cs_n,
  output reg adc_wr_n,
  output reg adc_rd_n,
  output wire adc_busy
    );
// ADC Control Signals
  localparam IDLE = 2'b00;
  localparam START_CONVERSION = 2'b01;
  localparam READ_DATA = 2'b10;

  reg [1:0] adc_state;
  reg [7:0] adc_output;

  // Assign ADC Interface Signals
  assign adc_data = adc_output;
  assign adc_busy = (adc_state != IDLE);

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      // Reset state
      adc_state <= IDLE;
      adc_output <= 8'b0;
      adc_cs_n <= 1;
      adc_wr_n <= 1;
      adc_rd_n <= 1;
    end else begin
      case (adc_state)
        IDLE: begin
          // Wait for ADC start command
          if (adc_start) begin
            adc_state <= START_CONVERSION;
            adc_cs_n <= 0;  // Enable ADC Chip Select
            adc_wr_n <= 0;  // Set ADC Write Signal
          end
        end

        START_CONVERSION: begin
          // Wait for ADC conversion completion
          adc_state <= READ_DATA;
          adc_wr_n <= 1;  // Clear ADC Write Signal
          adc_rd_n <= 0;  // Set ADC Read Signal
        end

        READ_DATA: begin
          // Read ADC data
          adc_output <= adc_data;  // Capture ADC Data
          adc_rd_n <= 1;           // Clear ADC Read Signal
          adc_cs_n <= 1;           // Disable ADC Chip Select
          adc_state <= IDLE;       // Return to Idle State
        end
      endcase
    end
  end


endmodule
