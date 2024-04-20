function out = MPC_Az(Reference)
yalmip('clear')

Count2Nm = (15/3276700)*(75/1);
%% MPC speed Controller %%
sysS = load("AzimuthSys.mat");
sysSpeed = getfield(sysS, string(fieldnames(sysS)));

A = [                          0,  sysSpeed.C; 
     zeros(length(sysSpeed.A),1),  sysSpeed.A];

B = -[0; sysSpeed.B];

C = [1, zeros(1,length(sysSpeed.A));
     0, sysSpeed.C];
D = 0;

% VonKarman Model %
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

sys = ss(A,B,C,D);

%% Configuration Initial Guess/Condition  %%
dt = 0.001;
T = 5.5*60;

N = 500;
nx = length(sys.A);
nu = 1;
ny = 2;

Q = [2000, 0; 0, 15];
R = .001;

u = sdpvar(repmat(nu,1,N),repmat(1,1,N));
x = sdpvar(repmat(nx,1,N+1),repmat(1,1,N+1));
r = sdpvar(repmat(ny,1,N+1),repmat(1,1,N+1));
d = sdpvar(1);
pastu = sdpvar(1);
 
constraints = [];
%% Objective Function Definition %%
objective = 0;
for k = 1:N
    objective = objective + (sys.C*x{k}-r{k})'*Q*(sys.C*x{k}-r{k}) + u{k}'*R*u{k};
end
objective = objective + (sys.C*x{N+1}-r{N+1})'*(sys.C*x{N+1}-r{N+1});           % Terminal Cost

%% System Constrains %
dynamics = @(x,u,d)[sys.A(1,:)*x-sys.B(1,:)*(u+d);
                    sys.A(2,:)*x-sys.B(2,:)*(u+d);
                    sys.A(3,:)*x-sys.B(3,:)*(u+d);
                    sys.A(4,:)*x-sys.B(4,:)*(u+d);
                    sys.A(5,:)*x-sys.B(5,:)*(u+d);
                    sys.A(6,:)*x-sys.B(6,:)*(u+d);
                    sys.A(7,:)*x-sys.B(7,:)*(u+d);];
for k=1:N  
   % Runge-Kutta 4 integration
   k1 = dynamics(x{k},         u{k}, d);
   k2 = dynamics(x{k}+dt/2*k1, u{k}, d);
   k3 = dynamics(x{k}+dt/2*k2, u{k}, d);
   k4 = dynamics(x{k}+dt*k3,   u{k}, d);
   x_next = x{k} + dt/6*(k1+2*k2+2*k3+k4);

   constraints = [constraints, x{k+1} == x_next];%;+E*d];     
end

%% Control implementation %%
parameters_in = {x{1}, [r{:}], d, pastu};
solutions_out = {[u{:}], [x{:}]};
 
controller = optimizer(constraints, objective,sdpsettings('solver','mosek'),parameters_in,solutions_out);
x0 = [360; zeros(length(sys.A)-1,1)];
clf;

%% Reference %%
Reference_Position = Reference(1,:)/3600;
Reference_Speed = Reference(2,:)/3600;

%% Initial guess %%
disturbance = randn(1)*.01;
oldu = 0;
hold on
xh = [x0];
yh = [sys.C*x0];
uh = [];
eh = [];

%% MPC Loop %% 
j = 0;
close all
t0 = 0;
T = 305;
for i = t0:dt:T
    j = j+1;
    future_r = [Reference_Position(j).*ones(1,N+1); Reference_Speed(j).*ones(1,N+1)];
    inputs = {xh(:,end), future_r, disturbance ,oldu};
    
    [solutions,diagnostics] = controller{inputs};    
    U = solutions{1};
    oldu = U(1);
    uh = [uh, oldu*Count2Nm];

    X = solutions{2};
    if diagnostics == 1
        error('The problem is infeasible');
    end
     %% Plotting real-time %%
    % Plotting Input 
    figure(2)
    title("Azimuth axes")
    subplot(3,1,1);
    cla;stairs(i:dt:(i+dt*(N-1)), U*Count2Nm,'b'); hold on
    stairs(t0:dt:i,uh,'r')
    

    %Plotting Position % 
    subplot(3,1,2);  
    cla;stairs(i:dt:(i+dt*N), sys.C(1,:)*X,'b');hold on; plot(i:dt:(i+dt*N), future_r(1,:),'k'); hold on
    stairs(t0:dt:i, yh(1,:),'g'); 
    stairs(t0:dt:i, Reference_Position(1:j),'r');
    if yh(1,end) > Reference_Position(j)
        YLIMP = [Reference_Position(j)-1, yh(1,end)+1];
    else
        YLIMP = [yh(1,end)-1, Reference_Position(j)+1];
    end    
    ylim(YLIMP)

    % Plotting Speed %
    subplot(3,1,3);
    cla;stairs(i:dt:(i+dt*N), sys.C(2,:)*X,'b');hold on;stairs(i:dt:(i+dt*N), future_r(2,:),'k');hold on
    stairs(t0:dt:i, yh(2,:),'g')
    stairs(t0:dt:i, Reference_Speed(1:j),'r');
    if yh(2,end) > Reference_Speed(j)
        YLIMS = [Reference_Speed(j)-5, yh(2,end)+5];
    else
        YLIMS = [yh(2,end)-5, Reference_Speed(j)+5];
    end
    ylim(YLIMS)
    
    %% Model Simulation %%
    k1 = dynamics(xh(:,end),           U(1), disturbance);
    k2 = dynamics(xh(:,end)+dt/2*k1,   U(1), disturbance);
    k3 = dynamics(xh(:,end)+dt/2*k2,   U(1), disturbance);
    k4 = dynamics(xh(:,end)+dt*k3,     U(1), disturbance);
    xt = xh(:,end) + dt/6*(k1+2*k2+2*k3+k4);
    
    xh = [xh, xt];
    yh = [yh, sys.C*xt];
    disturbance = VonKarmanNoise(i, VonKarman);
end
out.y = yh;
out.u = uh;
out.referenceP = Reference_Position;
out.referenceS = Reference_Speed;
out.ErrorSquared = eh.*3600;
end