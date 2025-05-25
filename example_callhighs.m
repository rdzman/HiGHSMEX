% This script provides examples for the different use cases of the
% callhighs function.
% Run this script section by section. Each section provides examples for
% different features of HiGHS.
%
% Author: Savyasachi Singh
%
% Covered by the MIT License (see LICENSE file for details).
% See https://github.com/savyasachi/HiGHSMEX for more information.

%% Get version of HiGHS, and the MATLAB class corresponding to the HighsInt (C++ integer type)

clc, clearvars

ver = callhighs("ver");
intType = callhighs("intType");
fprintf('HiGHS version is v%s.\nHighsInt type is %s.\n', ver, intType)
fprintf('Press ENTER to continue.\n'), pause, clc

%% Default values of the user-settable HiGHS options

defopts = callhighs("defopts");
fprintf('Default values of the HiGHS options are\n')
disp(defopts)
fprintf('Press ENTER to continue.\n'), pause, clc

%% Solve LP and MILP

% This example is taken from https://ergo-code.github.io/HiGHS/stable/interfaces/cpp/library/

% Min    f  =  x_0 +  x_1
% s.t.                x_1 <= 7
%        5 <=  x_0 + 2x_1 <= 15
%        6 <= 3x_0 + 2x_1
% 0 <= x_0 <= 4; 1 <= x_1

c = [1 1];
A = [0 1; 1 2; 3 2];
L = [-inf 5 6]; U = [7 15 inf];
l = [0 1]; u = [4 inf];

