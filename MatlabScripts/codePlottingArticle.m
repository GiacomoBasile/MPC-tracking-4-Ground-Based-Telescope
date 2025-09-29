if ~exist('SimOut')
    load([pwd, '\AstroRefence\AstroRefence_Scenario_89_TNG.mat'])
    load([pwd, '\SimulationResults\SimulationResults_LQG_PP_AC_89TNG.mat'])
end
Deg2Arcs = 3600;
Arcs2Deg = 1/Deg2Arcs;

Scenario_name = split(Scenario_name,'.');
Scenario_name = Scenario_name{1};

figPath = ['./Results/FigureResults/', Scenario_name,'/'];
path_eps = [figPath,'eps/'];
path_fig = [figPath,'fig/'];

mkdir(path_eps)
mkdir(path_fig)

%% Definition of Plotting Variable %%
% Azimuth 
AstroReferenceAzimuthPos = Arcs2Deg*SimOut.AstroReference.AzimuthPosition;
% Aggiustare l'output dei reference %%
ReferenceAzimuthPos = SimOut.ReferenceProcessedPositionAz;
AzimuthPos = Arcs2Deg*SimOut.PositionAz.PosAzDeg;

ReferenceAzimuthSpeed = SimOut.ReferenceProcessedSpeedAz;
AzimuthSpeed = Arcs2Deg*SimOut.SpeedAZ.SpeedAzDeg;

% Altitude 
AstroReferenceElevationPos = Arcs2Deg*SimOut.AstroReference.ElevationPosition;
% Aggiustare l'output dei reference %%
ReferenceElevationPos = SimOut.ReferenceProcessedPositionEl;
ElevationPos = Arcs2Deg*SimOut.PositionEl.PosElDeg;

ReferenceElevationSpeed = SimOut.ReferenceProcessedSpeedEl;
ElevationSpeed = Arcs2Deg*SimOut.SpeedEl.SpeedElDeg;

%% %%%%%%%%%%%%%% Azimuth Plotting %%%%%%%%%%%%%% %%
%% Azimuth Position %%
close all
clc

figp = figure();
plot(AstroReferenceAzimuthPos, 'LineWidth', 1.5); hold on
plot(ReferenceAzimuthPos,'LineWidth', 1.5)
plot(AzimuthPos,'LineWidth',1.5);
title('')
grid on
box on

x = xlabel('$t\,[s]$');
x.Interpreter = 'latex';
x.FontSize = 14;
x.FontWeight = 'bold';
y=ylabel('$\vartheta(t)\,[deg]$');
y.Interpreter="latex";
y.FontSize=14;
y.FontWeight="bold";
l = legend('$\vartheta^\star(t)$','$\bar{\vartheta}(t)$','$\vartheta(t)$');
l.Interpreter="latex";
l.FontSize=14;
l.FontWeight="bold";
l.Location="northeast";

b = axes('Position', [0.55,0.20,0.32,0.165],'box','on');
plot(AstroReferenceAzimuthPos, 'LineWidth', 1.5); hold on
plot(ReferenceAzimuthPos,'LineWidth', 1.5)
plot(AzimuthPos,'LineWidth',1.5);
grid on
box on
title('');
xlim([477.4136,477.4139])
ylim([3.19866*10^5, 3.1986605*10^5])
x = xlabel('');
y=ylabel('');

savefig(figp,[path_fig,'PositionAz.fig'])
saveas(figp, [path_eps,'PositionAz.eps'],"epsc")

%% Azimuth Speed %%
close all
clc

figp = figure();
plot(ReferenceAzimuthSpeed,'LineWidth', 1.5);hold on
plot(AzimuthSpeed,'LineWidth',1.5);
box on 
grid on 
title('')
x = xlabel('$t\,[s]$');
x.Interpreter = 'latex';
x.FontSize = 14;
x.FontWeight = 'bold';
y=ylabel('$\dot{\varphi}(t)\,[deg/s]$');
y.Interpreter="latex";
y.FontSize=14;
y.FontWeight="bold";
l = legend('$\dot{\bar{\varphi}}(t)$','$\dot{\varphi}(t)$');
l.Interpreter="latex";
l.FontSize=14;
l.FontWeight="bold";
l.Location="southwest";

a = axes('Position', [0.55,0.55,0.32,0.32],'box','on');
plot(SimOut.SpeedAZ.RefSpeedAzDeg*3600,'LineWidth', 1.5);hold on
plot(SimOut.SpeedAZ.SpeedAzDeg*3600,'LineWidth',1.5);
hold on
grid on
box on
title('');
xlim([440,445])
% ylim([257.526,257.528].*3600)
x = xlabel('');
y=ylabel('');


