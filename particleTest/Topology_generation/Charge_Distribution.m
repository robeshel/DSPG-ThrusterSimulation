clc 
clear

%-------------------------------------------------------------------------%
%                           LOADING THE INPUT FILES
%-------------------------------------------------------------------------%
load('Test') %Variable number for the test iteration
date_yes = char(datetime(2020,9,10));
folder_name = char(['Test_Data\' date_yes]);
Test = Test -1;
%-------------------------------------------------------------------------%

V = csvread([folder_name '\Test' num2str(Test) '_VtgDistMat.csv']);

Nx = size(V, 1);
Ny = size(V, 2);
cd_mat = zeros(Nx, Ny);

%-------------------------------------------------------------------------%
xn = 132; % Initial X position
yn =  126:378; % Initial Y position
Nj = 100000;
prt_in = yn(1,end) - yn(1,1) + 1;
% NPos_x = zeros(prt_in,Nj); % X position matrix to multiple trajectories
% NPos_y = zeros(prt_in,Nj); % Y position matrix to multiple trajectories
% time_step = zeros(prt_in,Nj);
Vx_new = zeros(prt_in,Nj);
Vy_new = zeros(prt_in,Nj);
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
f_bohm = 1;
v_bohm = f_bohm * sqrt(100* 1.60217662 * (10^-19) *3/(100 * 2.18017 * 10^-25));
tar_bm_crt = 0.001; %Ampere
beam_current = sum(cd_mat(:, end));
Clmb_chrg = 1.60217662 * 10^-19;
[Ex,Ey] = gradient(V);
del_x = 0.005 / (Nx-1); %m
del_y = del_x; %m
A_cell = del_x * del_y; %m*m
a = 0;
b = 0;
Vx_in = v_bohm;
Vy_in = 0;
%-------------------------------------------------------------------------%

NPos_x = csvread([folder_name '\Test' num2str(Test) '_NPos_x.csv']);
NPos_x = (reshape(NPos_x,[Nj, 253]))'; 
NPos_y = csvread([folder_name '\Test' num2str(Test) '_NPos_y.csv']);
NPos_y = (reshape(NPos_y,[Nj, 253]))';
time_step = csvread([folder_name '\Test' num2str(Test) '_TimeStep.csv']);
time_step = (reshape(time_step,[Nj, 253]))';

 p_dim = size(NPos_x,1);

pos_cellX = {};
pos_cellY = {};

for s = 1:p_dim
    [pos_cellX{s}, pos_cellY{s}] = Post_process(NPos_x(s,:), NPos_y(s,:));
end


% while beam_current < tar_bm_crt
%     cd_mat(150:350, 135) = cd_mat(135, 150:350) +  100 * Clmb_chrg/A_cell;
    for p = 1: p_dim-1
        y1 = yn(1,p)-0.5;
        x1 = xn-0.5;
       
            for r = 1:size(pos_cellX{p}, 2)
                x = pos_cellX{p}(1,r);
                y = pos_cellY{p}(1,r);
                del_t = time_step(p,r);
                
    %             while x1 < Nx || y1 < Ny || x1 > 0 || y1 > 0
    %               [x, y, Vx_new, Vy_new, del_t] = Simulation_Cd(x1, y1, Ex, Ey, Vx_in,Vy_in);
                    x2 = ceil(x);
                    y2 = ceil(y);
                    x3 = ceil(x);
                    y3 = floor(y);
                    i = ceil(y1);
                    j = ceil(x1);
                    if  x1 > Nx || y1 > Ny || x1 < 1 || y1 < 1
                        continue
                    else
                        cd_mat(i,j) = cd_mat(i, j) + (100 * Clmb_chrg/A_cell);
                        J_part =  cd_mat(i, j) / del_t;
                        
                        if J_part == inf
                            continue
                        else
                            a = cd_mat(i, j) + abs((100 * J_part * (del_t) * 10^-16 * (x2- x)*(y2-y)/(A_cell * del_x * del_y)));
                            b = cd_mat(i, j) + abs((100 * J_part * (del_t) * 10^-16 * (x3- x)*(y3-y)/(A_cell * del_x * del_y)));
                            c = cd_mat(i, j) + abs((100 * J_part * (del_t) * 10^-16 * (x2- x)*(y3-y)/(A_cell * del_x * del_y)));
                            d = cd_mat(i, j) + abs((100 * J_part * (del_t) * 10^-16 * (x3- x)*(y2-y)/(A_cell * del_x * del_y)));
                            cd_mat(i, j) = a + b + c + d;
                        end
                    end
                    
                    if abs(sqrt((x1-x)^2 + (y1-y)^2)) < 0.00001

                        continue
                    else
                        x1 = x;
                        y1 = y;
                        Vx_in = Vx_new;
                        Vy_in = Vy_new;
                        beam_current = beam_current + (cd_mat(i, end) * Vx_new(p,r));
                    end
            end
    %         beam_current = beam_current + (cd_mat(i, end) * Vx_new(p,r));
    end
    
% end

x = (1:Nx);
y = (1:Ny);

% Contour Display Charge Distribution
figure(2)
contour_range_V = -0.2:0.05:0.2;
contour(x,y,cd_mat,contour_range_V,'linewidth',0.5);
axis([min(x) max(x) min(y) max(y)]);
colorbar('location','eastoutside','fontsize',14);
h1=gca;
set(h1,'fontsize',14);
fh1 = figure(1); 
set(fh1, 'color', 'white')



%-------------------------------------------------------------------------%
%                       Writing Output File
%-------------------------------------------------------------------------%
if isfolder(folder_name)
    writematrix(cd_mat, [folder_name '\Test' num2str(Test) '_Chrg_distrb_Mat.csv'])  % writes the generated Charge distribution matrix to a given name
else
    mkdir(fullfile('Test_Data\', date))
    writematrix(cd_mat, [folder_name '\Test' num2str(Test) '_Chrg_distrb_Mat.csv'])  % writes the generated Charge distribution matrix to a given name
end

%-------------------------------------------------------------------------%


% NPos_x = zeros(25,Nj); % X position matrix to multiple trajectories
% NPos_y = zeros(25,Nj); % Y position matrix to multiple trajectories
% % Vx_in = v_bohm;
% % Vy_in = 0;
% srt_x = 130; % Initial X position
% r = 130:10:370; % Initial Y position
% for itr = 1:25
%     [NPos_x(itr,:), NPos_y(itr,:)] = Simulation(srt_x , r(1,itr), Ex, Ey);
% end
% NPos_x = csvread('NPos_x.csv');
% NPos_y = csvread('NPos_y.csv');
% time_step = csvread('time_step.csv');
% 
% p_dim = size(NPos_x, 1);
% pos_cellX = {};
% pos_cellY = {};
% 
% for s = 1:p_dim
%     [pos_cellX{s}, pos_cellY{s}] = Post_process(NPos_x(s,:), NPos_y(s,:));
% end
% 
% for s = 1:p_dim
%  pos_cellX{s} = round(pos_cellX{s});
%  pos_cellY{s} = round(pos_cellY{s});
% end
% 
% 
% for s = 1:p_dim
%     for t = 1:size(pos_cellX{s}, 2)
%         cd_mat(pos_cellX{s}(1,t),pos_cellY{s}(1,t)) = cd_mat(pos_cellX{s}(1,t),pos_cellY{s}(1,t)) + (100 * Clmb_chrg);
%     end
% end
