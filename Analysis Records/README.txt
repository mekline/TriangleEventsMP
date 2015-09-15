Analysis for fMRI experiments is conducted on Mindhive!

Here, save copies of critical files and records of the commands run for analyses. This is my first experiment, so possibly no need to store this much later on.  (IDEAL: don’t store multiple copies of anything at all; track analysis creation w/ versioning tools. How would we make that possible given current lab structure?)

First level analysis: these produce a set of contrast images for an individual brain (projected onto the standard brain). This includes con images from localizers and from critical experiments. In some cases we instead swipe these contrast images from a previous session that participant did(?)

For the EventsMP study, we want to generate contrasts for:
 
EventsMP
Dyloc
Langloc
MDLoc
MTLoc
BioLoc

Details about which contrasts are being computed for each experiment can be found in the appropriate build_contrast files in the Preprocessing folder.

NOTE that not all participants have all localizers from our session, either bc we didn’t run it (pilot subj FED_20150720a_3T2 doesn’t have bioloc for instance) or bc they had the localizer on a previous visit. Right now I don’t know where we get contrast images from previous/other sessions so they’re easily findable.  



*****
GENERAL EXPERIMENT INFO/NOTES

EventsMP should be run 5 times per participant

para
EventsMP_p1.para  _p2, _p3, _p4, _p5, _p6  *A documentation note: mod(counterb+run,6) - 1 = p.  So 1,1 = p1, 1,2 = p2; 2,1 = p2, etc.  This is NOT true for the first participant, whose cat file will therefore be a bit different from how the others are generated.  

*****	
COMMANDS

*Langloc (2 runs)
“You’ll see series of sentences, and nonwords like jabberwocky. Your job is just to pay attention and read the words you see, and don’t be too stressed out if the words seem to go by quickly. At the end of each sentence you’ll see a picture of a hand pressing a button, and you should press button number 1 each time, this is just to help you stay alert.”  

Shared/ev/langloc_for_stanford/fmrilanguagelocalizerexperiment/
kanwisher_langloc_2conds_main_fmri_idan(‘subid’, 1, 0)
kanwisher_langloc_2conds_main_fmri_idan(‘subid’, 2, 0)
(final input can be 1 for counterbalancing; needs to be constant/subject)

*MDLoc (2 runs, or 1 if running short on time)
“In this experiment, you will see a 4x3 grid of squares on the screen. These squares will light up in blue (one or two at a time) in some order. Then you will be shown two grids side-by-side, each with a pattern of blue squares. Your task is to choose which pattern corresponds to the sequence you just saw. Press button 1 to choose the grid on the left and button 2 to choose the one on the right. You will be given feedback after every trial. It’s designed to be very difficult so don’t worry if you are getting some of them wrong, the important thing is to focus on doing the task and try as hard as you can.”

Shared/ev/grid_MDloc/
python gridEXP.py -s subid -v4 -fy -n1 -c1
python gridEXP.py -s subid -v4 -fy -n2 -c2

NOTE: build_model/contrasts copied from MEGAANALYSIS named build_model_spatialFIN.m


*EventsMP (5 runs)
“In this task you’ll be watching short animations of characters moving around. There’s no task in this one, just focus on paying attention to what’s happening and try to stay alert.”

Shared/TriangleEventsMP/
eventsMP(‘subid’,1,1)
eventsMP(‘subid’,1,2)
eventsMP(‘subid’,1,3)
eventsMP(‘subid’,1,4)
eventsMP(‘subid’,1,5)
(middle input can be 1-6 for counterbalancing; needs to be constant/subject)

*Dyloc (4 runs (or 2))
“XXXXXXXX CURRENTLY BROKEN ON FRANKLIN”
“This experiment is made for kids, so it’s pretty fun. You’re just going to be seeing very short movies and animations of kids playing and things like that. Just try to stay alert and watch what’s happening.”

On Dax: Shared/Experiments/ev/0_LOCALIZERS/DyLoc/dyLoc_20090405
On Franklin:Shared/ev/Dyloc/dyLoc_20090405/
dyLocX(‘subid’,[1:6],1,1)
dyLocX(‘subid’,[1:6],2,2)
dyLocX(‘subid’,[1:6],3,3)
dyLocX(‘subid’,[1:6],4,4)
(2nd input can be [values 1-6] in any order for counterbalancing, constant/subject)

*MTLoc (2 runs)
“This is a lower-level vision test, so you’re going to be seeing just dots or static moving around. There will be some instructions on the screen to start that explains it a little more, but your task is just to press button number 1 whenever the red dot fades.”

Shared/ev/evMTLoc/
MTLoc_ev(‘subid’,1)
MTLoc_ev(‘subid’,2)

*BioLoc (2-4 runs)
“In this experiment you’re going to be seeing point-light animations of people and objects - so it’s just white dots, but the motion will make you think of more specific things & actions.  There’s a memory task for this one: every once in a while an animation will repeat, and whenever this happens you should press button #1. So for instance if you see the one that looks like a person hitting a baseball bat twice in a row, hit the button. Otherwise just watch the movies and pay attention to what’s happening.”

Shared/ev/BioLoc
bioloc2_evlab(‘subid’,[1:4],1,23452345)
bioloc2_evlab(‘subid’,[1:4],2,23452345)
bioloc2_evlab(‘subid’,[1:4],3,23452345)
bioloc2_evlab(‘subid’,[1:4],4,23452345)
(for counterbalancing, can use any order 1:4, and set a different random seed)


