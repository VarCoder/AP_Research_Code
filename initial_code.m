joy = vrjoystick(1); % initialize joystick
jc = JacoComm;  % initialize robot object
ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                         'Callback', 'delete(gcbf)');
rosinit;  % initialize ROS for waitfor function

connect(jc);  % establish a connection to the robot
setPositionControlMode(jc);  %change to position control mode instead of torque
goToHomePosition(jc); % https://robotics.stackexchange.com/questions/20935/what-are-joint-angles-of-kinova-jaco-in-home-position
calibrateFingers(jc); 
% runGravityCalibration(jc);

mode = 0; % by default it x-y translates
scale= 0.175; %scale for the velocity translations

cartcmd = [0;0;0;0;0;0]; 
fingercmd = [0;0;0];

drawnow; % draw the estop

r = rosrate(100);  %loop at 100 hz, this is the robot's only instruction speed
reset(r); % documentation says to do this before loops

buttons = zeros(1,10);
sendfingers=false;

while 1
    buttons_ = buttons;
    buttons = button(joy);

    if buttons(6) == 0 && buttons_(6) == 1
        mode = mod(mode + 1,3); % loop back the mode to 0 after switching
        disp(mode);
    end

    switch mode
        case 0
            cartcmd = [(buttons(3)-buttons(2))*scale;(buttons(1)-buttons(4))*scale;0;0;0;0];
            % change x,y with x and b buttons, y with a,y buttons
        case 1
            cartcmd = [0;0;(buttons(4)-buttons(1))*scale;0;0;0];
            % change z with y, a buttons
            % adjust current finger command to a delta of 1000

            if (buttons(3) == 0 && buttons_(3)==1) && fingercmd(1) < 6000
                fingercmd = fingercmd + 1000;
                sendfingers = true;        
            elseif (buttons(2) == 0 && buttons_(2) == 1) && fingercmd(1) > 0
                fingercmd = fingercmd - 1000;
                sendfingers = true;        
            end

        case 2
            % rotation over y is buttons y,x and rotation over z is b,a
            cartcmd = [0;0;0;0;(buttons(4)-buttons(3));(buttons(2)-buttons(1))];
    end

    
    if sendfingers
        sendFingerPositionCommand(jc,fingercmd);
    end
    %send the signal over a loop for smoother motion, 100 is the sweet spot
    %for latency
    for i = 1:100
        if any(cartcmd)
            sendCartesianVelocityCommand(jc,cartcmd);
        end
    end

    cartcmd = [0;0;0;0;0;0]; %reset cartesian position command
    sendfingers = false; %reset finger-sending command
    if ~ishandle(ButtonHandle) % if the button is pressed close the program (only exit condition)
        break;
    end
    waitfor(r); %using the rosrate, wait for the loop iter to end at the correct timing
end

disconnect(jc);  %disconnect to the api, library, and robot
rosshutdown %shut down ros (this is very important as ROS needs to be reset inorder to run again)
