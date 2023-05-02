# Clock definition
#create_clock -name clk_in -period 8 -waveform {0 4} [get_ports PHY_RX_CLK]

# SiTCP
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX11Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX12Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX13Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX14Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX15Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX16Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX17Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX18Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX19Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX1AData*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX1BData*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_RESET_OUT]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/BBT_SiTCP_RST/resetReq*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/memRdReq*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/orRdAct*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/dlyBank0LastWrAddr*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/dlyBank1LastWrAddr*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/muxEndTgl]

#set_false_path -from [get_nets u_MTX1/reg_fbh*] -to [get_nets u_MTX1/gen_tof[*].gen_ch[*].u_Matrix_Impl/in_fbh]

set_false_path -through [get_ports {LED[*]}]
set_false_path -through [get_nets {DIP[*]}]
set_false_path -through [get_nets {NIMOUT[*]}]
set_false_path -through [get_nets u_BCT_Inst/rst_from_bus]

create_generated_clock -name clk_gtx  [get_pins u_ClkSys_Inst/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name clk_sys  [get_pins u_ClkSys_Inst/inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name clk_spi  [get_pins u_ClkSys_Inst/inst/mmcm_adv_inst/CLKOUT2]

set_clock_groups -name async_sys -asynchronous -group {clk_sys clk_gtx} -group clk_spi

