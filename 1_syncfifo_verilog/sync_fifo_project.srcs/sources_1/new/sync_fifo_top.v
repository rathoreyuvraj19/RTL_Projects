`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: LRDE
// Engineer: Yuvraj Singh
// 
// Create Date: 23.10.2025 14:04:37
// Design Name: 
// Module Name: sync_fifo_top
// Project Name: sync_fifo
// Target Devices: 
// Tool Versions: 
// Description: Parameterized synchronous FIFO with full and empty flags.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//Code Design
module sync_fifo_top
 //Parameter Section
#(parameter FIFO_DEPTH = 8,
  parameter DATA_WIDTH = 32
)
(
    input i_clk,
    input i_reset,
    input i_wr_en,
    input i_rd_en,
    input i_cs,
    input [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data,
    output o_full,
    output o_empty
    );
    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);
    
    // Declare a 2-Dimensional array to store the data
    reg [DATA_WIDTH-1 : 0] fifo [0 : FIFO_DEPTH-1];
    
    // wr/rd pointer with 1 extra bit MSB
    reg [PTR_WIDTH : 0] write_pointer;
    reg [PTR_WIDTH : 0] read_pointer;
    
    //Write 
    always @(posedge i_clk or posedge i_reset) begin
        if(i_reset) 
            write_pointer <= 0 ;
        else if(i_cs && i_wr_en && !o_full)
            begin
                fifo[write_pointer[PTR_WIDTH-1:0]] <= i_data;
                write_pointer <= write_pointer + 1'b1;
            end
    end
    
    //Read 
    always @(posedge (i_clk) or posedge (i_reset)) begin
        if(i_reset) 
            begin
                read_pointer <= 0;
                o_data <= 0;
            end
        else if (i_cs && i_rd_en && !o_empty)
            begin
                o_data <= fifo[read_pointer[PTR_WIDTH-1:0]];
                read_pointer <= read_pointer + 1'b1;
            end
    end
    
    //Declare the empty and full logic
    assign o_empty = (read_pointer == write_pointer);
    assign o_full  = (write_pointer[PTR_WIDTH] != read_pointer[PTR_WIDTH]) &&
                 (write_pointer[PTR_WIDTH-1:0] == read_pointer[PTR_WIDTH-1:0]);

        
endmodule















