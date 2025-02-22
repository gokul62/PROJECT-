//design code for slave 

parameter w = 8;
parameter d = 8;

module slave (

  // input declaration
  input psel;
  input penable;
  input clk;
  input pwrite;
  input preset;
  input [(w-1):0] pw_data;
  input [(d-1):0] paddr;

  //output declaration 
  output reg [(w-1):0] pr_data;
  output reg pslverr;
  output reg pready;

);

  //mem array 

  reg [7:0] temp [16:0];

  //declaring the variable 

  integer i;

  // then procedure block 

  always@(posedge clk or penable )
    begin 

      if (preset)begin 
        pready <= 0;
        pslverr <= 0;
        pr_data <= 0;

        for (i=0;i<=16;i=i+1)
          temp[i] <= 0;
      end 

      else  begin 

        if (sel==1)begin  // module is in active region 
          if(penable ==1)begin  // operation begins
            pready <= 1;
            if (pwrite == 1) begin 
              if (paddr == 4'hf);
              temp[paddr] <= pw_data ;
            end 

            else begin 
              pslverr <= 1; // invalid address error when the address get overflow it comes to slverr
            end 
          end 

            else begin 
              pr_data = temp[paddr] // write == 0 then perform read operation 
            end 
        end 

        else begin 
          pready <= o; // penable is 0
        end 
      end 
      else begin 
        pready <= 0; // psel is 0
      end 
    end 
endmodule 


// testbench code for master 
parameter w = 8;
parameter d = 8;

module master ;

  wire [(w-1):0] pr_data;
  wire pslverr;
  wire pready;

  reg clk,psel,penable,preset;
  reg [(w-1):0] pw_data;
  reg [(w-8):0] paddr;
  reg pwrite ;

  slave dut (
    .clk(clk),
    .psel(psel),
    .preset(preset),
    .penable(penable),
    .pw_data(pw_data),
    .pwrite(pwrite),
    .pr_data(pr_data),
    .paddr(paddr),
    .pslverr(pslverr),
    .pready(pready)
  );

  // clock generation 

 initial begin 
   pclk =0;
   forever #5 clk = ~clk ;
 end 

  //reset logic 

  initial begin 

    preset = 1; // activate reset 
    repeat(2) @(posedge clk);
    preset = 0; // deactivate reset 
    100;
    $finish;

    // test case

    initial begin 
      $value$plusargs("test_case =%s ",test_case); //$value$plusargs (user_string, variable)
      case (test_case)

        //write case 

        "write" : 
          begin
            @(negedge preset); // preset is low 
        for (i=0;i<=5;i++)begin 
          @(posedge clk);
          psel <= 1;
          pw_data <= $random;
          paddr <= i;
          pwrite <= 1 ;
          $display (" pw_data = %b, paddr =%b ",pw_data,paddr);

          @(posedge clk);
          #2penable <= 1
          wait (pready == 1);

          @(posedge clk);
          #2 penable =0;
          psel <= 0;
        end 
            pwrite <= 0;
          end 

        "read" : begin 
          @(negedge preset);
          for (j=0;j<=5;j=j+1)begin 
            @(posedge clk);
            psel <= 1;
            paddr <= j;
            pwrite <=0;

            @(posedge clk);
            #2 penable <=1;
            wait (pready == 1);
            $display ("paddr = %b, pr_data = %b ",paddr,pr_data);

            @(posedge clk);
            #2 penable = 0;
            psel <= 0;
          end 
        end 

        "paddr_out" : begin 
          @(negedge reset);
          @(posedge clk);
         #2 psel <= 1;
          pwrite <= 1;
          paddr <= 8'h17; // address out of range 
         pw_data = 8'b 1010 1111;

          @(posedge clk);
         #2 penable = 1;
          wait(pready == 1);
          @(posedge clk );
          penable = 0;
          #2;
          psel <=0;
        end 
        endcase
    end 

        initial begin 
          $dumpfile ("dump.vcd");
          $dumpvars();
        end 

        endmodule 

    //output 
Write: paddr=00, pw_data=123
Write: paddr=01, pw_data=87
Write: paddr=02, pw_data=200
Write: paddr=03, pw_data=45
Write: paddr=04, pw_data=178
Write: paddr=05, pw_data=99

            


          
          

        
    
    
      

     











      

  
  
