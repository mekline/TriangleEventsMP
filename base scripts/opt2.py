import csv
import xlwt
import random
import copy
import sys

# optimize distribution of materials into runs by actor, story, segment
# Zuzanna Balewski, zzbalews@gmail.com
# last update: Sept. 5, 2014

def search(f,l,cond): #main search loop
    '''
    INPUT:
    -- f = filename
    -- l = list in ['1','2','3','4','5']
    -- cond = condition in ['A','B','C','D','E']
    OUTPUT: ans = solution state with all items
    '''
    global ans,fin
    #get items (ordered list of items to add)
    items = [row for row in csv.reader(open(f,'rU')) if row[8]==l and row[9]==cond]
    random.shuffle(items)
    items=items[:30]
    
    #make mapping (dict of items with item numbers as keys and item arrays as values)
    mapping = {}
    for i in items:
        mapping[i[2]]=i
    
    #start state d = ( (#),(#),(#),(#),(#) ), each run has 1 item
    d = tuple([(items[i][2],) for i in range(5)])

    #DFS
    parent = {d:None} #dict of checked nodes
    ans = None #solution state with all items
    fin=False #if found solution
    DFS(d,Adj,cond,parent,mapping,items)

    return ans,mapping



def DFS(s,Adj,cond,parent,mapping,items): #recursive depth first search loop
    '''
    INPUT:
    -- s = current state of ( (),(),(),(),() )
    -- cond = condition in ['A','B','C','D','E']
    -- parent = dict of checked nodes, pointers to parents
    -- mapping = dict of items with item numbers as keys and item arrays as values
    -- items = ordered list of items to add
    OUTPUT: [none] (global ans updated)
    '''
    global ans
    #assign state test
    if cond in ['A','B','E']: test = testStory
    elif cond in ['C','D']: test = testNoStory
    #get list of adjacent states
    next = Adj(s,items,mapping,test)

    if next=='finished': #save good solution
        print '     good distribution found!'
        ans = s
    
    for v in next: #go through each adjacent node
        if v not in parent: #if node hasn't been checked
            parent[v]=s #add node to checked dictionary
            DFS(v,Adj,cond,parent,mapping,items) #run DFS on node


def Adj(d,items,mapping,test): #returns viable adjacent states with new item
    '''
    INPUT:
    -- d = current state of ( (),(),(),(),() )
    -- items = ordered list of items to add
    -- mapping = dict of items with item numbers as keys and item arrays as values
    -- test = testStory() for cond in ['A','B','E'] or testNoStory() for cond in ['C','D']
    OUTPUT: list of adjacent states, or 'finished' if solution found
    '''
    global fin

    finished = sum([len(r) for r in d]) #number of items added
    if finished==len(items): #all items added
        #print 'reached limit!'
        fin = True
        return 'finished'

    if not fin: #solution not found
        item = items[finished][2] #new item to be added

        output = [] #list of good states
        for i in range(5): #add new item to each run, check of good state
            new_d = [[x for x in r] for r in d]
            new_d[i].append(item)
        
            if test(new_d,mapping):
                tuple_d = tuple([tuple(r) for r in new_d])
                output.append(tuple_d)
        return output
            
    else: #solution found, empty tree
        return []


def testStory(d,mapping): #check if state viable for conds 'A','B','E'
    '''
    INPUT:
    -- d = current state of ( (),(),(),(),() )
    -- mapping = dict of items with item numbers as keys and item arrays as values
    OUTPUT: if good state
    '''
    for run in d: #check each run
        #length <= 6
        if len(run)>6: return False
        actors,stories = [],{}
        for j in run:
            i = mapping[j]
            #unique actors in run
            if i[4] not in actors: actors.append(i[4])
            else: return False
            #max 2 of story, unique clips of same story
            if i[5] not in stories: stories[i[5]]=[1,i[6]]
            else:
                if stories[i[5]][0]==2: return False
                else:
                    stories[i[5]][0]=2
                    if i[6]==stories[i[5]][1]: return False
    return True

def testNoStory(d,mapping): #check if state viable for conds 'C','D'
    '''
    INPUT:
    -- d = current state of ( (),(),(),(),() )
    -- mapping = dict of items with item numbers as keys and item arrays as values
    OUTPUT: if good state
    '''
    for run in d: #check each run
        #lenght <=6
        if len(run)>6: return False
        actors= []
        for j in run:
            i = mapping[j]
            #unique actors in run
            if i[4] not in actors: actors.append(i[4])
            else: return False
    return True


def add_to_file(sheet,row,lst,cnd):
    print "Working on......   list",lst,"; cond",cnd
    ans,mapping = search('materials.csv',lst,cnd)
    k = 0
    rowx = row
    for i in ans:
        k+=1
        for j in i:
            output = mapping[j] + [k]
            rowx+=1
            for colx,value in enumerate(output):
                sheet.write(rowx,colx,value,xlwt.easyxf())

    return rowx

def split_all_materials(subj,lst):
    headings =["color","file","item","gesture","actor","story","clip within story","NA/NF/audio","list","condition","run"]
    book = xlwt.Workbook()
    sheet = book.add_sheet('materials')
    row = 0
    for colx,value in enumerate(headings):
        sheet.write(row,colx,value,xlwt.easyxf())
    for cnd in ['A','B','C','D','E']:
        row = add_to_file(sheet,row,lst,cnd)
    book.save('data/'+subj+'_items_divided.xls')



if __name__ == "__main__":

    #run from command line: $ python opt2.py subjectID list
    #subjectID = str, subject id name
    #list = int, 1-5
    
    #save xls file: easier to open in matlab

    args = sys.argv
    if len(args)!=3:
        print >> sys.stderr, "needs args: SUBJID list"
        sys.exit(1)
    
    split_all_materials(args[1],args[2])

