`timescale 1ms / 1ms
//////////////////////////////////////////////////////////////////////////////////
// Company: LRDE
// Engineer: Yuvraj Singh Rathore
// 
// Create Date: 02.11.2025
// Design Name: Traffic Light Controller
// Module Name: traffic_light_controller
// Project Name: FSM-based Traffic System
// Target Devices: Generic FPGA
// Description: 
//      A finite state machine controlling traffic lights for two roads (NS & EW).
//      Each direction alternates between Green, Yellow, and Red states.
// 
// Dependencies: None
// 
//////////////////////////////////////////////////////////////////////////////////


module top_traffic_light_controller #(
    //-----Input Frequency Value--------
    parameter c_INPUT_FREQ_HZ = 1000, // Input Frequency in HZ 
    //------Timing Constant-------------
    parameter c_GREEN_TIME = 10, //Seconds
    parameter c_YELLOW_TIME = 2 //Seconds
)
(
    input i_clk, 
    input i_reset,
    output reg [2:0] o_ns_lights, //North-South Light {Red, Yellow,Green}
    output reg [2:0] o_ew_lights //East_West Light {Red, Yellow,Green}
    );
    //-----Calculating the counter value based on the input frequency and Green and yellow time----------
    localparam c_GREEN_COUNT  = c_INPUT_FREQ_HZ * c_GREEN_TIME; 
    localparam c_YELLOW_COUNT = c_INPUT_FREQ_HZ * c_YELLOW_TIME; 
    
    //-----State Enconding------
    localparam S_NS_GREEN   = 3'd0;
    localparam S_NS_YELLOW  = 3'd1;
    localparam S_EW_GREEN   = 3'd2;
    localparam S_EW_YELLOW  = 3'd3;
    
    
    
    //------Internal Signals----
    reg [2:0]  r_state,r_next_state;
    integer r_counter; //Counts upto 10 seconds 
    
    //------Sequential Next State Logic-----
    always @(posedge i_clk or posedge i_reset)
    begin
        if(i_reset)
            begin
                r_state <= S_NS_GREEN;
                r_counter <= 0; 
            end
        else 
            begin  
                r_state <= r_next_state;
               
                //Increment Counter 
                if(r_state == S_NS_GREEN || r_state == S_EW_GREEN) begin
                    if(r_counter < c_GREEN_COUNT)
                        r_counter <= r_counter + 1'b1;
                    else
                        r_counter <= 0;
                end else begin// State is yellow
                    if(r_counter < c_YELLOW_COUNT)
                        r_counter <= r_counter + 1'b1;
                    else
                        r_counter <= 0;
                end
            end
    end
    
    //----Next State Logic-----
    always @(*)
    begin
    r_next_state = r_state;
        case (r_state)
            S_NS_GREEN   : begin
                            if (r_counter == c_GREEN_COUNT)
                                r_next_state = S_NS_YELLOW;
                            else 
                                r_next_state = r_state;
                           end
            S_NS_YELLOW  : begin
                            if (r_counter == c_YELLOW_COUNT)
                                r_next_state = S_EW_GREEN;
                            else 
                                r_next_state = r_state;
                           end
            S_EW_GREEN   : begin
                            if (r_counter == c_GREEN_COUNT)
                                r_next_state = S_EW_YELLOW;
                            else 
                                r_next_state = r_state;            
                           end
            S_EW_YELLOW  : begin
                            if (r_counter == c_YELLOW_COUNT)
                                r_next_state = S_NS_GREEN;
                            else 
                                r_next_state = r_state;            
                           end
            default      : begin
                           end
        endcase
    end
    
    
    //-----Output Logic--------
    always @(*)
    begin
        // Default all lights off
        o_ns_lights = 3'b100;
        o_ew_lights = 3'b100;
        case (r_state)
            S_NS_GREEN   : begin
                            o_ns_lights = 3'b001;
                            o_ew_lights = 3'b100;
                           end
            S_NS_YELLOW  : begin
                            o_ns_lights = 3'b010;
                            o_ew_lights = 3'b100;
                           end
            S_EW_GREEN   : begin
                            o_ns_lights = 3'b100;
                            o_ew_lights = 3'b001;
                           end
            S_EW_YELLOW  : begin
                            o_ns_lights = 3'b100;
                            o_ew_lights = 3'b010;                                    
                           end
        endcase
    end
    
endmodule
