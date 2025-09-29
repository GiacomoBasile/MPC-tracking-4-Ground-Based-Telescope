function [SimOut, Scenario_name] = SimulationPlatform(Configuration, ScenarioSim, model, mpcobj)
Deg2Arcs = 3600;
Arcs2Deg = 1/3600;

%% Set Flag for Simulation %%
SaveResults = Configuration.SaveResults;
Ref = Configuration.AstroComp;                    
Prepocessor.flag = Configuration.Prepocessor;            
SimulationTime = Configuration.SimulationTime;  
CtrMode = Configuration.CtrModes;            
NoiseFlag = Configuration.NoiseFlag;         
TNG = Configuration.TNG_ref;

if TNG == 1 
    Ref = 0;
    
    if ~isempty(ScenarioSim)
        Scenario = load(['./AstroRefence_from_TNG/',ScenarioSim,'.mat']);
        Scenario = Scenario.AstroReference;
    else
        Scenario = input("chose betwen|" + ...
                         "   1) Altitude 85,"+...
                         "   2) Altitude 89:  ");
        ScenarioSim = dir('./AstroRefence_from_TNG/');
        ScenarioSim = ScenarioSim(Scenario+2).name;
        ScenarioSim = split(ScenarioSim,'.');
        ScenarioSim = ScenarioSim{1};
        Scenario = load(['./AstroRefence_from_TNG/',ScenarioSim,'.mat']);
        Scenario = Scenario.AstroReference;
        
    end
    ScenarioConf = '_TNG';
else
    % Definition of the Astrometric Coordination (REF=0)%
    Scenario.RAhh = 14.5;
    Scenario.RAmm = 10;
    Scenario.RAss = 00.00;
    Scenario.DECdd = 50;
    Scenario.DECmm = 00; 
    Scenario.DECss = 00.00;
    Time = clock;
    Scenario.Time = [2023 7 20 18 26 31.1360];
    % % Site geografic coordination (Lat/Long) of TNG % %    
    Scenario.LATsite = 40.8370;
    Scenario.LONsite = 14.2262;
    Scenario.VLT = 0;

    ScenarioConf = '_Astro';
end

NNFConf = 0*prod(NoiseFlag == 'None') + 1*prod(NoiseFlag == 'WNou') + 2*prod(NoiseFlag == 'VKin');
Configuration = [repmat('_PP', Prepocessor.flag == 1), ...                                   % with Prepocessor
                repmat('_TS', Ref==1), ...                                                   % Trivial Scenario
                repmat('_AC', Ref==0), ...                                                   % Astrometry Computation
                repmat('_CR', Ref==3), ...                                                   % Constant Reference
                repmat('_WNou', NNFConf==1), ...                                             % White Noise in Output
                repmat('_VKin', NNFConf==2)];                                                % Von Karman Noise in Input

%% Model and Controllers load %%
% Preprocessor Parameters in [Deg]-[Deg/s]-[Deg/s^2]%
Prepocessor.Ts = .002;
Prepocessor.vmax = 0.7;
Prepocessor.amax = 5;
Prepocessor.p0az = 0;
Prepocessor.p0el = 90;
% Prepocess.vmax = 0.7;
% Prepocess.amax = 8;
% Prepocess.p0 = 0;

% Von Karman Model Paramters %
VonKarman.N =10000;
VonKarman.f = (0.01:(10-0.01)/VonKarman.N:10-((10-0.01)/VonKarman.N))';
VonKarman.phi = rand(VonKarman.N,1);
VonKarman.df = 0.01;
VonKarman.v_mean = 3;
VonKarman.V = VonKarman.v_mean;
VonKarman.I = 0.15;
VonKarman.L = 3.2;
VonKarman.A = 10;
VonKarman.tau = 100;
VonKarman.alpha = 0.35;

%% Identified Model Loading %%
sysAz = model.Az;
sysEl = model.El;

Tc = Prepocessor.Ts;

%% Simulation Model Configuration%%
SimulationPath = './Results/SimulationResults';
SimulinkModels = './SimulinkModelsVersions';

