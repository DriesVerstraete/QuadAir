function [Force, Moment] = Force_Moment(rho, Aircraft, AeroMatrices, STATE, CONTROL)


%% 4. Make vector X_tilde
X_tilde = Make_X_tilde_QuadAir1_3(STATE, CONTROL, 2, 1, Aircraft);

%% Calculate viscous force and moment
F_visc = zeros(1,3);
M_visc = zeros(1,3);
strips = size(AeroMatrices.Strips,1);
r_Bo_CG = Aircraft.r_bo_CG;
for s = 1:strips
    % point of application of viscous force
    r_P_Bo_Std = AeroMatrices.Strip.quarterChordPoint(s,:);
    r_P_CG = r_Bo_CG + r_P_Bo_Std;
    
    Ss = AeroMatrices.Strip.chord(s)*AeroMatrices.Strip.width(s);
    
    % calculate local velocity vector
    Vel_inv = (AeroMatrices.VelMat_Strips(:,:,s)*X_tilde)';
    
    % compute total circulation for strip
    Gamma_Ti = AeroMatrices.Strip.width(s)*(AeroMatrices.Gamma_total_strip(s,:)*X_tilde);
    
    % vector projections for local velocity and alfa
    x_vec = [1 0 0];
    b_vec = AeroMatrices.Strip.bound(s,:);
    n_vec = cross(x_vec,b_vec);
    n_vec = n_vec/norm(n_vec);
    b_vec = cross(n_vec, x_vec);
    
    
    Vs = Vel_inv - dot(Vel_inv, b_vec)*b_vec;
    Cl_s = 2*Gamma_Ti/(Ss*norm(Vs));
    Cd_s = 0.01 + 0.05*Cl_s^2;
    % Calculate viscous drag force
    Ds = 0.5*rho*Ss*Cd_s*norm(Vs)*Vs;
    F_visc = F_visc + Ds;
    M_visc = M_visc + cross(r_P_CG,Ds);
    
    
end
F_visc


%% 5.a) Compute net aerodynamic force
fprintf('\n***********************')
fprintf('\nNet aerodynamic force: (N)')
fprintf('\n***********************\n')
Fx = rho*X_tilde'*AeroMatrices.Px*X_tilde + F_visc(1);    % (N)
Fy = rho*X_tilde'*AeroMatrices.Py*X_tilde + F_visc(2);    % (N)
Fz = rho*X_tilde'*AeroMatrices.Pz*X_tilde + F_visc(3);    % (N)

Dx_inv = F_visc(1)
Fx_inv = rho*X_tilde'*AeroMatrices.Px*X_tilde

%% 5.b) Compute net aerodynamic moment about CG
fprintf('\n***********************')
fprintf('\nNet aerodynamic moment about CG: (N.m)')
fprintf('\n***********************\n')
Mx_CG = rho*X_tilde'*AeroMatrices.Qx*X_tilde + M_visc(1); % (N.m)
My_CG = rho*X_tilde'*AeroMatrices.Qy*X_tilde + M_visc(2); % (N.m)
Mz_CG = rho*X_tilde'*AeroMatrices.Qz*X_tilde + M_visc(3); % (N.m)

Force = [Fx, Fy ,Fz];
Moment = [Mx_CG, My_CG, Mz_CG];