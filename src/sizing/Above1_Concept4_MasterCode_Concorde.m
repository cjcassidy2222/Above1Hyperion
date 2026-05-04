%% Above 1 - Concept 4 Initial Sizing
% Nelson Laine & Ben Robinson
% Senior Design 25'-26'
% Based on Raymer - Conceptual Aircraft Design
clear;clc;

 %% Initial Sizing
 % Number of People on Board
 num_passengers = 72; % This is an estimate
 num_pilots = 3; % Captain & F.O & Engineer
 num_flightcrew = 6; % Flight Attendants (2 First Class, 4 Main Cabin)

 % Weight of Avg. person on board (person + baggage)
 weight_passenger = 180; % lbs

 % Total Weights
 W_crew = (num_pilots + num_flightcrew) * weight_passenger; % lbs
 W_payload = num_passengers * weight_passenger; % lbs

 % Initial Values (Some Guesses)
 W_TO = 400000; % lbs ( Concorde was 408,000 lb)
 TSFC_cruise1 = 1.195/3600; TSFC_loiter = 0.8/3600; % lb/s/lb, louter not available, assume pure turbojet
 time_loiter = 10; time_loiter2 = 10;% min
 altitude_cruise = 58000; % ft
 distance_cruise1 = 4020 * 6076.11549; % convert nautical mile to ft
 Mach_cruise1 = 2.05; % our goal mach
 e = 0.4; % assumption from Ch. 5 Raymer (Pg. 135)
 AR = 1.7; % AR chosen from average of X59 and Concorde and assuming Canard does 20% of lifting
 Max_LD = 7.55; % From Raymer estimates and Lecture W1L2 34 (Supersonic Cruise)



