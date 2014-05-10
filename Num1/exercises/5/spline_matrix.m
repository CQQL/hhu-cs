% Berechne die tridiagonale Matrix, die allen Splineverfahren gemein ist.
%
% (x, y) sind die Stuetzstellen.
%
% Die Matrix ist hierbei allerdings (n - 1)x(n + 1), die dann noch auf
% (n + 1)x(n + 1) erweitert werden muss (also 2 weitere Bedingungen).
function [M, b] = spline_matrix (x, y)
  n = length(x) - 1;
  M = zeros(n - 1, n + 1);
  b = zeros(n - 1, 1);

  % Abstaende von x(i) und x(i + 1)
  h = x(2:end) - x(1:end - 1);

  % Steigungen von (x(i), y(i)) nach (x(i + 1), y(i + 1))
  d = (y(2:end) - y(1:end - 1)) ./ h;

  for i = (1:n - 1)
    M(i,i:i + 2) = [1 / h(i), 2 * (1 / h(i) + 1 / h(i + 1)), 1 / h(i + 1)];
    b(i) = 3 * (d(i) / h(i) + d(i + 1) / h(i + 1));
  end
end
