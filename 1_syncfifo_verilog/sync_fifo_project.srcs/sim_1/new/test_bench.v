`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2025 11:20:32
// Design Name: 
// Module Name: test_bench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module self_check_test_bench 
(

    );
    //Parametes
    localparam int FIFO_DEPTH = 8;
    localparam int DATA_WIDTH = 32;
    localparam int CLK_FREQUENCY_MHZ = 100; //Specify the clock frequnecy here in MHZ
    localparam time CLK_PERIOD = (1.0/CLK_FREQUENCY_MHZ)*1us;
    
    //Test Bench Signals 
    reg i_clk=1;
    reg i_reset=1;
    reg i_wr_en=0;
    reg i_rd_en=1;
    reg i_cs=0;    
    reg [DATA_WIDTH-1:0] i_data=0;
    wire [DATA_WIDTH-1:0] o_data;
    wire o_full;
    wire o_empty;
    
    //ScoreBoard Memory
    reg [DATA_WIDTH-1:0] golden_fifo [0:FIFO_DEPTH-1] = '{default: 8'd0};;
    int wr_ptr = 0;
    int rd_ptr = 0;
    int golden_count = 0;
    int total_errors = 0;
    
    //DUT Instantiation
    sync_fifo_top UUT(
        .i_clk  (i_clk  ),
        .i_reset(i_reset),
        .i_wr_en(i_wr_en),
        .i_rd_en(i_rd_en),
        .i_cs   (i_cs   ),
        .i_data (i_data ),
        .o_data (o_data ),
        .o_full (o_full ),
        .o_empty(o_empty)
    );
    
    
    //Clock Generation : 
    initial begin
        i_clk = 0;
        forever #(CLK_PERIOD/2) i_clk = ~i_clk;
    end
    
//    //Task: Wrtie to FIFO (With Protection)
//    task fifo_write(input [DATA_WIDTH-1:0] data);
//    begin
//        @(posedge i_clk);
//        if(!o_full) begin
//            i_cs = 1'b1;
//            i_wr_en = 1'b1;
//            i_data = data;
//        end else begin
//            $display("[%0t] FIFO FULL. Write ignored.", $time);
//        end 
//        @(posedge i_clk);
//        i_cs = 1'b0;
//        i_wr_en = 1'b0;
//    end
//    endtask    

    //Task: Wrtie to FIFO (No protection/ Stress on DUT)
    task automatic fifo_write(input [DATA_WIDTH-1:0] data);
    begin
        @(posedge i_clk);
        i_cs = 1'b1;
        i_wr_en = 1'b1;
        i_data = data;
        
        //Expected Model update (only if not full)
        if(!o_full) begin
         golden_fifo[wr_ptr] = data; 
         wr_ptr = (wr_ptr + 1) % FIFO_DEPTH;//increments the write pointer by 1, but uses modulus (%) to make it wrap around once it reaches the FIFO's depth limit.
         golden_count++;
        end
        
        @(posedge i_clk);
        i_cs = 1'b0;
        i_wr_en = 1'b0;
        
        
    end
    endtask
    
    //Task: Read from FIFO
    task automatic fifo_read();
    reg [DATA_WIDTH-1 : 0] exp_data;
        begin
            @(posedge i_clk); // Applying the Chip select and read enable signals on positive edge of the clock
            i_cs = 1'b1;
            i_rd_en = 1'b1;
            @(posedge i_clk) // Waiting for the next positive edge of the clock and removing the signals
            i_cs = 1'b0;
            i_rd_en = 1'b0;
            
            //Reference Model Read (Only if its not empty)
            if(!o_empty) begin
                exp_data = golden_fifo[rd_ptr];
                rd_ptr = (rd_ptr+1)%FIFO_DEPTH;
                golden_count--;
                
                // Compare expected vs actual
                if (o_data !== exp_data) begin
                    $display("[%0t] ❌ ERROR: Expected %0d, got %0d", $time, exp_data, o_data);
                    total_errors++;
                end else begin
                    $display("[%0t] ✅ PASS: Read %0d matched", $time, o_data);
                end
            end
        end
    endtask
    
    //--------- Main test sequence -----------
    initial begin
        i_reset =1'b1; 
        i_wr_en =1'b0; 
        i_rd_en =1'b0; 
        i_cs    =1'b0;    
        i_data  = 0;
        #(5*CLK_PERIOD); //Delay of 5 clock cycles
        i_reset = 0;
        $display("[%0t] Reset deasserted. Starting test...", $time);

        //Write all enteries
        for(int i =0 ; i < FIFO_DEPTH ; i++) begin
            fifo_write(i*10);
        end // Array Should be full by now
        
        //Trying to fill in one more element to check the reaction
        fifo_write(999);
        
        //golden_fifo[2] = 3;
        
        //Write all enteries
        for(int i =0 ; i < FIFO_DEPTH ; i++) begin
            fifo_read();
        end // Array Should be empty by now
        
        fifo_read(); // DUT should not respond to the read command when its empty
        
        //Finally checking the total errors
        if(!total_errors) 
            $display("\n✅ TEST PASSED: FIFO behaved correctly under all conditions.");
        else
            $display("\n❌ TEST FAILED: %0d errors detected.", total_errors);
        #50;
        $finish;
    end
endmodule
