library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_fifo_slave_stream_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic;
		fifo_wdata : out std_logic_vector(31 downto 0);
    	fifo_wren  : out std_logic;
    	fifo_full  : in std_logic
	);
end simple_fifo_slave_stream_v1_0_S00_AXIS;

architecture arch_imp of simple_fifo_slave_stream_v1_0_S00_AXIS is
begin
	-- We tell the Radio we are ready ONLY if our real FIFO isn't full
    S_AXIS_TREADY <= not fifo_full; 

    -- 2. Drive the bridge signals to the top-level wrapper
    fifo_wdata <= S_AXIS_TDATA;
    
    -- 3. Only write if the Radio says data is VALID and our pipe is READY
    fifo_wren  <= S_AXIS_TVALID and (not fifo_full);

end arch_imp;
