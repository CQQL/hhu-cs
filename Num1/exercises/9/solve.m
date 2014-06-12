% Loese das Gleichungssystem Ax = b nach x auf
function x = solve (A, b)
  [L, R] = lr(A);
  n = length(b);
  x = zeros(n, 1);
  y = zeros(n, 1);

  % Ly = b loesen
  y(1) = b(1) / L(1, 1);
  for i = 2:n
    y(i) = (b(i) - L(i, 1:(i - 1)) * y(1:(i - 1))) / L(i, i);
  end

  % Rx = y loesen
  x(n) = y(n) / R(n, n);
  for i = ((n - 1):-1:1)
    x(i) = (y(i) - R(i, (i + 1):n) * x((i + 1):n)) / R(i, i);
  end
end
