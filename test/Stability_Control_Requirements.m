%% AIRCRAFT DESIGN & STABILITY ANALYSIS
% Author: Ryan Paul (Virginia Tech)

function [trim, dr_xw_deg, dr_oei_deg, SM, roll_rate,Cl_p,Cn_beta]=Stability_Control_Requirements()

%% 1. FLIGHT CONDITIONS & ATMOSPHERE
M_sup = 1.7;            % Supersonic Dash
V_ft_s = 357.6;         % Takeoff/Ref speed (ft/s)
rho_sl = 0.002377;      % Sea level density (slugs/ft^3)
q = 0.5 * rho_sl * V_ft_s^2; 
a0 = 2 * pi;            % 2D Lift slope (rad^-1)
M_sub = V_ft_s/1116;            % Takeoff Mach at sea level

%% 2. GEOMETRY: CRANKED MAIN WING 
x_w_LE = 41;          % Wing Leading Edge apex from nose (ft)

% --- Panel 1 (Inboard) ---
b1 = 16.45*2; c_r1 = 79.4; c_t1 = 32.9; sweep1 = deg2rad(70);
S1 = b1 * 0.5 * (c_r1 + c_t1);
MAC1 = (2/3) * c_r1 * (1 + (c_t1/c_r1) + (c_t1/c_r1)^2) / (1 + (c_t1/c_r1));
y_mac1 = (b1/6) * (1 + 2*(c_t1/c_r1)) / (1 + (c_t1/c_r1));
xle_mac1 = x_w_LE + y_mac1 * tan(sweep1);
AR1=b1^2/S1;

% --- Panel 2 (Outboard) ---
b2 = 19.6*2; c_r2 = c_t1; c_t2 = 11.3; sweep2 = deg2rad(40);
S2 = b2 * 0.5 * (c_r2 + c_t2);
MAC2 = (2/3) * c_r2 * (1 + (c_t2/c_r2) + (c_t2/c_r2)^2) / (1 + (c_t2/c_r2));
y_mac2 = (b2/6) * (1 + 2*(c_t2/c_r2)) / (1 + (c_t2/c_r2));
xle_mac2 = (x_w_LE + b1*tan(sweep1)) + y_mac2 * tan(sweep2);
AR2=b2^2/S2;

% --- Total Wing Integration ---
S    = S1 + S2;
span = (b1 + b2);
AR   = (span^2) / S;
MAC  = (S1*MAC1 + S2*MAC2) / S;
XLE_MAC=x_w_LE+c_r1-MAC+2.5;


%% 3. TAIL GEOMETRY
%Horizontal tail
c_root_h = 19.68;     % Root chord (ft)
c_tip_h  = 6.56;     % Tip chord (ft)
b_h      = 32;     % Total span of horizontal tail (ft)
x_LE_h = 142.0; % Leading edge of the tail root (ft)
sweep_h=40;
c_r_h=44;c_t_h=13;


%% 2. Geometric Calculations (The "Rest")
% Area (S_h)
S_h = (b_h / 2) * (c_root_h + c_tip_h);

% Aspect Ratio (AR_h)
AR_h = (b_h^2) / S_h;

%y MAC of tail
y_mac_h = (b_h/6) * (1 + 2*(c_t_h/c_r_h)) / (1 + (c_t_h/c_r_h));


% Taper Ratio (lambda)
lambda_h = c_tip_h / c_root_h;
deps_da = 0.45;         % Subsonic downwash gradient


% --- Vertical Tail Geometry (Two-Section Delta/Trapezoidal) ---

% Section 1: Root to Mid
x_ac_v   = 154.7;       
c_root_v  = 30;       % Chord at root
c_mid_v   = 16;       % Chord at transition
b1_v      = 9.65;       % Span of first section
rudder_length = 5.5;    %length of rudder, ft
r_root_v  = rudder_length/c_root_v;     % Rudder chord ratio at root (cr/c)
r_mid_v = rudder_length/c_mid_v;     % Rudder chord ratio at end of section 1

% Section 2: Mid to Tip
c_tip_v   = 10.15;        % Chord at tip
b2_v      = 6.85;       % Span of second section
r_tip_v   = rudder_length/c_tip_v;     % Rudder chord ratio at tip

% --- Numerical Integration Setup ---
n_pts = 100; % Points per section for resolution
y1 = linspace(0, b1_v, n_pts);
y2 = linspace(0, b2_v, n_pts);

% 1. Calculate Local Chords (Linear Variation)
c1_y = c_root_v + (c_mid_v - c_root_v) * (y1 / b1_v);
c2_y = c_mid_v  + (c_tip_v - c_mid_v)  * (y2 / b2_v);

% 2. Calculate Local Rudder Ratios (Linear Variation)
r1_y = r_root_v  + (r_mid_v - r_root_v) * (y1 / b1_v);
r2_y = r_mid_v + (r_tip_v - r_mid_v)  * (y2 / b2_v);

