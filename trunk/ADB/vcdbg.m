classdef vcdbg < handle
    properties
    end
    methods
        function Help(obj)
            system('adb shell vcdbg help log')            
        end
    end
end