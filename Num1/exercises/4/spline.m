% N - Anzahl der Stuetzstellen
% X - Auswertungsbereich
function Y = spline (min, max, X, N)
  % Gitterbreite
  h = (max - min) / (N - 1);

  % Stuetzstellen
  x = min:h:max;
  y = (x.^2 + 1).^(-1);

  a = ones(1, N - 1) .* (1 / h);
  b = ones(1, N) .* (4 / h);
  c = a;
  d = (3 / h^2) * [y(2) - y(1), (y(3:end) - y(1:end - 2)), y(N) - y(N - 1)];

  k = tridisolve(a, b, c, d);

  A = k(1:end - 1) * h - (y(2:end) - y(1:end - 1));
  B = -h * k(2:end) + (y(2:end) - y(1:end - 1));

  Y = zeros(1, length(X));

  % Index des Polynoms
  j = 1;

  for i = (1:length(X))
    q = X(i);

    if q > x(j + 1)
      j = j + 1;
    end

    t = (q - x(j)) / (x(j + 1) - x(j));

    p = (1 - t) * y(j) + t * y(j + 1) + t * (1 - t) * (A(j) * (1 - t)  + B(j) * t);

    Y(i) = p;
  end
end
