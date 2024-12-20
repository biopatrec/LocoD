% This function will assign number to IMU channels
function IMUChannumber=AssignNumbertoIMUchans(SelectedNodes,NumberofNodes)
IMUChannumber=[];
for i=1:NumberofNodes
    switch SelectedNodes(i)
        case "S1_ACC X"
            IMUChannumber=[IMUChannumber,1];
        case "S1_ACC Y"
            IMUChannumber=[IMUChannumber,2];
        case "S1_ACC Z"
            IMUChannumber=[IMUChannumber,3];
        case "S1_GYR X"
            IMUChannumber=[IMUChannumber,4];
        case "S1_GYR Y"
            IMUChannumber=[IMUChannumber,5];
        case "S1_GYR Z"
            IMUChannumber=[IMUChannumber,6];
       
        case "S2_ACC X"
            IMUChannumber=[IMUChannumber,7];
        case "S2_ACC Y"
            IMUChannumber=[IMUChannumber,8];
        case "S2_ACC Z"
            IMUChannumber=[IMUChannumber,9];
        case "S2_GYR X"
            IMUChannumber=[IMUChannumber,10];
        case "S2_GYR Y"
            IMUChannumber=[IMUChannumber,11];
        case "S2_GYR Z"
            IMUChannumber=[IMUChannumber,12];
            
            
        case "S3_ACC X"
            IMUChannumber=[IMUChannumber,13];
        case "S3_ACC Y"
            IMUChannumber=[IMUChannumber,14];
        case "S3_ACC Z"
            IMUChannumber=[IMUChannumber,15];
        case "S3_GYR X"
            IMUChannumber=[IMUChannumber,16];
        case "S3_GYR Y"
            IMUChannumber=[IMUChannumber,17];
        case "S3_GYR Z"
            IMUChannumber=[IMUChannumber,18];
   
        case "S4_ACC X"
            IMUChannumber=[IMUChannumber,19];
        case "S4_ACC Y"
            IMUChannumber=[IMUChannumber,20];
        case "S4_ACC Z"
            IMUChannumber=[IMUChannumber,21];
        case "S4_GYR X"
            IMUChannumber=[IMUChannumber,22];
        case "S4_GYR Y"
            IMUChannumber=[IMUChannumber,23];
        case "S4_GYR Z"
            IMUChannumber=[IMUChannumber,24];
            
            
        case "S5_ACC X"
            IMUChannumber=[IMUChannumber,25];
        case "S5_ACC Y"
            IMUChannumber=[IMUChannumber,26];
        case "S5_ACC Z"
            IMUChannumber=[IMUChannumber,27];
        case "S5_GYR X"
            IMUChannumber=[IMUChannumber,28];
        case "S5_GYR Y"
            IMUChannumber=[IMUChannumber,29];
        case "S5_GYR Z"
            IMUChannumber=[IMUChannumber,30];
            
        case "S6_ACC X"
            IMUChannumber=[IMUChannumber,31];
        case "S6_ACC Y"
            IMUChannumber=[IMUChannumber,32];
        case "S6_ACC Z"
            IMUChannumber=[IMUChannumber,33];
        case "S6_GYR X"
            IMUChannumber=[IMUChannumber,34];
        case "S6_GYR Y"
            IMUChannumber=[IMUChannumber,35];
        case "S6_GYR Z"
            IMUChannumber=[IMUChannumber,36];
    end
    
end


end