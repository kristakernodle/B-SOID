
function allRawData = bsoid_customSetup(fullPath)
    
    % Directory where all .csv files for unsupervised learning are located
    % fullPath = '/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/trainingData_Center/';

    % Get a list of all .csv files in the directory
    allFiles = dir([fullPath '*.csv']);

    for i = 1:length(allFiles)
        % Get full path of file
        filenamecsv = sprintf('%s/%s',allFiles(i).folder,allFiles(i).name);

        % Load file
        data_struct = importdata(filenamecsv);

        % Remove headings and such, just have the data
        rawdata = data_struct.data;

        % Re-arrange columns to be the following: nose (x,y), left paw (x,y), right paw (x,y), hindpaw 1 (0,0), hindpaw 2 (0,0), base of tail (0,0)
        leftPaw = rawdata(:,2:4);
        rightPaw = rawdata(:,5:7);
        nose = rawdata(:,8:10);
        missingBP = zeros(length(leftPaw),3);

        rawData = [rawdata(:,1), nose, leftPaw, rightPaw, missingBP, missingBP, missingBP];

        [allRawData{i},~] = dlc_preprocess(rawData,0.2);
        
    end

    save([fullPath 'allRawData.mat'],'allRawData');

end
