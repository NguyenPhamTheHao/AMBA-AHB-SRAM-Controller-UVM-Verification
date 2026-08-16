module byte_lane_masking_control(
    input logic [1:0] addr_control,
    input logic sram_write,
    input logic [2:0] sram_size,
    input logic sram_ce,
    output logic [3:0] sram_we
);
    always @(*) begin
            if (sram_ce && sram_write) begin
                case (sram_size)
                    3'b000: // 8-bit
                        sram_we[addr_control[1:0]] = 1'b1;
                    3'b001: // 16-bit
                        sram_we = (addr_control[1]) ? 4'b1100 : 4'b0011;
                    3'b010: // 32-bit
                        sram_we= 4'b1111;
                    default: sram_we= 4'b1111;
                endcase
            end
            else sram_we= 4'b0000;;
end
endmodule