classdef CamCal < handle
    properties (SetObservable = true)
        mode = 'AWB';
        ADB_Shell
    end
    properties (Hidden = true, SetObservable = true)
        mode_LUT = {'AWB'; ...
                    'LS'; ...
                    'Flash'}
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = CamCal
            ObjectInspector(obj)
        end
        function RUN(obj)
            switch obj.mode
                case 'AWB'
                    obj.AWB();
                case 'LS'
                    obj.LS();
                case 'Flash'
                    obj.Flash();
                otherwise
            end
        end
    end
    methods (Hidden = true)
        function obj = CamCal()
            %%
            obj.ADB_Shell = ADB_command_logger;
        end
        function AWB(obj)
            obj.ADB_Shell.ADB_Command_Shell('camcal -c 0 -t 3000 -d 10');
        end
        function LS(obj)
            obj.ADB_Shell.ADB_Command_Shell('camcal -c 1 -t 3000 -d 10');
        end
        function Flash(obj)
            obj.ADB_Shell.ADB_Command_Shell('camcal -c 2 -t 3000 -d 10'); 
        end
    end
end