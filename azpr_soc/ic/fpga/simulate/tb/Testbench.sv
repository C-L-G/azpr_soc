//****************************************************************************************************  
//*---------------Copyright (c) 2016 C-L-G.FPGA1988.lichangbeiju. All rights reserved-----------------
//
//                   --              It to be define                --
//                   --                    ...                      --
//                   --                    ...                      --
//                   --                    ...                      --
//**************************************************************************************************** 
//File Information
//**************************************************************************************************** 
//File Name      : Testbench.sv 
//Project Name   : azpr_soc
//Description    : the fpga testbench top of the chip.
//Github Address : github.com/C-L-G/azpr_soc/trunk/ic/fpga/simulate/tb/Testbench.sv
//License        : Apache-2.0
//**************************************************************************************************** 
//Version Information
//**************************************************************************************************** 
//Create Date    : 2016-12-01 09:00
//First Author   : lichangbeiju
//Last Modify    : 2016-12-01 14:20
//Last Author    : lichangbeiju
//Version Number : 12 commits 
//**************************************************************************************************** 
//Change History(latest change first)
//yyyy.mm.dd - Author - Your log of change
//**************************************************************************************************** 
//2016.12.01 - lichangbeiju - The first version.
//*---------------------------------------------------------------------------------------------------
//File Include : system header file
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

module Testbench();
    //************************************************************************************************
    // 1.Parameter and constant define
    //************************************************************************************************
    localparam time_samp_start  = 80        ;
    localparam time_samp_stop   = 10_000    ;
    
    //************************************************************************************************
    // 2.Register and wire declaration
    //************************************************************************************************
    //------------------------------------------------------------------------------------------------
    // 2.1 the output reg
    //------------------------------------------------------------------------------------------------   
    logic                   sda_m2s     ;
    logic   [00:00]         sda_s2m     ;
    logic                   scl         ;
    logic                   clk         ;
    //------------------------------------------------------------------------------------------------
    // 2.2 the internal reg
    //------------------------------------------------------------------------------------------------  
    
    logic                   sample_flag ;//bus inteface state
    int                     fp_eeprom   ;//
    bit                     vect_clk    ;//vector clock
    //------------------------------------------------------------------------------------------------
    // 2.x the test logic
    //------------------------------------------------------------------------------------------------

    //************************************************************************************************
    // 3.Main code
    //************************************************************************************************

    //------------------------------------------------------------------------------------------------
    // 3.1 the sdf annotate 
    //------------------------------------------------------------------------------------------------

    `ifdef POSTMAX
        initial begin
            $sdf_annotate("../../../apr/dataout/azpr_soc_top.sdf",dut.azpr_soc_top,,,"MAXIMUM");
        end
    `elsif POSTTYP
        initial begin
            $sdf_annotate("../../../apr/dataout/azpr_soc_top.sdf",dut.azpr_soc_top,,,"TYPICAL");
        end
    `elsif POSTMIN
        initial begin
            $sdf_annotate("../../../apr/dataout/azpr_soc_top.sdf",dut.azpr_soc_top,,,"MINIMUM");
        end
    `endif

    //------------------------------------------------------------------------------------------------
    // 3.2 the signal assignment
    //------------------------------------------------------------------------------------------------

    assign sda_m2s          = ee_if.iic.sdo ;
    assign ee_if.iic.sdi    = sda_s2m       ;

    //------------------------------------------------------------------------------------------------
    // 3.3 the wave dump
    //------------------------------------------------------------------------------------------------
    initial begin : WAVE_DUMP
        $fsdbDumpfile("test.fsdb");
        $fsdbDumpvars(0,dut);
        $fsdbDumpvars(0,gt5232_tb_top;);
        $fsdbDumpSVA;
    end

    //------------------------------------------------------------------------------------------------
    // 3.4 the hsim vector generate
    //------------------------------------------------------------------------------------------------
    `ifdef hsim
        initial begin : VECTOR_GEN_INIT
            fp_eeprom = $fopen("./hsim.vec","w+");
            
            $fdisplay(fp_eeprom,"radix  1       1       1       1   \n");
            $fdisplay(fp_eeprom,"io     i       i       i       i   \n");
            $fdisplay(fp_eeprom,"vname  pad1    pad3    pad5    pad6\n");

            $fdisplay(fp_eeprom,"period 10 ");
            $fdisplay(fp_eeprom,"TUNIT  1ns");
            $fdisplay(fp_eeprom,"vih    simvih");
            $fdisplay(fp_eeprom,"tskip");
            $fdisplay(fp_eeprom,"\n");
        end
        
        initial begin
            vect_clk    = 1'b0;
        end
        always begin
            #10 vect_clk = ~vect_clk;
        end 
        
        always @(posedge vect_clk) begin : VECTOR_GEN_SAMPLE
            if(sample_flag)
                $fdisplay(fp_eeprom,"%10d   %h  %h  %h  %h",
                $time,test_top.pad1,test_top.pad3,test_top.pad5,test_top.pad6);
        end
    `endif

    //************************************************************************************************
    // 4.Sub module instantiation
    //************************************************************************************************
    //------------------------------------------------------------------------------------------------
    // 4.1 the clk generate module
    //------------------------------------------------------------------------------------------------    
    azpr_clock_reset cr(.*);

    //------------------------------------------------------------------------------------------------
    // 4.2 the interface
    //------------------------------------------------------------------------------------------------    
    soc_if soc_if(system_clock);
    
    //------------------------------------------------------------------------------------------------
    // 4.3 the testcase with interface
    //------------------------------------------------------------------------------------------------    
    testcase tc(soc_if);
    
    //------------------------------------------------------------------------------------------------
    // 4.4 the interface
    //------------------------------------------------------------------------------------------------    
    gt5232_chip_top dut(.*);

    //------------------------------------------------------------------------------------------------
    // 4.5 the interface
    //------------------------------------------------------------------------------------------------    




endmodule    
//****************************************************************************************************
//End of Mopdule
//****************************************************************************************************