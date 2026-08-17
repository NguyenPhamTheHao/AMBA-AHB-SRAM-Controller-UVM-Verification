module sram(
    input logic clk,
    input logic resetn,
    input logic [15:0] A,
    input logic [31:0] WD,
    input logic [3:0] WE,
    input logic CE,
    output logic [31:0] RD
);
    //MEMORY OF SRAM
    //---Bank 0 ---
    logic [7:0] sram0_0 [0:8191];
    logic [7:0] sram0_1 [0:8191];
    logic [7:0] sram0_2 [0:8191];
    logic [7:0] sram0_3 [0:8191];
    //---Bank 1 ---
    logic [7:0] sram1_0 [0:8191];
    logic [7:0] sram1_1 [0:8191];
    logic [7:0] sram1_2 [0:8191];
    logic [7:0] sram1_3 [0:8191];

    // SIGNAL FOR SELECTING BANK
    logic bank_sel;

    //SIGNAL FOR ROW ADDRESS OF EACH SRAM
    logic [12:0] row_addr;

    //Empty of memory for clean simulation
    integer i;
    initial begin
        for(i=0;i<8192;i=i+1) begin
        sram0_0[i]=8'h0;  sram0_1[i]=8'h0;  sram0_2[i]=8'h0;  sram0_3[i]=8'h0; 
        sram1_0[i]=8'h0;  sram1_1[i]=8'h0;  sram1_2[i]=8'h0;  sram1_3[i]=8'h0; 
        end
    end
    assign bank_sel=A[15];
    assign row_addr=A[14:2];
    //Write operation
    always @(posedge clk) begin
        if(resetn && CE) begin
            if(!bank_sel) begin
                if(WE[0]) sram0_0[row_addr]<=WD[7:0];
                if(WE[1]) sram0_1[row_addr]<=WD[15:8];
                if(WE[2]) sram0_2[row_addr]<=WD[23:16];
                if(WE[3]) sram0_3[row_addr]<=WD[31:24];
            end
            else begin
                if(WE[0]) sram1_0[row_addr]<=WD[7:0];
                if(WE[1]) sram1_1[row_addr]<=WD[15:8];
                if(WE[2]) sram1_2[row_addr]<=WD[23:16];
                if(WE[3]) sram1_3[row_addr]<=WD[31:24];
            end
        end
    end

    //Read operation
    always @(*) begin
        if(!bank_sel) begin
            RD={sram0_3[row_addr], sram0_2[row_addr], sram0_1[row_addr], sram0_0[row_addr]};
        end
        else begin
            RD={sram1_3[row_addr], sram1_2[row_addr], sram1_1[row_addr], sram1_0[row_addr]};
        end
    end
endmodule