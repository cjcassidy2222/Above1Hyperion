function[cruise_cabin_altitude]=cruise_cabin_altitude_test()

%Carbon Fiber = 1 Titanium = 2 Steel = 3 Aluminum = 4

material = 1;

if material <= 2
    cruise_cabin_altitude = 6000 %feet
elseif material > 2
    cruise_cabin_altitude = 8000 %feet
end

