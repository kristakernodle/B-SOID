# -*- coding: utf-8 -*-
"""
Created on Tue Feb  4 08:34:46 2020

@author: kkrista
"""

import os
from os import path

def find_vidFullPath(vidDir,vidName):
    if list(vidDir)[-1] != '/':
        vidDir = vidDir + '/'
    if list(vidName)[-4:] != list('.MP4'):
        vidName = vidName + '.MP4'
    mouse = 'et' + vidName.split('_')[0]
    date = vidName.split('_')[1]
    reachVid = vidName.split('_')[-2]

    trainDir = vidDir + mouse + '/Training/'
    if path.exists(trainDir):
        trainDir_contents = os.listdir(trainDir)
        for item in trainDir_contents:
            if date in item.split('_'):
                date_folder = item
                break
        vidFullPath = trainDir + date_folder + '/Reaches' + reachVid + '/' + vidName
        if path.exists(vidFullPath):
            return vidFullPath
    return ['Directory does not exist. Check nesting folder structure.',vidDir,vidName]

def vidChop(vidDir,vidName,startFrame,endFrame,fps):
    # Modified from https://github.com/kristakernodle/VideoProcessing/blob/master/skilledReaching/createTrialVideos/LEDDetection.py
    # 02042020
    vidFullPath = find_vidFullPath(vidDir,vidName)
    
bsoid_outDir = "/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/bsoid_labeledData_testingData_Center/"
vidDir = "/Volumes/SharedX/Neuro-Leventhal/data/mouseSkilledReaching/"

if not path.exists(bsoid_outDir):
    print('bsoid_outDir does not exist. Please check your directory and try again.')
    print(bsoid_outDir)
if not path.exists(vidDir):
    print('vidDir does not exist. Please check your directory and try again.')
    print(vidDir)
    
allFiles = os.listdir(bsoid_outDir)
csvFiles = [file for file in allFiles if file.endswith('.csv')]

for csv in csvFiles:
    
    
    
#    with open(bsoid_outDir + '/' + csv) as f:
#        labels = f.read().splitlines()
#    
#    frames = getFrame
#    
    filename = csv.split('10fps')[0]
    if filename.endswith('_'):
        filename = filename[:-1]
    fullVidPath = find_vidFullPath(vidDir,filename)
    if type(fullVidPath) == list:
        continue
    
    vidOutDir = str('/'.join(fullVidPath.split('/')[:-2]) + '/bsoidVids/')
    pngOutDir = vidOutDir + str(filename) + "_10fpsPNG/"
    
    command0a = "rm -r " + vidOutDir
    command0b = "rm -r " + pngOutDir
    command1a = "mkdir " + vidOutDir
    command1b = "mkdir " + pngOutDir
    command2 = "ffmpeg -hide_banner -loglevel panic -i " + str(fullVidPath) + " -filter:v fps=fps=10 " + vidOutDir + str(filename) + "_10fpsvideo.mp4"
    command3 = "ffmpeg -hide_banner -loglevel panic -i " + vidOutDir + str(filename)+ "_10fpsPNG/img%01d.png"
    
    print(fullVidPath)
    os.system(command0a)
    
    os.system(command0b)
    print('making directory')
    os.system(command1a)
    os.system(command1b)
    print('making new vid')
    os.system(command2)
    print('making png')
    os.system(command3)
#    
#    vidChop(vidDir,filename,startFrame,endFrame,fps)
    
    
        
        
    
