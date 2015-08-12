Analysis for fMRI experiments is conducted on Mindhive.

Here, save copies of critical files and records of the commands run for analyses. This is my first experiment, so possibly no need to store this much later on.  (IDEAL: don’t store multiple copies of anything at all; track analysis creation w/ versioning tools. How would we make that possible given current lab structure?)

First level analysis: these produce a set of contrast images for an individual brain (projected onto the standard brain). This includes con images from localizers and from critical experiments. In some cases we get these contrast images from a previous session that participant did.

For the EventsMP study, we want to generate contrasts for:
 
EventsMP
Dyloc
Langloc
MDLoc
MTLoc
BioLoc

Details about which contrasts are being computed for each experiment can be found in the appropriate build_contrast files in the Preprocessing folder.

NOTE that not all participants have all localizers from our session, either bc we didn’t run it (pilot subj  FED_20150720a_3T2) or bc they had the localizer on a previous visit. Right now I don’t know where we get contrast images from previous sessions so they’re easily findable.  

GENERAL EXPERIMENT INFO

para
EventsMP_p1.para  _p2, _p3, _p4, _p5, _p6  *A documentation note: mod(counterb+run,6) - 1 = p.  So 1,1 = p1, 1,2 = p2; 2,1 = p2, etc.  This is NOT true for the first participant, whose cat file will therefore be a bit different from how the others are generated.  
	


INDIVIDUAL SUBJECTS

*****
FED_20150720a_3T2
ID: 199
Func runs: 9 11 13 15 17 19 21 23 25 27 29


1st level analyses:

Dyloc
run_subject_Aug202012.sh -c Config_allsteps_EventsMPExp_20150812.cfg -I /mindhive/nklab/u/mekline/Desktop/EventsMP/Data/FED_20150720a_3T2/FED_20150720a_3T2_dicom -m DyLoc 299_FED_20150720a_3T2


################
EventsMP
run_subject_Aug202012.sh -c Config_modelandcontrdef.cfg -I /users/evelina9/more_evelina_files/MEGADATA/299_FED_20150720a_3T2/FED_20150720a_3T2_dicoms -m EventsMP 299_FED_20150720a_3T2




