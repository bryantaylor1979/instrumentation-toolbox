classdef RedTide <  handle 
    % Fetch Spectrum through Ocean Optics Spectrometer using MATLAB Instrument Driver
    %
    % This example shows how to acquire the spectrum of a fluorescent light source
    % from an Ocean Optics Spectrometer.
    %
    % Instrument Control Toolbox(TM) supports communication with instruments
    % through high-level drivers.  In this example you can acquire spectrum
    % from an Ocean Optics Spectrometer using the MATLAB Instrument Driver.
    %
    % Copyright 2012 The MathWorks, Inc.
    %
    %
    % Requirements
    %
    % This example requires the following:
    % * A 64-bit Microsoft(R) Windows(R)
    % * Ocean Optics spectrometer USB2000
    % * Install OmniDriver downloadable from http://www.oceanoptics.com/
    % * OmniDriver.mdd available from MATLAB Central
    
    properties (SetObservable = true, GetObservable = false) %Input Parameters
        integrationTime = 50;   % integration time for sensor.
        realtime_Enable = false;
        timer_ExecutionMode = 'fixedDelay'; % [ {singleShot} | fixedSpacing | fixedDelay | fixedRate ] 
        timer_Period = 1;
    end
    properties (SetObservable = true, GetObservable = true)
        DATASET = dataset();
    end
    properties (Hidden = true, SetObservable = true, GetObservable = true)
        wavelengths = [];
        spectralData = [];
    end
    properties (Hidden = true, SetAccess = private, SetObservable = true) % SW/HW Information (Read-only)
        instrumentType
        driverType
        driverName
        deviceName   %If you change the index this may change. 
        deviceSerialNumber
        numOfSpectrometers
        hardwareVersion
        communicationState
    end
    properties (Hidden = true, SetObservable = true)
        DATASET_Class = 'spectrum';
        timer_ExecutionMode_LUT = { 'singleShot'; ...
                                    'fixedSpacing'; ...
                                    'fixedDelay'; ...
                                    'fixedRate'}
        handles 
        enable = 1;             % Enable flag.
        spectrometerIndex = 0;  % Spectrometer index to use (first spectrometer by default).
        channelIndex = 0;       % Channel index to use (first channel by default).
    end
    % TODO: Generate a class package which works on listeners and runs
    % real-time. 
    % TODO: Add a timer to the spectrum read the time delay maybe based on
    % the intergration time? Check for the values changing.
    % TODO: Spectrometer index -> I assume multiple uints
    % TODO: channelIndex -> What is the channel index? 
    % TODO: add a listener so that integrationTime can be set during
    % session. 
    methods
        function Example(obj)
           %% Example 1 - In Single Shot Mode
           % Ensure workspace is clear
           close all 
           clear classes
           
           %% Load RedTide object
           obj = RedTide(   'integrationTime', 50);
           ObjectInspector(obj)
           
           %%
           delete(obj)
           
           %%
           % Read wavelength and spectralData from device
           wavelengths = obj.wavelengths;
           spectralData = obj.spectralData;
           
           % plot data 
           plot(wavelengths,spectralData);
           
           %%
           ObjectInspector(obj)
           
           %% Looking at a list of avaliable properties of a classdef
           properties(obj)
           
           
           %% start RT
           obj.realtime_Enable = true;
           
           %% stop RT
           obj.realtime_Enable = false;         
           
           %%
        end
        function RUN(obj)
            obj.Get();
        end
    end
    methods (Hidden = true) %support functions
        function obj = RedTide(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
        	obj.Connect;
            obj.GetHwSwInformation;
            obj.SetDefaults;
            
            %%
            obj.handles.listeners.PreGet = obj.addlistener({'DATASET','timer_ExecutionMode'},'PreGet',@obj.GET);
            obj.handles.listeners.PostSet = obj.addlistener({'realtime_Enable','timer_Period'},'PostSet',@obj.SET);
            %%
            
            %[ {singleShot} | fixedSpacing | fixedDelay | fixedRate ]
            obj.handles.timer = timer('TimerFcn',@obj.TakeReading, 'Period', obj.timer_Period, 'ExecutionMode',obj.timer_ExecutionMode);
        end
        function TakeReading(varargin)
            obj = varargin{1};
            obj.spectralData;
        end
        function delete(obj)
           obj.DisConnect;
           delete (obj.handles.spectrometerObj);  
           delete(obj.handles.listeners.PostSet); 
           stop(obj.handles.timer);
           delete(obj.handles.timer);
        end
        function Connect(obj)
            %% Create MATLAB Instrument OmniDriver object.
            disp('Connect to Spectrometer')
            obj.handles.spectrometerObj = icdevice('OceanOptics_OmniDriver.mdd');

            %% Connect to the instrument.
            connect(obj.handles.spectrometerObj);      
        end
        function DisConnect(obj)
            %% Clean up.
            disp('Disconnect the Spectrometer')
            disconnect(obj.handles.spectrometerObj);        
        end
        function GetHwSwInformation(obj)
           %% Get Information
           % Should only need to read these on start-up. (These are
           % believe to be constants for the session. 
           obj.instrumentType = obj.getInstrumentType();
           obj.driverType = obj.getDriverType();
           obj.driverName = obj.getDriverName();
           obj.deviceName = obj.getName(obj.spectrometerIndex);
           obj.deviceSerialNumber = obj.getSerialNumber();
           obj.numOfSpectrometers = obj.getNumberOfSpectrometersFound();
           obj.hardwareVersion = obj.getVersionHW;
           obj.communicationState  = obj.getCommunicationState();
        end
        function SetDefaults(obj)
            obj.setIntegrationTime(obj.spectrometerIndex,obj.channelIndex,obj.integrationTime)
            obj.setCorrectForDetectorNonlinearity(obj.spectrometerIndex, obj.channelIndex, obj.enable)
            obj.setCorrectForElectricalDark(obj.spectrometerIndex, obj.channelIndex, obj.enable)
        end
        function GET(varargin)
            %%
            obj = varargin{1};
            param = varargin{2}.Name;
            switch param
                case 'spectralData'
                    obj.spectralData = obj.getSpectrum();
                case 'wavelengths'
                    obj.wavelengths = obj.getWavelengths();
                otherwise
                    obj.spectralData = obj.getSpectrum();
                    obj.wavelengths = obj.getWavelengths();
            end
            obj.DATASET = dataset(  {obj.wavelengths,'Wavelength'}, ...
                                    {obj.spectralData,'Transmission'})
        end
        function SET(varargin)
            %%
            obj = varargin{1};
            param = varargin{2}.Name;
            realtime_Enable_Val = obj.(param);
            switch param
                case 'realtime_Enable'
                    if realtime_Enable_Val == true
                        start(obj.handles.timer)
                    else
                        stop(obj.handles.timer)
                    end
                case 'timer_Period'
                    set(obj.handles.timer,'Period', obj.timer_Period);
                case 'timer_ExecutionMode'
                    set(obj.handles.timer,'ExecutionMode', obj.timer_ExecutionMode);
                otherwise
                    error('param not supported')
            end
        end
    end
    methods (Hidden = true) %Get values 
        % functions
        function wavelengths                = getWavelengths(obj)
            % Get the wavelengths of the first spectrometer and save them in a double
            % array.
            wavelengths = invoke(obj.handles.spectrometerObj, 'getWavelengths', obj.spectrometerIndex, obj.channelIndex);           
        end
        function spectralData               = getSpectrum(obj)
            % get Spectrum
            spectralData = invoke(obj.handles.spectrometerObj, 'getSpectrum', obj.spectrometerIndex);
        end
    end
    methods (Hidden = true) % Set Defaults
        function setIntegrationTime(obj,spectrometerIndex,channelIndex,integrationTime)
            invoke(obj.handles.spectrometerObj, 'setIntegrationTime', spectrometerIndex, channelIndex, integrationTime);
        end
        function setCorrectForDetectorNonlinearity(obj,spectrometerIndex, channelIndex, enable)
            % Enable correct for detector non-linearity.
            invoke(obj.handles.spectrometerObj, 'setCorrectForDetectorNonlinearity', spectrometerIndex, channelIndex, enable); 
        end
        function setCorrectForElectricalDark(obj,spectrometerIndex, channelIndex, enable)
            % Enable correct for electrical dark.
            invoke(obj.handles.spectrometerObj, 'setCorrectForElectricalDark', spectrometerIndex, channelIndex, enable);
        end
    end
    methods (Hidden = true) %start-up information
        function numOfSpectrometers         = getNumberOfSpectrometersFound(obj)
            % get Number of Spectrometers Attach to device
            numOfSpectrometers = invoke(obj.handles.spectrometerObj, 'getNumberOfSpectrometersFound');
        end
        function spectrometerName           = getName(obj,spectrometerIndex)
            % Get spectrometer name. 
            spectrometerName = invoke(obj.handles.spectrometerObj, 'getName', spectrometerIndex);
        end
        function spectrometerSerialNumber   = getSerialNumber(obj)
            % Get spectrometer serial number.
            spectrometerSerialNumber = invoke(obj.handles.spectrometerObj, 'getSerialNumber', obj.spectrometerIndex);
        end
        function driverType                 = getDriverType(obj)
            %%
            driverType	 = get(obj.handles.spectrometerObj,'DriverType');
        end
        function driverName                 = getDriverName(obj)
            driverName = get(obj.handles.spectrometerObj,'DriverName');
        end
        function InstrumentType             = getInstrumentType(obj)
            InstrumentType = get(obj.handles.spectrometerObj,'Type');
        end
        function HW_Version                 = getVersionHW(obj)
            Version = get(obj.handles.spectrometerObj,'Version');
            HW_Version = Version.Name;
        end
        function CommunicationState         = getCommunicationState(obj)
            CommunicationState = get(obj.handles.spectrometerObj,'Status');
        end
    end
end




