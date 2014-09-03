classdef IBIS_auto_capture < handle
    properties (SetObservable = true)
        Project = 'HTC';
        Type = 'ibis_flat_rev4';
        CT = [2000:500:9000];
        Lum = [500,1000,4000];
        ADB_Images_OBJ
        LightBoxTest_OBJ
        CamDriver_OBJ
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = IBIS_auto_capture();
            ObjectInspector(obj)
            
            %%
            obj.TakeOneSnapShot(8000,500);
            %%
            obj.TakeOneSnapShot(3000,4000);
        end
        function RUN(obj)
            %%
            obj.ADB_Images_OBJ.Project = obj.Project;
            obj.ADB_Images_OBJ.Type = obj.Type;
            x = size(obj.CT,2);
            y = size(obj.Lum,2);
            for i = 1:x
                for j = 1:y
                    obj.TakeOneSnapShot(obj.CT(i),obj.Lum(j));
                end
            end            
        end
    end
    methods (Hidden = true)
        function TakeOneSnapShot(obj,CT,Lum)
            obj.LightBoxTest_OBJ.CT = CT;
            obj.LightBoxTest_OBJ.Lum = Lum;
            obj.LightBoxTest_OBJ.RUN();
            pause(5);
            obj.CamDriver_OBJ.Capture();
            pause(1);
            FileCopied = false;
            while FileCopied == false
                disp(['file copied', num2str(FileCopied)])
                obj.ADB_Images_OBJ.FileName = [num2str(CT),'K_',num2str(Lum),'Lum.jpg'];
                obj.ADB_Images_OBJ.RUN();
                FileCopied = obj.ADB_Images_OBJ.FileCopied;
                obj.ADB_Images_OBJ.FileCopied = false;
            end
            FileCopied = false;   
        end
        function obj = IBIS_auto_capture()
            obj.ADB_Images_OBJ = ADB_Images(    'Location', ...
                                                '/sdcard/DCIM/100MEDIA/');
            obj.LightBoxTest_OBJ = LightBoxTest;
            obj.CamDriver_OBJ = CamDriver(      'CaptureLoc', ...
                                                [330,900] );
            obj.CamDriver_OBJ.EnableRaws();
        end
    end
end