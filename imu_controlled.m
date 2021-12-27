clear all;
myev3 = legoev3('bt','0016534DD7DB');
pause(15);
% motor port numbers
a = arduino();
fs = 100; % Sample Rate in Hz   
imu = mpu6050(a,'SampleRate',fs,'OutputFormat','matrix'); 
tic;

% GyroscopeNoise and AccelerometerNoise is determined from datasheet.
GyroscopeNoiseMPU6050 = 3.0462e-06; % GyroscopeNoise (variance) in units of rad/s
AccelerometerNoiseMPU6050 = 0.0061; % AccelerometerNoise (variance) in units of m/s^2
viewer = HelperOrientationViewer('Title',{'IMU Filter'});
FUSE = imufilter('SampleRate',imu.SampleRate, 'GyroscopeNoise',GyroscopeNoiseMPU6050,'AccelerometerNoise', AccelerometerNoiseMPU6050);
stopTimer=1000;

% Use imufilter to estimate orientation and update the viewer as the
% sensor moves for time specified by stopTimer
tic;

mymotor1 = motor(myev3, 'B');              
mymotor2 = motor(myev3, 'C');   
%mysonicsensor = sonicSensor(myev3);

while(toc < stopTimer)
    %reaidng IMU values
    [accelReadings, gyroReadings, timeStamps, overrun] = read(imu);
    %fuse them 
    rotators = FUSE(accelReadings, gyroReadings);
    %convert them into vector values
    val = rotvecd(rotators)
    %extract vetor values from matrix
    x = val(1,1)
    y = val(1,2)
    distance = 100*readDistance(mysonicsensor);
    
    for j = numel(rotators)
        viewer(rotators(j));
    end
    
     if distance >= 20
        if y>=20 
            mymotor1.Speed = 50;                    % Set motor speed
            mymotor2.Speed = 50;

        elseif y<=-20
            mymotor1.Speed = -50;                     % Set motor speed
            mymotor2.Speed = -50;

        elseif x>=20
            mymotor1.Speed = -10;                     % Set motor speed
            mymotor2.Speed = 10;

        elseif x<=-20
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
        if y<=-20
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
release(imu);
delete(imu);
clear;


