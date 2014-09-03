classdef ADB_Images < handle
    % Transfer the latest capture image from the phone to the location you desire
    properties (SetObservable = true)
        FileName = 'filename.jpg';
        ImageDatabase = 'Q:\bryant\isp_tools\cambs_matlab\Automated_CT_func\Images\';
        Location = '/sdcard/DCIM/Camera/'
        Status
        FileList = {'';''}
        ADB_filesystem_OBJ
    end
    properties (SetObservable = true, Hidden = true)
        Location_LUT = {'/sdcard/DCIM/Camera/'; ... %imx175
                        '/sdcard/DCIM/100MEDIA/'};  %HTC
        Project_LUT = { 'HTC'; ...
                        'Baffin'};
    end
    methods
        function Example(obj)
            %% HTC
            close all
            clear classes
            
            %%
            obj = ADB_Images('Location','/sdcard/DCIM/100MEDIA/')
            ObjectInspector(obj)
            
            %% Baffin
            obj = ADB_Images( 'Location','/sdcard/DCIM/Camera/');
            ObjectInspector(obj);            
        end
        function RUN(obj)
            %%
            obj.Status = 'running';
            filenames = obj.getPhoneFileNames();
            obj.getImage(filenames{end});
            obj.ADB_filesystem_OBJ.rm([obj.Location,filenames{end}]);
            obj.FileList = obj.getPhoneFileNames();
            obj.Status = 'complete';
        end
        function UpdateFileList(obj)
            obj.FileList = obj.getPhoneFileNames();
        end
    end
    methods (Hidden = true)
        function getImage(obj,filenameOnPhone)
            %%
            out = obj.ADB_filesystem_OBJ.pull([obj.Location,filenameOnPhone],[obj.ImageDatabase,obj.FileName]);
        end
        function deleteFilesFromPhone(obj,filenames)
           %%
           obj.Status = 'deleting files on Phone';
           x = size(filenames,1);
           for i = 1:x
                obj.ADB_filesystem_OBJ.rm([obj.Location,filenames{i}]);
           end            
        end
        function obj = ADB_Images(varargin)
            %%
            x = size(varargin,2);
            for i  = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            obj.ADB_filesystem_OBJ = ADB_filesystem;
            obj.FileList = obj.getPhoneFileNames();  
            obj.Status = 'ready';
        end
        function filenames = getPhoneFileNames(obj)
            filenames = obj.ADB_filesystem_OBJ.ls(obj.Location);
        end           
    end
end