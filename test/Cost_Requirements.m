function [n_units_breakeven, operating_cost] = Cost_Requirements()

%% Above1 Cost Requirement Function
% n_units_breakeven = breakeven production quantity [aircraft]
% operating_cost = acquisition-normalized cost [$/available-seat-mile]

%% Cost Assumptions
Re = 115; % engineering wrap rate [2012 $/hr]
Rt = 118; % tooling wrap rate [2012 $/hr]
Rm = 98; % manufacturing wrap rate [2012 $/hr]
Rq = 108; % quality control wrap rate [2012 $/hr]

avionics_frac = 0.08; % avionics fraction of airframe production cost
interior_per_pax = 3500; % interior cost per passenger [2012 $]
infl = 1.41; % inflation factor from 2012 to 2025
commercial_factor = 0.90; % commercial correction factor
modern_factor = 1.00; % modern manufacturing correction factor

engine_cost_2025 = 10e6; % engine cost [2025 $]
engine_cost_2012 = engine_cost_2025 / infl;

%% Mission and Life Assumptions
jfk_lhr_mi = 3451.4;
lhr_mia_mi = 4424.9;
mia_jfk_mi = 1089.6;

daily_route_mi = jfk_lhr_mi + lhr_mia_mi + mia_jfk_mi;
operating_days_per_year = 300;
service_life_years = 27;

%% Aircraft Inputs
We = 120000; % empty weight [lb]
Q = 30; % production quantity
FTA = 6; % flight test aircraft
Neng = 4; % number of engines
V = 1.70 * 574; % cruise speed [kt]
pax = 74; % passenger count

%% DAPCA Cost Model
He = 4.86 * We^0.777 * V^0.894 * Q^0.163;
Ht = 5.99 * We^0.777 * V^0.696 * Q^0.263;
Hm = 7.37 * We^0.82  * V^0.484 * Q^0.641;
Hq = 0.133 * Hm;

CD = 91.3 * We^0.63  * V^1.3;
CF = 2498 * We^0.325 * V^0.822 * FTA^1.21;
CM = 22.1 * We^0.921 * V^0.621 * Q^0.799;

CengH = He * Re;
Ctool = Ht * Rt;
Cmfg  = Hm * Rm;
Cqc   = Hq * Rq;

prod_labor = Cmfg + Cqc;
airframe_unit_2012 = (prod_labor + CM) / Q;

avionics_unit_2012 = avionics_frac * airframe_unit_2012;
interior_unit_2012 = pax * interior_per_pax;
engines_unit_2012 = engine_cost_2012 * Neng;

flyaway_2012 = (airframe_unit_2012 + avionics_unit_2012 + interior_unit_2012 + engines_unit_2012) * commercial_factor * modern_factor;

rdte_2012 = (CengH + Ctool + CD + CF) * commercial_factor * modern_factor;
program_2012 = rdte_2012 + Q * flyaway_2012;

flyaway_2025 = flyaway_2012 * infl;
rdte_2025 = rdte_2012 * infl;
program_2025 = program_2012 * infl;

%% Operating Cost Requirement
% Requirement: operating cost less than $0.30/nm
% Acquisition-normalized cost per available seat mile

lifetime_asm = pax * daily_route_mi * operating_days_per_year * service_life_years;
operating_cost = flyaway_2025 / lifetime_asm;

%% Breakeven Cost Requirement
% Requirement: breakeven cost equivalent to 860 units or less

sale_price_markup = 1.50; % sale price is 50% above flyaway cost

sale_price_2025 = sale_price_markup * flyaway_2025;
profit_per_aircraft = sale_price_2025 - flyaway_2025;

n_units_breakeven = ceil(rdte_2025 / profit_per_aircraft);

%% Extra Values

cost_per_seat_2025 = flyaway_2025 / pax;
acq_dollar_per_asm = operating_cost;
program_total_2025 = program_2025;

end