/*

Copyright (c) 2017 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * XFCP 2x1 switch
 */
module xfcp_switch_2x1
(
    input  wire        clk,
    input  wire        rst,

    /*
     * XFCP upstream ports
     */
    input  wire [7:0]  up_xfcp_0_in_tdata,
    input  wire        up_xfcp_0_in_tvalid,
    output wire        up_xfcp_0_in_tready,
    input  wire        up_xfcp_0_in_tlast,
    input  wire        up_xfcp_0_in_tuser,

    output wire [7:0]  up_xfcp_0_out_tdata,
    output wire        up_xfcp_0_out_tvalid,
    input  wire        up_xfcp_0_out_tready,
    output wire        up_xfcp_0_out_tlast,
    output wire        up_xfcp_0_out_tuser,

    input  wire [7:0]  up_xfcp_1_in_tdata,
    input  wire        up_xfcp_1_in_tvalid,
    output wire        up_xfcp_1_in_tready,
    input  wire        up_xfcp_1_in_tlast,
    input  wire        up_xfcp_1_in_tuser,

    output wire [7:0]  up_xfcp_1_out_tdata,
    output wire        up_xfcp_1_out_tvalid,
    input  wire        up_xfcp_1_out_tready,
    output wire        up_xfcp_1_out_tlast,
    output wire        up_xfcp_1_out_tuser,

    /*
     * XFCP downstream port
     */
    input  wire [7:0]  down_xfcp_in_tdata,
    input  wire        down_xfcp_in_tvalid,
    output wire        down_xfcp_in_tready,
    input  wire        down_xfcp_in_tlast,
    input  wire        down_xfcp_in_tuser,

    output wire [7:0]  down_xfcp_out_tdata,
    output wire        down_xfcp_out_tvalid,
    input  wire        down_xfcp_out_tready,
    output wire        down_xfcp_out_tlast,
    output wire        down_xfcp_out_tuser
);

localparam START_TAG = 8'hff;
localparam RPATH_TAG = 8'hfe;

localparam [2:0]
    DOWN_STATE_IDLE = 3'd0,
    DOWN_STATE_HEADER = 3'd1,
    DOWN_STATE_INSERT_ADDRESS = 3'd2,
    DOWN_STATE_INSERT_START = 3'd3,
    DOWN_STATE_TRANSFER = 3'd4;

reg [2:0] down_state_reg = DOWN_STATE_IDLE, down_state_next;

localparam [2:0]
    UP_STATE_IDLE = 3'd0,
    UP_STATE_HEADER_STORE = 3'd1,
    UP_STATE_HEADER_ADDRESS = 3'd2,
    UP_STATE_HEADER_CHECK_START = 3'd3,
    UP_STATE_HEADER_SEND = 3'd4,
    UP_STATE_TRANSFER = 3'd5,
    UP_STATE_DROP = 3'd6;

reg [2:0] up_state_reg = UP_STATE_IDLE, up_state_next;

reg down_hold;

reg down_need_start_reg = 1'b0, down_need_start_next;

reg [0:0] down_select_reg = 1'd0, down_select_next;
reg down_frame_reg = 1'b0, down_frame_next;

reg up_header_write;
reg [7:0] up_header_write_data;

reg [4:0] up_header_read_ptr_reg = 5'd0, up_header_read_ptr_next;
reg [4:0] up_header_write_ptr_reg = 5'd0, up_header_write_ptr_next;
reg [7:0] up_header_mem[31:0];

wire [7:0] up_header_read_data = up_header_mem[up_header_read_ptr_reg];

integer i;

initial begin
    for (i = 0; i < 32; i = i + 1) begin
        up_header_mem[i] = 0;
    end
end

reg [0:0] up_select_reg = 1'd0, up_select_next;
reg up_frame_reg = 1'b0, up_frame_next;


reg up_xfcp_0_in_tready_reg = 1'b0, up_xfcp_0_in_tready_next;
reg up_xfcp_1_in_tready_reg = 1'b0, up_xfcp_1_in_tready_next;
reg down_xfcp_in_tready_reg = 1'b0, down_xfcp_in_tready_next;

