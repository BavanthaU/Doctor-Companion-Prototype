a = arduino();
fs = 100; % Sample Rate in Hz   
imu = mpu6050(a,'SampleRate',fs,'OutputFormat','matrix'); 
tic;

% GyroscopeNoise and AccelerometerNoise is determined from datasheet.
GyroscopeNoiseMPU6050 = 3.0462e-06; % GyroscopeNoise (variance) in units of rad/s
AccelerometerNoiseMPU6050 = 0.0061; % AccelerometerNoise (variance) in units of m/s^2
viewer = HelperOrientationViewer('Title',{'IMU Filter'});
FUSE = imufilter('SampleRate',imu.SampleRate, 'GyroscopeNoise',GyroscopeNoiseMPU6050,'AccelerometerNoise', AccelerometerNoiseMPU6050);
stopTimer=100;

% Use imufilter to estimate orientation and update the viewer as the
% sensor moves for time specified by stopTimer
tic;
while(toc < stopTimer)
    [accelReadings, gyroReadings, timeStamps, overrun] = read(imu);
    rotators = FUSE(accelReadings, gyroReadings);
    rotvecd(rotators)
    
    for j = numel(rotators)
        viewer(rotators(j));
    end
end
release(imu);
delete(imu);
clear;