classdef TestClass < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prop
    end
    
    methods
        
        function meth(self, value)
            self.prop = value;
        end
        
        function self = TestClass()
            self.meth(3);
        end
    end
    
end

