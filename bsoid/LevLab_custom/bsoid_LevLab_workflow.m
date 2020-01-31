function [filtData,OF_mdl] = bsoid_LevLab_workflow(csvPath,fps,varargin)
%BSOID_CUSTOMSETUP    setup DLC output files for use with bsoid
%
%   INPUTS:
%   CSVPATH    String of directory pathway with DLC .csv output files to 
%              be used with bsoid
%              csvPath = '/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/';
%              csvPath = 'X:\Neuro-Leventhal\analysis\mouseSkilledReaching\DLCProcessing\B-SOiD\testingData_Center/';
%   filterDLCOutput    Logical (true/false) for saving filtData as .mat file in
%                  csvPath folder
%
%   OUTPUTS:
%   ?
%
%   Examples:
%   ?
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
    
    %% Load Data
    if filterDLCOutput
        % Filter Data
        filtData = bsoid_customSetup(csvPath,filterDLCOutput);
    else
        % Load existing .mat file
        filtData = load([csvPath 'allRawData_*.mat']);
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
        savefig(fig1,[csvPath 'bsoid_groupingFig.fig']);

        % Build model for future testing
        hldout=0.2;
        cv_it=20;
        btchsz = floor(length(grp)*0.2/cv_it);
        [OF_mdl,CV_amean,CV_asem,acc_fig] = bsoid_mdl(f_10fps,grp,hldout,cv_it,btchsz);
        fig2 = gcf;
        savefig(fig2,[csvPath 'bsoid_accuracyFig.fig']);

        % Save model for future use
        save([csvPath 'BSOID_model_' date '.mat'],'csvPath','fps','filtData','f_10fps','tsne_feats','grp','llh','OF_mdl','CV_amean','CV_asem')
    else
        allModels = dir([csvPath,'BSOID_model_*.mat']);
        if isempty(allModels)
            disp('Error: Model does not exist. Please check the directory and try again\n');
            disp('You can create a new model by setting "createModel=true"\n');
        else
            [A,I]=max([allModels(:).datenum]);
        end
    end
    
    %% Analyze Data
    
end