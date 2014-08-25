classdef LightBoxTest < handle
    % LIGHTBOXTEST
    % ============
    %
    % SerialNum = '09IPL0017'; THIS NEEDS TO BE CHANGE ON LINE 21 FOR YOUR
    % DEVICE. 
    %
    % Description
    % This is a simple function which used to control the brightness and
    % colour tempreture of the LED color viewer. 
    %
    % Properties
    % Enable:       switch on/off 
    % ColorTemp:    pulldown a select your CT (You must press RUN to apply)
    % Lum:          Brightness Value (This is not LUX, then press RUN) 
    % AppliedColourTemp:  The value active on the colour viewer (Read only) 
    % Lamps_OBJ:    This is the setlamp class (You can view the status) 
    %
    % Sub-Componets: SetLamps
    properties (SetObservable = true)
        INPUTS
        COM_PORT = 'COM9'; %10 Right port 9 left port
        SerialNum = '09IPL0018';
        Enable = 'TRUE';
        CT = 5100;
        Lum = 4000; %LUX
        Enable_Lum = true;
        PopupEnable = true;
        STATUS
        Connected
        ErrorMessage
        CompanyName
        Model
        ManufacturingDate
        Location
        Measurement_x
        Measurement_y
        DATASET_LUT = dataset([])
        AppliedColourTemp
        Lamps_OBJ
    end
    properties (Hidden = true, SetObservable = true)
        ColorTemp = '5100';
        ColorTemp_LUT = {	'2500'; ...    
                            '2900'; ...
                            '3200'; ...
                            '5100'; ...
                            '5600'; ...
                            '6500'; ...
                            '7500'; ...
                            '8500'; ...
                            '10000' };
        Enable_LUT = {  'TRUE'; ...
                        'FALSE'};
        SerialNum_LUT =  {   '09IPL0017'; ...
                             '09IPL0018'; ...
                             '10IVL0058'; ...
                             '11IVL0035'; ...
                             '13IVL0012'};
    end
    methods
        function Example(obj)
            %%
            close all
            clear all
            clear classes
            
            %%
            obj = LightBoxTest()
            ObjectInspector(obj)    
            
            %%
            CT_Value = 9999
            CT_Value = 10000 
            [Lamps,Brightness,x,y] = obj.GetLampTable_Advanced(CT_Value,obj.DATASET_LUT);
        end
        function RUN(obj)
            obj.DATASET_LUT = obj.GetTable(obj.SerialNum);
            obj.AppliedColourTemp = obj.CT;
            obj.SetLightBoxTemperature(obj.CT, obj.Lum);     % Set LightBox luminance            
        end
    end
    methods (Hidden = true)
        function [Lamps,Brightness,x,y] = GetLampTable_Advanced(obj,CT_Value,DATASET)
            CT_Values = cellfun(@str2num,obj.ColorTemp_LUT);
            if CT_Values(1) < CT_Value
                if CT_Values(end) > CT_Value
                    n = find(CT_Values > CT_Value);
                    CT1 = CT_Values(n(1)-1);
                    CT2 = CT_Values(n(1));

                    [Lamps1,Brightness1,x,y] = obj.GetLampTable(CT1, obj.DATASET_LUT);
                    [Lamps2,Brightness2,x,y] = obj.GetLampTable(CT2, obj.DATASET_LUT);

                    Diff = CT_Value - CT1;
                    TotalDiff = CT2 - CT1;
                    Percentage = Diff/TotalDiff;

                    Lamps(1) = round((Lamps2(1) - Lamps1(1))*Percentage + Lamps1(1));
                    Lamps(2) = round((Lamps2(2) - Lamps1(2))*Percentage + Lamps1(2));
                    Lamps(3) = round((Lamps2(3) - Lamps1(3))*Percentage + Lamps1(3));
                    Lamps(4) = round((Lamps2(4) - Lamps1(4))*Percentage + Lamps1(4));
                    Brightness(4) = round((Brightness2 - Brightness1)*Percentage + Brightness1);
                else
                warning('The value has been clipped')
                [Lamps,Brightness,x,y] = obj.GetLampTable(CT_Values(end), obj.DATASET_LUT);                     
                end
            else
               warning('The value has been clipped')
               [Lamps,Brightness,x,y] = obj.GetLampTable(CT_Values(1), obj.DATASET_LUT); 
            end              
        end
        function [Lamps,Brightness,x,y] = GetLampTable(obj,CT,DATASET)
            %%
            n = find(DATASET.CT == CT);
            Lamps = [DATASET.Lamp1(n),DATASET.Lamp2(n),DATASET.Lamp3(n),DATASET.Lamp4(n)];
            Brightness = DATASET.Brightness(n);
            x = DATASET.x(n);
            y = DATASET.y(n);
        end
        function ResultStatus = SetLightBoxTemperature( obj, colTemp, luminosity)
            %1 - success
            %0 - disconnected
            %-1 - not valid temp
            % "Avis" light lource basic set (provided with LED Color viewer)
            %instrreset; - requres packdge
            [Lamps,Brightness,x,y] = obj.GetLampTable_Advanced(colTemp, obj.DATASET_LUT);
            obj.Measurement_x = x;
            obj.Measurement_y = y;
            
            
            if obj.Enable_Lum == true
                luminosityFactor = double(luminosity) / max(Brightness);   % The factor is 1 for luminosity = 4000 Lux
                Lamps = round(Lamps * luminosityFactor);
            end
            
            if not(strcmpi(obj.Enable,'TRUE'))
                Lamps = [0,0,0,0];
            end     
            
            obj.Lamps_OBJ.Lamp1 = Lamps(1);
            obj.Lamps_OBJ.Lamp2 = Lamps(2);
            obj.Lamps_OBJ.Lamp3 = Lamps(3);
            obj.Lamps_OBJ.Lamp4 = Lamps(4);
            
            obj.Lamps_OBJ.PopupEnable = obj.PopupEnable;
            obj.Lamps_OBJ.RUN();
        end
        function obj = LightBoxTest(varargin) 
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.SerialNumUpdate();
            obj.addlistener('SerialNum','PostSet',@obj.SerialNumUpdate);
            obj.Lamps_OBJ = SetLamps(   'COM_PORT',     obj.COM_PORT, ...
                                        'PopupEnable',  obj.PopupEnable);
            obj.Connected = obj.Lamps_OBJ.Connected;
            obj.ErrorMessage = obj.Lamps_OBJ.ErrorMessage;
        end
        function SerialNumUpdate(varargin)
           obj = varargin{1};
           obj.DATASET_LUT = obj.GetTable(obj.SerialNum);
           DATA = num2cell(obj.DATASET_LUT.CT);
           obj.ColorTemp_LUT = cellfun(@num2str,DATA,'UniformOutput',false);
           obj.ColorTemp = obj.ColorTemp_LUT{1};
           
        end
        function DATASET_LUT = GetTable(obj,SerialNum)
            switch SerialNum
                  case '11IVL0035' % Sunnyvale
                    %%       CT     Lp1     Lp2     Lp3    Lp4  Brightness(Lux)  x       y
                    TABLE = [2300,  320,    153,     0,     0,      4000,        0.500,  0.421; ...
                             2500,  278,    138,    80,     0,      4000,        0.479,  0.416; ...
                             2900,    0,    311,    74,     0,      4000,        0.445,  0.409; ...  
                             3200,   61,    250,   109,    42,      4000,        0.426,  0.401; ...
                             4100,    0,    138,   218,     0,      4000,        0.382,  0.396; ...
                             5200,   22,     66,   257,    71,      4000,        0.341,  0.370; ...     
                             5600,    0,      0,   275,    77,      4000,        0.330,  0.362; ...         
                             6500,    0,      0,   237,   117,      4000,        0.312,  0.333; ...
                             7500,    0,      0,   208,   149,      4000,        0.300,  0.313; ...  
                             8500,    0,      0,   185,   172,      4000,        0.291,  0.299; ...
                             9500,    0,     30,   167,   194,      4000,        0.285,  0.289; ...
                            10000,    0,      0,   158,   203,      4000,        0.282,  0.284];    
                        
                    obj.CompanyName = 'AVIS';
                    obj.Location = 'Sunnyvale';
                    obj.Model = 'IPL-L150';
                    obj.ManufacturingDate = '4th Oct 2011';
                    
                 case '09IPL0018' % Cambs
                    %%       CT     Lp1     Lp2     Lp3    Lp4  Brightness(Lux)  x       y
                    TABLE = [2400,  290,    300,     0,     0,      3700,        0.488,  0.418; ...
                             2500,  215,    365,     0,     0,      3800,        0.477,  0.415; ...
                             2900,   90,    400,    73,     0,      3700,        0.440,  0.403; ...
                             3100,    0,    475,    73,    11,      3700,        0.428,  0.400; ...
                             4100,    0,    207,   251,     0,      3700,        0.376,  0.375; ...
                             5100,    0,     38,   400,     0,      3800,        0.340,  0.360; ...
                             5600,    0,      0,   380,    40,      3700,        0.330,  0.346; ...
                             6500,    0,      0,   320,   100,      3800,        0.314,  0.319; ...
                             7500,    0,      0,   270,   143,      3700,        0.302,  0.301; ...
                             8500,    0,      0,   235,   180,      3700,        0.294,  0.288; ...
                             9500,    0,      0,   207,   200,      3800,        0.289,  0.279; ...
                            10000,    0,      0,   190,   220,      3700,        0.286,  0.274];      
                    obj.CompanyName = 'IPIS';
                    obj.Location = 'Cambs';
                    obj.Model = 'IPL-L100';
                    obj.ManufacturingDate = '27th May 2009';
                    
                case '09IPL0017' % Suwon
                    %%       CT     Lp1     Lp2     Lp3    Lp4  Brightness(Lux)  x       y
                    TABLE = [2400,  245,    275,     0,     0,      3700,        0.486,  0.415; ...
                             2500,  175,    365,     0,     0,      3800,        0.473,  0.412; ...
                             2900,  150,    220,   100,     0,      3700,        0.440,  0.393; ...
                             3100,    0,    470,    40,     0,      3700,        0.428,  0.400; ...
                             4100,    0,    210,   210,     0,      3700,        0.375,  0.369; ...
                             5200,    0,     57,   340,     0,      3700,        0.340,  0.350; ...
                             5600,    0,      5,   370,     0,      3700,        0.330,  0.346; ...
                             6500,    0,      0,   320,    56,      3700,        0.313,  0.320; ...
                             7500,    0,      0,   279,    91,      3700,        0.302,  0.302; ...
                             8500,    0,      0,   246,   120,      3700,        0.294,  0.289; ...
                             9500,    0,      0,   225,   140,      3700,        0.289,  0.279; ...
                            10000,    0,      0,   210,   152,      3700,        0.286,  0.275];      
                    obj.CompanyName = 'IPIS';
                    obj.Location = 'Suwon';
                    obj.Model = 'IPL-L100';
                    obj.ManufacturingDate = '26th May 2009';
                case '10IVL0058' % Israel
                    %%       CT     Lp1     Lp2     Lp3    Lp4  Brightness(Lux)  x       y
                    TABLE = [2300,  410,    150,     0,     0,      4000,        0.513,  0.439; ...
                             2500,  270,    240,     0,     0,      4000,        0.493,  0.438; ...
                             2900,   50,    404,     0,     0,      4000,        0.460,  0.437; ...
                             3200,   50,    348,    52,    65,      4000,        0.426,  0.408; ...
                             4100,    0,    135,   260,     0,      4000,        0.388,  0.423; ...
                             5100,    0,      0,   284,    76,      4000,        0.341,  0.380; ...
                             5600,    0,      0,   253,    92,      4000,        0.330,  0.363; ...
                             6500,    0,      0,   201,   119,      4000,        0.312,  0.334; ...
                             7500,    0,      0,   162,   144,      4000,        0.300,  0.313; ...
                             8500,    0,      0,   131,   162,      4000,        0.291,  0.285; ...
                             9500,    0,      0,   106,   178,      4000,        0.285,  0.288; ...
                            10000,    0,      0,    98,   182,      4000,        0.282,  0.285];
                    obj.CompanyName = 'AVIS';
                    obj.Location = 'Yakum';
                    obj.Model = 'IPL-L100W';
                    obj.ManufacturingDate = '12th Nov 2010';
                case '13IVL0012' % China
                    %%       CT     Lp1     Lp2     Lp3    Lp4  Brightness(Lux)  x       y
                    TABLE = [2300,  404,    123,     0,     0,      4000,        0.505,  0.427; ...                       
                             2500,  356,    104,    74,     0,      4000,        0.479,  0.416; ...
                             2900,  131,    309,     0,     0,      4000,        0.456,  0.430; ...       
                             3100,  169,    210,    74,    46,      4000,        0.427,  0.400; ...
                             4100,    0,    197,   182,     0,      4000,        0.381,  0.393; ...
                             5200,   45,     38,   302,    31,      4000,        0.340,  0.360; ...   
                             5600,    0,      0,   315,    40,      4000,        0.330,  0.353; ...
                             6500,    0,      0,   268,    92,      4000,        0.313,  0.326; ...
                             7500,    0,      0,   233,   135,      4000,        0.301,  0.307; ...
                             8500,    0,      0,   205,   164,      4000,        0.292,  0.294; ...
                             9500,    0,     64,   142,   209,      4000,        0.288,  0.281; ...
                            10000,    0,      0,   173,   202,      4000,        0.284,  0.280];      
                    obj.CompanyName = 'AVIS';
                    obj.Location = 'China';
                    obj.Model = 'IPL-L150';
                    obj.ManufacturingDate = '24th April 2013';
                otherwise
					error('Your lightbox is not supported')
            end
            DATASET_LUT = dataset(      {TABLE(:,1),'CT'}, ...
                                        {TABLE(:,2),'Lamp1'}, ...
                                        {TABLE(:,3),'Lamp2'}, ...
                                        {TABLE(:,4),'Lamp3'}, ...
                                        {TABLE(:,5),'Lamp4'}, ...
                                        {TABLE(:,6),'Brightness'}, ...
                                        {TABLE(:,7),'x'}, ...
                                        {TABLE(:,8),'y'});
        end
    end
end