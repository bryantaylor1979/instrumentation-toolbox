classdef LiveTuning <   handle & ...
                        ADB_filesystem
    properties
    end
    methods
        function Example(obj)
           %%
           close all 
           clear classes
           obj = LiveTuning
           
           %%
           obj.makeWriteable;
           obj.pull('/system/etc/camera_info.ini');
           
           %% add "camera_tuning_file  = /mnt/sdcard/camera.txt" to the [Camera:0] section')
           [keys] = inifile('camera_info.ini','readall');
           
           %%
           key = {'camera:0','','camera_tuning_file','/mnt/sdcard/camera.txt'};   
           inifile('camera_info.ini','write',[keys;key],'plain');
           
           %%
           obj.push('camera_info.ini','/system/etc/');
           
           %%
           obj.push('camera.txt','/mnt/sdcard/');
        end
    end
end