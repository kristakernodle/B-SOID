# -*- coding: utf-8 -*-
"""
Created on Tue Feb  4 08:34:46 2020

@author: kkrista
"""

import os
from os import path

def find_vidFullPath(vidDir,vidName):
    if ~vidDir.endswith('/'):
        vidDir = vidDir + '/'
    mouse = 'et' + vidName.split('_')[0]
    date = vidName.split('_')[1]
    
    
    path.exists(vidDir + mouse + '/Training/' + mouse +'_' + date)

def vidChop(vidDir,vidName,startFrame,endFrame,fps):
    # Modified from https://github.com/kristakernodle/VideoProcessing/blob/master/skilledReaching/createTrialVideos/LEDDetection.py
    # 02042020
    vidFullPath = find_vidFullPath(vidDir,vidName)
    
bsoid_outDir = "X:/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/bsoid_labeledData_testingData_Center/"
vidDir = "X:/Neuro-Leventhal/data/mouseSkilledReaching/"

allFiles = os.listdir(bsoid_outDir)
csvFiles = [file for file in allFiles if file.endswith('.csv')]

for csv in csvFiles:
    with open(bsoid_outDir + '/' + csv) as f:
        labels = f.read().splitlines()
    filename = csv.split('10fps')[0]
    if filename.endswith('_'):
        filename = filename[:-1]
    vidChop(vidDir,vidName,startFrame,endFrame,fps)
    
    
        
        
    