savefig(figp,[path_fig,'SpeedAz.fig'])
saveas(figp, [path_eps,'SpeedAz.eps'],"epsc")


%% %%%%%%%%%%%%%% Elevation Plotting %%%%%%%%%%%%%% %%
%% Elevation Position %%
close all
clc

figp = figure();
plot(AstroReferenceElevationPos, 'LineWidth', 1.5); hold on
plot(ReferenceElevationPos,'LineWidth', 1.5)
plot(ElevationPos,'LineWidth',1.5);
title('')
grid on
box on

x = xlabel('$t\,[s]$');
x.Interpreter = 'latex';
x.FontSize = 14;
x.FontWeight = 'bold';
y=ylabel('$\vartheta(t)\,[arcsec]$');
y.Interpreter="latex";
y.FontSize=14;
y.FontWeight="bold";
l = legend('$\vartheta^\star(t)$','$\bar{\vartheta}(t)$','$\vartheta(t)$');
l.Interpreter="latex";
l.FontSize=14;
l.FontWeight="bold";
l.Location="northeast";

b = axes('Position', [0.55,0.20,0.32,0.165],'box','on');
plot(AstroReferenceElevationPos, 'LineWidth', 1.5); hold on
plot(ReferenceElevationPos,'LineWidth', 1.5)
plot(ElevationPos,'LineWidth',1.5);
grid on
box on

title('');
xlim([477.4136,477.4139])
ylim([3.19866*10^5, 3.1986605*10^5])
x = xlabel('');
y=ylabel('');


savefig(figp,[path_fig,'PositionEl.fig'])
saveas(figp, [path_eps,'PositionEl.eps'],"epsc")

%% Elevation Speed %%
close all
clc

figp = figure();
plot(ReferenceElevationSpeed,'LineWidth', 1.5);hold on
plot(ElevationSpeed,'LineWidth',1.5);
grid on
box on
title('')
x = xlabel('$t\,[s]$');
x.Interpreter = 'latex';
x.FontSize = 14;
x.FontWeight = 'bold';
y=ylabel('$\dot{\vartheta}(t)\,[deg/s]$');
y.Interpreter="latex";
y.FontSize=14;
y.FontWeight="bold";
l = legend('$\dot{\bar{\vartheta}}(t)$','$\dot{\vartheta}(t)$');
l.Interpreter="latex";
l.FontSize=14;
l.FontWeight="bold";
l.Location="southeast";

a = axes('Position', [0.55,0.55,0.32,0.32],'box','on');
grid on;
plot(SimOut.SpeedEl.RefSpeedElDeg*3600,'LineWidth', 1.5);hold on
plot(SimOut.SpeedEl.SpeedElDeg*3600,'LineWidth',1.5);
grid on
box on
title('');
xlim([440, 445])
x = xlabel('');
y=ylabel('');

savefig(figp,[path_fig,'SpeedEl.fig'])
saveas(figp, [path_eps,'SpeedEl.eps'],"epsc")


%% %%%%%%%%% Torques Plotting %%%%%%%%%  %%
%% Torques %%
close all
clc

figp = figure();
plot(SimOut.TorqueEl/(-1000),'LineWidth', 1.5);hold on
plot(SimOut.TorqueAz/(1000),'LineWidth', 1.5);
grid on
box on
title('')
x = xlabel('$t\,[s]$');
x.Interpreter = 'latex';
x.FontSize = 14;
x.FontWeight = 'bold';
y=ylabel('$u(t)\,[Nm]$');
y.Interpreter="latex";
y.FontSize=14;
y.FontWeight="bold";
l = legend('$\tau_e(t)$','$\tau_a(t)$');
l.Interpreter="latex";
l.FontSize=14;
l.FontWeight="bold";
l.Location="southeast";


savefig(figp,[path_fig,'Torques.fig'])
saveas(figp, [path_eps,'Torques.eps'],"epsc")


%% %%%%%%%%% Errors Plotting %%%%%%%%%  %%
errorElposition = ReferenceElevationPos - ElevationPos;
errorAzposition = ReferenceAzimuthPos - AzimuthPos;

errorElspeed = ReferenceElevationSpeed - ElevationSpeed;
errorAzspeed = ReferenceAzimuthSpeed - AzimuthSpeed;


%% Position errors %%
close all
clc

