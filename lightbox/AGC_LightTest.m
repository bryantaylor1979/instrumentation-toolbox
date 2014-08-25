classdef AGC_LightTest < handle
    % AGC_LIGHTTEST
    % =============
    %
    % Description
    % This is a simple function which used to control the brightness 
    % of the LED color viewer. This is used for the match the LV values
    % found on the k-touch test spec. This set lamp4 to zero, and then set
    % lamps 1-3 with the same brightness value. 
    %
    % Properties
    % Enable:       switch on/off 
    % LV:    pulldown a select your LV (You must press RUN to apply)
    % Lum:          Brightness Value (This is not LUX, then press RUN) 
    % AppliedLV:  The value active on the colour viewer (Read only) 
    % Lamps_OBJ:    This is the setlamp class (You can view the status) 
    %
    % Sub-Componets: SetLamps
    properties (SetObservable = true)
        LV = 'LV5';
        AppliedLV
        Lamps_OBJ
    end
    properties (Hidden = true, SetObservable = true)
        LV_LUT = {  'LV5'; ...
                    'LV6'; ...
                    'LV7'; ...
                    'LV8'; ...
                    'LV9'; ...
                    'LV10'; ...
                    'LV11'; ...
                    'LV12'; ...
                    'LV13'};
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = AGC_LightTest
           ObjectInspector(obj)
        end 
        function RUN(obj)
            %%
            LV_Num = str2num(obj.LV(3:end));
            Value = obj.LV2ValueLUT(LV_Num);
            obj.SetLamps( Value );
            obj.AppliedLV = obj.LV;
        end
    end
    methods (Hidden = true)
        function SetLamps(obj,Lamp)
            %%
            obj.Lamps_OBJ.Lamp1 = Lamp(1);
            obj.Lamps_OBJ.Lamp2 = Lamp(2);
            obj.Lamps_OBJ.Lamp3 = Lamp(3);      
            obj.Lamps_OBJ.RUN();
        end
        function obj = AGC_LightTest
            %%
            obj.Lamps_OBJ = SetLamps;
            obj.Lamps_OBJ.Lamp4 = 0;
            obj.RUN();
        end
        function Value = LV2ValueLUT(obj,LV)
            switch LV
                case 5
                    Value = [12,12,12];
                case 6
                    Value = [14,15,15];
                case 7
                    Value = [19,19,19];
                case 8
                    Value = [24,24,24];
                case 9
                    Value = [33,33,33];
                case 10
                    Value = [46,46,46];
                case 11
                    Value = [71,71,71];
                case 12
                    Value = [115,115,115];
                case 13
                    Value = [215,215,215];
            end
        end
    end
end