function y = gaus_interval (f, a, b, xs, as, m)
  y = 0;
  h = (b - a) / m;

  for i = 1:m
    y = y + gaus(f, a + (i - 1) * h, a + i * h, xs, as);
  end
end