figp = figure();
plot(errorElposition,'LineWidth', 1.5);hold on
plot(errorAzposition,'LineWidth', 1.5);hold off
grid on
box on
title('')
x = xlabel('$t\,[s]$');
x.Interpreter = 'latex';
x.FontSize = 14;
x.FontWeight = 'bold';
y=ylabel('$\bar{y}_p(t)-y_p(t)\,[deg]$');
y.Interpreter="latex";
y.FontSize=14;
y.FontWeight="bold";
l = legend('$\bar{\vartheta}(t)-\vartheta(t)$','$\bar{\varphi}(t)-\varphi(t)$');
l.Interpreter="latex";
l.FontSize=14;
l.FontWeight="bold";
l.Location="northeast";

a = axes('Position', [0.55,0.18,0.32,0.30],'box','on');
plot(errorElposition,'LineWidth', 1.5);hold on
plot(errorAzposition,'LineWidth', 1.5);hold off
grid on;
box on
title('');
xlim([450, 455])
x = xlabel('');
y=ylabel('');

savefig(figp,[path_fig,'PositionErrors.fig'])
saveas(figp, [path_eps,'PositionErrors.eps'],"epsc")

%% Speed errors %%
close all
clc

figp = figure();
plot(errorElspeed,'LineWidth', 1.5);hold on
plot(errorAzspeed,'LineWidth', 1.5);hold off
grid on
box on
title('')
x = xlabel('$t\,[s]$');
x.Interpreter = 'latex';
x.FontSize = 14;
x.FontWeight = 'bold';
y=ylabel('$\bar{\dot{y}}(t)-\dot{y}(t)\,[deg/s]$');
y.Interpreter="latex";
y.FontSize=14;
y.FontWeight="bold";
l = legend('$\dot{\bar{\vartheta}}(t)-\dot{\vartheta}(t)$','$\dot{\bar{\varphi}}(t)-\dot{\varphi}(t)$');
l.Interpreter="latex";
l.FontSize=14;
l.FontWeight="bold";
l.Location="southwest";

a = axes('Position', [0.55,0.18,0.32,0.30],'box','on');
plot(errorElspeed,'LineWidth', 1.5);hold on
plot(errorAzspeed,'LineWidth', 1.5);hold off
grid on
box on
title('');
xlim([450, 455])
x = xlabel('');
y=ylabel('');

savefig(figp,[path_fig,'SpeedErrors.fig'])
saveas(figp, [path_eps,'SpeedErrors.eps'],"epsc")

if prod(Configuration.CtrModes == 'MPC')
%% %%%%%%%%% Errors Estimation Plotting %%%%%%%%%  %%
% Only if MPC %
%% Estimation errors %%
% close all
% clc
% 
% figp = figure();
% plot(SimOut.EstimationErrorAz.Time,SimOut.EstimationErrorAz.Data(:,2:end-1),'LineWidth', 1.5);hold on
% plot(SimOut.EstimationErrorEl.Time,SimOut.EstimationErrorEl.Data(:,1:end-1),'LineWidth', 1.5);hold on
% grid on
% box on
% title('')
% x = xlabel('$t\,[s]$');
% x.Interpreter = 'latex';
% x.FontSize = 14;
% x.FontWeight = 'bold';
% y=ylabel('$x(t)-\hat{x}(t)$');
% y.Interpreter="latex";
% y.FontSize=14;
% y.FontWeight="bold";
% % l = legend('$s_1(t)-\int\vartheta(t)\,dt$','$s_2(t)-\int\varphi(t)\,dt$');
% % l.Interpreter="latex";
% % l.FontSize=14;
% % l.FontWeight="bold";
% % l.Location="southwest";
% 
% % a = axes('Position', [0.55,0.18,0.32,0.30],'box','on');
% % plot(SimOut.SpeedEl.RefSpeedElDeg*3600-SimOut.SpeedEl.SpeedElDeg*3600,'LineWidth', 1.5);hold on
% % plot(SimOut.SpeedAZ.RefSpeedAzDeg*3600-SimOut.SpeedAZ.SpeedAzDeg*3600,'LineWidth', 1.5);hold on
% % grid on
% % box on
% % title('');
% % xlim([450, 455])
% % % ylim([3.19866*10^5, 3.1986605*10^5])
% % x = xlabel('');
% % % x = xlabel('$t\,[s]$');
% % % x.Interpreter = 'latex';
% % % x.FontSize = 14;
% % % x.FontWeight = 'bold';
% % y=ylabel('');
% % % y=ylabel('$[arcsec]$');
% % % y.Interpreter="latex";
% % % y.FontSize=14;
% % % y.FontWeight="bold";
% 
% savefig(figp,[path_fig,'EstimationErrors.fig'])
% saveas(figp, [path_eps,'EstimationErrors.eps'],"epsc")
end