classdef tests < matlab.unittest.TestCase

    methods(Test)

        function stab_control_test(testCase)
            [trim, dr_xw_deg, dr_oei_deg, SM, roll_rate,Cl_p,Cn_beta]=Stability_Control_Requirements();
            testCase.verifyTrue(trim);
            testCase.verifyGreaterThanOrEqual(SM, 4);
            testCase.verifyLessThanOrEqual(SM, 7);
            testCase.verifyLessThan(dr_xw_deg, 20);
            testCase.verifyLessThan(dr_oei_deg, 20);
            testCase.verifyLessThan(Cl_p,0);
            testCase.verifyGreaterThan(Cn_beta,0);
            testCase.verifyGreaterThan(roll_rate,20);
        end

        function performance_test(testCase)
            [max_cruise_altitude, climb_rate] = Performance_Requirements();
            testCase.verifyGreaterThan(climb_rate,3000);
            testCase.verifyGreaterThan(max_cruise_altitude,50000)
        end
        
        function cost_test(testCase)
            [n_units_breakeven, operating_cost] = Cost_Requirements();
            testCase.verifyLessThanOrEqual(n_units_breakeven,860);
            testCase.verifyLessThan(operating_cost,0.3);
        end

        function pax_test(testCase)
            [Hyperion_Capacity] = PassengerCapacity();
            testCase.verifyGreaterThan(Hyperion_Capacity,70);
        end

        function cabin_alt_test(testCase)
            [cruise_cabin_altitude] = cruise_cabin_altitude_test();
            testCase.verifyEqual(cruise_cabin_altitude,6000);
        end
        
        function aero_test(testCase)
            [cruise_Cd,sup_LD,sub_LD,wing_loading] = aerodynamics_test();
            testCase.verifyLessThan(cruise_Cd,0.015);
            testCase.verifyGreaterThanOrEqual(sup_LD,7.5);
            testCase.verifyGreaterThanOrEqual(sub_LD,11.5);
            testCase.verifyLessThanOrEqual(wing_loading,1000);
        end
        
        function placeholder_test(testCase)
            testCase.verifyTrue(true);
        end
    end
end