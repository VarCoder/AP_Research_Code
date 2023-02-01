sens = 1/6.8;
while 1
    mouse = mouse_input(0,sens);
    calibration;
    bayoptim = bayopt(mouse.scale,mean(ratios)*tEnd);
    newsens = bayoptim.opt_acqusition(mouse.scale);
    percentdiff = (mouse.scale-newsens)/mouse.scale;
%     disp("New Sensitivity is %f%% of the last sensitivity!",percentdiff )
    mouse.delete();
    clear mouse;
    sens = newsens(1);
end