source /opt/Xilinx/2025.2/Vivado/settings64.sh
: this file assumes you have a bitfile in the impl_1 directory, and turns it into a bit.bin file
: for fpgautil
bootgen -image doug.bif -arch zynq -process_bitstream bin -w on

