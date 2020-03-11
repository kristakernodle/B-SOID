
function filtData = bsoid_customSetup(csvPath,saveMatFile,date,view)
%BSOID_CUSTOMSETUP    setup DLC output files for use with bsoid
%
%   INPUTS:
%   CSVPATH    String of directory pathway with DLC .csv output files to 
%              be used with bsoid
%   SAVEMATFILE    Logical (true/false) for saving filtData as .mat file in
%                  csvPath folder
%
%   OUTPUTS:
%   FILTDATA    Data cell containing 3 rows (full path to specific csv 
%               file, filtered dlc data from csv file, percent rectified 
%               for each body part (see dlc_proprocess.m)). Each column 
%               is a different csv file. Saves into .mat file
%
%   Examples:
%   clear allRawData;
%   allRawData = bsoid_customSetup('/path/to/csv/files/');
%
%   Created by: Krista Kernodle, Date: 01302020
%   Contact kkrista@umich.edu
    
    if nargin < 2
        saveMatFile = true;
    end
    
    if ~strcmp(csvPath(end),'/')
        csvPath = [csvPath '/'];
    end
    
    if ~exist(csvPath,'dir')
        print('Error: Directory does not exist \n')
        print(csvPath)
    end
    
    % Get a list of all .csv files in the directory
    allFiles = dir([csvPath '*.csv']);

    for ii = 1:length(allFiles)
        
        % Skip .csv files that are not of the view we are interested in
        if ~contains(allFiles(ii).name,view)
            continue
        end
        
        % Get full path of file
        filenamecsv = sprintf('%s/%s',allFiles(ii).folder,allFiles(ii).name);

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
        
        filtData{1,ii} = filenamecsv; %#ok<*AGROW>
        [filtData{2,ii},filtData{3,ii}] = dlc_preprocess(rawData,0.2);
        
    end
    
    if saveMatFile
        save([csvPath 'filtData-' date '.mat'],'filtData');
    end

end
