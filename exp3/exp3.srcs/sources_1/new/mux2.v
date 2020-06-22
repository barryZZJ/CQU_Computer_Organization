module mux2 #(parameter WIDTH = 32)
            (input wire[WIDTH-1:0] a,b,
              input wire s,
              output wire[WIDTH-1:0] y);
    
    assign y = s ? a : b;
endmodule
