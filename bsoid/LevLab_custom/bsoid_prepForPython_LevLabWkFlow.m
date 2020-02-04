function bsoid_prepForPython_LevLabWkFlow(csvPath,bsoid_outDir)
%BSOID_PREPFORPYTHON_LEVLABWKFLW  Save labeled 10fps data (bsoid output) into .csv files
%
%   INPUTS:
%   CSVPATH    String of directory pathway with DLC .csv output files to 
%              be used with bsoid
%              csvPath = '/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/';
%              csvPath = 'X:\Neuro-Leventhal\analysis\mouseSkilledReaching\DLCProcessing\B-SOiD\testingData_Center/';
%   BSOID_OUTDIR    String of directory pathway where .csv output files will be saved
%
%   Examples:
%   csvPath = '/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/';
%   bsoid_outDir = '/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/bsoid_labeledData_testingData_Center/';
%   bsoid_prepForPython_LevLabWkFlow(csvPath,bsoid_outDir);
%
%   Created by: Krista Kernodle, Date: 02032020
%   Contact kkrista@umich.edu

    %% Parse Inputs
    p = inputParser;
    addRequired(p,'csvPath',@ischar);
    addRequired(p,'bsoid_outDir',@ischar);
    parse(p,csvPath,bsoid_outDir);
    
    csvPath = p.Results.csvPath;
    bsoid_outDir = p.Results.bsoid_outDir;
    
    % Check directories
    if ~exist(csvPath,'dir')
        disp('Error: csvPath directory does not exist')
        disp(csvPath)
    end
    if ~exist(bsoid_outDir,'dir')
        disp('Error: bsoid_outDir directory does not exist \n')
        disp([bsoid_outDir,'\n'])
    end
    
    % Updated directory formatting
    if ~strcmp(csvPath(end),'/')
        csvPath = [csvPath '/'];
    end
    if ~strcmp(bsoid_outDir(end),'/')
        bsoid_outDir = [bsoid_outDir '/'];
    end
    
    %% Load most recently created analyzed data
    clear analyzedData;
    allAnalyzedData = dir([csvPath,'analyzedData-*.mat']);
    if isempty(allAnalyzedData)
        disp('Error: No analyzed data exists. Please check the directory and try again\n');
    else
        [~,I] = max([allAnalyzedData(:).datenum]);
        load([allAnalyzedData(I).folder '/' allAnalyzedData(I).name],'analyzedData');
    end
    
    %% Loop through each analyzedData entry and save 
    for ii = 1:length(analyzedData)
        split_filename = strsplit(analyzedData{1,ii},'/');
        filename = split_filename{2};
        vid = strsplit(filename,'D');
        vid = vid{1};
        csvwrite([bsoid_outDir vid '_10fpsLabels.csv'],analyzedData{4,ii}{1});
    end
    
end