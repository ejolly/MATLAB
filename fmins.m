function [x, options] = fmins(funfcn,x,options,grad,varargin)
%FMINS  Minimize function of several variables.
%   FMINS has been replaced with FMINSEARCH.  FMINS currently works but
%   will be removed in the future.  Use FMINSEARCH instead.
%
%   X = FMINS('F',X0) attempts to return a vector X which is a local
%   minimizer of F(x) near the starting vector X0.  'F' is a string
%   containing the name of the objective function to be minimized,
%   a string expression representing the objective function, or an
%   inline function object. F(x) should be a scalar valued function
%   of a vector variable.
%
%   X = FMINS('F',X0,OPTIONS) uses a vector of control parameters. If
%   OPTIONS(1) is positive, intermediate steps in the solution are
%   displayed; the default is OPTIONS(1) = 0.  OPTIONS(2) is the
%   termination tolerance for x; the default is 1.e-4.  OPTIONS(3) is
%   the termination tolerance for F(x); the default is 1.e-4.
%   OPTIONS(14) is the maximum number of function evaluations; the
%   default is OPTIONS(14) = 200*length(x). The other components of
%   OPTIONS are not used by FMINS. For more information, see FOPTIONS.
%
%   X = FMINS('F',X0,OPTIONS,[],P1,P2,...) provides for additional
%   arguments which are passed to the objective function, F(X,P1,P2,...)
%   Pass an empty matrix for OPTIONS to use the default values.
%
%   [X,OPTIONS] = FMINS(...) returns the number of function evaluations
%   in OPTIONS(10).
%
%   FMINS uses the Nelder-Mead simplex (direct search) method.
%
%   See also FMIN, FOPTIONS.

%   Reference: Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright,
%   Paul E. Wright, "Convergence Properties of the Nelder-Mead Simplex
%   Algorithm in Low Dimensions", May 1, 1997.  To appear in the SIAM
%   Journal of Optimization.
%
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.23 $  $Date: 2002/04/08 20:26:45 $

if nargin<3, options = []; end
options = foptions(options);
prnt = options(1);
tolx = options(2);
tolf = options(3);
% The input argument grad is there for compatibility with FMINU in
% the Optimization Toolbox, but is not used by this function.

% Convert to inline function as needed.
funfcn = fcnchk(funfcn,length(varargin));

n = prod(size(x));
if (~options(14))
  options(14) = 200*n;
end

% %  Generate warning
% warning('MATLAB:fmins:ObsoleteFunction', ...
%    ['FMINS is obsolete and has been replaced by FMINSEARCH.\n         ',...
%    'FMINS now calls FMINSEARCH which uses the following syntax:\n',...
%    '   [X,FVAL,EXITFLAG,OUTPUT] =FMINSEARCH(FUN,X0,OPTIONS,P1,P2,...)\n',...
%    '         Use OPTIMSET to define optimization options, or type\n',...
%    '         ''edit fmins'' to view the code used here.  FMINS will be\n',...
%    '       removed in the future; please use FMINSEARCH with the newsyntax.'])

%  Setup options and call FMINSEARCH
%  Uses options 1, 2, 3, 14
%  Options 1
if prnt==0; Display='off';else;Display='iter';end
%  Options 2, 3, 14
TolX = options(2); TolFun = options(3); MaxFunEvals = options(14);
Options = optimset('TolX',TolX,'TolFun',TolFun,'MaxFunEvals',MaxFunEvals);
[x,FVAL,EXITFLAG,OUTPUT] = fminsearch(funfcn,x,Options,varargin{:});
options(8)=FVAL;  %  This option was undocumented
options(10)=OUTPUT.funcCount;