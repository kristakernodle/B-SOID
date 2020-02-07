load('/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/analyzedData-2020-02-05-T-12-58-23.mat')
load('/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/BSOID_model-2020-01-31-T-10-23-54.mat')

og_dir = '/Volumes/SharedX/Neuro-Leventhal/data/mouseSkilledReaching';
allAnimalDir = dir(og_dir);

for index = 1:length(allAnimalDir)
   if contains(allAnimalDir(index).name,'et') && allAnimalDir(index).isdir
       trainingDirPath = strcat(og_dir,'/', allAnimalDir(index).name,'/Training');
       if exist(string(trainingDirPath),'dir')
           allTrainingDir = dir(trainingDirPath);
           for subindex = 1:length(allTrainingDir)
               if allTrainingDir(subindex).isdir && contains(allTrainingDir(subindex).name,'et')
                   subTrainingDir = dir([trainingDirPath '/' allTrainingDir(subindex).name]);
                   for sub_subindex = 1:length(subTrainingDir)
                       if contains(subTrainingDir(sub_subindex).name,'bsoid')
                           bsoidDirCont = dir([subTrainingDir(sub_subindex).folder '/bsoidVids/']);
                           for png_index = 1:length(bsoidDirCont)
                              if bsoidDirCont(png_index).isdir
                                  %% This gets you inside the bsoid dir
                              end
                           end
                       end
                   end
               end
                   
           end
       end
   end
end