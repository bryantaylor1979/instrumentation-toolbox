%%
classdef ADB_Logging <  handle & ...
                        ADB_command_logger
    properties (GetObservable = false, SetObservable = true)
        LogDestinationDir = 'C:\sourcecode\matlab\Programs\ADB\';
        LogDestinationFilename = 'log.txt';
        Buffer
        Logging_ENABLE = true;
    end
    properties (SetObservable = true)
        Disp = false
    end
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
           %%
           try, delete(obj.handles.timer), end
           close all
           clear classes
           
           %%
           obj = ADB_Logging;  
           ObjectInspector(obj)           
           
           %%
           obj.GetLog;

                 
           %% push and apk.
           %adb push SamsungCameraSEP13.apk /system/app/SamsungCamera.apk
           %%

           
           %% 
           delete(obj.handles.timer)
        end
        function GetLog(varargin)
            %%
            obj = varargin{1};
            
            %%
            PWD = pwd;
            filename = [obj.LogDestinationDir,obj.LogDestinationFilename];
            
            fid = fopen(filename,'w');
            fclose(fid);
            
            cd(obj.LogDestinationDir);
            obj.Log2TextFile(filename);
            cd(PWD);
        end
        function PlotLog(varargin)
           %% with filename and plotEnables
           LogDir = 'C:\sourcecode\matlab\Programs\ADB\';
           filename = 'log.txt';
           plotEnables = {  'plot_LensPositionState'; ...
                            'plot_RawFOM'};
           LogType = 'Auto';
           
           runLogs(  'LogDir',LogDir, ...
                     'filename',filename, ...
                     'plotEnables',plotEnables, ...
                     'LogType','Auto');            
        end
    end
    methods (Hidden = true)
        function Start(varargin)
            obj = varargin{1};
            State = get(obj.handles.start,'State');
            if strcmpi(State,'on')
                start(obj.handles.timer)
                set(obj.handles.stop,'State','off')
            else
                set(obj.handles.start,'State','on')
            end
        end
        function Stop(varargin)
            %%
            obj = varargin{1};
            State = get(obj.handles.stop,'State');
            if strcmpi(State,'on')
                stop(obj.handles.timer)
                set(obj.handles.start,'State','off')
            else
                set(obj.handles.stop,'State','on')
            end
        end
        function Display(varargin)
            %%
            obj = varargin{1};
            State = get(obj.handles.display,'State');
            if strcmpi(State,'on')
                obj.Disp = true;
            else
                obj.Disp = false;
            end
        end        
    end
    methods (Hidden = true) %Support functions
        function obj = ADB_Logging()
            %%
        	obj.CheckConnection();
            obj.TurnOnLogging;
            obj.handles.timer = timer(      'TimerFcn',@obj.GetBufferUpdateLogServer, ...
                                            'Period',0.001, ...
                                            'TasksToExecute', Inf, ...
                                            'ExecutionMode','fixedSpacing');
            
            obj.handles.listeners.PostSet = obj.addlistener({'Logging_ENABLE'},    'PostSet',  @obj.EnableLogs);
        end
        function EnableLogs(varargin)
            %%
            obj = varargin{1};
            if obj.Logging_ENABLE == true
                obj.EnableLogging('all')
            else
                obj.DisableLogging('all')
            end
        end
        function Buffer = GetBufferUpdateLogServer(varargin)
            obj = varargin{1};
            Buffer = obj.GetBufferUpdate('logserver');
        end
        function EnableLogging(obj,cat)
            %%
            obj.ADB_Command(['logserver -e ',cat]);
        end
        function DisableLogging(obj,cat)
            obj.ADB_Command(['logserver -d ',cat]); 
        end
        function Log2TextFile(obj,filename)
            method = 'logserver';
            switch lower(method)
                case 'logserver'
                    %%
                    system('adb shell "logserver -e matlab -s -D"')
                    system('adb shell "vcdbg log level isp_tuner_brcm_focus_log_category t"')
                    obj.ADB_Command(['logserver -d all']);
                    obj.ADB_Command(['logserver -e ','vcos']);
                    system(['adb shell logcat -d logserver > ',filename]); %Can get this to work through the ADB shell
                case 'vcdbg'
                    %%
                    obj.ADB_Command('vcdbg log level isp_tuner_brcm_focus_log_category t');
                    % adb shell vcdbg log msg > C:\sourcecode\matlab\Programs\CAF\Logs\log.txt
                    obj.ADB_Command('vcdbg log msg /storage/sdcard0/log.txt'); % ',filename])
                otherwise
            end
        end
        function TurnOnLogging(varargin)
            %%
            % Capture VideoCore logging with logserver.
            % The logging goes to the standard Android logcat.
            system(['adb shell logserver -D -s']);
        end
        function Buffer = GetBufferUpdate(obj,filterstring)
            %%
            tic
            obj.ResetBufferLog();
            [Buffer] = obj.GetLogFromBuffer(filterstring);
            if not(isempty(Buffer))
               if obj.Disp == true
                    disp(Buffer)
               end
               obj.Buffer = Buffer;
            end  
            string = {  ['Time to update: ',num2str(toc)]; ...
                        ['Frame rate: ',num2str(1/toc)]};
            set(obj.handles.text,'String',string)
        end
        function DisplayLogRT(obj,filterstring)
           %%
           while true
                Buffer = obj.GetBufferUpdate(filterstring);
           end           
        end
        function [Buffer] = GetLogFromBuffer(obj,filter_string)
             %%
             % logcat gets log continuosly on the screen 
             %     -d print and exit
             %     -s filter commands with string. 
             %
             % logserver - copy video into andriod
             
             if isempty(filter_string)
                [error, Buffer] = system(['adb shell logcat -d']);
             else
                [error, Buffer] = system(['adb shell logcat -d -s ',filter_string]);
             end
             Buffer = strrep(Buffer,'--------- beginning of /dev/log/main','');
             Buffer = strrep(Buffer,'--------- beginning of /dev/log/system','');
             Buffer = strrep(Buffer,' ','');
             if or(size(Buffer,2) == 2,size(Buffer,2) == 4)
                 Buffer = [];
             end
        end
        function ResetBufferLog(obj)
            %%
            system(['adb shell logcat -c']);
        end
    end
end