f = @(x) 4 / (1 + x^2);

int6 = [];
xs = [-sqrt(3/7 + 2/7 * sqrt(6/5)), -sqrt(3/7 - 2/7 * sqrt(6/5)), sqrt(3/7 - 2/7 * sqrt(6/5)), sqrt(3/7 + 2/7 * sqrt(6/5))];
as = [(18 - sqrt(30)) / 36, (18 + sqrt(30)) / 36, (18 + sqrt(30)) / 36, (18 - sqrt(30)) / 36];
for m = 1:100
  int6(m) = gaus_interval(f, 0, 1, xs, as, m);
end

int8 = [];
xs = [-1/3 * sqrt(5 + 2 * sqrt(10/7)), -1/3 * sqrt(5 - 2 * sqrt(10/7)), 0, 1/3 * sqrt(5 - 2 * sqrt(10/7)), 1/3 * sqrt(5 + 2 * sqrt(10/7))];
as = [(322 - 13 * sqrt(70)) / 900, (322 + 13 * sqrt(70)) / 900, 128/225, (322 + 13 * sqrt(70)) / 900, (322 - 13 * sqrt(70)) / 900];
for m = 1:100
  int8(m) = gaus_interval(f, 0, 1, xs, as, m);
end

X = 1:100;
semilogy(X, zeros(100, 1), X, abs(int6 - pi), X, abs(int8 - pi));
