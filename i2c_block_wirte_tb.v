`timescale 1us / 1ns

module i2c_block_read_tb ();
    parameter CLOCKPERIOD1 = 10;
    parameter CLOCKPERIOD2 = 44;
    parameter CHIP1_ADDR = 7'h0E;
    parameter CHIP2_ADDR = 7'h0F;

    reg reset;
    // master clock
    reg clock1;
    // slave clock
    reg clock2; 

    // For storing slave data
    reg [15:0]  slave2_data[0:255];

    wire SDA, SCL;
    wire [11:0] clk_div = 100;

    // i2c_1
    reg  [6:0]  master1_chip_addr;
    reg  [7:0]  master1_reg_addr;

    wire [3:0]  master1_status;
    wire        master1_done;
    wire        master1_busy;

    reg         master1_write_en;
    reg         master1_read_en;
    reg  [15:0] master1_data_in;
    wire [15:0] master1_data_out;

    wire        master1_sda_out;
    wire        master1_sda_oen;
    wire        master1_scl_out;
    wire        master1_scl_oen;

    reg  [6:0]  slave1_chip_addr;
    wire [7:0]  slave1_reg_addr;

    wire        slave1_busy;
    wire        slave1_done;

    wire        slave1_write_en;
    reg  [15:0] slave1_data_in;
    wire [15:0] slave1_data_out;

    wire        slave1_sda_in;
    wire        slave1_scl_in;

    wire        slave1_sda_out;
    wire        slave1_sda_oen;
    wire        slave1_scl_out;
    wire        slave1_scl_oen;

    reg         master1_write_mode;

    // i2c_2
    reg  [6:0]  master2_chip_addr;
    reg  [7:0]  master2_reg_addr;

    wire [3:0]  master2_status;
    wire        master2_done;
    wire        master2_busy;

    reg         master2_write_en;
    reg         master2_read_en;
    reg  [15:0] master2_data_in;
    wire [15:0] master2_data_out;

    wire        master2_sda_out;
    wire        master2_sda_oen;
    wire        master2_scl_out;
    wire        master2_scl_oen;

    reg  [6:0]  slave2_chip_addr;
    wire [7:0]  slave2_reg_addr;

    wire        slave2_busy;
    wire        slave2_done;

    wire        slave2_write_en;
    reg  [15:0] slave2_data_in;
    wire [15:0] slave2_data_out;

    wire        slave2_sda_in;
    wire        slave2_scl_in;

    wire        slave2_sda_out;
    wire        slave2_sda_oen;
    wire        slave2_scl_out;
    wire        slave2_scl_oen;

    reg         master2_write_mode;

    assign SDA = master1_sda_oen ? 1'bz : master1_sda_out;
    assign SDA = slave2_sda_oen  ? 1'bz : slave2_sda_out ;
    assign SCL = master1_scl_oen ? 1'bz : master1_scl_out;
    assign SCL = slave2_scl_oen  ? 1'bz : slave2_scl_out ;


    pullup(SDA);
    pullup(SCL);

    // i2c_1 --Master
    i2c #(
        .ADDR_BYTES(1),
        .DATA_BYTES(2)
    ) i2c_1 (
        .clk        (clock1),
        .reset      (reset),
        .clk_div    (clk_div),

        .master_open_drain (1'b1),
        .slave_open_drain (1'b0),

        //master I/O
        .master_chip_addr  (master1_chip_addr),
        .master_reg_addr   (master1_reg_addr),
        .master_data_in    (master1_data_in),
        .master_write_en   (master1_write_en),
        .master_write_mode (master1_write_mode),
        .master_read_en    (master1_read_en),
        .master_status     (master1_status),
        .master_done       (master1_done),
        .master_busy       (master1_busy),
        .master_data_out   (master1_data_out),

        .master_sda_in     (SDA),
        .master_scl_in     (SCL),
        .master_sda_out    (master1_sda_out),
        .master_sda_oen    (master1_sda_oen),
        .master_scl_out    (master1_scl_out),
        .master_scl_oen    (master1_scl_oen),

        //slave I/O
        .slave_chip_addr  (slave1_chip_addr),
        .slave_reg_addr   (slave1_reg_addr),
        .slave_data_in    (slave1_data_in),
        .slave_write_en   (slave1_write_en),
        .slave_data_out   (slave1_data_out),
        .slave_done       (slave1_done),
        .slave_busy       (slave1_busy),

        .slave_sda_in     (SDA),
        .slave_scl_in     (SCL),
        .slave_sda_out    (slave1_sda_out),
        .slave_sda_oen    (slave1_sda_oen),
        .slave_scl_out    (slave1_scl_out),
        .slave_scl_oen    (slave1_scl_oen)
    );

    // i2c_2 --Slave
    i2c #(
        .ADDR_BYTES(1),
        .DATA_BYTES(2)
    ) i2c_2 (
        .clk        (clock2),
        .reset      (reset),
        .clk_div    (clk_div),

        .master_open_drain (1'b0),
        .slave_open_drain (1'b1),

        //master I/O
        .master_chip_addr  (master2_chip_addr),
        .master_reg_addr   (master2_reg_addr),
        .master_data_in    (master2_data_in),
        .master_write_en   (master2_write_en),
        .master_write_mode (master2_write_mode),
        .master_read_en    (master2_read_en),
        .master_status     (master2_status),
        .master_done       (master2_done),
        .master_busy       (master2_busy),
        .master_data_out   (master2_data_out),

        .master_sda_in     (SDA),
        .master_scl_in     (SCL),
        .master_sda_out    (master2_sda_out),
        .master_sda_oen    (master2_sda_oen),
        .master_scl_out    (master2_scl_out),
        .master_scl_oen    (master2_scl_oen),

        //slave I/O
        .slave_chip_addr  (slave2_chip_addr),
        .slave_reg_addr   (slave2_reg_addr),
        .slave_data_in    (slave2_data_in),
        .slave_write_en   (slave2_write_en),
        .slave_data_out   (slave2_data_out),
        .slave_done       (slave2_done),
        .slave_busy       (slave2_busy),

        .slave_sda_in     (SDA),
        .slave_scl_in     (SCL),
        .slave_sda_out    (slave2_sda_out),
        .slave_sda_oen    (slave2_sda_oen),
        .slave_scl_out    (slave2_scl_out),
        .slave_scl_oen    (slave2_scl_oen)
    );

    // Initial conditions; setup
    initial begin
        $timeformat(-9,1, "ns", 12);

        reset <= 1'b0;

        slave1_chip_addr  <= CHIP1_ADDR;
        slave2_chip_addr  <= CHIP2_ADDR;

        master1_chip_addr <= 8'h00;
        master1_reg_addr  <= 8'h00;
        master1_data_in   <= 16'h0000;
        master1_write_en  <= 1'b0;
        master1_read_en   <= 1'b0;

        // set slave_data
        slave2_data[8'h00] <= 16'hA1A1;
        slave2_data[8'h0A] <= 16'hB2B2;
        slave2_data[8'h10] <= 16'hC3C3;
        slave2_data[8'h1A] <= 16'hD4D4;

        // multibyte
        master1_write_mode       <= 1'b0;

        // Initialize clock
        #2
        clock1 <= 1'b0;
        clock2 <= 1'b0;

        // Deassert reset
        #20
        reset <= 1'b1;

        #100 read_i2c(CHIP2_ADDR, 8'h00);
        #100 read_i2c(CHIP2_ADDR, 8'h0A);
        #100 read_i2c(CHIP2_ADDR, 8'h10);
        #100 read_i2c(CHIP2_ADDR, 8'h1A);

        #100 $finish;
    end

    // Save slave data to register
    always @ (posedge clock2) begin
        slave2_data_in <= slave2_data[slave2_reg_addr];
    end

    task read_i2c;
        input [6:0] chip_addr;
        input [7:0] reg_addr;

        begin
            @ (posedge clock1) begin
                master1_chip_addr = chip_addr;
                master1_reg_addr  = reg_addr;
                master1_read_en   = 1'b1;
            end

            @ (posedge clock1) begin
                master1_read_en = 1'b0;
            end

            @ (posedge clock1);

            while (master1_busy) begin
                @ (posedge clock1);
            end
        end
    endtask

    // Clock1 generation
    always #(CLOCKPERIOD1 / 2) clock1 <= ~clock1;
    // Clock2 generation
    always #(CLOCKPERIOD2 / 2) clock2 <= ~clock2;

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