% 3. Calculate Local Tau values
% Formula: tau = 1.2 * (dr_ratio)^0.6
tau1_y = 1.2 .* (r1_y).^0.6;
tau2_y = 1.2 .* (r2_y).^0.6;

% --- Combine and Integrate ---
% We weight tau by the local chord: Total_Tau = (1/S) * integral(tau(y) * c(y) dy)

% Calculate Area (S) of each section
S1_v = trapz(y1, c1_y);
S2_v = trapz(y2, c2_y);
S_total_v = S1_v + S2_v;
b_total=b1_v+b2_v;
AR_v = (b_total^2) / S_total_v;

% Integrate tau * chord across both sections
integrated_tau1 = trapz(y1, tau1_y .* c1_y);
integrated_tau2 = trapz(y2, tau2_y .* c2_y);

final_tau = (integrated_tau1 + integrated_tau2) / S_total_v;



%% 4. ANALYSIS: SUBSONIC REGIME (M = 0.8)
beta_sub = sqrt(1 - M_sub^2);

% Lift Slopes
cos_sweep_eff = (S1*cos(sweep1) + S2*cos(sweep2)) / S;
sweep_eff = acos(cos_sweep_eff);  %effective sweep of entire wing
e_w = 4.62*(1 - 0.045*AR^0.68)*(cos_sweep_eff)^0.15 - 3.1; %Oswald eff factor, Raymer estimation
e_h = 4.62*(1 - 0.045*AR_h^0.68)*(cosd(sweep_h))^0.15 - 3.1;

a_w_sub = a0 / (beta_sub + (a0/(pi*AR*e_w)));
a_h_sub = a0 / (beta_sub + (a0/(pi*AR_h*e_h)));

% Aerodynamic Centers (Absolute)
MAC_h = (2/3) * c_root_h * ((1 + lambda_h + lambda_h^2) / (1 + lambda_h));
X_ac_w_sub = XLE_MAC + 0.25 * MAC; 
X_ac_h_sub = x_LE_h + 0.25 * MAC_h;

% Tail Volume & Neutral Point
l_h_sub = X_ac_h_sub - X_ac_w_sub;
V_H_sub = (S_h * l_h_sub) / (S * MAC);
x_np_sub = 0.25 + V_H_sub * (a_h_sub/a_w_sub) * (1 - deps_da);
X_np_sub_abs = XLE_MAC + x_np_sub * MAC;

%% 5. ANALYSIS: SUPERSONIC REGIME (M = 1.7)
beta_sup = sqrt(M_sup^2 - 1);

a_w_sup = 4 / beta_sup;
a_h_sup = 4 / beta_sup;
% Supersonic AC Shift (Empirical)
X_ac_w_sup_abs = XLE_MAC + (0.25*MAC + (0.112 - 0.004*M_sup)*sqrt(S));
X_ac_h_sup_abs = x_LE_h + 0.25*MAC_h + (0.112 - 0.004 * M_sup) * sqrt(S_h); % Tail AC also shifts aft

% Supersonic Tail Volume (Note: Downwash deps/da = 0 in Supersonic)
l_h_sup = X_ac_h_sup_abs - X_ac_w_sup_abs;
V_H_sup = (S_h * l_h_sup) / (S * MAC);
X_np_sup_abs = X_ac_w_sup_abs + (a_h_sup/a_w_sup)*(S_h*l_h_sup/S);



%% 6. STATIC MARGIN & OEI CHECK
x_cg_loc = 90.8; % CG from nose (ft)

% Static Margins
SM_sub = (X_np_sub_abs - x_cg_loc) / MAC;
SM_sup = (X_np_sup_abs - x_cg_loc) / MAC;

SM=SM_sub*100

% Engine-Out Yaw (OEI)
T_max = 31000; y_eng = 19; 
N_eng = T_max * y_eng; 
l_v = x_ac_v - x_cg_loc;
V_v = (S_total_v * l_v) / (S * span);
a_v_takeoff = a0 / (sqrt(1-(V_ft_s/1116.5)^2) * (1 + (2/(pi*AR_v))));
Cn_dr = V_v * a_v_takeoff * final_tau;
dr_oei_deg = rad2deg( N_eng / (q * S * span * Cn_dr) );

%Crosswind landing:
V_xw_fps = 58.67; %40 mph in fps, as per requirements
beta_req_rad = asin(V_xw_fps / V_ft_s); 
beta_req_deg = rad2deg(beta_req_rad);
% 2. Calculate Directional Stability (Cn_beta)
% Primarily driven by the Vertical Tail Volume
% Includes a 1.2 multiplier for fuselage/wing destabilization effects
Cn_beta = 1.2 * V_v * a_v_takeoff; 