% Takeoff Segment
function [W_out, fuel_used] = segment_takeoff(W_in)
% ARGUMENTS:
%   W_in = Takeoff weight (lbf ("pound-force")) (In this context, it'll be the initial guess)

% RETURNS:
%   fuel_used = Weight of fuel burned during this segment (lbf)
%   W_out = Aircraft's weight at the end of this segment (lbf)
    WF = 0.995;
    W_out = W_in * WF;
    fuel_used = W_in -W_out;

end

% Climb Segment
function [W_out, fuel_used] = segment_climb(W_in)
% ARGUMENTS:
%   W_TO = Gross takeoff weight (lbf)
%   W_in = Aircraft's weight at the segment's start (lbf)
%   Mach = Mach number (I hope you recognize this, otherwise God help you)

% OUTPUTS:
%   W_out = Aircraft's weight at the end of the segment (lbf)
%   fuel_used = Weight of the fuel burned during this segment (lbf)
    WF = 0.980;
    fuel_used = (1-WF)*W_in;
    W_out = W_in - fuel_used;
end

% Cruise Segment 1
function [W_out, fuel_used,WF] = segment_cruise(W_in, TSFC, Distance, Mach, Max_LD)
% ARGUMENTS:
%   W_in = Aircraft's weight at the segment's start (lbf)
%   TSFC = Thrust Specific Fuel Consumption
%   Distance = Horizontal distance travelled (ft)
%   Mach = Mach number
%   CD0 = Zero-lift drag coefficient (dimensionless)
%   e = Oswald/span efficiency factor (dimensionless)
%   AR = Aspect ratio (dimensionless)
%   W_TO = Gross takeoff weight (lbf)

% RETURNS:
%   W_out = Aircraft's weight at the segment's end (lbf)
%   fuel_used = Weight of fuel burned during the segment (lbf)
    [T,a,P,rho] = atmosisa(60000*0.3048); % all in metric units
    V = Mach * (a*3.2808399); % ft/s now
    q = 0.5 * (rho*0.0019403203259304) * (V^2); % dynamic pressure
    LD = Max_LD * 0.866;
    WF = exp( (-(Distance*TSFC))/(V*LD)); % from Mission Analysis lecture
    % WF = 0.53; % Roskam Estimate
    W_out = WF *W_in;
    fuel_used = W_in - W_out;

end

% Loiter Segment
function [W_out, fuel_used,WF] = segment_loiter(W_in, time, TSFC,Max_LD)
% ARGUMENTS:
%   W_TO = Takeoff weight (lbf)
%   W_in = Previous segment's end weight (lbf)
%   CD0 = Zero-lift drag coefficient
%   e = Oswald/span efficiency factor
%   AR = Aspect ratio
%   TSFC = Thrust Specific Fuel Consumption

% RETURNS:
%   W_out = Aircraft's weight at segment's end (lbf)
%   fuel_used = Weight of burned fuel (lbf)
%   LD = Lift-to-drag ratio (dimensionless)
    LD = Max_LD;
    time = time*60;
    %WF = exp((-time*TSFC)/LD); %from Mission analysis lecture
    WF = 0.968;
    W_out = WF *W_in;
    fuel_used = W_in - W_out;
end

% Landing Segment
function [W_out, fuel_used] = segment_landing(W_in)
% ARGUMENTS:
%   W_in = Aircraft weight at end of previous segment (lbf)
%   W_TO = Takeoff weight (lbf)

% RETURNS:
%   W_out = Aircraft weight at end of segment (lbf)
%   fuel_used = Weight of burned fuel (lbf)
    WF = 0.992; %given assumption
    W_out = W_in * WF;
    fuel_used = W_in -W_out;
end

% Descent Segment
function [W_out, fuel_used] = segment_descent(W_in)
% ARGUMENTS:
%   W_in = Aircraft weight at end of previous segment (lbf)
%   W_TO = Takeoff weight (lbf)

% RETURNS:
%   W_out = Aircraft weight at end of segment (lbf)
%   fuel_used = Weight of burned fuel (lbf)
    WF = 0.985; %given assumption
    W_out = W_in * WF;
    fuel_used = W_in -W_out;
end

% Alternate Airport Segment
function [W_out, fuel_used] = segment_alternate(W_in)
% ARGUMENTS:
%   W_in = Aircraft weight at end of previous segment (lbf)
%   W_TO = Takeoff weight (lbf)

% RETURNS:
%   W_out = Aircraft weight at end of segment (lbf)
%   fuel_used = Weight of burned fuel (lbf)
    WF = 0.959; %given assumption
    W_out = W_in * WF;
    fuel_used = W_in -W_out;
end

loop_count = 1;

% Iterating
convergence = 100; % start it high
while abs(convergence) >= 0.05

    % Call all functions to get segment weights (W_segment) and fuel burn (fn)
    [W_Takeoff, f1] = segment_takeoff(W_TO);
    [W_Climb1, f2] = segment_climb(W_Takeoff);
    [W_Cruise1, f3,WF_cruise] = segment_cruise(W_Climb1, TSFC_cruise1, distance_cruise1, Mach_cruise1, Max_LD);
    [W_Descent, f4] = segment_descent(W_Cruise1);
    [W_Alternate,f5] = segment_alternate(W_Descent);
    [W_Loiter2, f6,WF_loiter] = segment_loiter(W_Alternate, time_loiter, TSFC_loiter, Max_LD);
    [W_Landing2, f7] = segment_landing(W_Loiter2);

    % Calculate total fuel used and weight fractions from final calculations code
    total_fuel_used = f1 + f2 + f3 + f4 + f5 + f6 + f7;
    fuel_fraction = total_fuel_used/W_TO;

    % Choose an empty weight model. They produce different results

    %empty_weight = 2.995 * (W_TO^(0.8489)); % Kawanabe Paper
    empty_weight = 0.5 * (W_TO^(0.9876)); % Raj Historical Trendline

    empty_weight_fraction = empty_weight / W_TO;
    W_fixed = W_crew + W_payload; % total payload (Crew + Passengers)
    W_TO_new = (W_fixed / (1-empty_weight_fraction-fuel_fraction));
    convergence = (abs(W_TO_new - W_TO)/W_TO) * 100; % check new convergence value, if not within 0.05 percent do again

    W_TO = W_TO_new; % Set previous takeoff weight as new guess
    loop_count = loop_count + 1;
end

fprintf('Estimated TOGW: %.2f lb\n',W_TO)

%% Cost Estimates
W_e = empty_weight; % Empty weight estimate from loop, lb
M_Mach = Mach_cruise1;
[T,a,P,rho] = atmosisa(60000*0.3048); % all in metric units
T_60000 = T * 1.8; % Rankine, Convert from Kelvin to Rankine
a_60000 = a * 3.2808399; % ft/s, Convert from m/s to ft/s
P_60000 = P * 0.000145038; % psi, Convert from Pa to psi
rho_60000 = rho * 0.00194032; % ib/ft^3, convert from kg/m^3 to ib/ft^3
Max_V = (M_Mach * (a*3.2808399))*0.5924838; % KNOTS
Q = 14; % Units produced in five years
FTA = 6; % Flight test aircraft
T_max = 38050; % MAXIMUM ENGINE THRUST ESTIMATE, lbf
M_max = M_Mach;%Max_mach_estimate;
T_turbineinlet = 2100; % Farenheint

% Cost Estimates
N_engine = Q * 4; % assume 4 engines
C_avionics = 6000*W_e; % cost of avionics

% Hourly Costs
Re = 115;
Rt = 118;
Rq = 108;
Rm = 98;

% Using fps eqns (2012 dollars converted to 2025 at end)
% Engineering Hours 
He = 4.86 * (W_e^0.777) * (Max_V^0.894) * (Q^0.163);

% Tooling Hours
Ht = 5.99 * (W_e^0.777) * (Max_V^0.696) * (Q^0.263);

% Mfg Hours
Hm = 7.37 * (W_e^0.82) * (Max_V^0.484) * (Q^0.641);

% QC Hours
Hq = 0.133 * Hm;

% Devel Support Cost
CD_cost = 91.3 * (W_e^0.63) * (Max_V^1.3);

% Flight Test Cost
CF = 2498 * (W_e^0.325) * (Max_V^0.822) * (FTA^1.21);

% Mfg Materials Cost
CM = 22.1 * (W_e^0.921) * (Max_V^0.621) * (Q^0.799);

% Engine Prod. Cost
C_eng = 3112 * ( (0.043 * T_max) + (243.25*M_max) + (0.0969*T_turbineinlet) - 2228);

% Total
RDTE_flyaway = He*Re + Ht*Rt + Hm*Rm + Hq*Rq + CD_cost + CF + CM + C_eng*N_engine + C_avionics;
cost_estimate = (RDTE_flyaway * 1.41);

fprintf('Total cost (total program): $%s\n', ...
    string(java.text.DecimalFormat('#,##0.00').format(cost_estimate)));

%% Constraint Analysis
beta = empty_weight_fraction; % Weight Fraction
c = -0.1289; % Regression Constants
d = 0.7506; % Regression Constants
C_fe = 0.0035; % Skin Friction Coefficient. Raymer, Table 12.3
S_wet = (10^c) * (W_TO^d); % Wetted Area

BAH = 3;
CD0 = C_fe * (BAH); % Equation 12.23 Raymer
Wto_S_range = 20:7:300; % Wing Loading, using calculated W_TO
Mach_Max = 2.04; % Max Mach of Concept
lambda_le = 55; % degrees, X-59 Sweep angle
lambda_te = 0;
sweep_max_t = (lambda_le + lambda_te) / 2;
k1_sup = ((AR*((Mach_Max.^2)-1).*cosd(lambda_le))./(((4*AR*sqrt(Mach_Max.^2) - 1))-2)); % Drag Estimates Part 3
k2 = 0; % 0 for Supersonic
e_osw = 4.61 * (1 - 0.045*AR^0.68)*(cosd(lambda_le)^0.15) - 3.1; % oswald efficiency, Drag Estimates Part 3
e_notoswald = 2 / ( 2 - AR + sqrt( 4 + (AR^2) * ( 1 + tand(sweep_max_t)^2 )) ); % not oswald efficiency, Drag Estimates Part 3
k1_sub = 1 / (pi * e_osw*3);
cl_Alpha = 0.1 / (1 + (57.3*0.1)/(pi*e_notoswald*3));
CLmin_D = cl_Alpha * (1.049/2);
CDmin = C_fe * (BAH);
k2_sub = -2 * k1_sub * CLmin_D;
CD01 = CDmin + k1_sub* CLmin_D^2;

%% Max Mach
lapse_rate_Mach = 0.25; % Obtained from Chat
V = Mach_Max*a_60000;
q = 0.5*rho_60000*V^2;
A = (q*CD0)/lapse_rate_Mach;
B = q/lapse_rate_Mach*k1_sup*(beta/q)^2;
T_Wto = A.*(1./Wto_S_range) + B.*Wto_S_range;

%% Cruise 
V_cruise = Max_V * 1.68781; % Max velocity calculated
q_cruise = 0.5 * rho_60000 * V_cruise; % Dynamic Pressure
lapse_rate = 0.3; % Obtained from Chat

% Found in Cruise Constraint Lecture
A_cruise = (q_cruise *CD0)/lapse_rate; 
B_cruise = (q_cruise/lapse_rate)*k1_sup*((beta/q_cruise)^2);
TW_Cruise = A_cruise.*(1./Wto_S_range) + B_cruise.*Wto_S_range; % Found in slides

%% Max Altitude
lapse_rate = 0.25; % Obtained from Chat
[T,a,P,rho] = atmosisa(60000*0.3048); % all in metric units
T_60000 = T * 1.8; % Rankine, Convert from Kelvin to Rankine
a_60000 = a * 3.2808399; % ft/s, Convert from m/s to ft/s
P_60000 = P * 0.000145038; % psi, Convert from Pa to psi
rho_60000 = rho * 0.00194032; % ib/ft^3, convert from kg/m^3 to ib/ft^3
V_alt = Mach_Max*a_60000; % Velocity at Max Altitude
q_alt = 0.5*rho_60000*V_alt^2; % Dynamic Pressure

% Obtained through HW2
A = (q_alt*CD0)/lapse_rate;
B = q_alt/lapse_rate*k1_sup*(beta/q_alt)^2;
TW_Alt = A.*(1./Wto_S_range) + B.*Wto_S_range; % Found in slides

%% Climb
ks = 1.2; % Constraint Lecture, Slide 27
CL_max_Climb = 1.2; % Guess
gamma = .017; % Constraint Lecture, Slide 27
TW_Climb_Val = ks^2/CL_max_Climb * CD0 + CL_max_Climb * k1_sup + gamma; % Constraint Lecture, Slide 26
N = 4; % Number of Engines
TW_Climb = 1/.8 * 1/.94 * N/(N-1) * (W_Climb1/W_TO) * TW_Climb_Val; % Constraint Lecture, Slide 29

%% Takeoff
% Constants
[T,a,P,rho] = atmosisa(0*0.3048); % all in metric units
T_0 = T * 1.8; % Rankine, Convert from Kelvin to Rankine
a_0 = a * 3.2808399; % ft/s, Convert from m/s to ft/s
P_0 = P * 0.000145038; % psi, Convert from Pa to psi
rho_0 = rho * 0.00194032; % lb/ft^3, convert from kg/m^3 to lb/ft^3
V_TO = 360; % ft/s, Estimated from X-59 and Concorde Takeoff speeds
beta_TO = 1; % Weight fraction at takeoff
K1 = k1_sub; 
K2 = k2_sub;
s_to = 5000; % takeoff distance
CL_max_val = [1.6, 1.8, 2]; % Obtained through Roskam, Table 3.1

[WS_grid, CL_grid] = meshgrid(Wto_S_range, CL_max_val);
T_s = (ks.^2 .* beta_TO.^2) ./ (lapse_rate .* rho_0 .* CL_grid .* 32.2 .* s_to) .* WS_grid ...
    + (0.7 .* CD0) ./ (beta_TO .* CL_grid) + 0.03;

%% Landing
% Constants
beta = 1; % Weight fraction at Landing
V_Land = 280; % ft/s, Estimated from X-59 and Concorde Landing speeds
%CL_max = 1.2; % Raymer, Appedix D, may change
CL_max_val = [1.8, 2, 2.2]; % Obtained through Roskam, Table 3.1
ks = 1.3; % Constraint Analysis Lecture, Slide 27
s_l = 6000; % ft, Landing distance
[WS_grid, CL_grid] = meshgrid(Wto_S_range, CL_max_val);
Landing = (s_l*rho_0*32.2*(0.5*CL_grid + 0.83*CD0))/(ks^2*beta); % Given

%% Plotting Design space
plot(Wto_S_range, T_Wto)
hold on
xlabel('W_{TO}/S')
ylabel('T_{sL}/W_{TO}')
title('Optimal Design Space')
%plot(Wto_S_range, TW_Cruise)
plot(Wto_S_range, TW_Alt)
%plot(Wto_S_range, T_s)
plot(Wto_S_range, T_s(1,:))
plot(Wto_S_range, T_s(2,:))
plot(Wto_S_range, T_s(3,:))
xline(Landing(1))
xline(Landing(2))
xline(Landing(3))
%plot(Wto_S_range, TW_Climb)
yline(TW_Climb)
%TW_Table = [T_Wto; TW_Cruise; TW_Alt];
TW_Table = [T_Wto; TW_Alt];
%legend('Max Mach', 'Cruise', 'Service Ceiling', 'Takeoff', 'Climb');
legend('Max Mach', 'Service Ceiling', 'Takeoff: CL_{max} = 1.6', ...
    'Takeoff: CL_{max} = 1.8','Takeoff: CL_{max} = 2.0', ...
    'Landing: CL_{max} = 1.8', 'Landing: CL_{max} = 2', ...
    'Landing: CL_{max} = 2.2', 'Climb', 'Location','north');
xlim([20 300]);
% Function to find optimal space
function [optimal_WS, min_TW] = solveOptimalPoint(TW_Table, T_s, Wto_S_range)
    T_Wto_Required = max([TW_Table; T_s], [], 1);
    [min_TW, min_idx] = min(T_Wto_Required);
    optimal_WS = Wto_S_range(min_idx);
end

% Optimal Space, not involving constraint lines of landing and takeoff
[optimal_WS, min_TW] = solveOptimalPoint(TW_Table, T_s, Wto_S_range);

plot(optimal_WS, min_TW, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 10, 'DisplayName', 'Optimum Point')

calculated_S = W_TO / optimal_WS;
required_thrust = min_TW * W_TO;

fprintf('For this concept, Sref is: %.2f ft^2 and Total Thrust Required is: %.2f lbf\n',calculated_S,required_thrust)
fprintf('Thrust per engine: %.2f lbf (assuming %.0f engines)\n',required_thrust/N,N)

%% Sound Level Estimates