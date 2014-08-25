classdef SetLamps < handle
    % SETLAMPS
    % ========
    %
    % Description
    % This is a very basic interface to LED Color Viewer
    % This allows you to control the brightness on each LED. 
    % 4 LED Controls in total. 
    %
    % Properties
    % COM_PORT:     com port that the color viewer 
    % Lamp1:        Lamp1 Brightness
    % Lamp2:        Lamp2 Brightness
    % Lamp3:        Lamp3 Brightness
    % Lamp4:        Lamp4 Brightness
    properties ( SetObservable = true )
        COM_PORT = 'COM9'; %10 Right port 9 left port
        Lamp1 = 270; % goes up to 1300
        Lamp2 = 240; 
        Lamp3 = 0;
        Lamp4 = 0;
        STATUS
        ErrorMessage = '';
        Connected = false
        log = false
        PopupEnable = false;
    end
    properties (Hidden = true)
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = SetLamps()
            
            %%
            ObjectInspector(obj)
        end
        function RUN(obj)
            obj.SetLampS(   [obj.Lamp1,obj.Lamp2,obj.Lamp3,obj.Lamp4] )
        end
    end
    methods (Hidden = true)
        function obj = SetLamps(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            if obj.log == true
            disp('Opening com-ports...');
            end
            obj.handles.LightBox_ComDevice = serial( obj.COM_PORT, 'BaudRate', 57600 );
            try
                fopen(obj.handles.LightBox_ComDevice);
                obj.Connected = true;
            catch
                if obj.PopupEnable == true
                    errordlg(   {   ['Color viewer not found on ',obj.COM_PORT] ,...
                                    ['Please check cable and port number']}, 'Connection Error');   
                else
                    obj.ErrorMessage = ['Color viewer not found on ',obj.COM_PORT];
                end
                obj.Connected = false;
            end
        end
        function delete(obj)
            %%
            if obj.log == true
            disp('deleting SetLamps class');
            end
            fclose(obj.handles.LightBox_ComDevice);
            if obj.log == true
            disp('closing serial port');
            end
            delete(obj.handles.LightBox_ComDevice);
            clear obj.handles.LightBox_ComDevice
            
            temp = instrfind;
            delete(temp);
        end
        function SetLampS(obj,Lamps)
            s1 = obj.handles.LightBox_ComDevice;

            LampsVect = [   rem(Lamps(1),256); floor(Lamps(1)/256); ...
                            rem(Lamps(2),256); floor(Lamps(2)/256); ...
                            rem(Lamps(3),256); floor(Lamps(3)/256); ...
                            rem(Lamps(4),256); floor(Lamps(4)/256)];

            %disp(['   LampsVect: ' int2str(LampsVect')]), disp('')

            userModeEn = hex2dec( ['5A'; '07'; '01'; '12'; '01'; '00'; '03'] ); % Switch camera to User mode
            str1 = hex2dec( ['5A'; '08'; '01'; '01'; '00'; '0F'; '00'; '03'] ); % Start send lamps data
            str2 = [hex2dec( ['5A'; '0E'; '01'; '02'; '00'] ); uint16(LampsVect); hex2dec( '03' )]; % Lamps data

            fwrite( s1, userModeEn );
            fwrite( s1, str1 );
            fwrite( s1, str2 );
        end
    end
end