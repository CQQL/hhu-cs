% Werte den kubischen Spline mit den Ableitungen v(i) und Stuetzstellen x(i),
% y(i) an den Stellen X aus.
%
% Annahme: Alle Werte in X sind aufsteigend sortiert und sind zwischen x(1) und
% x(end).
function Y = spline_eval (x, y, v, X)
  % Index des aktuellen Polynoms
  j = 1;
  Y = zeros(1, length(X));

  % Abstaende zwischen x(i) und x(i + 1)
  h = x(2:end) - x(1:end - 1);

  % Steigung zwischen (x(i), y(i)) und (x(i + 1), y(i + 1))
  d = (y(2:end) - y(1:end - 1)) ./ h;

  for i = (1:length(X))
    % Berechnung des j-ten Polynoms an der Stelle q.
    q = X(i);

    if q > x(j + 1)
      j = j + 1;
    end

    p = y(j) \
        + (q - x(j)) * v(j) \
        + (q - x(j))^2 * ((d(j) - v(j)) / h(j)) \
        + (q - x(j))^2 * (q - x(j + 1)) * ((v(j + 1) + v(j) - 2 * d(j)) / (h(j))^2);

    Y(i) = p;
  end
end
