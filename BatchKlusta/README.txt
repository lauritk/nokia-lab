
BATCH KLUSTA, "WINDOWS" BATCH SCRIPT FOR KLUSTAKWIK.
*****************************************************************

NAME:
batchKlusta.cmd

DATE:
19/12/2017

DEVELOPED:
Lauri Kantola, 
University of Jyväskylä, Department of Psychology

EMAIL: 
contact@laurikantola.info,
lauri.t.kantola@jyu.fi
*****************************************************************

FILES:
- batchKlusta.cmd (the script)
- klustaParam.prm (template for klusta parameters)
- revisedAtlas32ch4shaft_default.prb (default probe-file)
- README.txt (this file)
*****************************************************************

HOW TO USE:
1. Just add the script folder to Windows User Environment Path.

2. Copy 'klustaParam.prm' and 'revisedAtlas32ch4shaft_default.prb' 
   to your current working directory.
   
3. Use in any folder via Command Prompt typing 'batchKlusta'.

4. Follow the instructions given in the Command Prompt!

NOTE:
Filenames should follow the usual naming convention:

e.g. 411_lightx45_ITI2min_se3.mcd, or 411_Random1000_CC1.mcd.

Folder structure should follow following structure:

basefolder\sub_id\infix\postfix

e.g. clustering\411\lightx45_ITI2min\se3 or clustering\411\Random1000\CC1\

*****************************************************************

HINTS:
1. You can use other probe-files. Just copy the file to 
   the working directory and type name in the script!
   
2. You can also make own parameter-files for klusta.
   Use any regular Klusta parameter-files, but just
   remove first two lines from file that says 
   'experiment_name' and 'prb_file'. The script will
   generate those lines with proper ones!
   
3. Script also logs the progress. Check the working 
   directory for log-files!