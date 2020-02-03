function [analyzedData] = bsoid_dataAnalysis_LevLabWkFlw(csvPath,fps,varargin)
%BSOID_DATAANALYSIS_LEVLABWKFLW  Create new/load old bsoid model and analyze all data in a directory
%
%   INPUTS:
%   CSVPATH    String of directory pathway with DLC .csv output files to 
%              be used with bsoid
%              csvPath = '/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/';
%              csvPath = 'X:\Neuro-Leventhal\analysis\mouseSkilledReaching\DLCProcessing\B-SOiD\testingData_Center/';
%   FPS   Frames per second (recording speed)
%
%   OPTIONAL INPUTS:
%   FILTERDLCOUTPUT    Logical. If true, filters all data in csvPath and saves it as a .mat file in csvPath folder. If false, loads most recently created filtData-date.mat
%   CREATEMODEL    Logical. If true, creates new model and saves in csvPath as .mat file. If false, loads most recent model in csvPath.
%   
%   OUTPUTS:
%   ANALYZEDDATA
%
%   Examples:
%   csvPath = '/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/';
%   fps = 100;
%   [analyzedData] = bsoid_LevLab_workflow(csvPath,fps,true,true);
%
%   Created by: Krista Kernodle, Date: 01302020
%   Contact kkrista@umich.edu
    
%% Parse Inputs
    p = inputParser;
    validScalarPosNum = @(x) isnumeric(x) && (x>0);
    addRequired(p,'csvPath',@ischar);
    addRequired(p,'fps',validScalarPosNum);
    addOptional(p,'filterDLCOutput',true);
    addOptional(p,'createModel',true);
    parse(p,csvPath,fps,varargin{:});
    
    csvPath = p.Results.csvPath;
    fps = p.Results.fps;
    filterDLCOutput = p.Results.filterDLCOutput;
    createModel = p.Results.createModel;
    
    % Update csvPath formatting
    if ~strcmp(csvPath(end),'/')
        csvPath = [csvPath '/'];
    end
    
    % Check csvPath to make sure it exists
    if ~exist(csvPath,'dir')
        disp('Error: Directory does not exist \n')
        disp([csvPath,'\n'])
    end
    
    d=char(datetime('now','Format','yyyy-MM-dd''-T-''HH-mm-ss'));
    
    %% Load Data
    if filterDLCOutput
        % Filter Data
        filtData = bsoid_customSetup(csvPath,filterDLCOutput,d);
    else
        % Load existing .mat file
        allFiltMats = dir([csvPath 'filtData*.mat']);
        if isempty(allFiltMats)
            disp('Error: Filtered data does not exist. Please check the directory and try again\n');
        else
            [A,I] = max([allFiltMats(:).datenum]);
            load([allFiltMats(I).folder '/' allFiltMats(I).name]);
        end
    end
    
    %% Load Model
    if createModel
        % Create unsupervised grouping
        data = cell(1,length(filtData));
        for ii = 1:length(filtData)
            data{1,ii} = filtData{2,ii};
        end
        [f_10fps,tsne_feats,grp,llh,bsoid_fig] = bsoid_gmm(data,fps,1);
        fig1 = gcf;
        savefig(fig1,[csvPath 'bsoid_groupingFig-' d '.fig']);

        % Build model for future testing
        hldout=0.2;
        cv_it=20;
        btchsz = floor(length(grp)*0.2/cv_it);
        [OF_mdl,CV_amean,CV_asem,acc_fig] = bsoid_mdl(f_10fps,grp,hldout,cv_it,btchsz);
        fig2 = gcf;
        savefig(fig2,[csvPath 'bsoid_accuracyFig-' d '.fig']);

        % Save model for future use
        save([csvPath 'BSOID_model-' d '.mat'],'csvPath','fps','filtData','f_10fps','tsne_feats','grp','llh','OF_mdl','CV_amean','CV_asem')
    else
        allModels = dir([csvPath,'BSOID_model_*.mat']);
        if isempty(allModels)
            disp('Error: Model does not exist. Please check the directory and try again\n');
        else
            [~,I] = max([allModels(:).datenum]);
            load([allModels(I).folder '/' allModels(I).name],'OF_mdl');
        end
    end
    
    %% Analyze Data
    analyzedData = cell(5,length(filtData));
    for ii = 1:length(filtData)
        [labels,f_10fps_test] = bsoid_svm({filtData{2,ii}},fps,OF_mdl);
        analyzedData{1,ii} = filtData{1,ii};
        analyzedData{2,ii} = filtData{2,ii};
        analyzedData{3,ii} = filtData{3,ii};
        analyzedData{4,ii} = labels;
        analyzedData{5,ii} = f_10fps_test;
    end
    
    save([csvPath 'analyzedData-' d '.mat'],'analyzedData');
    
end