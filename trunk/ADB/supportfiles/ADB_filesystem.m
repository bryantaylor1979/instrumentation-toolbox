classdef ADB_filesystem <   handle
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = ADB_filesystem;
            
            %%
            ObjectInspector(obj)
            
            %% Push APK manual from CTT tool to phone
            filename_PC = 'C:\Program Files\Broadcom Corporation\CameraTuningTool\CaptureControl.apk';
            directory_Phone = '/system/app'
            obj.remount
            obj.push(filename_PC,directory_Phone)
        end
        function makeWriteable(obj)
            obj.handles.ADB_Shell.ADB_Command('mount -o remount,rw /system');
        end
        function push(obj,filename_PC,directory_Phone)
            PWD = pwd;
            [path,file,ext] = fileparts(filename_PC)
            cd(path)
            dos(['adb push ',[file,ext],' ',directory_Phone]);
            cd(PWD)
        end
        function out = pull(varargin)
            %dos(['adb pull /storage/sdcard0/log.txt ',filename])
            obj = varargin{1};
            fileName_Phone = varargin{2};
            try
                filename_PC = varargin{3};
                [error,string] = dos(['adb pull ',fileName_Phone,' ',filename_PC]);
            catch
                [error,string] = dos(['adb pull ',fileName_Phone]);
            end  
            %%
            p = findstr(string,'list...');
            q = findstr(string,'files pulled');
            out.filesPulled = str2num(string(p+7:q-1));
            
            p = findstr(string,'pulled.');
            q = findstr(string,'files skipped');
            out.filesSkipped = str2num(string(p+7:q-1));
        end
        function remount(obj)
            obj.handles.ADB_Shell.ADB_Command('remount');
        end
        function rm(obj,filename)
            string = ['adb shell "rm ',filename,'"']
            dos(string)
        end
        function getfilenamelist(obj)
            %%
            cd('\Computer\BCM28145_LITTLE_CAPRI_TK')
            
            %%
            obj.remount
            dos(['filenames.bat']);
            
            %%
            dos('adb shell')
            
            %%
            unix('adb shell cd ls')
            
            %%
            
            %%
            
            
%             obj.handles.ADB_Shell.ADB_Command_Shell('ls');
%             obj.handles.ADB_Shell.ADB_Command_Shell('ls');
        end
    end
    methods (Hidden = true)
        function obj = ADB_filesystem()
            obj.handles.ADB_Shell = ADB_command_logger;
        end        
    end
end