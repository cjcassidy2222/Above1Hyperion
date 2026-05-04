function [MaxMach] = CruiseMachRequirement()
% Taking the data obtained from the Cruise Performance Excel Sheet given
% from Air Vehicle Design
filename = 'Hyperion_Cruise_Performance.xlsx';

data = readtable(filename, ...
    'Sheet', 1, ...
    'Range', 'V25:X125');

Mach = data.Mach;
RequiredThrust = data.RequiredThrust;
DryAvailableThrust = data.AvailableDryThrust_Klb;

% Find first index where required > available
% Only consider Mach > 1
mask = Mach > 1;

Mach_sup = Mach(mask);
Req_sup = RequiredThrust(mask);
Dry_sup = DryAvailableThrust(mask);

% Find first crossing AFTER Mach 1
idx = find(Req_sup > Dry_sup, 1, 'first');

% Get max Mach (point before crossing), Maximum Dry thrust location
if ~isempty(idx) && idx > 1
    MaxMach = Mach_sup(idx - 1);
else
    MaxMach = NaN;
end

disp(MaxMach)
end