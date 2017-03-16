
''' This script will replace all "long" library paths such as
@rpath/a/long/path/libExample.dylib with shortened paths such as
@rpath/libExample.dylib. It does not change the rpaths themselves,
just the references to them.
'''

import os, sys, subprocess

def fixOneFile(inputPath, resetRpath):
    '''Correct a single file'''

    # Get list of libraries loaded by this library
    cmd = ['otool', '-l', inputPath]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    otoolOutput, err = p.communicate()

    #print otoolOutput

    # Search for abs paths to the USGS hard coded location
    needRpath  = False
    lines      = otoolOutput.split()
    numUpdates = 0
    for line in lines:

        # Keep track of whether the next change step is for an ID or a LOAD operation.
        if line == 'LC_ID_DYLIB':
            idLine = True
        if line == 'LC_LOAD_DYLIB':
            idLine = False

        # Only change lines containing @rpath
        if '@rpath' not in line:
            continue

        # Trim off just the library name and prepend @rpath
        pos     = line.rfind('/')
        end     = line[pos:]
        newPath = '@rpath' + end

        if newPath == line: # Skip already correct lines
            continue

        # Replace the line
        if idLine: # Handle LC_ID_DYLIB lines
            cmd = ' '.join(['install_name_tool', '-id', newPath, inputPath])
        else: # Handle LC_LOAD_DYLIB lines
            cmd = ' '.join(['install_name_tool', '-change', line, newPath, inputPath])
        #print cmd
        os.system(cmd)
        numUpdates += 1

    # TODO: Delete any existing rpaths to keep things clean!
    # If this option is set, reset the RPATH to look only in the local folder.
    if resetRpath:
        cmd = 'install_name_tool -add_rpath ./ ' + inputPath
        #print cmd
        os.system(cmd)
        numUpdates += 1

    return numUpdates

def main():
    '''Main program corrects all files in a folder'''

    # Check input arguments
    usage = 'python finalizeInstalledOsxRpaths.py folder [resetRpath]'
    if len(sys.argv) < 2:
        print usage
        return -1

    inputFolder= sys.argv[1]
    resetRpath = False
    if len(sys.argv) == 3:
        resetRpath = True
    if not os.path.exists(inputFolder):
        print 'Input folder '+inputFolder+' does not exist!'
        return -1

    # Fix all of the .dylib files in the given folder
    files = os.listdir(inputFolder)
    for f in files:
        if '.dylib' in f:
            numUpdates = fixOneFile(os.path.join(inputFolder, f), resetRpath)
            print f + ' --> ' + str(numUpdates) + ' changes made.' 
            #raise Exception('DEBUG')
    

# Execute main() when called from command line
if __name__ == "__main__":
    sys.exit(main())



