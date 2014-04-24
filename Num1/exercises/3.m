# Berechnung der dividierten Differenzen
function ds = diffs (x, y)
  l = length(x);
  ds = zeros(l, l);

  ds(:, 1) = y;

  for j = 2:l
    for i = 1:(l - (j - 1))
      ds(i, j) = (ds(i + 1, j - 1) - ds(i, j - 1)) / (x(i + j - 1) - x(i));
      if x(i + j - 1) - x(i) == 0
        x'
        printf("%d %d %f\n", i, j, x(i));
      end
    end
  end

  ds = ds(1, :);
endfunction

# Werte ein Polynom in der Newtondarstellung an den Stellen x aus
function ys = newton_eval (xs, diffs, x)
  ys = ones(1, length(x)) .* diffs(end);

  for i = (length(xs) - 1):-1:1
    ys = ys .* (x - xs(i)) + diffs(i);
  end
endfunction

function y = f (x)
  y = 1 ./ (1 .+ (x .^ 2));
endfunction

# Plotte f mit den gegebenen Knoten und den Tschebyscheff-Knoten auf dem Intervall x
function plotx (n, c, x)
  xs = -c:(2 * c / n):c;
  xt = c * cos(((2 * (0:n) + 1) / (2 * (n + 1))) * pi);
  ds = diffs(xs, f(xs));
  dt = diffs(xt, f(xt));

  plot(x, f(x), "r;f(x);", "LineWidth", 2,
       x, newton_eval(xs, ds, x), strcat("b;c=", num2str(c), ";"), "LineWidth", 2,
       x, newton_eval(xt, dt, x), "c;Tschebyscheff;", "LineWidth", 2);
endfunction

x = -e:0.01:e;
ns = [3, 10, 20];

for n = ns
  figure("name", strcat("n = ", num2str(n), ", c = e/2 + 1"));
  plotx(n, (e / 2) + 1, x)

  figure("name", strcat("n = ", num2str(n), ", c = e/2 - 0.5"));
  plotx(n, (e / 2) - 0.5, x)
end
