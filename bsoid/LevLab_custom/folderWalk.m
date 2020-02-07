og_dir = '/Volumes/SharedX/Neuro-Leventhal/data/mouseSkilledReaching';
allAnimalDir = dir(og_dir);

for index = 1:length(allAnimalDir)
   if contains(allAnimalDir(index).name,'et') && allAnimalDir(index).isdir
       trainingDirPath = strcat(og_dir,'/', allAnimalDir(index).name,'/Training');
       if exist(string(trainingDirPath),'dir')
           disp(trainingDirPath)
           break
       end
   end
end