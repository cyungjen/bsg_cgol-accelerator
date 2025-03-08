module bsg_cgol_ctrl #(
   parameter `BSG_INV_PARAM(max_game_length_p)
  ,localparam game_len_width_lp=`BSG_SAFE_CLOG2(max_game_length_p+1)
) (
   input clk_i
  ,input reset_i

  ,input en_i

  // Input Data Channel
  ,input  [game_len_width_lp-1:0] frames_i
  ,input  v_i
  ,output ready_o

  // Output Data Channel
  ,input yumi_i
  ,output v_o

  // Cell Array
  ,output update_o
  ,output en_o
);

  wire unused = en_i; // for clock gating, unused
  
  // TODO: Design your control logic
  parameter IDLE=0, INIT=1, RUNNING=2, OUTPUT=3, DONE=4;


  reg [2:0] state;
  reg [2:0] next_state;

  reg [game_len_width_lp-1:0] frame_counter;

  // ========================
  // State Register
  // ========================
  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i)
        state <= IDLE;
    else
        state <= next_state;
  end
//   always_ff @(posedge clk_i) begin
//     if(v_o|v_i)
//     $display("Time %0t: State=%d, update_o=%b, en_o=%b, v_o=%b, v_i=%b", 
//             $time, state, update_o, en_o, v_o, v_i);
//   end
  // ========================
  // Next State Logic
  // ========================
  always_comb begin
      next_state = state;
      case (state)
          IDLE:    if (v_i) next_state = INIT;                   // Wait for new game request
          INIT:    next_state = RUNNING;                         // Pulse update, move to execution
          RUNNING: if (frame_counter == 1) next_state = OUTPUT;  // Game finished. frame_counter == 1 because 
          OUTPUT:  if (yumi_i) next_state = DONE;                // Data sent successfully
          DONE:    next_state = IDLE;                            // Reset and wait for next game
      endcase
  end

  // ========================
  // Frame Counter Logic
  // ========================
  always_ff @(posedge clk_i) begin
      if (state == IDLE && v_i)
          frame_counter <= frames_i;                        // Load number of frames
      else if (state == RUNNING && frame_counter > 0)
          frame_counter <= frame_counter - 1;               // Decrease frame count
  end
  // reg [game_len_width_lp-1:0] frame_counter_next;
  // always_ff @(posedge clk_i) begin
  //   // if (state == RUNNING && frame_counter > 0)
  //     frame_counter_next <= frame_counter - 1;
  // end
  // always_ff @(posedge clk_i) begin
  //     if (state == IDLE && v_i)
  //         frame_counter <= frames_i;                        // Load number of frames
  //     else if (state == RUNNING && frame_counter > 0)
  //         frame_counter <= frame_counter_next;               // Decrease frame count
  // end

  // ========================
  // Control Signal Outputs
  // ========================
  assign ready_o  = (state == IDLE);   // Ready when in IDLE
  assign update_o = (state == IDLE && v_i==1'b1);   // Pulse update in INIT
  assign en_o     = (state[1]& ~state[0]); // RUNNING Enable execution
  assign v_o      = (state == OUTPUT ); // Output valid when in OUTPUT state

endmodule
