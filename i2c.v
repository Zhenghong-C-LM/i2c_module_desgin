/*
i2c

Author  Zhenghong Chen (qus9bh@virginia.edu)

Description:
  i2c (Master and Slave)
*/
module i2c
    #(
        parameter ADDR_BYTES = 1,
        parameter DATA_BYTES = 2,
        parameter ST_WIDTH = 1 + ADDR_BYTES + DATA_BYTES,
        parameter REG_ADDR_WIDTH = 8 * ADDR_BYTES
    )(

        input  clk,            // System clock
        input  reset,          // Reset signal
        input  [11:0] clk_div, // Clock divider value to configure SCL from the system clock
        input master_open_drain, // Open drain
        input slave_open_drain, // Open drain

        //Master I/O
        input [6:0] master_chip_addr, // Other Chip Address
        input [REG_ADDR_WIDTH - 1:0] master_reg_addr, // Other Chip Register address
        input [8 * DATA_BYTES - 1:0] master_data_in,         // Data read from register
        input master_write_en,    // Write enable
        input master_write_mode,  // Write mode (0: single, 1: multi-byte)
        input master_read_en,     // Read enable
        output [ST_WIDTH - 1:0] master_status,
        output master_done,
        output master_busy,
        output [8 * DATA_BYTES - 1:0] master_data_out,   // Data to write to register

        input  master_sda_in,    // SDA Input
        output master_sda_out,   // SDA Output
        output master_sda_oen,   // SDA Output Enable

        input  master_scl_in,    // SCL Input
        output master_scl_out,   // SCL Output
        output master_scl_oen,   // SCL Output Enable

        //Slave I/O
        input [6:0] slave_chip_addr, // This Chip Address
        input [REG_ADDR_WIDTH - 1:0] slave_reg_addr, // This Chip Register address
        input [8 * DATA_BYTES - 1:0] slave_data_in,    // Data read from register
        output slave_write_en,    // Write enable
        output [8 * DATA_BYTES - 1:0] slave_data_out,  // Data to write to register
        output slave_done,
        output slave_busy,

        input  slave_sda_in,    // SDA Input
        output slave_sda_out,   // SDA Output
        output slave_sda_oen,   // SDA Output Enable

        input  slave_scl_in,    // SCL Input
        output slave_scl_out,   // SCL Output
        output slave_scl_oen    // SCL Output Enable
        );

        // i2c Master
        i2c_master i2c_master (
            .clk        (clk),
            .reset      (reset),
            .clk_div    (clk_div),

            .open_drain (open_drain),

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

            .sda_in     (master_scl_in),
            .scl_in     (master_scl_in),
            .sda_out    (master_sda_out),
            .sda_oen    (master_sda_oen),
            .scl_out    (master_scl_out),
            .scl_oen    (master_scl_oen)
        );

        // i2c Slave
        i2c_slave i2c_slave (
            .clk        (clock),
            .reset      (reset),

            .open_drain (open_drain),

            .chip_addr  (slave_chip_addr),
            .reg_addr   (slave_reg_addr),
            .data_in    (slave_data_in),
            .write_en   (slave_write_en),
            .data_out   (slave_data_out),
            .done       (slave_done),
            .busy       (slave_busy),

            .sda_in     (slave_sda_in),
            .scl_in     (slave_scl_in),
            .sda_out    (slave_sda_out),
            .sda_oen    (slave_sda_oen),
            .scl_out    (slave_scl_out),
            .scl_oen    (slave_scl_oen)
        );
endmodule