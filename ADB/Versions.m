classdef Versions <     handle & ...
                        ADB_command_logger
    properties
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %% run automatic mode
            obj = Versions;
            
            %% insert cats  
            [version,built,buildmachine] = obj.GetVCBuildInfo();
        end
        function [version,built,buildmachine] = GetVCBuildInfo(obj)
            [~, Buffer] = obj.ADB_Command('vcos-version');
            [version,built,buildmachine] = obj.VideocoreDecode(Buffer);           
        end
        function [version,built,buildmachine] = VideocoreDecode(obj,Buffer)
            %%
            n = findstr(Buffer,'Videocore Version Info');
            VideoCoreStr = Buffer(n:end);
            
            % version
            n = findstr(VideoCoreStr,'version');
            version = VideoCoreStr(n+8:end);
            
            % built
            n = findstr(VideoCoreStr,'Built');
            p = findstr(VideoCoreStr,'Copyright');
            builtinfo = VideoCoreStr(n+6:p-1);
            p = findstr(builtinfo,'on');
            built = builtinfo(1:p-2);
            buildmachine = builtinfo(p+3:end);            
        end
    end
end