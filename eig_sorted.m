function [U, lambda] = eig_sorted(A, varargin)
% returns an eigendecomposition of A, with egienvalues sorted from large to
% small.

[U, lambda] = eig(A, 'vector', varargin{:});
[lambda,i] = sort(lambda, 'descend');
U = U(:,i);

end

