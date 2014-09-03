classdef LogCat <       handle & ...
                        ADB_filesystem
    properties (SetObservable = true)
        Buffer
        ADB_filesysem_OBJ = ADB_filesystem;
        ADB_Shell = ADB_command_logger;
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = LogCat
            ObjectInspector(obj)
            
            %% reset buffer 
            obj.ResetBuffer();
            
            %%
            ObjectInspector(obj)
            
            %% 1. filter on logserver string
            %  2. Dump the log to the command window
            obj.Buffer = obj.DumpLog2CommandWindow('logserver','')
            
            %%
            obj.Buffer = obj.DumpLog2CommandWindow('','')
            
            %%
            filename = 'C:\sourcecode\matlab\Programs\CAF\Logs\log.txt';
            obj.Buffer = obj.DumpLog2CommandWindow('logserver',filename);
            
            %%
            filename = 'C:\sourcecode\matlab\Programs\ADBs\log.txt';
            obj.Buffer = obj.DumpLog2CommandWindow('',filename);
            
            %%
            obj = LogCat
            
            %%
            obj.ResetBuffer()
            obj.ContLog2CommandWindow('logserver')

            %%
            
        end
        function ResetBuffer(obj)
            %% RESET BUFFER
            obj.ADB_Shell.ADB_Command_Shell('logcat -c');   
        end
        function LogCatHelp(obj)
            %%
            obj.ADB_Shell.ADB_Command_Shell('logcat -h -d');
        end
        function ContLog2CommandWindow(obj,filterString)
            disp('ehhlo')
            string = 'logcat';
            %filter string
            if not(isempty(filterString))
                string = [string,' -s ',filterString];
            end
            [~,Buffer] = obj.ADB_Shell.ADB_Command_Shell(string);
        end
        function Buffer = DumpLog2CommandWindow(obj,filterString,filename)
            % this filter in the string "logserver"
            %  system('adb shell logcat -d')
            fileloggingMethod = 'adb'; %win or adb
            string = 'logcat -d';
            fileName_log_phone = '/storage/sdcard0/log.txt';
            

            obj.rm(fileName_log_phone);
            % filename adb
            if not(isempty(filename))
                fid = fopen(filename,'w');
                fclose(fid);
                if strcmpi(fileloggingMethod,'adb')
                    string = [string,' -f ',fileName_log_phone];
                end
            end
            
            %filter string
            if not(isempty(filterString))
                string = [string,' -s ',filterString];
            end
            
            % filename win
            if not(isempty(filename))
                if strcmpi(fileloggingMethod,'win')
                    string = [string,' < ',filename];
                end
            end
            
            % filename adb
            [~,Buffer] = obj.ADB_Command(string);   
            
            if not(isempty(filename))
                if strcmpi(fileloggingMethod,'adb')
                    obj.pull(fileName_log_phone,filename)
                end
            end
        end
    end
end