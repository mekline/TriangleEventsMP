# TriangleEventsMP
an fMRI script for presenting videos from a set in feature-based blocks (e.g. all-same, f1-same-f2-diff, all-diff) 

Requires Matlab + Psychtoolbox

This is a reasonably basic script for presenting a series of movies in the scanner, handling the interactions with the MRI and keeping an eye on the exact timing of video presentation. No participant responses are collected from button boxes, but they probably could be. (Check out Psychtoolbox keyboard/input handling.)

The things that make the experiment weird are all in in choose_order.  Choose_order.m should return a cellarray with the list of videos, in order, that you want to play, plus any info you want to keep track of (like which block they are part of, length, condition, etc.)

In this version, I construct blocks that are defined by the *relationship* between movies, rather than the movies themselves.  (So for instance a 'same manner' block is any four movies that share the same random manner of motion, but differ on the other dimensions, and an 'all diff' block is one where the four movies each have different values for manner, path, and agent.)

If you just want blocks of a condition, then you instead want to randomize your block order however you want it, choose/randomize movies for each block, and then send them back over as a flat list of movies in the cellarray.
