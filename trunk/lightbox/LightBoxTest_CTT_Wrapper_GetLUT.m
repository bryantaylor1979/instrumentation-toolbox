function LUT = LightBoxTest_CTT_Wrapper_GetLUT(COM_PORT,SerialNum)
    % LightBoxTest_CTT_Wrapper
    %
    % COM_PORT: String e.g 'COM9'
    % SerialNum: String
    %            '09IPL0017' -> Suwon
    %            '09IPL0018' -> Cambs
    %            '10IVL0058' -> Israel
    %            '11IVL0035' -> Sunnyvale
    %            '13IVL0012' -> China
    % Connected: false if it failed to connect. 
    %
    % Example: LightBoxTest_CTT_Wrapper_GetLUT('COM9','10IVL0058')
    obj = LightBoxTest( 'COM_PORT',     COM_PORT, ...
                        'SerialNum',    SerialNum, ...
                        'PopupEnable',  false);
    LUT = cellfun(@str2num,obj.ColorTemp_LUT);
end