clc
close all;
clear all;
%-------------------------------------------------------------------------%
%                         INITIALIZATION    
%-------------------------------------------------------------------------%
% E = Total electric field matrix using Poisson's equation
% V = Potential matrix
% Nx = Number of grid points in X- direction
% Ny = Number of grid points in Y-Direction
%-------------------------------------------------------------------------%
% Enter the dimensions
qi= 1;
e_charge = 1.602e-19;
eps = 8.854*(10^-12);
res = 20;
m_Xe = 2.1801714e-25; %kg
Nx = 51;     % Number of X-grids
Ny = 51;     % Number of Y-grids
mpx = ceil(Nx/2); % Mid-point of x
mpy = ceil(Ny/2); % Mid point of y
Ni = 50;  % Number of iterations for the Poisson solver
V = zeros(Nx,Ny);   % Potential (Voltage) matrix
T = 0;            % Top-wall potential
B = 0;            % Bottom-wall potential
L = 30;            % Left-wall potential
R = 0;            % Right-wall potential
%-------------------------------------------------------------------------%
% Initializing edges potentials
%-------------------------------------------------------------------------%
V(1,:) = L;
V(Nx,:) = R;
V(:,1) = B;
V(:,Ny) = T;
%-------------------------------------------------------------------------%
% Initializing Corner potentials
%-------------------------------------------------------------------------%
V(1,1) = 0.5*(V(1,2)+V(2,1));
V(Nx,1) = 0.5*(V(Nx-1,1)+V(Nx,2));
V(1,Ny) = 0.5*(V(1,Ny-1)+V(2,Ny));
V(Nx,Ny) = 0.5*(V(Nx,Ny-1)+V(Nx-1,Ny));
%-------------------------------------------------------------------------%
% -------------------------------------------------------------------------%
% Initializing Particle Properties
% -------------------------------------------------------------------------%
mat_size = 51; % particle matrix size
Position_mat = zeros(mat_size,mat_size);
Time_mat = zeros(mat_size,mat_size);%initializing Particle Matrix
% -------------------------------------------------------------------------%
t1 = 5; %Thickness of screen Grid
t2 = 8; %Thickness of Acc Grid
g = 9; % Gap Between Screen And Acc Grid
r_s = 16; % Radius of Screen Grid
r_a = 7; % Radius of Acc Grid
lp_s = 14;   % Length of plate in terms of number of grids 
lp_a = 18;   % Length of plate in terms of number of grids  
pp_s = 13; %Position of plate_1 on x axis
pp_a = pp_s + t1 + g; %Position of plate_2 on x axis


for z = 1:Ni    % Number of iterations
    for i=2:Nx-1
        for j=2:Ny-1
% -------------------------------------------------------------------------%
            % The next lines are meant to force the matrix to hold the 
            % potential values for all iterations
                V(1:mpy - r_s, pp_s:pp_s+t1) = 1200;
                V(mpy + r_s:51, pp_s:pp_s+t1) = 1200;
                V(1:mpy - r_a, pp_a:pp_a+t2) = -500;
                V(mpy + r_a:51,  pp_a:pp_a+t2) = -500;
% -------------------------------------------------------------------------%
                V(i,j)=0.25*(V(i+1,j)+V(i-1,j)+V(i,j+1)+V(i,j-1));
        end
    end      
end
% Take transpose for proper x-y orientation
A = gradient(V);
[Ex,Ey]=gradient(V);
Ex = -Ex;
Ey = -Ey;

% Electric field Magnitude
E = (qi/(4*pi*eps))* (1./Ex.^2+Ey.^2);  
x = (1:Nx);
y = (1:Ny);

% Contour Display for electric potential
figure(1)
contour_range_V = -1201:0.5:1201;
contour(x,y,V,contour_range_V,'linewidth',0.05);
axis([min(x) max(x) min(y) max(y)]);
colorbar('location','eastoutside','fontsize',10);
xlabel('x-axis in meters','fontsize',10);
ylabel('y-axis in meters','fontsize',10);
title('Electric Potential distribution, V(x,y) in volts','fontsize',10);
h1=gca;
set(h1,'fontsize',10);
fh1 = figure(1); 
set(fh1, 'color', 'white')


% Quiver Display for electric field Lines
figure(2)
contour(x,y,E,'linewidth',0.5);
hold on, quiver(x,y,Ex,Ey,2)
title('Electric field Lines, E (x,y) in V/m','fontsize',14);
axis([min(x) max(x) min(y) max(y)]);
colorbar('location','eastoutside','fontsize',14);
xlabel('x-axis in meters','fontsize',14);
ylabel('y-axis in meters','fontsize',14);
h3=gca;
set(h3,'fontsize',14);
fh3 = figure(2); 
set(fh3, 'color', 'white')
acc_x = zeros(1,Ni); 
acc_y = zeros(1,Ni);
vel_x =  zeros(1,Ni);
vel_y =  zeros(1,Ni);
time = zeros(1,Ny);
Pos_x = zeros(1, Ni);
Pos_y = zeros(1, Ni);
i = 26;
j = 2;
min_p = 0.01; %mm
max_p = 0.1; %mm


for z = 2:Ni    % Number of iterations
    while i<51
        while j<51    % Number of iterations
    %Potential = [A(i+1,j), A(i+1,j+1), A(i,j+1), A(i-1,j+1), A(i-1,j), A(i-1,j-1), A(i,j-1), A(i+1,j-1)];
    %Potential = [A(i+1,j), A(i,j+1), A(i-1,j), A(i,j-1)]
    Fx = Ex(i,j) * qi * e_charge * (-1);
    Fy = Ey(i,j) * qi * e_charge * (-1);
    acc_x(1,z) = (Fx./m_Xe) * 10e-9; %mm/ms^2
    acc_y(1,z) = (Fy./m_Xe) * 10e-9; %mm/ms^2
    del_t = 0.01;
    for k=1:Ni
        Pos_x(1, z) = Pos_x(1,z-1) + (vel_x(1,z) + (acc_x(1,z)*(del_t)))*del_t;
        Pos_y(1, z) = Pos_y(1,z-1) + (vel_y(1,z) + (acc_y(1,z)*(del_t)))*del_t;
        if abs(Pos_x(1,z) - Pos_x(1,z-1)) < min_p; or abs(Pos_y(1,z) - Pos_y(1,z-1)) < min_p
            del_t = 2 * del_t;
        elseif abs(Pos_x(1,z) - Pos_x(1,z-1)) > max_p; or abs(Pos_y(1,z) - Pos_y(1,z-1)) > max_p
            del_t = del_t/2;
        end
    end
        end
    end
end

figure(4)
plot(acc)
%title('Acceleration','fontsize',14);
% hold on 
figure(5)
plot(vel)
%title('Velocity','fontsize',14, 'r');
figure(6)
plot(state_mat)
%title('Position','fontsize', 14, 'k--');
hold off
 % this is a new model

