function varargout = callhighs(varargin)
% MATLAB mex interface to the HiGHS optimization library.
% https://github.com/ERGO-Code/HiGHS
% HiGHS can solve large scale quadratic programs (QP), linear programs
% (LP), and, mixed integer programs (MIP). It can also perform
% multi-objective optimization for the linear objectives.
%
% HiGHS solves the following program with variable x
%            T
%           x  ⋅ Q ⋅ x     T
% minimize  ---------- + c  ⋅ x + offset
%                2
% subject to
%  L <= A ⋅ x <= U
%  l <= x <= u
% where,
% Q is a n x n symmetric matrix.
% A is a m x n matrix.
% L, U are m x 1 vectors.
% c, l, u are n x 1 vectors.
% x is a n x 1 vector. Each element of vector x can be continuous, or,
% an interger.
% All the matrices and vectors in the above program are real valued. See
% the documentation of HiGHS for the details.
%
% USAGE:
% 1) ver = callhighs("ver")
%    Returns the HiGHS version string.
%
% 2) intType = callhighs("intType")
%    Returns the MATLAB class corresponding to HighsInt type. This will be
%    "int32" or "int64".
%
% 3) defopts = callhighs("defopts")
%    Returns the default values for all the user settable options of HiGHS
%    as a MATLAB struct. All the HiGHS options are listed at the following
%    webpage.
%    https://ergo-code.github.io/HiGHS/stable/options/definitions/
%
% 4) [soln, info, opts, basis] = callhighs(c, A, L, U, l, u, Q, integrality, options, objSense, setSoln, setBasis)
%    Solves the optimization problem. First four inputs (c, A, L, and, U)
%    are required and the rest are optional. Pass [] for any input argument
%    (except c and A) to use the default value for that argument.
%
% INPUTS:
% c - Vector of column costs in the objective. Offset is set to zero.
%                             - OR -
%     It should be a cell array (size: 1x2, or, 2x1) where, c{1} is the
%     vector of column costs, and, c{2} is the offset in the objective.
%                             - OR -
%     It should be an array of structs for multi-objective optimization. See
%     https://ergo-code.github.io/HiGHS/stable/guide/further/#guide-multi-objective-optimization
%     The fields of the struct should be same as the HighsLinearObjective
%     C++ struct as described here
%     https://ergo-code.github.io/HiGHS/stable/structures/structs/HighsLinearObjective/
% A - Linear inequality constraint matrix. It can be full or sparse.
% L - Lower bound vector for the linear inequality constraint. Pass [] to
%     set the lower bound to negative infinity.
% U - Upper bound vector for the linear inequality constraint. Pass [] to
%     set the upper bound to infinity.
% l - Lower bound vector for the optimization variable. Pass [] to set the
%     lower bound to negative infinity.
% u - Upper bound vector for the optimization variable. Pass [] to set the
%     upper bound to infinity.
% Q - Symmetric matrix for the quadratic objective. It can be full or
%     sparse. Pass [] to set Q equal to zero.
% integrality - Vector of strings to specify the type of optimization
%               variable. The possible strings and their meaning are
%               "c"  - Continuous
%               "i"  - Integer
%               "sc" - Semi-continuous
%               "si" - Semi-integer
%               "ii" - Implied integer
%               Pass [] to omit setting the integrality. See
%               https://ergo-code.github.io/HiGHS/stable/structures/enums/#HighsVarType
% options - MATLAB struct with values for the HiGHS user-settable options.
%           Pass [] to use the default values for the user-settable options.
%           See https://ergo-code.github.io/HiGHS/stable/options/definitions/
% objSense - It should be "min" or "max" to minimize or maximize the
%            objective. Pass [] to minimize the objective.
% setSoln - Set the HiGHS starting point for hot-start. See
%           https://ergo-code.github.io/HiGHS/stable/guide/further/#hot-start
%           It should be a vector
%                             - OR -
%           It should be struct with same fields as the HighsSolution C++
%           struct as described here
%           https://ergo-code.github.io/HiGHS/stable/structures/structs/HighsSolution/
%                             - OR -
%           It should be [] to omit setting the solution with HiGHS.
% setBasis - Set basis for HiGHS hot-starting. See
%            https://ergo-code.github.io/HiGHS/stable/guide/further/#hot-start
%            It should be struct with same fields as the HighsBasis C++
%            struct as described here
%            https://ergo-code.github.io/HiGHS/stable/structures/structs/HighsBasis/
%            The "col_status" and "row_status" fields of the basis struct
%            must be vector of strings. The possible strings and their
%            meaning are
%            "l" - Lower
%            "b" - Basic
%            "u" - Upper
%            "z" - Zero
%            "n" - Non basic
%            See https://ergo-code.github.io/HiGHS/stable/structures/enums/#HighsBasisStatus
%                             - OR -
%            It should be [] to omit setting the basis with HiGHS.
%
% OUTPUTS:
% soln - Solution struct returned by HiGHS. See
%        https://ergo-code.github.io/HiGHS/stable/structures/structs/HighsSolution/
% info - Solution information struct returned by HiGHS. See
%        https://ergo-code.github.io/HiGHS/stable/structures/structs/HighsInfo/
% opts - Struct containing the values of user settable options used by
%        HiGHS. See https://ergo-code.github.io/HiGHS/stable/options/definitions/
% basis - Basis struct returned by HiGHS. See
%         https://ergo-code.github.io/HiGHS/stable/structures/structs/HighsBasis/
%
% NOTE:
% The warning ID for all the warnings issued by callhighs is highs:mex. To
% turn off the warnings use warning("off", "highs:mex").
%
% CAUTION:
% Do NOT call the highsmex function directly in MATLAB, otherwise it would
% lead to a crash. Always use callhighs function.
%
% EXAMPLES:
% See MATLAB script example_callhighs.m for examples.
%
% Author: Savyasachi Singh
%
% Covered by the MIT License (see LICENSE file for details).
% See https://github.com/savyasachi/HiGHSMEX for more information.


% Out of process execution of highsmex function.
% https://www.mathworks.com/help/matlab/matlab_external/out-of-process-execution-of-c-mex-functions.html

persistent mh

if ~(isa(mh, "matlab.mex.MexHost") && isvalid(mh))
    mh = mexhost;
end

if nargin>1
    if issparse(varargin{2})
        varargin{2} = sparseMatrixToCell(varargin{2});
    end
end
if nargin>6
    if issparse(varargin{7})
        varargin{7} = sparseMatrixToCell(varargin{7});
    end
end

[varargout{1:nargout}] = feval(mh, "highsmex", varargin{:});

% ----------------------------------------------------------------------- %

function c = sparseMatrixToCell(A)

if ~nnz(A)
    c=[];
    return
end

c = cell(1, 5);
[c{1}, c{2}, c{3}] = find(A);
[c{4}, c{5}]=size(A);

% EOF
