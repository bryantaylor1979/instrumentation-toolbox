classdef AutoCT_func < handle
    properties (SetObservable = true)
        InstallDir = 'C:\sourcecode\matlab\Programs\Automated_CT_func\';
        Pause_CT2Capture = 3; %pause between captures in seconds
        BlackLevel = 16;
        Status
        Progress
        Drv_OBJ
        LightBox_OBJ
        ADB_filesystem_OBJ
        RawExtract_OBJ
        EnergyCalc_OBJ
        CT_func_DATASET = dataset([])
        ImageIO
    end
    properties (Hidden = true)
        RedNorm
        CT
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = AutoCT_func
           ObjectInspector(obj)
        end
        function RUN(obj)
            %%
            rmdir([obj.InstallDir,'Images']);
            obj.Drv_OBJ.EnableRaws();
            obj.Drv_OBJ.CloseCameraApp();
            pause(1)
            obj.Drv_OBJ.StartCameraApp();
            obj.CopyImages();
            pause(4);
            filenames = obj.GetFileNames();
            obj.DeleteFilesFromPC(filenames);
            obj.DeleteFilesFromPhone(filenames);
           
            %%
            obj.Status = 'Capturing images';
            
            %%
            ColourTemps = [ 2500, ...
                            2900, ...
                            3200, ...
                            5100, ...
                            5600, ...
                            6500, ...
                            7500, ...
                            8500, ...
                            10000, ...
                            10000]; %Two 10000 to fix a bug.
                        
                        %%
            obj.CaptureImages(ColourTemps);
            
            %%
            obj.CopyImages();
            filenames = obj.GetFileNames();
            obj.DeleteFilesFromPhone(filenames);
            
            %%
            obj.RenameImages(filenames,ColourTemps);
            
            %% extract raws
            obj.Status = 'Extract raws';
            filenames = obj.GetFileNames();
            obj.RawExtract_OBJ.filename = filenames;
            obj.RawExtract_OBJ.pathname = [obj.InstallDir,'Images'];
            obj.RawExtract_OBJ.RUN();       
            
            %%
            obj.ImageIO.Path = [obj.InstallDir,'Images'];
            obj.ImageIO.ImageType = '.raw';
            obj.ImageIO.RUN();
            filenames = obj.ImageIO.names;                       
            
            %%
            x = max(size(ColourTemps));
            clear filenames
            for i = 1:x
                filename = ['CT-',num2str(ColourTemps(i)),'.raw']
                RedNorm(i) = obj.RedNormCalc(filename);
                filenames{i} = filename;
                CT(i) = ColourTemps(i);
            end
            obj.Status = 'Complete';
            for i = 1:x
                disp([filenames{i},' - ', num2str(RedNorm(i))])
            end
            obj.RedNorm = RedNorm;
            obj.CT = CT;
            
            %%
            obj.CT_func_DATASET = dataset(   ...
                                            {rot90(obj.CT,3),'CT'}, ...
                                            {rot90(obj.RedNorm,3),'RedNorm'});
             
            %% plot
            figure, plot(CT,RedNorm);      
        end
    end
    methods (Hidden = true)
        function obj = AutoCT_func
            %%
            obj.Drv_OBJ = CamDriver;
            obj.LightBox_OBJ = LightBoxTest;
            obj.ADB_filesystem_OBJ = ADB_filesystem;
            obj.RawExtract_OBJ = extract_raw_Wrapper;
            obj.EnergyCalc_OBJ = EnergyCalc;
            obj.ImageIO = ImageIO;
        end
        function CopyImages(obj)         
            %%
            obj.Status = 'Copying files from phone';
            obj.ADB_filesystem_OBJ.pull('/sdcard/DCIM/Camera',[obj.InstallDir,'Images']);
        end
        function DeleteFilesFromPC(obj,filenames)
            obj.Status = 'deleting files on PC';
           x = size(filenames,1);
           for i = 1:x
               delete(fullfile([obj.InstallDir,'Images'],filenames{i}));
           end            
        end
        function RenameImages(obj,filenames,ColourTemps)
            %%
            ColourTemps = rot90(ColourTemps,2);
            x = size(filenames,1);
            [path,file,type]= fileparts(filenames{1});
            for i = 1:x-1
                try
                filename = ['CT-',num2str(ColourTemps(i)),type]
                movefile(   fullfile([obj.InstallDir,'Images'],filenames{i}), ...
                            fullfile([obj.InstallDir,'Images'],filename));
                end
            end
        end
        function CaptureImages(obj,ColourTemps)
            x = size(ColourTemps,2);
            for i = 1:x
                obj.Progress = [num2str(round(i/x*100)),'%'];
                obj.LightBox_OBJ.ColorTemp = num2str(ColourTemps(i));
                obj.LightBox_OBJ.RUN();
                pause(obj.Pause_CT2Capture);
                obj.Drv_OBJ.Capture;
                pause(obj.Pause_CT2Capture);
            end
        end
        function [RedNorm,Energy,Gains] = RedNormCalc(obj,filename)
            %%
            obj.EnergyCalc_OBJ.FileName = fullfile([obj.InstallDir,'Images'],filename);
            obj.EnergyCalc_OBJ.RUN()
            obj.EnergyCalc_OBJ.ChannelOffsets.GreenOffset = obj.BlackLevel;
            obj.EnergyCalc_OBJ.ChannelOffsets.RedOffset = obj.BlackLevel;
            obj.EnergyCalc_OBJ.ChannelOffsets.BlueOffset = obj.BlackLevel;
            
            RedEnergy = obj.EnergyCalc_OBJ.RedEnergy;
            BlueEnergy = obj.EnergyCalc_OBJ.BlueEnergy;
            GreenEnergy = obj.EnergyCalc_OBJ.GreenEnergy;
            Energy = [RedEnergy,GreenEnergy,BlueEnergy];
            Gains = max(Energy)./Energy;
            RedNorm = Gains(1)/sum(Gains);      
        end
    end
end
    