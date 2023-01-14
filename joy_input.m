classdef joy_input < handle
    properties
        mode = 0;
        scale = 0.175;
    end

    properties (SetAccess=private)
        joy = vrjoystick(1);
        jc = JacoComm;
    end

    properties (Transient)
        cartcmd = [0;0;0;0;0;0]; 
        fingercmd = [0;0;0];
        buttons = zeros(1,10);
        sendfingers=false;
    end

    methods

        function obj = joy_input(m,s)
            if nargin > 0
                obj.mode = m;
                obj.scale = s;
            end
        end

        function init(obj)
            connect(obj.jc);  % establish a connection to the robot
            setPositionControlMode(obj.jc);  %change to position control mode instead of torque
            goToHomePosition(obj.jc); % https://robotics.stackexchange.com/questions/20935/what-are-joint-angles-of-kinova-jaco-in-home-position
            calibrateFingers(obj.jc); 
        end

        function run(obj)
            buttons_ = obj.buttons;
            obj.buttons = button(obj.joy);
            if obj.buttons(6) == 0 && buttons_(6) == 1
                obj.mode = mod(obj.mode + 1,3); % loop back the mode to 0 after switching
            end

            switch obj.mode

                case 0
                    obj.cartcmd = [(obj.buttons(3)-obj.buttons(2))*obj.scale;(obj.buttons(1)-obj.buttons(4))*obj.scale;0;0;0;0];
                    % change x,y with x and b buttons, y with a,y buttons
                
                case 1
                    obj.cartcmd = [0;0;(obj.buttons(4)-obj.buttons(1))*obj.scale;0;0;0];
                    % change z with y, a buttons
                    % adjust current finger command to a delta of 1000
        
                    if (obj.buttons(3) == 0 && buttons_(3)==1) && obj.fingercmd(1) < 6000
                        obj.fingercmd = obj.fingercmd + 1000;
                        obj.sendfingers = true;        
                    elseif (obj.buttons(2) == 0 && buttons_(2) == 1) && obj.fingercmd(1) > 0
                        obj.fingercmd = obj.fingercmd - 1000;
                        obj.sendfingers = true;        
                    end
        
                case 2
                    % rotation over y is buttons y,x and rotation over z is b,a
                    obj.cartcmd = [0;0;0;0;(obj.buttons(4)-obj.buttons(3));(obj.buttons(2)-obj.buttons(1))];
            end
            
            if obj.sendfingers
                sendFingerPositionCommand(obj.jc,obj.fingercmd);
            end

            for i = 1:100
                if any(obj.cartcmd)
                    sendCartesianVelocityCommand(obj.jc,obj.cartcmd);
                end
            end
            obj.cartcmd = [0;0;0;0;0;0]; %reset cartesian position command
            obj.sendfingers = false; %reset finger-sending command
        end
        
        function reset(obj)
            disconnect(obj.jc);
        end
    
    end  
end