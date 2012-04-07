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

class synth_tool:
    '''
    This is the base class for any simulation tool.  Here we keep all the common things
    that a simulation will perform.
    '''

    ################################################################################
    def __init__(self, options, config, args):

        ## opts are the command line options
        self.opts = options

        ## cfg is the config file object
        self.cfg = config

        ## by checking the options we can create a string for which type of simulation we are running
        self.fpga_type = "xilinx"        
        if options.xilinx:
            self.fpga_type = "xilinx"
        if options.altera:
            self.fpga_type = "altera"
        if options.asic:
            self.fpga_type = "asic"

        return

    ################################################################################
    def get_executable(self, executable):
        '''
        Utility function to get the absolute path for an executable.
        This is used by all simulations to find the actual program
        that simulates the design
        '''
        stdout_handle = os.popen("which "+executable, "r")
        return stdout_handle.read().rstrip('\n') 


    ################################################################################
    def clean_synthesis(self):
        '''
        Remove the directory with the results from the last time we ran this simulation
        '''
        print "Cleaning Sim " + self.sim_dir

        command = "rm -rf " + self.sim_dir
        print command

        ## try to remove the old directory, if it is not there, os.system throws an exception
        ## so we catch it and move on
        try:
            os.system("rm -rf " + self.sim_dir)
        except:
            print self.sim_dir+" is already gone!"

    ################################################################################
    def synthesis(self):
        print "OVER RIDE THIS FUNCTION!"
        return
    
    ################################################################################
    def place_and_route(self):
        print "OVER RIDE THIS FUNCTION!"
        return

    ################################################################################
    def generate_file(self):
        print "OVER RIDE THIS FUNCTION!"
        return    

 
