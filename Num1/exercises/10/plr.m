% Berechne die pivotisierte LR-Zerlegung von A so, dass PA = LR gilt.
function [P, L, R] = plr (A)
  [n, m] = size(A);
  P = eye(n);
  L = eye(n);
  R = A;

  for i = 1:n
    [m, l] = max(abs(R(i:end, i)));
    l = i + l - 1;
    m = A(l, i);
    P([i, l], :) = P([l, i], :);
    R([i, l], :) = R([l, i], :);

    for j = (i + 1):n
      L(j, i) = R(j, i) / R(i, i);

      for k = 1:n
        R(j, k) = R(j, k) - L(j, i) * R(i, k);
      end
    end

    L([i, l], 1:(i - 1)) = L([l, i], 1:(i - 1));
  end
end
