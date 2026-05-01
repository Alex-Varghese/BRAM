`timescale 1ns/1ps

module dual_port_bram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8
)(
    // =========================
    // PORT A
    // =========================
    input  wire                     clk_a,
    input  wire                     en_a,
    input  wire                     we_a,
    input  wire [(DATA_WIDTH/8)-1:0] be_a,
    input  wire [ADDR_WIDTH-1:0]    addr_a,
    input  wire [DATA_WIDTH-1:0]    din_a,
    output reg  [DATA_WIDTH-1:0]    dout_a,

    // =========================
    // PORT B
    // =========================
    input  wire                     clk_b,
    input  wire                     en_b,
    input  wire                     we_b,
    input  wire [(DATA_WIDTH/8)-1:0] be_b,
    input  wire [ADDR_WIDTH-1:0]    addr_b,
    input  wire [DATA_WIDTH-1:0]    din_b,
    output reg  [DATA_WIDTH-1:0]    dout_b
);

    // =========================
    // MEMORY
    // =========================
    localparam DEPTH = (1 << ADDR_WIDTH);

    // FPGA hint for BRAM inference
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    integer i;

    // =========================
    // PORT A
    // =========================
    always @(posedge clk_a) begin
        if (en_a) begin

            // READ FIRST (standard BRAM behavior)
            dout_a <= mem[addr_a];

            // WRITE (byte enable)
            if (we_a) begin
                for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                    if (be_a[i]) begin
                        mem[addr_a][8*i +: 8] <= din_a[8*i +: 8];
                    end
                end
            end

        end
    end

    // =========================
    // PORT B
    // =========================
    always @(posedge clk_b) begin
        if (en_b) begin

            // READ
            dout_b <= mem[addr_b];

            // WRITE
            if (we_b) begin
                for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
                    if (be_b[i]) begin
                        mem[addr_b][8*i +: 8] <= din_b[8*i +: 8];
                    end
                end
            end

        end
    end

endmodule
