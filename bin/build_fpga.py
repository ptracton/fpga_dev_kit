#! /usr/bin/env python

################################################################################
#
# $Header:$
# $Revision:$
# $State:$
# $Date:$
# $Author:$
#
# Original Author: Phil Tracton ptracton@gmail.com
#
# Description: 
#
# $Log:$
#
################################################################################

import optparse
import sys
import os
import config_file
import ise
import quartus
import design_compiler

##
## This is the entry point of the program.  Since this is the top program, we do not define classes in this file.
## We instantiate them and use them
##
if __name__ == '__main__':


    ##
    ## Read the command line options
    ##
    parser = optparse.OptionParser()

    ##
    ## Configuration file and root path in relation to where the simulations run from
    ##
    parser.add_option("-r", "--root",     dest="root",     action='store', default="../../", help="The root path")
    parser.add_option("-f", "--cfg_file", dest="cfg_file", action='store', default="fpga.cfg",     help="The configuration file to use")

    ##
    ## Technologies: Altera, Xilinx or "ASIC" which is just generic verilog RTL and not tech specific
    ## You can only use 1 of these at a time.  Each one will set a define for the simulation, ALTERA, XILINX or ASIC
    ##
    parser.add_option("-a", "--altera", dest="altera", action='store_true', help="simulate using Altera defines")
    parser.add_option("-x", "--xilinx", dest="xilinx", action='store_true', help="simulate using Xilinx defines")
    parser.add_option("-s", "--asic",   dest="asic",   action='store_true', help="simulate using ASIC defines")

    ##
    ## Support switches.  They handle various tasks
    ##
    parser.add_option("-d", "--debug",   dest="debug",   action='store_true', help="turns on debugging print statements")
    
    ##
    ## Get the options dictionary and list of arguments passed in from CLI
    ##
    (opts, args) = parser.parse_args()

    ##
    ## Display the options passed in if you use the -d switch
    ##
    if opts.debug:
        print opts
        print args

    ##
    ## Create a simulation object, fill in the details
    ##
    cfg = config_file.config_file(opts, file_name=opts.cfg_file, root=opts.root)

    if opts.xilinx:
        FPGA = ise.ise(opts, cfg, args)
        FPGA.create_xst_file()
        FPGA.create_prj_file()
        sys.exit(0)
    if opts.altera:
        FPGA = quartus.quartus(opts, cfg, args)
    if opts.asic:
        FPGA = design_compiler.design_compiler(opts, cfg, args)

    ##
    ## Synthesis will turn the RTL into a sea of gates
    ##
    FPGA.synthesis()

    ##
    ## Place and Route will place and route the design for the specified FPGA
    ## 
    FPGA.place_and_route()

    ##
    ## Generate File will create the image file to download to the FPGA
    ##
    FPGA.generate_file()
    
    ##
    ## All done, terminate program
    ##
    print "\n\nAll Done!\n"    
    sys.exit(0)
