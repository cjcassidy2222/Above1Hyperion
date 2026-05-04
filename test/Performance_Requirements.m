function [max_cruise_altitude, climb_rate] = Performance_Requirements()

%% Above1 Performance Requirement Function
% max_cruise_altitude = maximum cruise altitude capability (ft)
% climb_rate = max climb rate at cruise altitude (ft/min)

%% Aircraft Inputs
W_to = 2.02e5; % takeoff gross weight (lbf)
W = 0.70 * W_to; % mid-cruise weight (lbf)
S = 2713.5; % wing area (ft^2)
AR = 1.91048; % aspect ratio
e = 0.5316; % Oswald efficiency
CD0 = 0.020; % zero-lift drag coefficient
Tsl = 125400; % total static thrust (lbf)
Mach_cr = 1.7; % cruise Mach number

%% Requirement Inputs
cruise_altitude_req = 50000; % required cruise altitude (ft)
ROC_req = 100; % service ceiling cutoff (ft/min)

%% Atmosphere Setup
[~, rho0] = std_atm(0);

%% Climb Rate vs Altitude
alts_ft = 20000:1000:65000;
ROCmax_ftmin = zeros(size(alts_ft));

k = 1 / (pi * AR * e); % induced drag factor

for i = 1:length(alts_ft)

    [a_i, rho_i] = std_atm(alts_ft(i));
    Ms = 0.7:0.1:Mach_cr;
    roc_alt = zeros(size(Ms));

    for j = 1:length(Ms)

        M = Ms(j);
        V = M * a_i;
        q = 0.5 * rho_i * V^2;

        CL = W / (q * S);
        CD = CD0 + k * CL^2;
        D = q * S * CD;

        sigma = rho_i / rho0;
        T_av = Tsl * sigma * (1 + 0.6 * M);
        T_av = min(T_av, Tsl);

        roc_alt(j) = (T_av - D) * V / W; % climb rate (ft/s)

    end
    ROCmax_ftmin(i) = max(roc_alt) * 60; % climb rate [ft/min)
end

%% Cruise Altitude Requirement
% Requirement: aircraft capable of cruise at 50,000 ft or higher

idx = find(ROCmax_ftmin <= ROC_req, 1, 'first');

if isempty(idx)
    max_cruise_altitude = alts_ft(end);
else
    max_cruise_altitude = alts_ft(idx);
end

%% Climb Rate Requirement
% Requirement: climb to cruise altitude at 3000 ft/min or higher

climb_rate = interp1(alts_ft, ROCmax_ftmin, cruise_altitude_req, 'linear');

end

function [a, rho] = std_atm(h_ft)

h = h_ft * 0.3048; % altitude (m)
T0 = 288.15; % sea-level temperature (K)
P0 = 101325; % sea-level pressure (Pa)
L = 0.0065; % lapse rate (K/m)
g0 = 9.80665; % gravity (m/s^2)
R = 287.058; % gas constant (J/kg-K)
gamma = 1.4; % ratio of specific heats

if h < 11000
    T = T0 - L * h;
    P = P0 * (T / T0)^(g0 / (R * L));
else
    T = 216.65;
    P11 = P0 * (T / T0)^(g0 / (R * L));
    P = P11 * exp(-g0 * (h - 11000) / (R * T));
end

rho_SI = P / (R * T);
a_SI = sqrt(gamma * R * T);

rho = rho_SI * 0.00194032; % density (slug/ft^3)
a = a_SI * 3.28084; % speed of sound (ft/s)

end