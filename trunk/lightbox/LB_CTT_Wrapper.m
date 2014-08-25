function varargout = LB_CTT_Wrapper(varargin)
% LB_CTT_Wrapper - operate lightbox 
% varargin:
% opcode :  0  - query set of temperatures
%                     1 -  send an update  to the lightbox and disconnect
% COM_PORT : string describing com port name: such as 'COM1' 
% SerialNum: serial number of the light box, such as '10IVL0058'
% colorTemp (optional, in case the opcode is 1) - reuqested color
% temperature
if (length(varargin)<3)
            error('LB_CTT_Wrapper: Number of input arguments must be at least 3.');
end

opcode  = varargin{1};
COM_PORT = varargin{2};
SerialNum = varargin{3};
ColorTemp = 3200; %default value
if (opcode == 1)
    if (length(varargin)>=4)
        ColorTemp =  varargin{4};
    else
        error('LB_CTT_Wrapper: Please supply colour temperature to set light box to.');
    end
end
if (opcode > 1)
    error('LB_CTT_Wrapper: opcode %d not supported ',opcode);
end
if (~isnumeric(ColorTemp))
            error('LB_CTT_Wrapper: input argument ColorTemp must be of an integer type.');
end
        obj = LightBoxTest( 'Enable',       'FALSE', ...
                            'COM_PORT',     COM_PORT, ...
                            'SerialNum',    SerialNum, ...
                            'PopupEnable',  false);
        LUT = cellfun(@str2num,obj.ColorTemp_LUT);
switch (opcode)
    case 0,
        %nothing else to do...
    case 1,
        obj.Enable = 'TRUE';
        obj.ColorTemp = num2str(ColorTemp);
        obj.RUN();
end
varargout{1} = LUT;
