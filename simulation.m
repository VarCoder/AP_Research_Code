jaco = loadrobot("kinovaJacoJ2N6S300");
jaco.DataFormat = 'column';
q_home = [4.8055,2.9211,0.9989,4.2076,1.4420,1.3220,0,0,0]';
eeName = 'j2n6s300_end_effector';
T_home = getTransform(jaco,q_home,eeName);

ik = inverseKinematics('RigidBodyTree',jaco);
ik.SolverParameters.AllowRandomRestart = false;

weights = [1,1,1,1,1,1];
q_init = q_home;

numJoints = size(q_home,1);
numWaypoints = 10;
% Take input as a float list of sz 5
qs = zeros(numWaypoints,numJoints);

% ButtonHandle = uicontrol('Style', 'PushButton', ...
%                          'String', 'Stop loop', ...
%                          'Callback', 'delete(gcbf)');
dummyInput = [0 0 0 0 6.8]/6.8; % order is +x, -x, +y, -y, m_switch
mode = 0;
dest = [0 0 0];
cur = [0 0 0];

figure; set(gcf,'Visible','on');
ax = show(jaco,q_home);
ax.CameraPositionMode='auto';
hold on;

r = robotics.Rate(30);
% while true
%     if dummyInput > 0
%         mode = mod(mode+1,2);
%     end
% if any(dummyInput)
switch mode
    case 0 % x-y translation
        dest = cur + [dummyInput(2)-dummyInput(3),dummyInput(4)-dummyInput(5),0] * 0.9/6.8;
    case 1 % z transformation
        dest = cur + [0,0,dummyInput(2)-dummyInput(3)] * 0.9/6.8;                
end
points = cat(1,linspace(cur(1),dest(1),numWaypoints),linspace(cur(2),dest(2),numWaypoints),linspace(cur(3),dest(3),numWaypoints))';
% cur
% dest
points
% end
    

%     if ~ishandle(ButtonHandle) % if the button is pressed close the program (only exit condition)
%         break;
%     end
%     clear points;
% end

