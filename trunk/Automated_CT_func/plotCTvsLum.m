classdef plotCTvsLum < handle
    properties (SetObservable = true)
        Customer = 'HTC';
        Type = 'ibis_flat_rev2';
        CT = [2000:500:9000];
        Lum = [500,1000,4000];
        ImageDatabase = 'C:\sourcecode\matlab\Programs\Automated_CT_func\Images\';
        imageIO_OBJ
    end
    properties (Hidden = true, SetObservable = true)
        Type_LUT = {'ibis_flat_rev4'; ...
                    'ibis_flat_rev3'; ...
                    'ibis_flat_rev2'; ...
                    'ibis_flat_rev1'; ...
                    'ibis_flat'; ...
                    'ibis_flat_vx'};
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = plotCTvsLum
           ObjectInspector(obj)
           %%
           obj.RUN()
        end
        function RUN(obj)
            %%
            Path = fullfile(obj.ImageDatabase,obj.Customer,obj.Type)
           x = size(obj.CT,2);
           y = size(obj.Lum,2);
           h = figure;
           position = get(h,'position');
           position(3) = 984;
           position(4) = 214;
           set(h,'position',position);
           
           Positions = [0.64,0.44,0.24]
           count = 1;
           for j = 1:y
                for i = 1:x
                    CT = obj.CT(i);
                    Lum = obj.Lum(j);
                    filename = [num2str(CT),'K_',num2str(Lum),'Lum.jpg'];
                    img = imread(fullfile(Path,filename));
                    h = subplot(y,x,count);
                    imagesc(img);
                    set(h,'XTickLabel','')
                    set(h,'XTick',[])
                    set(h,'YTickLabel','')
                    set(h,'YTick',[])
                    Position = get(h,'Position');
                    Position(4) = 0.14;
                    Position(2) = Positions(j);
                    set(h,'Position',Position);
                    if j == 1
                        title(num2str(CT))
                    end
                    if i == 1
                       ylabel(num2str(Lum)) 
                    end
                    count = count + 1;
                end
           end
        end
    end
    methods (Hidden = true)
        function  obj = plotCTvsLum()
        end
    end
end