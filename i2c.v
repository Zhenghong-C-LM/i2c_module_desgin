/*
i2c

Author  Zhenghong Chen (qus9bh@virginia.edu)

Description:
  i2c (Master and Slave)
*/
module i2c
    #(
        parameter ADDR_BYTES = 1,
        parameter DATA_BYTES = 4,
        parameter ST_WIDTH = 1 + ADDR_BYTES + DATA_BYTES,
        parameter REG_ADDR_WIDTH = 8 * ADDR_BYTES
    )(
        input enable,          // Enable

        input  clk,            // System clock
        input  reset,          // Reset signal
        input  [11:0] clk_div, // Clock divider value to configure SCL from the system clock
        input  open_drain,     // Open drain
        

        //Master logic
        input [6:0] chip_addr,                        // Other Chip Address
        input [REG_ADDR_WIDTH - 1:0] reg_addr,        // Other Chip Register address
 
        input write_en,                               // Write enable
        input write_mode,                             // Write mode (0: single, 1: multi-byte)
        input read_en,                                // Read enable
        output [ST_WIDTH - 1:0] status,

        //Slave logic
        input [6:0]  chip_id,                          // This Chip Address
        output [REG_ADDR_WIDTH - 1:0] slave_reg_addr,  // This Chip Register address
        output slave_write_en,                         // Write enable

        //Data path
        input [8 * DATA_BYTES - 1:0] data_in,         // Data read from register
        output [8 * DATA_BYTES - 1:0] data_out,   // Data to write to register
        output done,
        output busy,

        //SDA and SCL
        input  sda_in,    // SDA Input
        output sda_out,   // SDA Output
        output sda_oen,   // SDA Output Enable

        input  scl_in,    // SCL Input
        output scl_out,   // SCL Output
        output scl_oen,   // SCL Output Enable

	// registers
	 output reg [8 * DATA_BYTES - 1:0] master_rd_xacn_reg, // data comes from slave during read transaction
	 output reg [8 * DATA_BYTES - 1:0] slave_wr_xacn_reg  // data comes from master during write transaction 
        );


        //wire
        wire master_sda_out;
        wire slave_sda_out;

        wire master_sda_oen;
        wire slave_sda_oen;

        wire master_scl_out;
        wire slave_scl_out;

        wire master_scl_oen;
        wire slave_scl_oen;
        
        wire [8 * DATA_BYTES - 1:0] master_data_out;
        wire [8 * DATA_BYTES - 1:0] slave_data_out;

        wire master_done;
        wire slave_done;

        wire master_busy;
        wire slave_busy;

        // i2c Master
        i2c_master i2c_master (
            .clk        (clk),
            .reset      (reset),
            .clk_div    (clk_div),

            .open_drain (open_drain),
	    .enable	(enable),
            .chip_addr  (chip_addr),
            .reg_addr   (reg_addr),
            .data_in    (data_in),
            .write_en   (write_en),
            .write_mode (write_mode),
            .read_en    (read_en),
            .status     (status),
            .done       (master_done),
            .busy       (master_busy),
            .data_out   (master_data_out),

            .sda_in     (sda_in),
            .scl_in     (scl_in),
            .sda_out    (master_sda_out),
            .sda_oen    (master_sda_oen),
            .scl_out    (master_scl_out),
            .scl_oen    (master_scl_oen)
        );

        // i2c Slave
        i2c_slave i2c_slave (
            .clk        (clk),
            .reset      (reset),
	    .enable 	(~enable),
            .open_drain (open_drain),

            .chip_addr  (chip_id),
            .reg_addr   (slave_reg_addr),
            .data_in    (data_in),
            .write_en   (slave_write_en),
            .data_out   (slave_data_out),
            .done       (slave_done),
            .busy       (slave_busy),

            .sda_in     (sda_in),
            .scl_in     (scl_in),
            .sda_out    (slave_sda_out),
            .sda_oen    (slave_sda_oen),
            .scl_out    (slave_scl_out),
            .scl_oen    (slave_scl_oen)
        );

        assign sda_out = enable ? master_sda_out : slave_sda_out;
        assign sda_oen = enable ? master_sda_oen : slave_sda_oen;
        assign scl_out = enable ? master_scl_out : slave_scl_out;
        assign scl_oen = enable ? master_scl_oen : slave_scl_oen;
        assign data_out = enable ? master_data_out : slave_data_out;
        assign done = enable ? master_done : slave_done;
        assign busy = enable ? master_busy : slave_busy;

// 32bit read  and write  registers for read and write operation
// decoded using one bit of addr and writ_en and read_en signals

        always @ (posedge clk) begin
		if (reset) begin
		  master_rd_xacn_reg <= 32'h0000;
		  slave_wr_xacn_reg <= 32'h0000;	
		end else begin
		  master_rd_xacn_reg <= master_data_out;
 		  slave_wr_xacn_reg <= slave_data_out;
		end
	end
         


endmodule
