module project_1(

  input clk_i,
  input reset_i,
  input write_en,
  input read_en,
  input data_i,

  output reg data_o,
  output reg full_o,
  output reg empty_o
);

  parameter width = 8;

  //create mem

  reg [7:0] mem [width -1:0];

  //pointers and counter 

  reg[2:0] write_ptr;
  reg[2:0] read_ptr;
  reg[2:0] count ;

// full and empty flags 

  assign full_o = (count == width );
  assign empty_o = (count == 0);

  //write process 

  always@(posedge clk_i or negedge reset_i)
    begin 

      if(!reset ) begin 
        write_ptr <= 3'b0;
        end 
      
      else begin 
        
          if (write_en && !full_o)
            begin 
              mem[write_ptr] <= data_i;
              write_ptr = write_ptr++;
         end
      end 
    end 

  // read process 

  always@(posedge clk_i or negedge reset_i)
    begin 

      if (!reset_i)
        begin 
          read_en = 3'b0;
        end 
    else begin 
      if (read_en  && !empty_o)
        begin 
          data_o <= mem[read_ptr];
          read_ptr <= read_ptr++;
        end 
    end 
    end 

  //count

  always@(posedge clk_i or negedge reset_i)begin 

    if (!reset_i)begin 
     count = 2'b0;
    end 

    else begin 
      case ({write_en,read_n})
        2'b10 : if(!full_o) count = count+1 ;
        2'b01 : if(!empty_o) count = count-1 ;
        2'b11 : count <= count ; // both read and write same time 
        default : count <= count ; //no operation 
      endcase 

    end 
  end 
endmodule 

//testbench 

module FIFO_TB;

  reg write_en;
  reg read_en;
  reg data_i;
  reg clk_i,reset_i;

  wire full_o;
  wire empty_o;
  wire data_o;

  FIFO dut ( 
    clk_i.(clk_i),
    reset_i(reset_i),
    data_i(data_i),
    data_o(data_o),
    write_en(write_en),
    read_en(read_en),
    full_o(full_o),
    empty_o(empty_o)
  );

  clk_i = 0;
  always #5clk_i = ~clk_i

    integer i; //for loop running 

  initial begin 

    reset_i = 2'b0;
    data_i = 8'b0;
    write_en = 2'b0;
    read_en = 2'b0;

    #10 reset_i = 1;

     // Test Writing to FIFO
        wr_en_i = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            data_i = i;
            #10;
            $display("Time: %0t | Write: %d | Full: %b | Empty: %b", $time, data_i, full_o, empty_o);
        end
        wr_en_i = 1'b0;

        // Test Reading from FIFO
        rd_en_i = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            #10;
            $display("Time: %0t | Read: %d | Expected: %d | Empty: %b", $time, data_o, i, empty_o);
        end
        rd_en_i = 1'b0;

        // Underflow Test: Reading from Empty FIFO
        rd_en_i = 1'b1;
        #10;
        $display("Time: %0t | Read Attempted from Empty FIFO | Data: %d | Empty: %b", $time, data_o, empty_o);
        rd_en_i = 1'b0;

        // Overflow Test: Writing More Than Capacity
        wr_en_i = 1'b1;
        for (i = 0; i < 10; i = i + 1) begin
            data_i = i;
            #10;
            $display("Time: %0t | Write: %d | Full: %b", $time, data_i, full_o);
        end
        wr_en_i = 1'b0;

        // Simultaneous Write & Read
        wr_en_i = 1'b1;
        rd_en_i = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            data_i = i + 16;
            #10;
            $display("Time: %0t | Write: %d | Read: %d | Full: %b | Empty: %b", 
                     $time, data_i, data_o, full_o, empty_o);
        end
        wr_en_i = 1'b0;
        rd_en_i = 1'b0;

        $stop;
    end
endmodule
    

  

  
    
    







  

        













  
  
  
