function get_paras(matfile)

%Load in the mat file
spm = load(matfile)
%Make & sort a table

info = spm.spm_inputs;
info

[cond1 cond2]= info.name;
[ons1 ons2]= info.ons;

list1 = repmat(cond1, 6, 1);
list2 = repmat(cond2, 6, 1);

%print it out like a para file!

conds = table([ons1; ons2], [list1;list2]);
conds = sortrows(conds, 'Var1')




end