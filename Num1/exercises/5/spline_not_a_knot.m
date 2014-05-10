% Berechnet die Steigungen des kubischen not-a-knot Splines mit den
% Stuetzstellen (x, y).
function v = spline_not_a_knot (x, y)
  % Abstaende von x(i) und x(i + 1)
  h = x(2:end) - x(1:end - 1);

  % Steigungen von (x(i), y(i)) nach (x(i + 1), y(i + 1))
  d = (y(2:end) - y(1:end - 1)) ./ h;

  [m, b] = spline_matrix(x, y);

  n = length(x) - 1;
  M = zeros(n + 1, n + 1);
  M(2:end - 1, :) = m;

  M(1, 1) = 1 / h(1);
  M(1, 2) = 1 / h(1) - 1 / h(2);
  M(1, 3) = -1 / h(2);

  M(end, end - 2) = 1 / h(end - 1);
  M(end, end - 1) = 1 / h(end - 1) - 1 / h(end);
  M(end, end) = -1 / h(end);

  B = [2 * (d(1) / h(1) - d(2) / h(2)); b; 2 * (d(end - 1) / h(end - 1) - d(end) / h(end))];

  v = M \ B;
end
