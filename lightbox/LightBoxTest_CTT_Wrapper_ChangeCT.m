function Connected = LightBoxTest_CTT_Wrapper_ChangeCT(COM_PORT,SerialNum,ColorTemp)
    % LightBoxTest_CTT_Wrapper
    %
    % COM_PORT: String e.g 'COM9'
    % SerialNum: String
    %            '09IPL0017' -> Suwon
    %            '09IPL0018' -> Cambs
    %            '10IVL0058' -> Israel
    %            '11IVL0035' -> Sunnyvale
    %            '13IVL0012' -> China
    % ColourTemp = (double) e.g 6500
    % Connected: false if it failed to connect. 
    %
    % Example: LightBoxTest_CTT_Wrapper_ChangeCT('COM9','10IVL0058',6500)
    obj = LightBoxTest( 'COM_PORT',     COM_PORT, ...
                        'SerialNum',    SerialNum, ...
                        'PopupEnable',  false);
    obj.ColorTemp = num2str(ColorTemp);
    
    obj.RUN();
    Connected = obj.Connected;
end