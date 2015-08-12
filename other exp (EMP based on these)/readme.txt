Gestures Experiment
-------------------

NOTE: For each subject, materials are split into runs with python script (opt2.py) -- this optimizes most even distribution of actors/stories/segments into blocks; if the script takes more than a couple seconds, kill manually and run again (should not happen regularly!). The main experiment loop is a matlab script (gestures_exp.m). The python script can be run from the matlab command window or an independent terminal window. 

* need xlwt package for python: $ pip install xlwt *


TO RUN:

$$ python opt2.py SUBJ list

	SUBJ = str, subject ID
	list = int, 1-5

>> gestures_exp(SUBJ,run,counterbalancing)
	
	SUBJ = subject ID (char, same as above)
	run = run number (1-5) [order doesn't matter, reference for split materials]
	counterbalancing = block order (1-5)

Each run is 258 sec (4 min 18 sec).
This is a passive viewing task, so no responses are recorded. The planned item presentation order/timing is saved at the start of each run. To prevent over-write (for example, in case of restarting run) repeat file names will be appended with '-x1', '-x2', ... 
The trial onsets (in Psychtoolbox time) are saved in _onsets.csv as a check.

EXAMPLE: 

$$ python opt2.py ztest 1
>> gestures_exp('ztest',1,2,5)
>> gestures_exp('ztest',2,2,4)
>> gestures_exp('ztest',3,2,3)
>> gestures_exp('ztest',4,2,2)
>> gestures_exp('ztest',5,2,1)

[over 5 runs, subject will see one ever item in particular list]



-------------------
contact: Zuzanna Balewski, zzbalews@gmail.com
last update: Sept. 25, 2014
