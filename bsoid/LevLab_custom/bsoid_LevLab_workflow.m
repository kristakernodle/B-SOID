function bsoid_LevLab_workflow(csvPath,fps,makeNewModel,saveMatFile)
%BSOID_CUSTOMSETUP    setup DLC output files for use with bsoid
%
%   INPUTS:
%   CSVPATH    String of directory pathway with DLC .csv output files to 
%              be used with bsoid
%   SAVEMATFILE    Logical (true/false) for saving filtData as .mat file in
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

    if isempty(csvPath)
        csvPath = '/Volumes/SharedX/Neuro-Leventhal/analysis/mouseSkilledReaching/DLCProcessing/B-SOiD/testingData_Center/';
        % csvPath = 'X:\Neuro-Leventhal\analysis\mouseSkilledReaching\DLCProcessing\B-SOiD\testingData_Center/';
    end

    if ~strcmp(csvPath(end),'/')
        csvPath = [csvPath '/'];
    end
    
    if ~exist(csvPath,'dir')
        print('Error: Directory does not exist \n')
        print(csvPath)
    end
    
    %% Filter Data
    filtData = bsoid_customSetup(csvPath,saveMatFile);
    
    %% Create unsupervised grouping
    [f_10fps,tsne_feats,grp,llh,bsoid_fig] = bsoid_gmm(filtData,fps,1);
    savefig(bsoid_fig,[csvPath 'bsoid_groupingFig.fig']);
    
    %% Build model for future testing
    [OF_mdl,CV_amean,CV_asem,acc_fig] = bsoid_mdl(f_10fps,grp);
    savefig(acc_fig,[csvPath 'bsoid_accuracyFig.fig']);
    
    %% Save model for future use
    save([csvPath 'BSOID_model_' date '.mat'],'csvPath','fps','filtData','f_10fps','tsne_feats','grp','llh','OF_mdl','CV_amean','CV_asem')
    
end