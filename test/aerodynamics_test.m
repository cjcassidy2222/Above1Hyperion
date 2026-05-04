function [cruise_Cd,sup_LD,sub_LD,wing_loading] = aerodynamics_test()

%% Homework 5 - Aerodynamics - Preliminary Drag Estimates - Part 4 - CD0 Table and Drag Polar
% Computes CDmin, CD0, k1, k2 vs Mach and returns Lift and Drag given altitude and Mach
% For Aerodynamics teams
% Refined CD0 estimates

close all
clear;
clc;



%% --------------------------------------------------
% Aircraft Parameters - Concept
AR = 1.91;             % Aspect ratio
S_ref = 2713.5;            % Wing planform area [ft^2]
lambda_LE = 70*pi/180;     % Leading edge sweep [deg]
Length = 186;     % Fuselage length [ft]
radius = 9.67/2;     % radius of fuselage
Amax = pi*radius^2;       % Max fuselage cross-sectional area [ft^2]
Cf = 0.0025;       % Skin friction drag coefficient (from Brandt's work as well as Roskam, Air Vehicle Design, Volume 1, Table 3.5
E_wd = 1.8;         % Empircal Wave drag estimate, 1.8-2.2 from Raymer Pg. 435

% Additional parameters
h_ft = 58000;   % Altitude in feet
W = 206225; % Aircraft weight (lbf)

% Aircraft Parameters - CONCORDE (_C designation)
AR_C = 1.7;             % Aspect ratio
S_ref_C = 3856;            % Wing planform area [ft^2]
lambda_LE_C = 55*pi/180;     % Leading edge sweep [deg]
Length_C = 203.75;     % Fuselage length [ft]
radius_C = 10.25/2;     % radius of fuselage
Amax_C = pi*radius^2;       % Max fuselage cross-sectional area [ft^2]
E_wd_C = 2.2;         % Empircal Wave drag estimate, 1.8-2.2 from Raymer Pg. 435

% Additional parameters
h_ft_C = 60000;   % Altitude in feet
W_C = 408000; % Aircraft weight (lbf)

M_lower = 0.1;
M_upper = 3.0;
n = 100; % number of data points desired
mach_array = linspace(M_lower, M_upper, n);
mach_array = mach_array';
% Use these lines for when Perfromance needs the data
%mach_array = linspace(0.524147536,2,21)'; % same as excel for ease

alpha = linspace(-15, 15, 60);
alpha = alpha';
% Estimate since Concorde had Biconvex, special airfoil
alpha_L0_C = -1.65; % 2-D zero-lift AOA for airfoil at Mach 0.2 sea level conditions according to XFOIL (inviscid flow theory)
% For NACA 65-206, USE THIS (from XFOIL)
alpha_L0 = -1.601;


%% --------------------------------------------------
% Initializing some empty arrays
CD_mach = zeros(length(mach_array));
CD0_sub = zeros(length(mach_array));
CD0_sup = zeros(length(mach_array));
CD_sub = zeros(length(mach_array));
CD_sup = zeros(length(mach_array));
CD_wave = zeros(length(mach_array));
CD_min = zeros(length(mach_array));
CL_mach = zeros(length(mach_array));
k1_sup = zeros(length(mach_array));
q = zeros(length(mach_array));
V = zeros(length(mach_array));



%% --------------------------------------------------
% Derived Mach points
M_CD0_max = real(1 / (cos(lambda_LE)^0.2)); % Determines the Mach at CD0 max or something?
M_CD0_max_C = real(1 / (cos(lambda_LE_C)^0.2)); % Determines the Mach at CD0 max or something?
tc = 0.06;
M_crit = 1.0 - 0.065 * (cos(lambda_LE) * 100 * (tc))^0.6; % This determines the critical Mach number
M_crit_C = 1.0 - 0.065 * (cos(lambda_LE_C) * 100 * (tc))^0.6; % This determines the critical Mach number

% Estimate S_wet
c = -0.1289; % Coefficient for fighter aircraft, given for S_wetrest equation, provided by Roskam's Aircraft Design Volume 1 (1985), Table 3.5.
d = 0.7506; % Coefficient for fighter aicraft, given for S_wetrest equation, provided by Roskam's Aircraf Design Volume 1 (1985), Table 3.5.
S_wet = 5 * S_ref; % Wetted Area; % This should be 5 * S_ref for our concept
S_wet_C = (10^c) * (W_C^d); % Wetted Area

% Generate velocity array

% Get local speed of sound at desired alt
[~, a, P, rho] = atmosisa(h_ft*0.3048);
a = a/0.3048; % Convert m/s into ft/s
[~, a_C, P_C, rho_C] = atmosisa(h_ft_C*0.3048);
a_C = a_C/0.3048; % Convert m/s into ft/s

% Compute velocity for mach range
V = mach_array.*a; % ft/sec
V_C = mach_array.*a_C; % ft/sec

% Compute dynamic pressure
q = 0.5 .* rho .* V.^2; % lbf/ft^2
q_C = 0.5 .* rho_C .* V_C.^2; % lbf/ft^2

% Compute e_osw
e_osw = (4.6*(1 - 0.033 * AR^(0.53)) * (cos(lambda_LE))^(0.1) - 3.3); % Equation from Brandt's work, "Aero" sheet, around cell I12.
e_osw_C = (4.6*(1 - 0.033 * AR_C^(0.53)) * (cos(lambda_LE_C))^(0.1) - 3.3); % Equation from Brandt's work, "Aero" sheet, around cell I12.

% Get k1 subsonic
k1_sub = 1/(pi*e_osw*AR);
k1_sub_C = 1/(pi*e_osw_C*AR_C);

% Compute c_l_alpha
c_l_alpha = 0.1; % From Brandt's work, "Aero", ~cell E14)

% Compute e_notoswald
e_notoswald = (2)/(2 - AR + sqrt(4 + (AR^2) * (1 + tan(lambda_LE)^2) ) ); 
e_notoswald_C = (2)/(2 - AR_C + sqrt(4 + (AR_C^2) * (1 + tan(lambda_LE_C)^2) ) ); 

% Compute CL_alpha
CL_alpha = (c_l_alpha) / ( 1 + ( (57.3 * c_l_alpha) / (pi * e_notoswald * AR) ) );
CL_alpha_C = (c_l_alpha) / ( 1 + ( (57.3 * c_l_alpha) / (pi * e_notoswald_C * AR_C) ) );
cruise_Cd = 0.01;

% Get CL_minD
% CL_minD = 0.027156; % From Brandt, "Aero" sheet
% CL_minD = CL_alpha * ( sqrt(NACA/1000) /2);
CL_minD = CL_alpha * -1 * alpha_L0/2;
CL_minD_C = CL_alpha_C * -1 * alpha_L0_C/2;

% Compute k2 subsonic
k2_sub = -2 * k1_sub * CL_minD;
k2_sub_C = -2 * k1_sub_C * CL_minD_C;

% Compute CDmin
CD_min = Cf*S_wet/S_ref;
CD_min_C = Cf*S_wet_C/S_ref_C;

% Calculate CD0 for subsonic case
CD0_sub = CD_min + k1_sub.*CL_minD.^2;
CD0_sub_C = CD_min_C + k1_sub_C.*CL_minD_C.^2;

% Compute k1 supersonic
k1_sup = ( (AR.*(mach_array.^2 - 1)./(4*AR*sqrt(mach_array.^2 - 1) - 2) ) .* cos(lambda_LE) );
k1_sup(imag(k1_sup)~=0)=0;
k1_sup_C = ( (AR_C.*(mach_array.^2 - 1)./(4*AR_C*sqrt(mach_array.^2 - 1) - 2) ) .* cos(lambda_LE_C) );
k1_sup_C(imag(k1_sup_C)~=0)=0;

% Compute k2 supersonic
k2_sup = 0;
sup_LD = 8.7;
sub_LD = 12.3;


% Compute CD_wave
CD_wave = ( (4.5.*pi)./(S_ref) .* ((Amax - 0)/ Length)^2 .* E_wd .* (0.74 + 0.37 .* cos(lambda_LE)) .* (1 - 0.3 .* sqrt(mach_array - M_CD0_max)) );
CD_wave(imag(CD_wave)~=0.0)=0;
CD_wave_C = ( (4.5.*pi)./(S_ref_C) .* ((Amax_C - 0)/ Length_C)^2 .* E_wd_C .* (0.74 + 0.37 .* cos(lambda_LE_C)) .* (1 - 0.3 .* sqrt(mach_array - M_CD0_max_C)) );
CD_wave_C(imag(CD_wave_C)~=0.0)=0;

% Compute CD0 for supersonic case
CD0_sup = CD0_sub + CD_wave;
CD0_sup_C = CD0_sub_C + CD_wave_C;

% Compute CL
% Assume lift = weight
CL_mach = W ./ (q * S_ref); % Brandt uses this form in their work. Dimensionally, it's lbf/ft^2 / lfb/ft^2, which all cancels out nicely
CL_angle = CL_alpha.*alpha;
CL_mach_C = W_C ./ (q_C * S_ref_C); % Brandt uses this form in their work. Dimensionally, it's lbf/ft^2 / lfb/ft^2, which all cancels out nicely
CL_angle_C = CL_alpha_C.*alpha;

%% Compute CD for level case
% Subsonic
CD_sub = CD0_sub + k1_sub.*CL_mach.^2 + k2_sub.*CL_mach;
CD_sub_C = CD0_sub_C + k1_sub_C.*CL_mach_C.^2 + k2_sub_C.*CL_mach_C;


% Supersonic
CD_sup = CD0_sup + k1_sup.*CL_mach.^2 + k2_sup.*CL_mach;
CD_sup_C = CD0_sup_C + k1_sup_C.*CL_mach_C.^2 + k2_sup.*CL_mach_C;
cruise_Cd = CD_sup_C;

% Trim values that we don't need
CD_sub = CD_sub(mach_array<M_CD0_max); % Removes all values ABOVE MCD0_max because this isn SUBSONIC ONLY
CD_sub = CD_sub(CD_sub>0.0); % Removes all zero elements.
CD_sub_C = CD_sub_C(mach_array<M_CD0_max_C); % Removes all values ABOVE MCD0_max because this isn SUBSONIC ONLY
CD_sub_C = CD_sub_C(CD_sub_C>0.0); % Removes all zero elements.

% Trim imaginary numbers
CD_sup(imag(CD_sup)~=0.0)=0; % Sets all imaginary components to 0.
CD_sup = CD_sup(CD_sup>0.0); % Removes all zero elements.
CD_sup = CD_sup(mach_array>=M_CD0_max); % Remove all values below MCD0_max because this is SUPERSONIC ONLY
CD_sup_C(imag(CD_sup_C)~=0.0)=0; % Sets all imaginary components to 0.
CD_sup_C = CD_sup_C(CD_sup_C>0.0); % Removes all zero elements.
CD_sup_C = CD_sup_C(mach_array>=M_CD0_max_C); % Remove all values below MCD0_max because this is SUPERSONIC ONLY

CD_mach = [CD_sub; CD_sup]; % Assemble CD array
CD_mach_C = [CD_sub_C; CD_sup_C]; % Assemble CD array

% Compute CL/CD
CL_CD_mach = CL_mach./CD_mach;
CL_CD_mach_C = CL_mach_C./CD_mach_C;


%% Compute CD for various alpha ranges
% Subsonic
CD_angle = CD0_sub + k1_sub.*CL_angle.^2 + k2_sub.*CL_angle;
CD_angle_C = CD0_sub_C + k1_sub_C.*CL_angle_C.^2 + k2_sub_C.*CL_angle_C;

% Supersonic
% CD_sup = CD0_sub + k1_sup.*CL_alpha.^2 + k2_sup.*CL_alpha;

% Trim values that we don't need
% CD_sub = CD_sub(mach_array<M_CD0_max); % Removes all values ABOVE MCD0_max because this isn SUBSONIC ONLY
% CD_sub = CD_sub(CD_sub>0.0); % Removes all zero elements.

% Trim imaginary numbers
% CD_sup(imag(CD_sup)~=0.0)=0; % Sets all imaginary components to 0.
% CD_sup = CD_sup(CD_sup>0.0); % Removes all zero elements.
% CD_sup = CD_sup(mach_array>=M_CD0_max); % Remove all values below MCD0_max because this is SUPERSONIC ONLY

% CD_angle = [CD_sub]; % Assemble CD array

% Compute CL/CD
CL_CD_angle = CL_angle./CD_angle;


% Form complete k1, k2
index = (mach_array<M_crit);
k1(index) = k1_sub;
k2(index) = k2_sub;
index = (mach_array>=M_crit);
k1(index) = k1_sup(index);
k2(index) = k2_sup;
k1 = k1';
k2 = k2';

% Form complete CD0
CD0 = CD0_sup; % This is because CD0_sup is negliigibly different from CD0_sub because CD0_sub is incorporated into the results

max_LD = (max(CL_mach)/max(CD_mach))
LD_point = zeros(1,length(CL_angle));
LD_point_C = zeros(1,length(CL_angle_C));
for i = 1:length(CL_angle)
    LD_point(i) = CL_angle(i)/CD_angle(i);
    LD_point_C(i) = CL_angle_C(i)/CD_angle_C(i);
end
[~, id_max] = max(LD_point);
[~, id_max_C] = max(LD_point_C);
max_LD_C = (max(CL_mach_C)/max(CD_mach_C));
wing_loading = 860;

% Generate plots
figure
hold on
grid on
plot(CL_mach, CD_mach, 'LineWidth', 2)
xlabel("C_L")
ylabel("C_D")
hold off

figure
hold on
grid on
title("C_L/C_D vs Mach Number (level) ")
plot(mach_array, CL_CD_mach, 'LineWidth', 2)
xlabel("Mach Number")
ylabel("C_L/C_D")
hold off

figure
hold on
grid on
title("C_L vs C_D (angle)")
plot(CL_angle, CD_angle, 'LineWidth', 2)
xlabel("C_L")
ylabel("C_D")
hold off

figure
hold on
grid on
title("Drag Polar")
plot(CD_angle, CL_angle, 'LineWidth', 2, 'Color','b')
plot(CD_angle_C,CL_angle_C,'LineWidth', 2,'Color','r','LineStyle','--')
plot(CD_angle(id_max),CL_angle(id_max),'ro','MarkerSize',8,"MarkerFaceColor",'r')
plot(CD_angle_C(id_max_C),CL_angle_C(id_max_C),'ro','MarkerSize',8,"MarkerFaceColor",'r')
plot(CL_angle)
legend('Hyperion','Concorde','Location','east')
xlabel("C_L")
ylabel("C_D")
hold off
xlim([0.005 0.07])
ylim([-0.55 0.55])


% Generate table
% Index the Mach values close to the key ones
m_key = [0.1, 0.2, 0.5, M_CD0_max, M_crit, 1.5, 2.0]; % Initialize array of key Mach values.

% Begin borrowed code:
% Unoriginal code. Source (top answer): https://www.mathworks.com/matlabcentral/answers/4249-round-towards-specific-values-in-an-array
%for idx1=1:length(m_key)
 %   for idx2=1:length(mach_array)
  %      C(idx2,idx1)=m_key(idx1)-mach_array(idx2);
   % end
%end
% Now find the index of the min values
%[v,i]=min(abs(C));
% 'i' now contants the list of locations in B that corespond to the nearest
% A value
% mach_array(i)
% End borrowed code

% Form the table
T = table(mach_array(:), CD0(:), CD_mach(:), k1(:), k2(:), ...
    'VariableNames', {'Mach_Number', 'CD0', 'CD', 'k1', 'k2'});

%disp(T)

end