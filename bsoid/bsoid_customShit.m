
allData = {cell(1,length(allRawData)); cell(1,length(allRawData),7)};
for ii = 1:length(allRawData)
    currRawData{1}=allRawData{2,ii};
    [labels,f_10fps_test] = bsoid_svm(currRawData,fps,OF_mdl);
    allData{1,ii} = labels{1};
    allData{2,ii} = f_10fps_test{1};
end

%
goodVidInd=[];
for ii = 1:length(allRawData)
    perc_rect=allRawData{3,ii};
    if any(perc_rect<0.15)
        goodVidInd(end+1)=ii;
    end
end