// internal datapath
reg [7:0] up_xfcp_out_tdata_int;
reg       up_xfcp_out_tvalid_int;
reg       up_xfcp_out_tready_int_reg = 1'b0;
reg       up_xfcp_out_tlast_int;
reg       up_xfcp_out_tuser_int;
wire      up_xfcp_out_tready_int_early;

reg [7:0] down_xfcp_out_tdata_int;
reg       down_xfcp_out_tvalid_int;
reg       down_xfcp_out_tready_int_reg = 1'b0;
reg       down_xfcp_out_tlast_int;
reg       down_xfcp_out_tuser_int;
wire      down_xfcp_out_tready_int_early;


assign up_xfcp_0_in_tready = up_xfcp_0_in_tready_reg;
assign up_xfcp_1_in_tready = up_xfcp_1_in_tready_reg;
assign down_xfcp_in_tready = down_xfcp_in_tready_reg;

// mux for upstream output control signals
reg current_output_tready;
reg current_output_tvalid;
always @* begin
    case (up_select_reg)
        1'd0: begin
            current_output_tvalid = up_xfcp_0_out_tvalid;
            current_output_tready = up_xfcp_0_out_tready;
        end
        1'd1: begin
            current_output_tvalid = up_xfcp_1_out_tvalid;
            current_output_tready = up_xfcp_1_out_tready;
        end
        default: begin
            current_output_tvalid = 1'b0;
            current_output_tready = 1'b0;
        end
    endcase
end

// mux for incoming upstream packet
reg [7:0] current_input_tdata;
reg current_input_tvalid;
reg current_input_tready;
reg current_input_tlast;
reg current_input_tuser;
always @* begin
    case (down_select_reg)
        1'd0: begin
            current_input_tdata = up_xfcp_0_in_tdata;
            current_input_tvalid = up_xfcp_0_in_tvalid;
            current_input_tready = up_xfcp_0_in_tready;
            current_input_tlast = up_xfcp_0_in_tlast;
            current_input_tuser = up_xfcp_0_in_tuser;
        end
        1'd1: begin
            current_input_tdata = up_xfcp_1_in_tdata;
            current_input_tvalid = up_xfcp_1_in_tvalid;
            current_input_tready = up_xfcp_1_in_tready;
            current_input_tlast = up_xfcp_1_in_tlast;
            current_input_tuser = up_xfcp_1_in_tuser;
        end
        default: begin
            current_input_tdata = 8'd0;
            current_input_tvalid = 1'b0;
            current_input_tready = 1'b0;
            current_input_tlast = 1'b0;
            current_input_tuser = 1'b0;
        end
    endcase
end

// downstream control logic
wire [1:0] request;
wire [1:0] acknowledge;
wire [1:0] grant;
wire grant_valid;
wire [0:0] grant_encoded;

// arbiter instance
arbiter #(
    .PORTS(2),
    .TYPE("ROUND_ROBIN"),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY("HIGH")
)
arb_inst (
    .clk(clk),
    .rst(rst),
    .request(request),
    .acknowledge(acknowledge),
    .grant(grant),
    .grant_valid(grant_valid),
    .grant_encoded(grant_encoded)
);

// request generation
assign request[0] = up_xfcp_0_in_tvalid & ~acknowledge[0];
assign request[1] = up_xfcp_1_in_tvalid & ~acknowledge[1];

// acknowledge generation
assign acknowledge[0] = up_xfcp_0_in_tvalid & up_xfcp_0_in_tready & up_xfcp_0_in_tlast;
assign acknowledge[1] = up_xfcp_1_in_tvalid & up_xfcp_1_in_tready & up_xfcp_1_in_tlast;