% --- Case B: Crosswind Landing (Sideslip) ---
% Formula: Cn_beta * beta + Cn_dr * delta_r = 0 (Steady state)
dr_xw_deg = rad2deg( (Cn_beta * beta_req_rad) / Cn_dr );

% --- Combined Requirement ---
% Often, you need a bit of both, but usually we look for the "Critical Case"
dr_max_req = max(dr_oei_deg, dr_xw_deg);


%% ============================================
%   DATCOM-BASED STABILITY DERIVATIVES MODULE
%% ============================================

deriv = struct();

%% --- 1. BASIC PARAMETERS ---
eta_h = 0.9;                  % tail efficiency factor
x_cg_nd = (x_cg_loc - XLE_MAC)/MAC;   % nondimensional CG
x_ac_nd = 0.25;               % wing AC location (subsonic)

%% --- 2. LIFT CURVE SLOPE (TOTAL AIRCRAFT) ---
deriv.CL_alpha = a_w_sub + a_h_sub * (S_h/S) * (1 - deps_da);

%% --- 3. LONGITUDINAL DERIVATIVES ---

% Cm_alpha (pitching moment slope)
deriv.Cm_alpha = deriv.CL_alpha*(x_cg_nd - x_ac_nd) ...
    - eta_h * a_h_sub * V_H_sub * (1 - deps_da);

% Pitch damping
deriv.Cm_q = -2 * eta_h * a_h_sub * V_H_sub;

% Lift due to pitch rate
deriv.CL_q = 2 * eta_h * a_h_sub * (S_h/S);

%% --- 4. LATERAL-DIRECTIONAL DERIVATIVES ---

% Directional stability (already computed)
deriv.Cn_beta = Cn_beta;

% Dihedral effect (approximation)
dihedral_deg = 3.5; % set if known

Cl_beta_w = -0.0005 * AR * (sweep_eff * 180/pi);
Cl_beta_tail = -0.0001 * (S_h/S);

deriv.Cl_beta = Cl_beta_w + Cl_beta_tail;

% Roll damping
deriv.Cl_p = -0.5 * AR;

% Yaw damping
deriv.Cn_r = -2 * V_v * a_v_takeoff;

% Side force derivative
deriv.CY_beta = -deriv.Cn_beta;

%% --- 5. CONTROL DERIVATIVES ---

% Rudder effectiveness (already computed)
deriv.Cn_dr = Cn_dr;

% Elevator effectiveness (DATCOM estimate)
tau_e = 1; %stabilator
deriv.Cm_de = -eta_h * a_h_sub * V_H_sub * tau_e;



%% ============================================================
% AILERON CHORD SIZING (FIXED SPAN, WITH STABILATOR ASSIST)
%% ============================================================

% --- Flight condition ---
V = V_ft_s;     
b = span;       

% --- Requirement ---
p_req = deg2rad(20);     

% --- Control limits ---
delta_a_max = deg2rad(20);   
delta_s_max = deg2rad(20);   % stabilator differential

% --- Aerodynamics ---
Cl_p = deriv.Cl_p;
Cl_alpha_w = a_w_sub;
Cl_alpha_h = a_h_sub;

% ============================================================
% --- USER INPUT: FIX AILERON SPAN HERE ---
% ============================================================
b_a=10.815;   % <-- YOU SET THIS (fraction of semi-span)

b_half = b / 2;
y_tip = b_half-2; %includes 2.5 feet from wing tip

% Aileron span location
% b_a = span_frac * b_half;
y_inner = y_tip - b_a;
y_outer = y_tip;

% Span effectiveness factor (NOW FIXED)
eta_a = (y_outer^2 - y_inner^2) / (b_half^2);

% ============================================================
% --- STABILATOR CONTRIBUTION ---
% ============================================================

Cl_ds = (S_h / S) * (y_mac_h / b) * eta_h * Cl_alpha_h;

% ============================================================
% --- SWEEP AILERON CHORD RATIO ---
% ============================================================
ca_c_vec = linspace(0.05, 0.5, 150);

p_achieved = zeros(size(ca_c_vec));

for i = 1:length(ca_c_vec)

    ca_c = ca_c_vec(i);

    % Aileron effectiveness
    tau_a = 0.6 * (ca_c)^0.5;   % empirical DATCOM-style estimate
    Cl_da = Cl_alpha_w * tau_a * ca_c * eta_a;

    % Total rolling contribution
    Cl_total = Cl_da * delta_a_max + Cl_ds * delta_s_max;

    % Roll rate
    p_achieved(i) = - (2 * V / b) * (Cl_total / Cl_p);

end

% --- Find minimum chord ratio ---
idx = find(p_achieved >= p_req, 1, 'first');
roll_rate=rad2deg(p_achieved(idx));

if isempty(idx)
else
    optimal_ca_c = ca_c_vec(idx);

end


%% ===============================================
% Test Requirements and output results
%  ===============================================

% is true of the FBW is capable of trimming the aircraft mid flight, which
% it is. 
trim=true;


