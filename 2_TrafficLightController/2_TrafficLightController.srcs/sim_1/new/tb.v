`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2025 13:26:15
// Design Name: 
// Module Name: tb
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


module tb(

    );
     //-----Input Frequency Value--------
    parameter c_INPUT_FREQ_HZ = 1000.0; // Input Frequency in HZ 
    //------Timing Constant-------------
    parameter c_GREEN_TIME = 10; //Seconds
    parameter c_YELLOW_TIME = 2; //Seconds
    localparam time c_CLK_PERIOD = (1s/c_INPUT_FREQ_HZ);
    
    
    //------DUT I/O-----------
    reg i_clk=0;
    reg i_reset=1;
    wire [2:0] o_ns_lights;
    wire [2:0] o_ew_lights;
    
    //--------------DUT Instantiation------------------
    top_traffic_light_controller #(
     .c_INPUT_FREQ_HZ (c_INPUT_FREQ_HZ), // Input Frequency in HZ 
     .c_GREEN_TIME (c_GREEN_TIME), //Seconds
     .c_YELLOW_TIME (c_YELLOW_TIME) //Seconds
)
DUT(
     .i_clk (i_clk), 
     .i_reset (i_reset),
     .o_ns_lights (o_ns_lights), //North-South Light {Red, Yellow,Green}
     .o_ew_lights(o_ew_lights) //East_West Light {Red, Yellow,Green}
    );
    
    
    
    //------------------Clock Generation---------------
    initial begin
        i_clk = 0;
        forever #(c_CLK_PERIOD/2.0) i_clk = ~i_clk;
    end
    
    //----------Reset Genearation--------------
    initial begin 
        i_reset = 1;
        #5 // Hold the reset high for few cycles
        i_reset = 0;
    end 
    
    //--------------Monitor Outputs--------
    initial begin 
        $display("----------------------------------------------------------");
        $display("Time\t\tState\t\tNS Lights\tEW Lights");
        $display("----------------------------------------------------------");
        $monitor("%0t\t%b\t%b\t\t%b", $time, DUT.r_state, o_ns_lights, o_ew_lights);
    end
    
//    //---------Simulation run time control--------------
//    initial begin
//        #(c_INPUT_FREQ_HZ * (c_GREEN_TIME + c_YELLOW_TIME) * 4);
//        $display("Simulation complete.");
//        $finish;
//    end 
    
    //---------Assertion-----------------
    
    always @(posedge(i_clk))
    begin
        //Ensure that both the green signals are never green simulanitously
        if (o_ns_lights[0] && o_ew_lights[0]) begin
            $error("ERROR: Both directions GREEN at time %0t!", $time);
        end
    end
endmodule























