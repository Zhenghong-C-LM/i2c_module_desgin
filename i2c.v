/*
i2c

Author  Zhenghong Chen (qus9bh@virginia.edu)

Description:
  i2c (Master and Slave)
*/
`include "i2c_slave.v"
`include "i2c_master.v"
module i2c
    #(
        parameter ADDR_BYTES = 1,
        parameter DATA_BYTES = 2,
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
        input [8 * DATA_BYTES - 1:0] data_in1,         // Data read from register
        input [8 * DATA_BYTES - 1:0] data_in0,         // Data read from register
        output reg [8 * DATA_BYTES - 1:0] data_out1,       // Data to write to register
        output reg [8 * DATA_BYTES - 1:0] data_out0,       // Daat to write to register
        output done,
        output busy,

        //SDA and SCL
        input  sda_in,    // SDA Input
        output sda_out,   // SDA Output
        output sda_oen,   // SDA Output Enable

        input  scl_in,    // SCL Input
        output scl_out,   // SCL Output
        output scl_oen    // SCL Output Enable
        );

	    //Pulse signal generation Register
	    reg i2c_count_write;
	    reg i2c_count_read;
	    reg write_en_pulse;
	    reg read_en_pulse;

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

        wire [8 * DATA_BYTES - 1:0] data_in;
        wire [8 * DATA_BYTES - 1:0] data_out;

        // i2c Master
        i2c_master i2c_master (
            .clk        (clk),
            .reset      (reset),
            .clk_div    (clk_div),

            .open_drain (open_drain),
	        .enable	    (enable),
            .chip_addr  (chip_addr),
            .reg_addr   (reg_addr),
            .data_in    (data_in),
            // .write_en   (write_en),
            .write_en   (write_en_pulse),
            .write_mode (write_mode),
            // .read_en    (read_en),
            .read_en    (read_en_pulse),
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


        assign data_in = (enable || (slave_reg_addr == 8'h00)) ? data_in0 : data_in1;
        always @ (posedge slave_write_en || master_done) begin
            if ((slave_reg_addr == 8'h00) || enable) begin
                data_out0 <= data_out;
            end else if (slave_reg_addr == 8'h01) begin
                data_out1 <= data_out;
            end
        end 

        // Pulse signal generation
        always @ (posedge clk) begin
		    if (write_en == 1) begin
			    if (i2c_count_write == 0) begin
				    write_en_pulse <= 1; 
				    i2c_count_write <= 1;
			        end
			    else begin
				    write_en_pulse <= 0; 
			    end 
		    end	
		    else begin
			    i2c_count_write <= 0;
			    write_en_pulse <= 0; 
		    end
    	end

	    always @ (posedge clk) begin
		    if (read_en == 1) begin
			    if (i2c_count_read == 0) begin
				    read_en_pulse <= 1; 
				    i2c_count_read <= 1;
			    end
			else begin
				    read_en_pulse <= 0; 
			    end 
		    end	
		    else begin
			    i2c_count_read <= 0;
			    read_en_pulse <= 0; 
		    end
    	end

endmodule
