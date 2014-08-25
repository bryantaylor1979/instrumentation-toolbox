classdef Spectrum_RT <  handle & ...
                        RedTide
    properties (Hidden = true)
    end
    %TODO:  changing the intergration time does not seem to have any
    %effect? 
    %TODO: when updateRate is lower i can't seem to stop it. 
    %TODO: Ensure buffer and GUI can update at the owe rate. 
    methods
        function Example(obj)
           %% Problems
           % TODO: the input dynamic inputs timer_Period is not working 
           % TODO: the timer_Period can not be changed live? 
            
           %% Real Time Example Link to Spectrumplot
           % init
           close all
           clear classes
           obj = Spectrum_RT(   'integrationTime',    50, ...
                                'timer_Period',       0.1);
           
           %% open a gui to edit variables
           % set realtime_Enable = true to start streaming and false to stop. 
           ObjectInspector(obj)
           ObjectInspector(obj.handles.objSP)
           
          
           
           %%
           obj.timer_Period = 0.5
           
           %%
           get(obj.handles.timer)
        end
    end
    methods (Hidden = true)
        function obj = Spectrum_RT(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{1}) = varargin{i+1};
            end
            obj.Init
        end
        function Init(obj)
           %%
           obj.handles.objSP = plotSpectrum(    'wavelengths',      obj.wavelengths, ...
                                                'spectralData',     obj.spectralData);
                            
           % link with listener
           obj.handles.listener = obj.addlistener('spectralData','PreGet',@obj.Update);            
        end
        function Update(varargin)
            %%
            obj = varargin{1};
            obj.handles.objSP.spectralData =  obj.spectralData;
            drawnow;
        end
    end
end