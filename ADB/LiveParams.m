classdef LiveParams < handle
    properties
        handles 
    end
    properties 
        DecodedLog
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = LiveParams
           
           %%
           obj.handles.ADB = ADB_Logging;
           obj.handles.decodelistener = addlistener(obj.handles.ADB, 'Buffer', 'PostSet', @obj.Decode);
%            obj.handles.displaylistener = addlistener(obj, 'DecodedLog', 'PostSet', @obj.Display);
        end
        function Display(varargin)
            %%
            obj = varargin{1}
            obj.DecodedLog
            x = size(obj.DecodedLog,1)
            for i = 1:x
                
            end
        end
        function Decode(varargin)
            
           obj = varargin{1};
           
           %%
           Buffer = obj.handles.ADB.Buffer;
           fieldnames = {   'substate', ...
                            'FOM', ...
                            'reason', ...
                            'dFOM_from_MAX', ...
                            'max_focus_fom', ...
                            'r', ...
                            'g', ...
                            'b', ...
                            'max_sat', ...
                            'min_sat', ...
                            'sat', ...
                            'deltasat', ...
                            'cdi_exposure', ...
                            'prev_cdi_exposure', ...
                            'FOM_adjusted', ...
                            'prev_FOM_adjusted', ...               
                            'av_dFOM', ...        
                            'dFOM_thresh', ...
                            'dFOM_thresh_lower', ...
                            'dFOM_f2f', ...
                            'dgrn_thresh', ...
                            'dgrn_thresh_lower', ...
                            'grn_adj', ...
                            'prev_grn_adj', ...
                            'dgf2f', ...    
                            'dgf2f_adjusted', ...
                            'delta_FOM', ...
                            'g_norm', ...
                            'dFOMf2f_adjusted', ...
                            'zoom_width'};
                        
           [log,f] = obj.DecodeLog(Buffer,fieldnames); % Buffer: this contains lots of stuff not just caf. 
                                                       % log: only contains decoded CAF parameters
           %%
           numberOfFrameBuffer = 10;
           if isempty(obj.DecodedLog)
                %% crop the last numberOfFrameBuffer
                [MaxInNewLog,MinInNewLog] = obj.GetMaxMinFrameNumber(log,f);
                MinFrameAllowed = MaxInNewLog-numberOfFrameBuffer;
                if MinFrameAllowed >= MinInNewLog
                    obj.DecodedLog = log;
                else
                    log = obj.CropBetweenFrames(log,MaxInNewLog,MinFrameAllowed,f);
                end
           elseif isempty(log)
                % do nothing. This should never happen? 
           else
               %% find max and min frame number in buffer
%                MaxInBuffer
                [MaxInBuffer,MinInBuffer] = obj.GetMaxMinFrameNumber(obj.DecodedLog,f);
                [MaxInNewLog,MinInNewLog] = obj.GetMaxMinFrameNumber(log,f);
                
                if MaxInNewLog-numberOfFrameBuffer < MinInBuffer;
                    obj.DecodedLog = [obj.DecodedLog;log];
                else
                    x = 1
                end
           end
        end
        function log = CropBetweenFrames(obj,MaxIn,MinIn,f)
            %%
            n = find(strcmpi(f,'frame_num'));
            CELL = struct2cell(log);
            framenumbers = cell2mat(CELL(n,:));
            
        end
        function [MaxIn,MinIn] = GetMaxMinFrameNumber(obj,log,f)
                n = find(strcmpi(f,'frame_num'));
                CELL = struct2cell(log);
                framenumbers = cell2mat(CELL(n,:));
                MaxIn = max(framenumbers);
                MinIn = min(framenumbers);            
        end
        function [log,f] = DecodeLog(obj,Buffer,fieldnames)
           %%
           logfile = textscan(Buffer, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', ...
                                      'Delimiter', ':', ...
                                      'MultipleDelimsAsOne', 1);
                                  
           n = find(strcmpi(logfile{3},'CAF_MATLAB'));

                        
           x = size(fieldnames,2);
           for i = 1:x
                param = str2double(logfile{i+3}(n));
             	celltable(:,i) =  param;
           end

           
           %% get frame number
           n = find(strcmpi(logfile{16},'frame'));
           FrameNumbers = str2double(logfile{17}(n));
           celltablef = [celltable,FrameNumbers];
           
           %%
           celltablef = sortrows(celltablef,31);      
           
           %%
           [x,y]= size(celltablef);
           celltablef = num2cell(celltablef);
           f = [fieldnames,'frame_num'];
           log = cell2struct(celltablef,f,2);            
        end
    end
end