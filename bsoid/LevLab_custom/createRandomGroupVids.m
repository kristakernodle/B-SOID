load('/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/analyzedData-2020-02-05-T-12-58-23.mat')
load('/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/BSOID_model-2020-01-31-T-10-23-54.mat')

clear grp

n=15;
n_len=1;
X=50;
filepathOutResults='/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/bsoid_vids_byGroup';
og_dir = '/Volumes/SharedX/Neuro-Leventhal/data/mouseSkilledReaching';
allAnimalDir = dir(og_dir);

for index = 1:length(allAnimalDir)
   
    if contains(allAnimalDir(index).name,'et') && allAnimalDir(index).isdir
       trainingDirPath = strcat(og_dir,'/', allAnimalDir(index).name,'/Training');
       
       if exist(string(trainingDirPath),'dir')
           allTrainingDir = dir(trainingDirPath);
           
           for subindex = 1:length(allTrainingDir)
               
               if allTrainingDir(subindex).isdir && contains(allTrainingDir(subindex).name,'et')
                   subTrainingDirPath = [trainingDirPath '/' allTrainingDir(subindex).name];
                   subTrainingDir = dir(subTrainingDirPath);
                   
                   for sub_subindex = 1:length(subTrainingDir)
                       if contains(subTrainingDir(sub_subindex).name,'bsoid')
                           bsoidDirPath = [subTrainingDir(sub_subindex).folder '/bsoidVids/'];
                           bsoidDirCont = dir(bsoidDirPath);
                           
                           for png_index = 1:length(bsoidDirCont)
                              if bsoidDirCont(png_index).isdir && contains(bsoidDirCont(png_index).name,'PNG')
                                  PNGpath = [bsoidDirCont(png_index).folder '/' bsoidDirCont(png_index).name '/'];
                                  
                                  vidID = bsoidDirCont(png_index).name;
                                  vidID = vidID(1:end-9);
                                  
                                  for ii = 1:length(analyzedData)
                                      if contains(analyzedData{1,ii},vidID)
                                          grp = analyzedData{4,ii}{1};
                                          break
                                      end
                                  end
                                  
                                  [t,B,b_ex] = action_gif2(PNGpath,grp',n,n_len,X,filepathOutResults);
                                  
                              end
                           end
                       end
                   end
               end  
           end
       end
   end
end