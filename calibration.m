% Calibration System
% Try to reach given object (soft)
% Based on amount of total error and elapsed time, input to bayesian
% optimizer
% Change sensitivity parameters (globally | locally)
% 
% 
% 


% filename = "cfg.mat"
% if isfile(filename)
%     load(filename)
% else
%     calibration_count = 0;
%     
% end

ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'End Trial', ...
                         'Callback', 'delete(gcbf)');

calibration_count = 0;
joy = joy_input;
joy.init();

pos_arr = zeros(6);
neg_arr = zeros(6);

r = rosrate(100);  %loop at 100 hz, this is the robot's only instruction speed
reset(r); % documentation says to do this before loops

drawnow; % draw estop
tStart = tic;

while 1
    joy.run();
    cur_move = joy.cartcmd / joy.scale;

    for i= 1:numel(cur_move)
        if cur_move(i) > 0
            pos_arr(i) = pos_arr(i) + cur_move(i);
        else
            neg_arr(i) = -neg_arr(i) + cur_move(i);
        end
    end
    
    if ~ishandle(ButtonHandle)
        break;
    end
    waitfor(r);
end
tEnd = toc(tStart);
joy.reset();