*****
INDIVIDUAL SUBJECTS

+++++
FED_20150720a_3T2
ID: 199
Ran (in this session) EventsMP (5), DyLoc (4), MTLoc (2)
Func runs: 9 11 13 15 17 19 21 23 25 27 29


Dyloc
run_subject_Aug202012.sh -c Config_allsteps_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150720a_3T2/FED_20150720a_3T2_dicom -m DyLoc FED_20150720a_3T2

MTloc
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150720a_3T2/FED_20150720a_3T2_dicom -m MTLoc FED_20150720a_3T2

EventsMP
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150720a_3T2/FED_20150720a_3T2_dicom -m EventsMP FED_20150720a_3T2

BioLoc
Nope!

LangLoc
(from a previous sessions, not yet sure how to incorporate)

MDLoc
(from a previous sessions, not yet sure how to incorporate)


+++++
FED_20150820a_3T2
ID: 322
Ran (in this session) LangLoc(2), MDLoc(1), EventsMP (5), DyLoc (2), MTLoc (2), BioLoc(2)
Func runs: 5 7 9 11 13 17 19 21 23 25 27 29 31 33


DyLoc
run_subject_Aug202012.sh -c Config_allsteps_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150820a_3T2/FED_20150820a_3T2_dicom -m DyLoc FED_20150820a_3T2

MTloc
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150820a_3T2/FED_20150820a_3T2_dicom -m MTLoc FED_20150820a_3T2

EventsMP
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150820a_3T2/FED_20150820a_3T2_dicom -m EventsMP FED_20150820a_3T2

LangLoc
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150820a_3T2/FED_20150820a_3T2_dicom -m langlocSN FED_20150820a_3T2

MDLoc
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150820a_3T2/FED_20150820a_3T2_dicom -m MDLoc FED_20150820a_3T2

This failed too! Why the hell?  Let’s try renaming everything the original way.

Trying as spatialFIN, maybe that matters?

+++++
FED_20150823_3T2
ID: 323
Ran (in this session) LangLoc(2), MDLoc(1), EventsMP (5), DyLoc (2), MTLoc (2), BioLoc(2)
Func runs: 5 7 9 11 13 15 17 19 21 23 25 29 31 33

DyLoc
run_subject_Aug202012.sh -c Config_allsteps_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150823_3T2/FED_20150823_3T2_dicom -m DyLoc FED_20150823_3T2

MTloc
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150823_3T2/FED_20150823_3T2_dicom -m MTLoc FED_20150823_3T2

EventsMP
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150823_3T2/FED_20150823_3T2_dicom -m EventsMP FED_20150823_3T2

LangLoc
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150823_3T2/FED_20150823_3T2_dicom -m langlocSN FED_20150823_3T2

MDLoc
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150823_3T2/FED_20150823_3T2_dicom -m MDLoc FED_20150823_3T2

—This failed! Not sure why.  See screenshot 0823_3T2 for the error. 

Trying as spatialFIN, maybe that matters?
run_subject_Aug202012.sh -c Config_modelandcontrdef_EventsMPExp_20150812.cfg -I /mindhive/evlab/u/mekline/Desktop/EventsMP/Data/FED_20150823_3T2/FED_20150823_3T2_dicom -m spatialFIN FED_20150823_3T2



***** Run outputs, to calm the brain of mk


FED_20150820a_3T2

ser   ntp    seq name
----  ----   --------
  1:  128:   AAHScout_32ch
  2:    4:   AAHScout_32ch_MPR
  3:  176:   T1_MPRAGE_1iso
  4:  176:   T1_MPRAGE_1iso
  5:  179:   ge_func_2p1x2p1x4_PACE_improved
  6:  179:   MoCoSeries
  7:  179:   ge_func_2p1x2p1x4_PACE_improved
  8:  179:   MoCoSeries
  9:  180:   ge_func_2p1x2p1x4_PACE_improved
 10:  180:   MoCoSeries
 11:  180:   ge_func_2p1x2p1x4_PACE_improved
 12:  180:   MoCoSeries
 13:  224:   ge_func_2p1x2p1x4_PACE_improved
 14:  224:   MoCoSeries
 15:    9:   ge_func_2p1x2p1x4_PACE_improved
 16:    9:   MoCoSeries
 17:  137:   ge_func_2p1x2p1x4_PACE_improved
 18:  137:   MoCoSeries
 19:  180:   ge_func_2p1x2p1x4_PACE_improved
 20:  180:   MoCoSeries
 21:  117:   ge_func_2p1x2p1x4_PACE_improved
 22:  117:   MoCoSeries
 23:  117:   ge_func_2p1x2p1x4_PACE_improved
 24:  117:   MoCoSeries
 25:  149:   ge_func_2p1x2p1x4_PACE_improved
 26:  149:   MoCoSeries
 27:  180:   ge_func_2p1x2p1x4_PACE_improved
 28:  180:   MoCoSeries
 29:  137:   ge_func_2p1x2p1x4_PACE_improved
 30:  137:   MoCoSeries
 31:  180:   ge_func_2p1x2p1x4_PACE_improved
 32:  180:   MoCoSeries
 33:  149:   ge_func_2p1x2p1x4_PACE_improved
 34:  149:   MoCoSeries


