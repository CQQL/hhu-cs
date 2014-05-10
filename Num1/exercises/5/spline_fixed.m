% Berechnet die Steigungen des kubischen Splines mit festen Steigungen an den
% Enden mit den Stuetzstellen (x, y).
function v = spline_fixed (x, y, v0, vn)
  [m, b] = spline_matrix(x, y);

  n = length(x) - 1;
  M = zeros(n + 1, n + 1);
  M(2:end - 1, :) = m;
  M(1, 1) = 1;
  M(end:end) = 1;

  B = [v0; b; vn];

  v = M \ B;
end
