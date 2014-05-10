% Berechnet die Steigungen des natuerlichen, kubischen Splines mit den
% Stuetzstellen (x, y).
function v = spline_natural (x, y)
  % Abstaende von x(i) und x(i + 1)
  h = x(2:end) - x(1:end - 1);

  % Steigungen von (x(i), y(i)) nach (x(i + 1), y(i + 1))
  d = (y(2:end) - y(1:end - 1)) ./ h;

  [m, b] = spline_matrix(x, y);

  n = length(x) - 1;
  M = zeros(n + 1, n + 1);
  M(2:end - 1, :) = m;

  M(1, 1) = 4 / h(1);
  M(1, 2) = 2 / h(1);
  M(end, end - 1) = 2 / h(end);
  M(end, end) = 4 / h(end);

  B = [3 * d(1) / h(1); b; 3 * d(end) / h(end)];

  v = M \ B;
end
