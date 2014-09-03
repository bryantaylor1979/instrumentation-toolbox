classdef ADB_command_logger < handle
    properties (SetObservable = true)
        Shell = true
        commandstr
        Log2CommandWindow = true
        Error = 0;
        String = {'',''};
    end
    methods 
        function [] = RUN(obj)
            if obj.Shell == true
                [obj.Error,obj.String] = obj.ADB_Command_Shell(obj.commandstr);
            else
                [obj.Error,obj.String] = obj.ADB_Command(obj.commandstr);
            end
        end
    end
    methods (Hidden = true)
        function Example(obj)
            %% Check connection to phone
            obj = ADB_command_logger;
            obj.CheckConnection;
        end
        function [Error,String] = Dos_Command(obj,commandstr)
            %%
            if obj.Log2CommandWindow == true
               disp(commandstr) 
            end
            [Error,String] = system(commandstr);
            if not(isempty(String))
                disp(String)
            end
        end
        function [Error,String] = ADB_Command_Shell(obj,commandstr)
            [Error,String] = obj.Dos_Command(['adb shell ',commandstr,'']);
        end
        function [Error,String] = ADB_Command(obj,commandstr)
            [Error,String] = obj.Dos_Command(['adb "',commandstr,'"']);
        end
        function CheckConnection(obj)
            %%
            [~, string] = system('adb shell -echo');
            if not(isempty(strfind(string,'error: device not found')))
                 errordlg('Please check phone is attached','device not found');
            else
                 disp('device found') 
            end
        end
        function obj = ADB_command_logger()
        end
    end
end