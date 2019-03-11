import pandas as pd
import sys
import json
import math
import os

rankfile = sys.argv[1]
combofile = sys.argv[2]
#modulename = sys.argv[3]

ranks = pd.read_table(rankfile, header=None, index_col=False)
combos = pd.read_table(combofile, header=None, index_col=False)

#rankarr = pd.DataFrame(ranks)[1].tolist()
alltfcombos = pd.DataFrame(combos)[1].tolist()

threshold = round(len(alltfcombos)*0.15)
rankdf = pd.DataFrame(ranks)
filtdf = rankdf.loc[rankdf[0]>= threshold]
rankarr = filtdf[1].tolist()

counts = []
count = 0
count3 = 0
countdict = {}
myrange = len(rankarr)-1
print(rankarr,threshold, len(alltfcombos))
for i in range(myrange):
    countdict[rankarr[i]] = {}
    countdict[rankarr[i]]['two-way'] = {}
    countdict[rankarr[i]]['three-way'] = {}
    for j in range(i,myrange):
        count = 0
        for tfstring in alltfcombos:
            mylist = tfstring.split(",")
            if all(x in mylist for x in [rankarr[i], rankarr[j]]):
                count+=1
        if rankarr[i] != rankarr[j]:
            for k in range(j+1, myrange):
                count3 = 0
                #print(rankarr[i], rankarr[j], rankarr[k])
                for tfstring in alltfcombos:
                    tflist = tfstring.split(",")
                    if all(x in tflist for x in [rankarr[i], rankarr[j], rankarr[k]]):
                        count3+=1
                countdict[rankarr[i]]['three-way'][rankarr[j]+"+"+rankarr[k]] = count3
        countdict[rankarr[i]]['two-way'][rankarr[j]] = count


newdict = {}
for k in countdict:
    newdict[k] = {}
    newdict[k]['two-way'] = sorted(countdict[k]['two-way'].items(), key=lambda x: x[1],reverse=True)
    newdict[k]['three-way'] = sorted(countdict[k]['three-way'].items(), key=lambda x: x[1],reverse=True)
    
print(countdict)  
countdata = open("countTFcombo.json", "w")
countdata.write(json.dumps(newdict, indent=4))
countdata.close()