always @* begin
    down_state_next = DOWN_STATE_IDLE;

    down_hold = 1'b0;

    down_need_start_next = down_need_start_reg;

    down_select_next = down_select_reg;
    down_frame_next = down_frame_reg;

    up_xfcp_0_in_tready_next = 1'b0;
    up_xfcp_1_in_tready_next = 1'b0;

    down_xfcp_out_tdata_int = current_input_tdata;
    down_xfcp_out_tvalid_int = current_input_tvalid & current_input_tready & down_frame_reg;
    down_xfcp_out_tlast_int = current_input_tlast;
    down_xfcp_out_tuser_int = current_input_tuser;

    if (current_input_tready & current_input_tvalid) begin
        if (current_input_tlast) begin
            // end of frame detection
            down_frame_next = 1'b0;
        end
    end

    case (down_state_reg)
        DOWN_STATE_IDLE: begin
            // wait for incoming upstream packet
            if (grant_valid & down_xfcp_out_tready_int_reg) begin
                down_frame_next = 1'b1;
                down_select_next = grant_encoded;
                down_state_next = DOWN_STATE_HEADER;
            end else begin
                down_state_next = DOWN_STATE_IDLE;
            end
        end
        DOWN_STATE_HEADER: begin
            // transfer header until start tag or rpath tag
            if (current_input_tvalid & current_input_tready) begin
                if (current_input_tlast) begin
                    down_xfcp_out_tuser_int = 1'b1;
                    down_frame_next = 1'b0;
                    down_state_next = DOWN_STATE_IDLE;
                end else if (current_input_tdata == RPATH_TAG) begin
                    down_hold = 1'b1;
                    down_need_start_next = 1'b0;
                    down_state_next = DOWN_STATE_INSERT_ADDRESS;
                end else if (current_input_tdata == START_TAG) begin
                    down_hold = 1'b1;
                    down_need_start_next = 1'b1;
                    down_xfcp_out_tdata_int = RPATH_TAG;
                    down_state_next = DOWN_STATE_INSERT_ADDRESS;
                end else begin
                    down_state_next = DOWN_STATE_HEADER;
                end
            end else begin
                down_state_next = DOWN_STATE_HEADER;
            end
        end
        DOWN_STATE_INSERT_ADDRESS: begin
            // insert address
            down_hold = 1'b1;
            if (down_xfcp_out_tready_int_reg) begin
                down_xfcp_out_tdata_int = grant_encoded;
                down_xfcp_out_tvalid_int = 1'b1;
                down_xfcp_out_tlast_int = 1'b0;
                down_xfcp_out_tuser_int = 1'b0;
                if (down_need_start_reg) begin
                    down_state_next = DOWN_STATE_INSERT_START;
                end else begin
                    down_hold = 1'b0;
                    down_state_next = DOWN_STATE_TRANSFER;
                end
            end else begin
                down_state_next = DOWN_STATE_INSERT_ADDRESS;
            end
        end
        DOWN_STATE_INSERT_START: begin
            // insert start
            down_hold = 1'b1;
            if (down_xfcp_out_tready_int_reg) begin
                down_xfcp_out_tdata_int = START_TAG;
                down_xfcp_out_tvalid_int = 1'b1;
                down_xfcp_out_tlast_int = 1'b0;
                down_xfcp_out_tuser_int = 1'b0;
                down_state_next = DOWN_STATE_TRANSFER;
            end else begin
                down_state_next = DOWN_STATE_INSERT_START;
            end
        end
        DOWN_STATE_TRANSFER: begin
            // transfer upstream packet out through downstream port
            if (current_input_tvalid & current_input_tready) begin
                if (current_input_tlast) begin
                    down_frame_next = 1'b0;
                    down_state_next = DOWN_STATE_IDLE;
                end else begin
                    down_state_next = DOWN_STATE_TRANSFER;
                end
            end else begin
                down_state_next = DOWN_STATE_TRANSFER;
            end
        end
    endcase

    // generate ready signal on selected port
    case (down_select_next)
        1'd0: up_xfcp_0_in_tready_next = down_xfcp_out_tready_int_early & down_frame_next & ~down_hold;
        1'd1: up_xfcp_1_in_tready_next = down_xfcp_out_tready_int_early & down_frame_next & ~down_hold;
    endcase
end