% Solve the LP
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u);
fprintf('\nLP solution is\n'), disp(soln.col_value)
fprintf('LP model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

% Solve the MILP. For the above LP declare the optimization variables as integers.
c = {[1 1], 0}; % Explicitly define zero offset for the linear objective
integrality = ["i"; "i"]; % x_0 and x_1 should be integers
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality);
fprintf('\nMILP solution is\n'), disp(soln.col_value)
fprintf('MILP model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

% Solve the MILP but this time maximize the objective. Also suppress HiGHS
% messages that are printed on the MATLAB console.
options = struct("log_to_console", false); % Specify the option "log_to_console" which should be a logical type.
options = highsoptset("log_to_console", 0); % Specify the option "log_to_console" as a double. It will be cast to the appropriate type.
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality, options, "max");
fprintf('\nMILP solution is\n'), disp(soln.col_value)
fprintf('MILP model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

%% Solve QP. Also perform hot-starting.

% This example is taken from the documentation of the MATLAB's quadprog function.
Q = [1 -1; -1 2];
c = [-2; -6];
A = [1 1; -1 2; 2 1];
U = [2; 2; 3];

% Solve the QP
[soln, info, opts, basis] = callhighs(c, A, [], U, [], [], Q);
% soln.col_value % should be [0.6667; 1.3333]
fprintf('\nQP model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

% Hot starting with solution struct and basis struct
[soln, info, opts, basis] = callhighs(c, A, [], U, [], [], Q, [], [], [], soln, basis);
% soln.col_value  % should be [0.6667; 1.3333]
% info.qp_iteration_count % should be 0 because we hot started from the optimal point
fprintf('\nQP model status is %s. After hot-start QP took %d iterations to solve. \nPress ENTER to continue.\n', info.model_status_string, info.qp_iteration_count), pause, clc

% Hot starting with solution vector and basis struct
[soln, info, opts, basis] = callhighs(c, A, [], U, [], [], Q, [], [], [], soln.col_value, basis);
% soln.col_value  % should be [0.6667; 1.3333]
% info.qp_iteration_count % should be 0 because we hot started from the optimal point
fprintf('\nQP model status is %s. After hot-start QP took %d iterations to solve. \nPress ENTER to continue.\n', info.model_status_string, info.qp_iteration_count), pause, clc

% Hot starting with random solution vector
[soln, info, opts, basis] = callhighs(c, A, [], U, [], [], Q, [], [], [], randn(2, 1));
% soln.col_value  % should be [0.6667; 1.3333]
% info.qp_iteration_count % should be 1
fprintf('\nQP model status is %s. After hot-start QP took %d iterations to solve. \nPress ENTER to continue.\n', info.model_status_string, info.qp_iteration_count), pause, clc


%% Solve QP with sparse A and Q matrices

Q = diag(1:3, -2) + diag(1:5);
A = [
    1	0	1	1	0
    1	1	0	0	0
    0	1	1	0	1
    1	0	1	0	1
    1	1	1	0	0
    0	0	1	1	0
    0	0	1	1	0
    1	1	0	0	1
    1	1	1	1	1
    1	1	0	0	1
    ];
L = [3, 7, 6, 1, 2, 5, 9, 3, 6, 2];
c = [0.5, -0.5, 0.01, 0.3, 0.8];
options = highsoptset("log_to_console", 0);

% Solve the QP
[soln, info, opts, basis] = callhighs(c, A, L, [], [], [], Q, [], options);
fprintf('\nQP model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

% Solve the same QP but this time with sparse A and Q
[soln, info, opts, basis] = callhighs(c, sparse(A), L, [], [], [], sparse(Q), [], options);
fprintf('\nQP model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

%% Solve multi-objective LP and MILP

% This example is taken from the test code in HiGHS/check/TestMultiObjective.cpp

intType = callhighs("intType");
A = highsSparseToMatrix(3, 2, [0, 3, 6], [0, 1, 2, 0, 1, 2], [3, 1, 1, 1, 1, 2]);
L = -inf(3, 1); U = [18; 8; 14];
l = [0; 0]; u = inf(2, 1);
integrality = ["c"; "c"];
clear c
% Define the first linear objective
c(1).weight = -1;
c(1).offset = -1;
c(1).coefficients = [1, 1];
c(1).abs_tolerance = 0.0;
c(1).rel_tolerance = 0.0;
c(1).priority = cast(0, intType); % When blend_multi_objectives is true then priority is ignored. But the linear objective struct should still have the priority field.
% Define the second linear objective
c(2).weight = 1e-4;
c(2).offset = 0;
c(2).coefficients = [1, 0];
c(2).abs_tolerance = 0.0;
c(2).rel_tolerance = 0.0;
c(2).priority = cast(0, intType);

% Solve multi-objective LP with blending
options = highsoptset("blend_multi_objectives", 1);
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality, options);
% soln.col_value % should be [2; 6]
fprintf('\nMulti-objective LP (with blending) model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc


% Solve multi-objective LP with lexicographic optimization (with zero abs/rel_tolerance)
options = highsoptset("blend_multi_objectives", 0); % lexicographic optimization
% [soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality, options); % This should result in error because both the linear objectives have the same priority
c(1).priority = cast(10, intType);
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality, options);
% soln.col_value % should be [2; 6]
fprintf('\nMulti-objective LP (with lexicographic optimization) model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

% Solve multi-objective LP with lexicographic optimization after modifying the first linear objective
options = highsoptset("blend_multi_objectives", 0); % lexicographic optimization
c(1).coefficients = [1.0001, 1];
c(1).abs_tolerance = 1e-5;
c(1).rel_tolerance = 0.05;
c(2).weight = 1e-3;
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality, options);
% soln.col_value % should be [4.9; 3.1]
fprintf('\nMulti-objective LP (with lexicographic optimization) model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

% Solve multi-objective MILP with lexicographic optimization
integrality = ["i"; "i"];
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality, options);
% soln.col_value % should be [5; 3]
fprintf('\nMulti-objective MILP (with lexicographic optimization) model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

% Solve multi-objective LP with lexicographic optimization after modifying the abs_tolerance of first linear objective
c(1).abs_tolerance = inf;
integrality = ["c"; "c"];
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality, options);
% soln.col_value % should be [1.30069; 6.34966]
fprintf('\nMulti-objective LP (with lexicographic optimization) model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

% Solve multi-objective MILP with lexicographic optimization
integrality = ["i"; "i"];
[soln, info, opts, basis] = callhighs(c, A, L, U, l, u, [], integrality, options);
% soln.col_value % should be [2; 6]
fprintf('\nMulti-objective MILP (with lexicographic optimization) model status is %s.\nPress ENTER to continue.\n', info.model_status_string), pause, clc

%%

function A = highsSparseToMatrix(nrow, ncol, start, index, values)
% Inputs start and index must be 0 based indices (C style)

A = zeros(nrow, ncol);
for j = 1:ncol
    ii = start(j)+1:start(j+1);
    A(index(ii)+1, j) = values(ii);
end

end

% EOF