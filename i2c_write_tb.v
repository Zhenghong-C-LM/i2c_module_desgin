`timescale 1ns / 1ps

module i2c_write_tb ();
    parameter CLOCKPERIOD = 20;
    parameter CHIP_ADDR = 7'h0F;

    reg reset;
    reg clock;

    // For storing slave data
    reg [15:0]  slave_data[0:255];

    // Check data
    wire [15:0] slave_test1;
    wire [15:0] slave_test2;
    wire [15:0] slave_test3;
    wire [15:0] slave_test4;

    wire SDA, SCL;
    wire [11:0] clk_div = 100;

    reg  [6:0]  master_chip_addr;
    reg  [7:0]  master_reg_addr;

    wire [3:0]  master_status;
    wire        master_done;
    wire        master_busy;

    reg         master_write_en;
    reg         master_read_en;
    reg  [15:0] master_data_in;
    wire [15:0] master_data_out;

    wire        master_sda_out;
    wire        master_sda_oen;
    wire        master_scl_out;
    wire        master_scl_oen;

    reg  [6:0]  slave_chip_addr;
    wire [7:0]  slave_reg_addr;

    wire        slave_busy;
    wire        slave_done;

    wire        slave_write_en;
    reg  [15:0] slave_data_in;
    wire [15:0] slave_data_out;

    wire        slave_sda_in;
    wire        slave_scl_in;

    wire        slave_sda_out;
    wire        slave_sda_oen;
    wire        slave_scl_out;
    wire        slave_scl_oen;

    reg         write_mode;

    assign SDA = master_sda_oen ? 1'bz : master_sda_out;
    assign SDA = slave_sda_oen  ? 1'bz : slave_sda_out ;
    assign SCL = master_scl_oen ? 1'bz : master_scl_out;
    assign SCL = slave_scl_oen  ? 1'bz : slave_scl_out ;

    pullup(SDA);
    pullup(SCL);

    // i2c Master
    i2c_master #(
        .ADDR_BYTES(1),
        .DATA_BYTES(2)
    ) i2c_master (
        .clk        (clock),
        .reset      (reset),
        .clk_div    (clk_div),

        .open_drain (1'b1),

        .chip_addr  (master_chip_addr),
        .reg_addr   (master_reg_addr),
        .data_in    (master_data_in),
        .write_en   (master_write_en),
        .write_mode (write_mode),
        .read_en    (master_read_en),
        .status     (master_status),
        .done       (master_done),
        .busy       (master_busy),
        .data_out   (master_data_out),

        .sda_in     (SDA),
        .scl_in     (SCL),
        .sda_out    (master_sda_out),
        .sda_oen    (master_sda_oen),
        .scl_out    (master_scl_out),
        .scl_oen    (master_scl_oen)
    );

    // i2c Slave
    i2c_slave #(
        .ADDR_BYTES(1),
        .DATA_BYTES(2)
    ) i2c_slave (
        .clk        (clock),
        .reset      (reset),

        .open_drain (1'b1),

        .chip_addr  (slave_chip_addr),
        .reg_addr   (slave_reg_addr),
        .data_in    (slave_data_in),
        .write_en   (slave_write_en),
        .data_out   (slave_data_out),
        .done       (slave_done),
        .busy       (slave_busy),

        .sda_in     (SDA),
        .scl_in     (SCL),
        .sda_out    (slave_sda_out),
        .sda_oen    (slave_sda_oen),
        .scl_out    (slave_scl_out),
        .scl_oen    (slave_scl_oen)
    );

    // Initial conditions; setup
    initial begin
        $timeformat(-9,1, "ns", 12);

        // Initial Conditions
        reset <= 1'b0;

        slave_chip_addr  <= CHIP_ADDR;

        master_chip_addr <= 8'h00;
        master_reg_addr  <= 8'h00;
        master_data_in   <= 16'h0000;
        master_write_en  <= 1'b0;
        master_read_en   <= 1'b0;

        // multibyte
        write_mode       <= 1'b0;

        // Initialize clock
        #2
        clock <= 1'b0;

        // Deassert reset
        #20
        reset <= 1'b1;

        // write_test
        #100 write_i2c(CHIP_ADDR, 8'h00, 16'hA1A1);
        #100 write_i2c(CHIP_ADDR, 8'h0A, 16'hB2B2);
        #100 write_i2c(CHIP_ADDR, 8'h10, 16'hC3C3);
        #100 write_i2c(CHIP_ADDR, 8'h1A, 16'hD4D4);
        #100 $finish;
    end

    // Check signal
    assign slave_test1 = slave_data[8'h00];
    assign slave_test2 = slave_data[8'h0A];
    assign slave_test3 = slave_data[8'h10];
    assign slave_test4 = slave_data[8'h1A];

    // Store
    always @ (posedge clock) begin
        if (slave_write_en) begin
            slave_data[slave_reg_addr] <= slave_data_out;
        end
    end

    // write_function
    task write_i2c;
        input [6:0]  chip_addr;
        input [7:0]  reg_addr;
        input [15:0] data;

        begin
            @ (posedge clock) begin
                master_write_en  = 1'b1;

                master_chip_addr = chip_addr;
                master_reg_addr  = reg_addr;
                master_data_in   = data;
            end

            @ (posedge clock)
                master_write_en = 1'b0;

            @ (posedge clock);

            while (master_busy) begin
                @ (posedge clock);
            end
        end
    endtask

    // Clock generation
    always #(CLOCKPERIOD / 2) clock <= ~clock;

// Icarus Verilog
`ifdef IVERILOG
    initial $dumpfile("vcdbasic.vcd");
    initial $dumpvars();
`endif

// VCS
`ifdef VCS
    initial $vcdpluson;
`endif

// Altera Modelsim
`ifdef MODEL_TECH
`endif

// Xilinx ISIM
`ifdef XILINX_ISIM
`endif    
endmodule