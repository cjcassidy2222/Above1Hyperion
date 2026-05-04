%% Fuselage, Wing and Tail Sizing
% Developed by N.L
% Chaoter 6 Raymer
% Uses Concorde values to verify
clear;clc;

%% Fuselage sizing
% Concorde was 203 ft 9 in (203.75 ft)
W_TO = 206225.67; % lbs

% Regression
% Concorde, Tupolev, 2707
TOGW = [408000;456000;674600];
F_length = [203.75;215.6;306];

% Take natural logarithm
logW = log(TOGW);
logL = log(F_length);

% Fit linear model: log(L) = log(a) + C*log(W)
p = polyfit(logW, logL, 1);  % returns [slope, intercept]

C = p(1);          % exponent
ln_a = p(2);       % log of coefficient
a = exp(ln_a);     % coefficient in original units

% Raymer Estimates
a_raymer = 1.05;
C_raymer = 0.43;

fuselage_length = a * (W_TO^C);
fuselage_length_raymer = a_raymer * (W_TO^C_raymer);

fprintf('Fuselage Length Estimate based on SST Regression: %.2f ft (%.2f m)\n',fuselage_length,fuselage_length*0.3048)
fprintf('Fuselage Length Estimate based on Raymer Estimates: %.2f ft (%.2f m)\n',fuselage_length_raymer,fuselage_length_raymer*0.3048)

fineness_estimate = 16;
max_diameter_fuselage = fuselage_length_raymer / fineness_estimate;
fprintf('Using Raymer Estimate:\nFuselage Main Diameter Estimate based on Fineness Ratio of %.1f: %.2f ft (%.2f m)\n',fineness_estimate, max_diameter_fuselage,max_diameter_fuselage*0.3048)

%% Tire Sizing
% Using transport estimates Raymer Table 11.1 (pg. 344)
% Estimates are very good!!
% Nothing needs to be changed here

% Diameter
a_diam = 1.63;
b_diam = 0.315;

% Width
a_width = 0.1043;
b_width = 0.48;

% Weight Distribution
W_main = 0.9 * W_TO;

% Assume 4-wheel bogey for main gear, 2 wheel for front
W_on_wheel_main = W_main / 8; % 2 sets of gear w/ 4 wheels each

% Calculate size
diameter_main = a_diam * (W_on_wheel_main^b_diam);
width_main = a_width * (W_on_wheel_main^b_width);
diameter_nose = 0.65 * diameter_main;
width_nose = 0.65 * width_main;

fprintf('Recommended Tire Size:\nMAIN WHEELS\nDiameter: %.2f in, Width: %.2f in\n',diameter_main,width_main)
fprintf('NOSEWHEELS\nDiameter: %.2f in, Width: %.2f in\n',diameter_nose,width_nose)

%% Fuel tank volumes
fuel_used_weight = 99000; % lbs

%% Inlet Capture Area estimate
target_mach = 1.7; % goal cruise mach
% Reference Table 10.17 pg. 300 (1.7 is 0.0260)
cap_per_mass = 0.0260;

% We need to pick an engine and get the inlet area for our concept to do this
Area_inlet = 10.2; % ft^2
[T,a,P,rho] = atmosisa(52000*0.3048);
rho = rho * 0.00194032; % slug/ft^3, convert from kg/m^3
V = target_mach * (a * 3.2808399); % ft/s

m_dot = rho * V * Area_inlet * 32.2;

capture_area = cap_per_mass * m_dot;

fprintf('Recommended Capture Area: %.3f ft^2\n',capture_area)
%% Wing Location and other factors
% Chapter 4 to do all this (starts pg. 53)
% Raymer Table 4.2 pg. 89 dihedral angle
% Reference Fig 4.20 and 4.21 for AR-Sweep Relation pg. 82
% Tail Volume Coeff Estimates
% Raymer Table 6.4 Estimates Jet Transport (pg. 160)
c_HT = 0.5;
c_VT = 0.09;

%%%%% Inputs %%%%%%%
S_W = 2713.; % ft^2
c_root = 24.2/0.3048; % ft, Root Chord
c_tip = 3.452/0.3048; % ft, roughly?, Tip Chord
b_W = 21.98/0.3048; % ft, Wingspan

% Estimates of Moment Arms (L_HT and L_VT)
L_VT = 25/0.3048; % ft
L_HT = 27/0.3048; % Concorde didnt have a horiztonal tail :(

%%%%% Calculations %%%%%%%
cbar_W = (c_root + c_tip)/2; % Average chord

S_HT = (c_HT * cbar_W * S_W)/(L_HT);
S_VT = (c_VT * b_W * S_W)/(L_VT);

fprintf('Recommended Horizontal Tail Area: %.3f ft^2 (%.3f m^2)\nRecommended Vertical Tail Area: %.3f ft^2 (%.3f m^2)\n',S_HT,S_HT*0.09290304,S_VT,S_VT*0.09290304)

%% Control Surface Size Estimation
% Raymer Estimates Table 6.5 pg. 162
elevator_ratio = 0.25;
rudder_ratio = 0.32;

elevator_chord = elevator_ratio * c_root;
rudder_chord = rudder_ratio * c_root;

aileron_length = 0.2 * c_root;
flap_length = 0.2 * c_root;
aileron_v_wing_chord = aileron_length/c_root;
% Use Raymer Fig. 6.3 (pg. 161) to get Aileron Span/Wing Span estimate
% For Concorde, its estimated as follows
aileron_v_wing_span = 0.44;
aileron_span = aileron_v_wing_span * b_W;

fprintf('Control Surface Sizing:\nElevator Chord: %.3f ft\nRudder Chord: %.3f ft\n',elevator_chord,rudder_chord)
fprintf('Aileron Chord: %.3f ft, Aileron Span: %.3f ft\nFlap Chord: %.3f ft\n',aileron_length,aileron_span,flap_length)

%% MAC Estimation
c_root_wing = 24.2;
lambda_wing = 0.37927;
b_wing = 21.98;
Lambda_LE_wing = 70;
x_wing = 18.75; % inside fuselage

x_wing = ((3.86/2)/tand(20)) + x_wing;

MAC_wing = (2/3) * c_root_wing * (1 + lambda_wing + lambda_wing^2) / (1+lambda_wing);
% Estimating y-location of main wing's MAC
y_MAC_wing = (b_wing/6) * (1 + 2*lambda_wing)/(1+lambda_wing);
% Estimating x-location of main wing's MAC
x_MAC_wing = x_wing + y_MAC_wing * tand(Lambda_LE_wing);
