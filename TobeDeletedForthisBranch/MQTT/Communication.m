classdef Communication
    %COMMUNICATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        topic_OSL='pi/osl/'
        
        ClientID='Andro'
    end
    
    methods
        
        function SendCommandMQTT(this,message,client)
            
            message = convertStringsToChars(message);
            client.publish('pi/osl/', message)
        
        end
        function client=connecttoMQTT(this)
           client = mqtt('tcp://192.168.224.159', 'ClientID', 'Andro');
           
            
        end
        
        
    end
end

