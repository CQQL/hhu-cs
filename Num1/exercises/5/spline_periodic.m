% Berechnet die Steigungen des periodischen, kubischen Splines mit den
% Stuetzstellen (x, y).
function v = spline_periodic (x, y)
  % Abstaende von x(i) und x(i + 1)
  h = x(2:end) - x(1:end - 1);

  % Steigungen von (x(i), y(i)) nach (x(i + 1), y(i + 1))
  d = (y(2:end) - y(1:end - 1)) ./ h;

  [m, b] = spline_matrix(x, y);

  n = length(x) - 1;
  M = zeros(n + 1, n + 1);
  M(2:end - 1, :) = m;

  % s''(x_0) = s''(x_n)
  M(1, 1) = 4 / h(1);
  M(1, 2) = 2 / h(1);
  M(1, end - 1) = 2 / h(end);
  M(1, end) = 4 / h(end);

  % v_0 = v_n
  M(end, 1) = -1;
  M(end, end) = 1;

  B = [6 * (d(1) / h(1) + d(end) / h(end)); b; 0];

  v = M \ B;
end
