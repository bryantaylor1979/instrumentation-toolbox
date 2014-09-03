classdef CamDriver <    handle
    properties (SetObservable = true)
        Project = 'Baffin';
        Path = 'C:\sourcecode\matlab\Programs\ADB\dpf\';
        FileName = 'ov5693_settings_v410.txt';
        CaptureLoc = [250,700]; %k-touch -> 250, 700 
                                %baffin ->  240, 720
        CameraAppIconLoc = [200,420]    %k-touch    200,420
                                        %HTC        420,850
                                        %HTC rev2   330,900
        ADB_OBJ
        ADB_FS
    end
    properties (SetObservable = true, Hidden = true)
        Project_LUT =  {    'Baffin'; ...
                            'HTC'};
    end
    methods 
       function Example(obj)
           %%
           close all
           clear classes
           obj = CamDriver
           ObjectInspector(obj)
           
           %% Open camera in stills mode#

           
           
           %%
           obj.SelectSceneMode(1)          
           
           %%
           while true
               for i = 1:3
                   obj.SelectSceneMode(i)
                   obj.CaptureNframes(10)
                   pause(1)
               end
           end
           
           %% Select Scene Mode
           obj.Tap(240,720)
           
           %%
           Delta = 300;
%            obj.Tap(190,100)
           obj.Swipe(190,460,190,0)
           
           %%
           obj.RecordEvent()
           %%
           obj.SendEvent()
           
           %%
           obj.ADB_Command('input swipe')
           
           %%
           obj.ADB_Command('su -- getevent -lt')               
        end
       function Capture(obj)
            %%
            obj.Tap(obj.CaptureLoc(1),obj.CaptureLoc(2));
       end
       function CloseCameraApp(obj)
           obj.ADB_OBJ.ADB_Command_Shell('killall mediaserver');
           pause(1)
%            obj.OK();
       end
       function StartCameraApp(obj)
           disp(obj.Project)
           if strcmpi(obj.Project,'baffin')
               obj.StartActivity('android.media.action.STILL_IMAGE_CAMERA') %other modes not known.
           else
               obj.Tap(obj.CameraAppIconLoc(1),obj.CameraAppIconLoc(2));
           end
       end
       function EnableRaws(obj)
           % or adb shell vcdbg set ca_sw_stage_disables 0
           if strcmpi(obj.Project,'baffin')
                obj.ADB_OBJ.ADB_Command_Shell('adb shell vcdbg set ca_sw_stage_disables 0');
           else
                obj.ADB_OBJ.ADB_Command_Shell('setprop debug.brcm.isp.dump_raw true');
           end
       end
       function GetLog(obj)
           %%
           obj.ADB_OBJ.ADB_Command_Shell('logcat > /data/isp/mytest_log.txt')
       end
       function PushDPF(obj)
           %%
           filename_PC = [obj.Path,obj.FileName];
           directory_Phone = '/data/isp/'
           obj.ADB_FS.push(filename_PC,directory_Phone);
       end
       function GetImage(obj)
           
       end
    end
    methods (Hidden = true)
        function obj = CamDriver(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.ADB_OBJ = ADB_command_logger;
            obj.ADB_OBJ.CheckConnection;
            obj.ADB_FS = ADB_filesystem();
            
            if strcmpi(obj.Project,'baffin')
                obj.CaptureLoc = [240, 720];
            elseif strcmpi(obj.Project,'k-touch')
                obj.CaptureLoc = [250, 700];
            end
        end
        function OK(obj)
           %%
           obj.Tap(100,420);
        end
        function CaptureNframes(obj,Number)
           for i = 1:Number
            obj.Capture();
           end
        end
        function SelectSceneMode(obj,Number)
           obj.PressSceneModes;
           pause(1)
           obj.PressSceneNumber(Number);
           obj.TapImage()            
        end
        function TapImage(obj)
            %%
             obj.Tap(650,400)
        end
        function StartActivity(obj,Mode)
            obj.ADB_OBJ.ADB_Command_Shell(['am start -a ',Mode])
        end
        function PressSceneModes(obj)
           obj.Tap(40,340) 
        end
        function PressSceneNumber(obj,Number)
            switch Number
                case 1
                    obj.Tap(190,100)
                case 2
                    obj.Tap(190,290)
                case 3
                    obj.Tap(190,430)
                otherwise
            end
        end
    end
    methods (Hidden = true) % Low level commands
        function RecordEvent(obj)
            obj.ADB_Command('getevent') 
        end
        function SendEvent(obj)
            obj.ADB_Command('sendevent') 
        end
        function Tap(obj,X,Y)
            string = repmat(['input tap ',num2str(X),' ',num2str(Y)],1,1);
            obj.ADB_OBJ.ADB_Command_Shell(string);
        end
        function Swipe(obj,Xs,Ys,Xe,Ye)
            string = ['input swipe ',num2str(Xs),' ',num2str(Ys),' ',num2str(Xe),' ',num2str(Ye)];
            obj.ADB_Command_Shell(string);
        end
    end
end
