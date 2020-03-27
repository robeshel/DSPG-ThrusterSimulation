clc
close all;
clear all;
tic
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
L = 0;            % Left-wall potential
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
t1 = 5;
t2 = 8;
g = 9;
r_1 = 11;
r_2 = 7;
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
                V(pp_s:pp_s+t1, mpy + r_1:mpy+r_1+lp_s) = 1200;
                V(pp_s:pp_s+t1, mpy - r_1 - lp_s:mpy - r_1) = 1200;
                V(pp_a:pp_a+t2, mpy + r_2:mpy+r_2+lp_a) = -500;
                V(pp_a:pp_a+t2, mpy-r_2-lp_a:mpy - r_2) = -500;
% -------------------------------------------------------------------------%
                V(i,j)=0.25*(V(i+1,j)+V(i-1,j)+V(i,j+1)+V(i,j-1));
        end
    end      
end
% Take transpose for proper x-y orientation
V = V';
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
acc = zeros(1,Ny); 
vel =  zeros(1,Ny);
time = zeros(1,Ny);
position = zeros(100,100);
i = 26;
j = 2;

timer = toc
disp(timer)

for z = 2:Ni    % Number of iterations
    while i<40
        while j<40    % Number of iterations
    Potential = [A(i+1,j), A(i+1,j+1), A(i,j+1), A(i-1,j+1), A(i-1,j), A(i-1,j-1), A(i,j-1), A(i+1,j-1)];
    Index = find(max(abs(Potential)));
    if Index == 1
       E_val = V(i+1,j);
    elseif Index == 2
       E_val = V(i+1,j+1);
    elseif Index == 3
       E_val = V(i,j+1);
    elseif Index == 4
       E_val = V(i-1,j+1);
    elseif Index == 5
       E_val = V(i-1,j);
    elseif Index == 6
       E_val = V(i-1,j-1);
    elseif Index == 7
       E_val = V(i,j-1);
    elseif Index == 8
       E_val = V(i+1,j-1);
    end
   F =  qi * e_charge * E_val * (-1);
   acc(1,z) = (F./m_Xe) * 10e-16; %0.1 mm/ns^2
   vel(1, z) = vel(1,z-1)^2 + 2 * acc(1,z); % 0.1 m/ns;
   time(1, z) = vel(1,z-1) + (0.5)*(acc(1,z));%ns;
   
   position(i,j) = 1;
   
     if Index == 1
       i = i+1;
    elseif Index == 2
       i = i+1;
       j = j+1;
    elseif Index == 3
       j = j+1;
    elseif Index == 4
        i = i-1;
        j = j+1;
    elseif Index == 5
       i = i-1;
    elseif Index == 6
       i = i-1;
       j = j-1;
    elseif Index == 7
       j = j-1;
    elseif Index == 8
       i = i+1;
       j = j-1;
     end
   
        end
    end
end

figure(4)
plot(acc)
% title('Acceleration','fontsize',14);
% hold on 
figure(5)
plot(vel)
% title('Velocity','fontsize',14, 'r');
figure(6)
plot(state_mat)
%title('Position','fontsize', 14, 'k--');
hold off
 % this is a new model