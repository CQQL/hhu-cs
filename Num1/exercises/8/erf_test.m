X = {[-sqrt(3/5), 0, sqrt(3/5)], [-sqrt(3/7 + 2/7 * sqrt(6/5)), -sqrt(3/7 - 2/7 * sqrt(6/5)), sqrt(3/7 - 2/7 * sqrt(6/5)), sqrt(3/7 + 2/7 * sqrt(6/5))], [-1/3 * sqrt(5 + 2 * sqrt(10/7)), -1/3 * sqrt(5 - 2 * sqrt(10/7)), 0, 1/3 * sqrt(5 - 2 * sqrt(10/7)), 1/3 * sqrt(5 + 2 * sqrt(10/7))]};
A = {[5/9, 8/9, 5/9], [(18 - sqrt(30)) / 36, (18 + sqrt(30)) / 36, (18 + sqrt(30)) / 36, (18 - sqrt(30)) / 36], [(322 - 13 * sqrt(70)) / 900, (322 + 13 * sqrt(70)) / 900, 128/225, (322 + 13 * sqrt(70)) / 900, (322 - 13 * sqrt(70)) / 900]};

for x = (0.1:0.1:1)
  printf('      x = %f\n', x);

  for i = (1:3)
    xs = X{i};
    as = A{i};

    printf('g(x, %d) = %f\n', i + 1, gaus_erf(x, xs, as));
  end

  printf(' erf(x) = %f\n\n', erf(x));
end