// upstream control logic
always @* begin
    up_state_next = UP_STATE_IDLE;

    up_header_write = 0;
    up_header_write_data = down_xfcp_in_tdata;

    up_header_read_ptr_next = up_header_read_ptr_reg;
    up_header_write_ptr_next = up_header_write_ptr_reg;

    up_select_next = up_select_reg;
    up_frame_next = up_frame_reg;

    down_xfcp_in_tready_next = 1'b0;

    up_xfcp_out_tdata_int = down_xfcp_in_tdata;
    up_xfcp_out_tvalid_int = down_xfcp_in_tvalid & down_xfcp_in_tready & up_frame_reg;
    up_xfcp_out_tlast_int = down_xfcp_in_tlast;
    up_xfcp_out_tuser_int = down_xfcp_in_tuser;

    if (down_xfcp_in_tready & down_xfcp_in_tvalid) begin
        // end of frame detection
        if (down_xfcp_in_tlast) begin
            up_frame_next = 1'b0;
        end
    end

    case (up_state_reg)
        UP_STATE_IDLE: begin
            // wait for incoming downstream packet
            down_xfcp_in_tready_next = ~current_output_tvalid;

            up_header_read_ptr_next = 5'd0;
            up_header_write_ptr_next = 5'd0;

            if (~up_frame_reg & down_xfcp_in_tready & down_xfcp_in_tvalid) begin
                // start of frame, grab select value
                up_frame_next = 1'b1;

                // store header
                up_header_write = 1'b1;
                up_header_write_ptr_next = up_header_write_ptr_reg + 5'd1;

                if (down_xfcp_in_tlast) begin
                    down_xfcp_in_tready_next = 1'b1;
                    up_state_next = UP_STATE_DROP;
                end else if (down_xfcp_in_tdata == START_TAG) begin
                    down_xfcp_in_tready_next = 1'b1;
                    up_state_next = UP_STATE_DROP;
                end else if (down_xfcp_in_tdata == RPATH_TAG) begin
                    down_xfcp_in_tready_next = 1'b1;
                    up_state_next = UP_STATE_HEADER_ADDRESS;
                end else begin
                    down_xfcp_in_tready_next = 1'b1;
                    up_state_next = UP_STATE_HEADER_STORE;
                end
            end else begin
                up_state_next = UP_STATE_IDLE;
            end
        end
        UP_STATE_HEADER_STORE: begin
            // store header in FIFO
            up_xfcp_out_tvalid_int = 1'b0;
            down_xfcp_in_tready_next = 1'b1;

            if (down_xfcp_in_tready & down_xfcp_in_tvalid) begin
                up_header_write = 1'b1;
                up_header_write_ptr_next = up_header_write_ptr_reg + 5'd1;

                if (down_xfcp_in_tlast) begin
                    up_state_next = UP_STATE_DROP;
                end else if (up_header_write_ptr_reg == 5'd31) begin
                    up_state_next = UP_STATE_DROP;
                end else if (down_xfcp_in_tdata == START_TAG) begin
                    up_state_next = UP_STATE_DROP;
                end else if (down_xfcp_in_tdata == RPATH_TAG) begin
                    up_state_next = UP_STATE_HEADER_ADDRESS;
                end else begin
                    up_state_next = UP_STATE_HEADER_STORE;
                end
            end else begin
                up_state_next = UP_STATE_HEADER_STORE;
            end
        end
        UP_STATE_HEADER_ADDRESS: begin
            // store address
            up_xfcp_out_tvalid_int = 1'b0;
            down_xfcp_in_tready_next = 1'b1;

            if (down_xfcp_in_tready & down_xfcp_in_tvalid) begin
                if (down_xfcp_in_tlast) begin
                    up_state_next = UP_STATE_DROP;
                end else if (down_xfcp_in_tdata == START_TAG) begin
                    up_state_next = UP_STATE_DROP;
                end else if (down_xfcp_in_tdata > 8'd1) begin
                    up_state_next = UP_STATE_DROP;
                end else begin
                    // route packet
                    up_select_next = down_xfcp_in_tdata;
                    down_xfcp_in_tready_next = 1'b0;
                    up_state_next = UP_STATE_HEADER_CHECK_START;
                end
            end else begin
                up_state_next = UP_STATE_HEADER_ADDRESS;
            end
        end
        UP_STATE_HEADER_CHECK_START: begin
            // check start tag
            up_xfcp_out_tvalid_int = 1'b0;
            down_xfcp_in_tready_next = 1'b0;

            if (down_xfcp_in_tvalid) begin
                if (down_xfcp_in_tdata == START_TAG) begin
                    if (up_header_write_ptr_reg > 1) begin
                        up_header_write_ptr_next = up_header_write_ptr_reg - 5'd1;
                        down_xfcp_in_tready_next = 1'b0;
                        up_state_next = UP_STATE_HEADER_SEND;
                    end else begin
                        down_xfcp_in_tready_next = up_xfcp_out_tready_int_early;
                        up_state_next = UP_STATE_TRANSFER;
                    end
                end else begin
                    down_xfcp_in_tready_next = 1'b0;
                    up_state_next = UP_STATE_HEADER_SEND;
                end
            end else begin
                up_state_next = UP_STATE_HEADER_CHECK_START;
            end
        end
        UP_STATE_HEADER_SEND: begin
            // transfer header out of FIFO
            up_xfcp_out_tdata_int = up_header_read_data;
            up_xfcp_out_tvalid_int = 1'b1;

            if (up_xfcp_out_tready_int_early) begin
                up_header_read_ptr_next = up_header_read_ptr_reg + 1;
                if (up_header_read_ptr_next == up_header_write_ptr_reg) begin
                    down_xfcp_in_tready_next = up_xfcp_out_tready_int_early;
                    up_state_next = UP_STATE_TRANSFER;
                end else begin
                    up_state_next = UP_STATE_HEADER_SEND;
                end
            end else begin
                up_state_next = UP_STATE_HEADER_SEND;
            end
        end
        UP_STATE_TRANSFER: begin
            // transfer downstream packet through proper upstream port
            if (down_xfcp_in_tready & down_xfcp_in_tvalid) begin
                // end of frame detection
                if (down_xfcp_in_tlast) begin
                    up_frame_next = 1'b0;
                    up_header_read_ptr_next = 5'd0;
                    up_header_write_ptr_next = 5'd0;
                    up_state_next = UP_STATE_IDLE;
                end else begin
                    up_state_next = UP_STATE_TRANSFER;
                end
            end else begin
                up_state_next = UP_STATE_TRANSFER;
            end
            down_xfcp_in_tready_next = up_xfcp_out_tready_int_early & up_frame_next;
        end
        UP_STATE_DROP: begin
            // drop packet
            down_xfcp_in_tready_next = 1'b1;
            up_xfcp_out_tvalid_int = 1'b0;

            if (down_xfcp_in_tready & down_xfcp_in_tvalid) begin
                // end of frame detection
                if (down_xfcp_in_tlast) begin
                    up_frame_next = 1'b0;
                    down_xfcp_in_tready_next = 1'b0;
                    up_header_read_ptr_next = 5'd0;
                    up_header_write_ptr_next = 5'd0;
                    up_state_next = UP_STATE_IDLE;
                end else begin
                    up_state_next = UP_STATE_DROP;
                end
            end else begin
                up_state_next = UP_STATE_DROP;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        down_state_reg <= DOWN_STATE_IDLE;
        up_state_reg <= UP_STATE_IDLE;
        down_select_reg <= 2'd0;
        down_frame_reg <= 1'b0;
        up_select_reg <= 3'd0;
        up_frame_reg <= 1'b0;
        up_xfcp_0_in_tready_reg <= 1'b0;
        up_xfcp_1_in_tready_reg <= 1'b0;
        down_xfcp_in_tready_reg <= 1'b0;
    end else begin
        down_state_reg <= down_state_next;
        up_state_reg <= up_state_next;
        down_select_reg <= down_select_next;
        down_frame_reg <= down_frame_next;
        up_select_reg <= up_select_next;
        up_frame_reg <= up_frame_next;
        up_xfcp_0_in_tready_reg <= up_xfcp_0_in_tready_next;
        up_xfcp_1_in_tready_reg <= up_xfcp_1_in_tready_next;
        down_xfcp_in_tready_reg <= down_xfcp_in_tready_next;
    end

    down_need_start_reg <= down_need_start_next;

    up_header_read_ptr_reg <= up_header_read_ptr_next;
    up_header_write_ptr_reg <= up_header_write_ptr_next;

    if (up_header_write) begin
        up_header_mem[up_header_write_ptr_reg] = up_header_write_data;
    end
end

// upstream output datapath logic
reg [7:0] up_xfcp_out_tdata_reg = 8'd0;
reg       up_xfcp_0_out_tvalid_reg = 1'b0, up_xfcp_0_out_tvalid_next;
reg       up_xfcp_1_out_tvalid_reg = 1'b0, up_xfcp_1_out_tvalid_next;
reg       up_xfcp_out_tlast_reg = 1'b0;
reg       up_xfcp_out_tuser_reg = 1'b0;

reg [7:0] temp_up_xfcp_tdata_reg = 8'd0;
reg       temp_up_xfcp_tvalid_reg = 1'b0, temp_up_xfcp_tvalid_next;
reg       temp_up_xfcp_tlast_reg = 1'b0;
reg       temp_up_xfcp_tuser_reg = 1'b0;

// datapath control
reg store_up_xfcp_int_to_output;
reg store_up_xfcp_int_to_temp;
reg store_up_xfcp_temp_to_output;

assign up_xfcp_0_out_tdata = up_xfcp_out_tdata_reg;
assign up_xfcp_0_out_tvalid = up_xfcp_0_out_tvalid_reg;
assign up_xfcp_0_out_tlast = up_xfcp_out_tlast_reg;
assign up_xfcp_0_out_tuser = up_xfcp_out_tuser_reg;

assign up_xfcp_1_out_tdata = up_xfcp_out_tdata_reg;
assign up_xfcp_1_out_tvalid = up_xfcp_1_out_tvalid_reg;
assign up_xfcp_1_out_tlast = up_xfcp_out_tlast_reg;
assign up_xfcp_1_out_tuser = up_xfcp_out_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign up_xfcp_out_tready_int_early = current_output_tready | (~temp_up_xfcp_tvalid_reg & (~current_output_tvalid | ~up_xfcp_out_tvalid_int));

always @* begin
    // transfer sink ready state to source
    up_xfcp_0_out_tvalid_next = up_xfcp_0_out_tvalid_reg;
    up_xfcp_1_out_tvalid_next = up_xfcp_1_out_tvalid_reg;
    temp_up_xfcp_tvalid_next = temp_up_xfcp_tvalid_reg;

    store_up_xfcp_int_to_output = 1'b0;
    store_up_xfcp_int_to_temp = 1'b0;
    store_up_xfcp_temp_to_output = 1'b0;

    if (up_xfcp_out_tready_int_reg) begin
        // input is ready
        if (current_output_tready | ~current_output_tvalid) begin
            // output is ready or currently not valid, transfer data to output
            up_xfcp_0_out_tvalid_next = up_xfcp_out_tvalid_int & (up_select_reg == 1'd0);
            up_xfcp_1_out_tvalid_next = up_xfcp_out_tvalid_int & (up_select_reg == 1'd1);
            store_up_xfcp_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_up_xfcp_tvalid_next = up_xfcp_out_tvalid_int;
            store_up_xfcp_int_to_temp = 1'b1;
        end
    end else if (current_output_tready) begin
        // input is not ready, but output is ready
        up_xfcp_0_out_tvalid_next = temp_up_xfcp_tvalid_reg & (up_select_reg == 1'd0);
        up_xfcp_1_out_tvalid_next = temp_up_xfcp_tvalid_reg & (up_select_reg == 1'd1);
        temp_up_xfcp_tvalid_next = 1'b0;
        store_up_xfcp_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        up_xfcp_0_out_tvalid_reg <= 1'b0;
        up_xfcp_1_out_tvalid_reg <= 1'b0;
        up_xfcp_out_tready_int_reg <= 1'b0;
        temp_up_xfcp_tvalid_reg <= 1'b0;
    end else begin
        up_xfcp_0_out_tvalid_reg <= up_xfcp_0_out_tvalid_next;
        up_xfcp_1_out_tvalid_reg <= up_xfcp_1_out_tvalid_next;
        up_xfcp_out_tready_int_reg <= up_xfcp_out_tready_int_early;
        temp_up_xfcp_tvalid_reg <= temp_up_xfcp_tvalid_next;
    end

    // datapath
    if (store_up_xfcp_int_to_output) begin
        up_xfcp_out_tdata_reg <= up_xfcp_out_tdata_int;
        up_xfcp_out_tlast_reg <= up_xfcp_out_tlast_int;
        up_xfcp_out_tuser_reg <= up_xfcp_out_tuser_int;
    end else if (store_up_xfcp_temp_to_output) begin
        up_xfcp_out_tdata_reg <= temp_up_xfcp_tdata_reg;
        up_xfcp_out_tlast_reg <= temp_up_xfcp_tlast_reg;
        up_xfcp_out_tuser_reg <= temp_up_xfcp_tuser_reg;
    end

    if (store_up_xfcp_int_to_temp) begin
        temp_up_xfcp_tdata_reg <= up_xfcp_out_tdata_int;
        temp_up_xfcp_tlast_reg <= up_xfcp_out_tlast_int;
        temp_up_xfcp_tuser_reg <= up_xfcp_out_tuser_int;
    end
end

// downstream output datapath logic
reg [7:0]  down_xfcp_out_tdata_reg = 8'd0;
reg        down_xfcp_out_tvalid_reg = 1'b0, down_xfcp_out_tvalid_next;
reg        down_xfcp_out_tlast_reg = 1'b0;
reg        down_xfcp_out_tuser_reg = 1'b0;

reg [7:0]  temp_down_xfcp_tdata_reg = 8'd0;
reg        temp_down_xfcp_tvalid_reg = 1'b0, temp_down_xfcp_tvalid_next;
reg        temp_down_xfcp_tlast_reg = 1'b0;
reg        temp_down_xfcp_tuser_reg = 1'b0;

// datapath control
reg store_down_xfcp_int_to_output;
reg store_down_xfcp_int_to_temp;
reg store_down_xfcp_temp_to_output;

assign down_xfcp_out_tdata = down_xfcp_out_tdata_reg;
assign down_xfcp_out_tvalid = down_xfcp_out_tvalid_reg;
assign down_xfcp_out_tlast = down_xfcp_out_tlast_reg;
assign down_xfcp_out_tuser = down_xfcp_out_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign down_xfcp_out_tready_int_early = down_xfcp_out_tready | (~temp_down_xfcp_tvalid_reg & (~down_xfcp_out_tvalid_reg | ~down_xfcp_out_tvalid_int));

always @* begin
    // transfer sink ready state to source
    down_xfcp_out_tvalid_next = down_xfcp_out_tvalid_reg;
    temp_down_xfcp_tvalid_next = temp_down_xfcp_tvalid_reg;

    store_down_xfcp_int_to_output = 1'b0;
    store_down_xfcp_int_to_temp = 1'b0;
    store_down_xfcp_temp_to_output = 1'b0;

    if (down_xfcp_out_tready_int_reg) begin
        // input is ready
        if (down_xfcp_out_tready | ~down_xfcp_out_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            down_xfcp_out_tvalid_next = down_xfcp_out_tvalid_int;
            store_down_xfcp_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_down_xfcp_tvalid_next = down_xfcp_out_tvalid_int;
            store_down_xfcp_int_to_temp = 1'b1;
        end
    end else if (down_xfcp_out_tready) begin
        // input is not ready, but output is ready
        down_xfcp_out_tvalid_next = temp_down_xfcp_tvalid_reg;
        temp_down_xfcp_tvalid_next = 1'b0;
        store_down_xfcp_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        down_xfcp_out_tvalid_reg <= 1'b0;
        down_xfcp_out_tready_int_reg <= 1'b0;
        temp_down_xfcp_tvalid_reg <= 1'b0;
    end else begin
        down_xfcp_out_tvalid_reg <= down_xfcp_out_tvalid_next;
        down_xfcp_out_tready_int_reg <= down_xfcp_out_tready_int_early;
        temp_down_xfcp_tvalid_reg <= temp_down_xfcp_tvalid_next;
    end

    // datapath
    if (store_down_xfcp_int_to_output) begin
        down_xfcp_out_tdata_reg <= down_xfcp_out_tdata_int;
        down_xfcp_out_tlast_reg <= down_xfcp_out_tlast_int;
        down_xfcp_out_tuser_reg <= down_xfcp_out_tuser_int;
    end else if (store_down_xfcp_temp_to_output) begin
        down_xfcp_out_tdata_reg <= temp_down_xfcp_tdata_reg;
        down_xfcp_out_tlast_reg <= temp_down_xfcp_tlast_reg;
        down_xfcp_out_tuser_reg <= temp_down_xfcp_tuser_reg;
    end

    if (store_down_xfcp_int_to_temp) begin
        temp_down_xfcp_tdata_reg <= down_xfcp_out_tdata_int;
        temp_down_xfcp_tlast_reg <= down_xfcp_out_tlast_int;
        temp_down_xfcp_tuser_reg <= down_xfcp_out_tuser_int;
    end
end

endmodule
