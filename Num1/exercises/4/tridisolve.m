function x = tridisolve (a, b, c, d)
  x = d;
  n = length(x);

  for j = 1:(n - 1)
    mu = a(j) / b(j);
    b(j + 1) = b(j + 1) - mu * c(j);
    x(j + 1) = x(j + 1) - mu * x(j);
  end

  x(n) = x(n) / b(n);

  for j = (n - 1):-1:1
    x(j) = (x(j) - c(j) * x(j + 1)) / b(j);
  end
end
