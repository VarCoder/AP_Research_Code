ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'End Trial', ...
                         'Callback', 'delete(gcbf)');


% joy = joy_input;
mouse.init();
% flush(mouse.joy);
pos_arr = zeros(1,6);
neg_arr = zeros(1,6);

r = rateControl(100);  %loop at 100 hz, this is the robot's only instruction speed
reset(r); %e documentation says to do this before loops

drawnow; % draw estop
tStart = tic;
while 1
%     tic
    cur_mode = mouse.mode;
    mouse.run();
    
    mouse.genCmd();
    cur_move = mouse.cartcmd;
    mouse.sendCmd();
    new_mode = mouse.mode;

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
%     toc
end
tEnd = toc(tStart);
pos_arr
neg_arr
ratios = pos_arr/neg_arr;
ratios(isnan(ratios))=0;
