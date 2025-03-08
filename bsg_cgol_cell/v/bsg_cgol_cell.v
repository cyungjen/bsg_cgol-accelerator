/**
* Conway's Game of Life Cell
*
* data_i[7:0] is status of 8 neighbor cells
* data_o is status this cell
* 1: alive, 0: death
*
* when en_i==1:
*   simulate the cell transition with 8 given neighors
* else when update_i==1:
*   update the cell status to update_val_i
* else:
*   cell status remains unchanged
**/

module bsg_cgol_cell (
    input clk_i

    ,input en_i          
    ,input [7:0] data_i

    ,input update_i     
    ,input update_val_i

    ,output logic data_o
  );

  // TODO: Design your bsg_cgl_cell
  // Hint: Find the module to count the number of neighbors from basejump

  wire [3:0] num_alive;
  reg data_o_comb;
  bsg_popcount #(.width_p(8)) popcount_inst (
      .i(data_i),
      .o(num_alive)
  );


  // always@(posedge clk_i) begin
  //   if(update_i) begin
  //     data_o <= update_val_i;
  //   end
  //   else if(en_i) begin
  //     if(data_o == 1'd1)begin//when the cell itself is alive
  //       if(num_alive < 2'd2 || num_alive > 3'd3)begin
  //         data_o <= 1'd0;
  //       end
  //       else begin
  //         data_o <= 1'd1;
  //       end
  //     end
  //     else if(data_o == '0)begin//when the cell itself is dead
  //       if(num_alive == 3'd3)begin
  //         data_o <= 1'd1;
  //       end
  //       else begin
  //         data_o <= 1'd0;
  //       end
  //     end
  //   end
  // end
  
  always_comb begin
    case(num_alive)
      4'd2: data_o_comb = data_o;  
      4'd3: data_o_comb = 1'b1;    
      default: data_o_comb = 1'b0; 
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (update_i)
      data_o <= update_val_i;
    else if (en_i)
      data_o <= data_o_comb;
  end

endmodule
