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

import sys
import os
import synth_tool

class ise(synth_tool.synth_tool):
    '''
    '''
    
    ################################################################################
    def __init__(self, options, config, args):

        synth_tool.synth_tool.__init__(self, options, config, args)

        self.prj_file = self.cfg.project+".prj"
        self.xst_file = self.cfg.project+".xst"
        self.ngc_file = self.cfg.project+".ngc"
        self.ngd_file = self.cfg.project+".ngd"
        self.ncd_file = self.cfg.project+".ncd"
        self.map_ncd_file = self.cfg.project+"_map.ncd"
        self.pcf_file = self.cfg.project+".pcf"
        self.twx_file = self.cfg.project+".twx"
        self.twr_file = self.cfg.project+".twr"
        self.ut_file = self.cfg.project+".ut"
        self.ppr_file = self.cfg.project+"_timesim.v"
        return

    ################################################################################
    def create_xst_file(self):
        if os.path.exists(self.xst_file):
            os.remove(self.xst_file)

        try:
            f = open(self.xst_file, "w")
        except:
            print "Failed to open %s for writing\nTerminate Program\n\n" % self.xst_file
            sys.exit(1)

        f.write("set -tmpdir ./xst/projnav.tmp\n")
        try:
            os.makedirs("xst/projnav.tmp")
        except:
            print "Dirs already made"
            
        f.write("set -xsthdpdir \"xst\"\n")
        f.write("run\n")
        f.write("-top "+self.cfg.project+"\n")
        f.write("-ifn "+self.prj_file+"\n")
#        f.write("-ifmt mixed\n")
        f.write("-ofn "+self.cfg.project+"\n")
        f.write("-ofmt NGC\n")        
        f.write("-p "+self.cfg.xilinx.fpga_model+"\n")
        for i in self.cfg.xilinx.synthesis_options:
            f.write(i+"\n")
            
        f.close()
        return

    ################################################################################
    def create_prj_file(self):

        if os.path.exists(self.prj_file):
            os.remove(self.prj_file)

        try:
            f = open(self.prj_file, "w")
        except:
            print "Failed to open %s for writing\nTerminate Program\n\n" % self.prj_file
            sys.exit(1)

        prj_string = "verilog work \""

        print self.opts

        if self.opts.xilinx:
            for i in self.cfg.xilinx.synthesis_files:
                print i
                f.write(prj_string+self.cfg.root+"/"+i.strip("'")+"\"\n")


        for i in self.cfg.list_synthesis_files:
            f.write("verilog work  "+self.cfg.root+i.strip("'")+"\n")

        for i in self.cfg.core_synthesis_files:
            f.write("verilog work  "+i.strip("'")+"\n")

        if self.cfg.cpu == "picoblaze":
            f.write("verilog work  "+self.cfg.root + self.cfg.program_image+"\n")            

        f.close()
        
        return
    
    ################################################################################
    def synthesis(self):

        ##
        ## Create the xst file that controls the flow of the tools and the
        ## prj file that lists the files to synthesize
        ##
        self.create_xst_file()
        self.create_prj_file()

        ##
        ## Get all the executables that we will need for this process
        ## 
        xst = self.get_executable("xst")
        ngdbuild = self.get_executable("ngdbuild")
        map_executable = self.get_executable("map")

        ##
        ## Run the front end synthesis
        ## 
        log_file = self.cfg.project+".syr"
        command = xst +" -intstyle ise -ifn "+self.xst_file+" -ofn "+log_file
        print command
        os.system(command)

        ##
        ## NGDBUILD Translates and merges the various source files of a design into a
        ## single "NGD" design database
        ##
        command = ngdbuild+" -intstyle ise -dd _ngo -nt timestamp -uc "+self.cfg.root+"/"+self.cfg.xilinx.constraints+" -p "+self.cfg.xilinx.fpga_model+" " +self.ngc_file+" " +self.ngd_file
        print command
        os.system(command)


        ##
        ## MAP maps design to xilinx elements
        ##
        command = map_executable +" -intstyle ise -p "+ self.cfg.xilinx.fpga_model+" -o "+self.map_ncd_file + " " +self.ngd_file + " " + self.pcf_file 
        print command
        os.system(command)


        return
    
    ################################################################################
    def place_and_route(self):

        ##
        ## Get all the executables that we will need for this process
        ## 
        par = self.get_executable("par")
        trce = self.get_executable("trce")
        netgen = self.get_executable("netgen")

        ##
        ## PAR -- Place and Route
        ##
        command = par +" -w -intstyle ise " + self.map_ncd_file + " " +self.ncd_file +" "+self.pcf_file
        print command
        os.system(command)

        ##
        ## TRCE: Creates a Timing Report file (TWR) derived from static timing
        ## analysis of the Physical Design file (NCD). The analysis is typically
        ## based on constraints included in the optional Physical Constraints
        ## file (PCF).
        ##
        command = trce + " -intstyle ise -xml " + self.twx_file+" " +self.ncd_file +" "+ self.pcf_file
        print command
        os.system(command)

        ##
        ## Netgen -- creates a post place and route simulation model 
        ## 
        command = netgen + " -intstyle ise -sdf_anno false -insert_glbl true -ofmt verilog -dir netgen/par -pcf " + self.pcf_file + " -sim "+self.ncd_file +" " + self.ppr_file
        print command
        os.system(command)
        
        return

    ################################################################################
    def generate_file(self):

        ##
        ## Get all the executables that we will need for this process
        ## 
        bitgen = self.get_executable("bitgen")
        
        ##
        ## BITGEN -- create the bit file for download
        ##
        command = bitgen + " -intstyle ise -g StartupClk:JtagClk "  + self.ncd_file
        print command
        os.system(command)
        
        return