mdl = ['Telescope_model_',CtrMode];
CtrModeS = CtrMode;
CtrModeS = 1*prod(CtrModeS == 'PID') + 2*prod(CtrModeS == 'MPC');

if ~any(~strcmp(find_system('SearchDepth', 0), mdl)) 
    open(mdl)
end
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'ode4')

switch CtrModeS
    case 1
        % Speed gain %
        Kv = 450;
        
        % Elevation PID gains %
        Kp_el = 80;
        Ki_el = 120;
        Kd_el = 1;

        % Azimuth PID gains %
        Kp_az = 110;
        Ki_az = 150;
        Kd_az = 2;
        
        % workspace variable assignement %
        assignin('base', 'Kv', Kv);
        assignin('base', 'Kp_el', Kp_el);
        assignin('base', 'Ki_el', Ki_el);
        assignin('base', 'Kd_el', Kd_el);
        assignin('base', 'Kp_az', Kp_az);
        assignin('base', 'Ki_az', Ki_az);
        assignin('base', 'Kd_az', Kd_az);
        
    case 2
        A_az = model.Az.A;
        A_el = model.El.A;
        B_az = model.Az.B;
        B_el = model.El.B;
        C_az = model.Az.C;
        C_el = model.El.C;
        
        % integration speed %
        APaz = [0, C_az; zeros(size(A_az,1),1), A_az];
        BPaz = [0; B_az];
        CPaz = blkdiag(1,C_az);
        DPaz = zeros(2,1);
        
        APel = [0, C_el; zeros(size(A_el,1),1), A_el];
        BPel = [0; -B_el];
        CPel = blkdiag(1,C_el);
        DPel = zeros(2,1);
         
        At = blkdiag(APel, APaz);
        Bt = blkdiag(BPel, BPaz);
        Ct = blkdiag(CPel, CPaz);
        Dt = blkdiag(DPel, DPaz);

        x0_az = [0; zeros(size(A_az,1),1)];
        x0_el = [90*3600; zeros(size(A_el, 1),1)];

        % assign internal scope variable into the Matlab Workspace %
        assignin('base', 'x0_az', x0_az);
        assignin('base', 'APaz', APaz);
        assignin('base', 'BPaz', BPaz);
        assignin('base', 'CPaz', CPaz);
        assignin('base', 'DPaz', DPaz);
        assignin('base', 'x0_el', x0_el);
        assignin('base', 'APel', APel);
        assignin('base', 'BPel', BPel);
        assignin('base', 'CPel', CPel);
        assignin('base', 'DPel', DPel);
        assignin('base', 'At', At);
        assignin('base', 'Bt', Bt);
        assignin('base', 'Ct', Ct);
        assignin('base', 'Dt', Dt);
end
%% Assign internal scope variable into the Matlab Workspace %%
assignin('base', 'Ref', Ref);
assignin('base', 'Prepocessor', Prepocessor);
assignin('base', 'SimulationTime',  SimulationTime);
assignin('base', 'CtrMode', CtrMode );
assignin('base', 'NNFConf', NNFConf);
assignin('base', 'sysAz', sysAz);
assignin('base', 'sysEL', sysEl);
assignin('base', 'VonKarman', VonKarman);
assignin('base', 'Tc', Tc);
assignin('base', 'Scenario', Scenario)
assignin('base', 'TNG', TNG)
assignin('base', 'Deg2Arcs', Deg2Arcs)
assignin('base', 'Arcs2Deg', Arcs2Deg)


display(['Scenario ', ScenarioSim, ' is selected']);
display(['for simulation under the action of the ControlMode: ',CtrMode, ' controller.']);

SimOut = sim([SimulinkModels, '/', mdl,'.slx']);

if SaveResults
    save([SimulationPath, '/SimulationResults_',CtrMode,Configuration,ScenarioConf,'.mat'],"SimOut")
end
Scenario_name = ['Scenario_',CtrMode,Configuration,ScenarioConf,'.mat'];
end
% C:\Users\giaco\Documents\MATLAB\Examples\R2023b\ident\EstimateNonlinearGreyBoxModelExample