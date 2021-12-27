%clear all;
%a = arduino()
%pause(5);
%myev3 = legoev3('bt','0016534DD7DB');
%pause(15);
% motor port numbers

mymotor1 = motor(myev3, 'B');              
mymotor2 = motor(myev3, 'C');   
%mysonicsensor = sonicSensor(myev3);

for i = 1 :1000
    distance = 100*readDistance(mysonicsensor);
    y = readVoltage(a,'A1');
    x = readVoltage(a,'A0');
    
    x = int16(mapfun(x, 0, 5, 512, -512));
    y = int16(mapfun(y, 0, 5, -512, 512));
    
    fprintf(" X value: %d, Y value: %d \n",x,y);
   
    if distance >= 20
        if y>=200 
            mymotor1.Speed = 50;                    % Set motor speed
            mymotor2.Speed = 50;

        elseif y<=-200
            mymotor1.Speed = -50;                     % Set motor speed
            mymotor2.Speed = -50;

        elseif x>=200
            mymotor1.Speed = -10;                     % Set motor speed
            mymotor2.Speed = 10;

        elseif x<=-200
            mymotor1.Speed = 10;                     % Set motor speed
            mymotor2.Speed = -10;
        else
            mymotor1.Speed = 0;                     % Set motor speed
            mymotor2.Speed = 0;
        end
        start(mymotor1);                            % Start motor
        start(mymotor2);
    else
        disp("obstacle !!!!!!!!!!!!!!!")
        if y<=-200
            mymotor1.Speed = -50;                     % Set motor speed
            mymotor2.Speed = -50;
        else
            mymotor1.Speed = 0;                     % Set motor speed
            mymotor2.Speed = 0; 
        end
        start(mymotor1);                            % Start motor
        start(mymotor2);
    end

end

function output = mapfun(value,fromLow,fromHigh,toLow,toHigh)
narginchk(5,5)
nargoutchk(0,1)
output = (value - fromLow) .* (toHigh - toLow) ./ (fromHigh - fromLow) + toLow;
end