clear all
close all
clc

References = dir("TrackingGeneratorReferences\");
References = {References.name};
References = References(~strncmp(References, '.', 1));

for i = 1:length(References)
    close all
    clc
    TrackingReference = load(['TrackingGeneratorReferences\', References{i}]);
    TrackingReference = getfield(TrackingReference,string(fieldnames(TrackingReference)));
    display([int2str(i),'-th Scenario is simulating: ',References{i}]) 
    TrackingReference1 = [TrackingReference(1,:).Data(1)*ones(1,5/0.001), TrackingReference(1,:).Data';
                          TrackingReference(2,:).Data(1)*ones(1,5/0.001), TrackingReference(2,:).Data';
                          TrackingReference(3,:).Data(1)*ones(1,5/0.001), TrackingReference(3,:).Data';
                          TrackingReference(4,:).Data(1)*ones(1,5/0.001), TrackingReference(4,:).Data'];
    % out_Az = MPC_Az(TrackingReference1);
    out_El = MPC_El(TrackingReference1);
    results.Elevation = out_El;
    results.Azimuth = out_Az;
    save(['Results\Results_of_TY_Star_',References{i},'.mat'],"results");
end
