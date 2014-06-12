% Berechne die LR-Zerlegung von A
function [L, R] = lr (A)
  [n, m] = size(A);
  L = eye(n);
  R = A;

  for i = 1:n
    for j = (i + 1):n
      L(j, i) = R(j, i) / R(i, i);

      for k = 1:n
        R(j, k) = R(j, k) - L(j, i) * R(i, k);
      end
    end
  end
end
