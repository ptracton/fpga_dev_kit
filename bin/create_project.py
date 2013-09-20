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
import shutil

def install_files(src, dst):
    shutil.copy2(src+"/skeleton/fpga.cfg", dst+"/configurations/")
    shutil.copy2(src+"/skeleton/testbench.v", dst+"/bench/verilog/")
    shutil.copy2(src+"/skeleton/dump.v", dst+"/bench/verilog/")
    shutil.copy2(src+"/skeleton/timescale.v", dst+"/bench/verilog/includes")
    
    shutil.copy2(src+"/skeleton/isim.tcl", dst+"/sim/rtl_sim/src")
    shutil.copy2(src+"/skeleton/Makefile", dst+"/sim/rtl_sim/src")
    
    shutil.copy2(src+"/skeleton/isim.tcl", dst+"/sim/ppr_sim/src")
    shutil.copy2(src+"/skeleton/Makefile", dst+"/sim/ppr_sim/src")

    shutil.copy2(src+"/skeleton/README", dst)
    shutil.copy2(src+"/skeleton/README", dst+"/fpga/")
    shutil.copy2(src+"/skeleton/README", dst+"/software/applications/")
    return

def safe_mkdir(path):
    try:
        os.makedirs(path)
    except:
        print("Failed to make " + path)
        sys.exit(1)
    return

def list_to_dirs(dirs):
    
    for i in dirs:
        print(i.strip("[']"))
        safe_mkdir(i.strip("[']"))
    return

def fpga_project(project_name):

    print("\n\nCreating FPGA Project: " + project_name)

    ##
    ## DIR STRUCTURE:  project_name
    ##                 bench 
    ##                    behavioral
    ##                    includes
    ##                 configurations
    ##                 documents
    ##                 rtl
    ##                    verilog
    ##                       project_name (top level instance)
    ##                 sim
    ##                    ppr_sim
    ##                       bin
    ##                       run
    ##                       src
    ##                     rtl_sim
    ##                        bin
    ##                        run
    ##                        src
    ##                     tests
    ##                 fpga
    ##                  software
    ##                     application
    ##
    ##

    if (os.path.exists(project_name)):
        print("Project: "+project_name+" already exists")
        sys.exit(1)

    project_dirs = []
    project_dirs.append(project_name+"/bench/verilog/behavioral")
    project_dirs.append(project_name+"/bench/verilog/includes")
    project_dirs.append(project_name+"/bench/verilog/tasks")
    project_dirs.append(project_name+"/configurations")
    project_dirs.append(project_name+"/documents")
    project_dirs.append(project_name+"/rtl/verilog/"+project_name)
    project_dirs.append(project_name+"/sim/ppr_sim/bin")
    project_dirs.append(project_name+"/sim/ppr_sim/run")
    project_dirs.append(project_name+"/sim/ppr_sim/src")
    project_dirs.append(project_name+"/sim/rtl_sim/bin")
    project_dirs.append(project_name+"/sim/rtl_sim/run")
    project_dirs.append(project_name+"/sim/rtl_sim/src")
    project_dirs.append(project_name+"/sim/tests")
    project_dirs.append(project_name+"/fpga/")
    project_dirs.append(project_name+"/software/applications")


    src_dir = os.path.realpath(__file__)
    src_dir = src_dir.split("/")[:-1]
    src_dir = '/'.join(map(str, src_dir))
    print(src_dir)

    
    list_to_dirs(project_dirs)
    
    install_files(src_dir, project_name)
    
    return



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
    ## Support switches.  They handle various tasks
    ##
    parser.add_option("-d", "--debug",   dest="debug",  action='store_true', help="turns on debugging print statements")
   

    ##
    ## Get the options dictionary and list of arguments passed in from CLI
    ##
    (opts, args) = parser.parse_args()
    
    ##
    ## Display the options passed in if you use the -d switch
    ##
    if opts.debug:
        print(opts)
        print(args)

    ##
    ## Make sure the user specified a test case to run otherwise there is no stimulus file to copy
    ## and the test will fail to run
    ##
    if not args:
        print("Must specify a project name!")
        sys.exit(1)

    project_name = str(args[0]).strip("[']")
    fpga_project(project_name)


    ##
    ## All done, terminate program
    ##
    print("\n\nAll Done!\n")    
    sys.exit(0)
