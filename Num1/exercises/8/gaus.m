% Berechne das Integral mit der Gaussquadraturformel.
%
% f - Funktion
% A - untere Grenze
% B - obere Grenze
% xs - Stuetzstellen
% as - Gewichte
function y = gaus (f, A, B, xs, as)
  y = 0;
  n = length(xs);
  h = B - A;

  for i = 1:n
    a_ = as(i);
    x_ = xs(i);
    a = h/2 * a_;
    x = A + (x_ + 1) * h/2;

    y = y + a * f(x);
  end
end
