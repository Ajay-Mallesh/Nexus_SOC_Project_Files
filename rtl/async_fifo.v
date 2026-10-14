module async_fifo #(parameter WIDTH=512, DEPTH=16) (
    input  wire wclk, wrst_n, winc,
    input  wire [WIDTH-1:0] wdata,
    input  wire rclk, rrst_n, rinc,
    output reg  [WIDTH-1:0] rdata,
    output wire full, empty
);
    // Address width calculation
    localparam ADDR_WIDTH = $clog2(DEPTH);
    
    // Internal pointers and RAM
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0] wptr, rptr;
    reg [ADDR_WIDTH:0] wptr_gray, rptr_gray;
    reg [ADDR_WIDTH:0] wptr_sync1, wptr_sync2, rptr_sync1, rptr_sync2;

    // Write Logic
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr <= 0; wptr_gray <= 0;
        end else if (winc && !full) begin
            mem[wptr[ADDR_WIDTH-1:0]] <= wdata;
            wptr <= wptr + 1;
            wptr_gray <= (wptr + 1) ^ ((wptr + 1) >> 1);
        end
    end

    // Read Logic
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr <= 0; rptr_gray <= 0;
        end else if (rinc && !empty) begin
            rdata <= mem[rptr[ADDR_WIDTH-1:0]];
            rptr <= rptr + 1;
            rptr_gray <= (rptr + 1) ^ ((rptr + 1) >> 1);
        end
    end

    // Pointer Synchronization (2-Stage FF)
    always @(posedge rclk) {wptr_sync2, wptr_sync1} <= {wptr_sync1, wptr_gray};
    always @(posedge wclk) {rptr_sync2, rptr_sync1} <= {rptr_sync1, rptr_gray};

    // Full/Empty Flags
    assign full  = (wptr_gray == {~rptr_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rptr_sync2[ADDR_WIDTH-2:0]});
    assign empty = (rptr_gray == wptr_sync2);
endmodule