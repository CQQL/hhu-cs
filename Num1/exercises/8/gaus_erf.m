function y = gaus_erf (X, xs, as)
  y = 0;
  n = length(xs);

  for i = 1:n
    a = as(i);
    x = (xs(i) + 1) * X/2;

    y = y + X/2 * a * exp(-(x^2));
  end

  y = 2/sqrt(pi) * y;
end
