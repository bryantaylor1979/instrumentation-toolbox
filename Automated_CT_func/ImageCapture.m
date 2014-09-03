classdef ImageCapture < handle
    properties (SetObservable = true)
        ImageDatabase = 'Q:\bryant\isp_tools\cambs_matlab\Automated_CT_func\Images\imx175_LE7\';
        Location = '/sdcard/DCIM/Camera/';
        ImageName = '2000K_LE7.jpg';
        ADB_Images_OBJ
        CamDriver_OBJ
    end
    properties (Hidden = true, SetObservable = true)
        Location_LUT
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = ImageCapture();
            ObjectInspector(obj)  
        end
        function RUN(obj)
            %%
            obj.TakeOneSnapShot();           
        end
    end
    methods (Hidden = true)
        function TakeOneSnapShot(obj)
            obj.CamDriver_OBJ.Capture();
            obj.ADB_Images_OBJ.FileName = obj.ImageName;
            obj.ADB_Images_OBJ.ImageDatabase = obj.ImageDatabase;
            pause(4);
            obj.ADB_Images_OBJ.RUN();  
        end
        function obj = ImageCapture()
            obj.ADB_Images_OBJ = ADB_Images('Location',  obj.Location);
            obj.Location_LUT = obj.ADB_Images_OBJ.Location_LUT;
            obj.CamDriver_OBJ = CamDriver();
            obj.CamDriver_OBJ.EnableRaws();
            obj.CamDriver_OBJ.StartActivity('android.media.action.STILL_IMAGE_CAMERA') %other modes not known.
        end
    end
end