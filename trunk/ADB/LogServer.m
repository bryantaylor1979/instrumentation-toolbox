classdef LogServer <    handle 
    properties %User definable       
    end
    properties (Hidden = true)
        runOnInt = true;
        selectedCat = [];
        cat = { 'general'; ...  
                'codecs'; ...    
                'filesystem'; ...    
                'vmcs'; ...    
                'dispman'; ...    
                'camplus'; ...    
                'apps'; ...    
                'clockman'; ...   
                'vcos'; ...    
                'image-pool'; ...    
                'hdmi'; ...    
                'minimal'; ...    
                'tuner'; ...    
                'vchi'; ...    
                'matlab'; ...    
                'user'};
        log = true
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            
            %% run automatic mode
            obj = LogServer;
            ObjectInspector(obj)
            ObjectInspector(obj.handles.ADB_Shell)
            
            %% insert cats
            objLog = LogServer('selectedCat',{'vcos','tuner'});
            
            %%
            objLog.SendLogServer2LogCat
            
            %% display log cat help
            obj = LogServer('runOnInt',false);
            obj.Help;
            
            %%
            obj.ADB_Command('adb remount')
            obj.ADB_Command('adb push SamsungCamera.apk SamsungCamera.apk')
        end
        function obj = LogServer(varargin)
            %
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.handles.ADB_Shell = ADB_command_logger;
            
            if obj.runOnInt == true
                obj.handles.ADB_Shell.CheckConnection();
                if isempty(obj.selectedCat)
                    obj.selectedCat = obj.GetUserList(obj.cat);
                end

                obj.OnlyEnableCat(obj.selectedCat);
                obj.SendLogServer2LogCat;
            end
            
        end        
        function DisableCat(obj,cat)
            obj.handles.ADB_Shell.ADB_Command(['logserver -d ',cat]);
        end
        function EnableCat(obj,cat)  
            obj.handles.ADB_Shell.ADB_Command(['logserver -e ',cat]);
        end
        function OnlyEnableCat(obj,selectedCat)
            %%
            x = size(selectedCat,1);
            obj.DisableCat('all');
            for i = 1:x
                Cat = obj.selectedCat{i};
                obj.EnableCat(Cat);
            end
        end
        function Help(obj)
            obj.handles.ADB_Shell.ADBCommand('adb shell logserver help');
        end
    end
    methods (Hidden = true) % support functions
        function SendLogServer2LogCat(obj)
            % http://confluence/display/MobileMultimedia/Techniques+that+I+use+to+debug+VideoCore
            % Capture VideoCore logging with logserver.
            % The logging goes to the standard Android logcat.
            obj.handles.ADB_Shell.ADB_Command(['logserver -s -D']);            
        end
        function cat = GetUserList(obj,cat)
    
            %% User Prompt
            [s,v] = listdlg('PromptString','Select a file:',...
                            'SelectionMode','multiple',...
                            'ListString',cat);
            cat = cat(s);
        end
    end
end