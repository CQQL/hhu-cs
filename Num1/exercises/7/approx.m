a = 0;
epsilon = e^(-7);
n = 50;

f1 = @(x) 4 / (1 + x^2);
f2 = @(x) 16 * x^15;
f3 = @(x) (3 / 2) * sqrt(x);

fs = {f1, f2, f3};
reals = [pi, 1, 3^(3/2)];
bs = [1, 1, 3];

printf('epsilon = %f\n\n', epsilon);

for i = 1:3
  f = fs{i};
  real = reals(i);
  b = bs(i);

  [r_r, N_r] = romberg_e(f, a, b, n, epsilon);
  [r_b, N_b] = bulirsch_e(f, a, b, n, epsilon);

  printf('Romberg: r = %f, n = %d, Fehler = %f\n', r_r, N_r, real - r_r);
  printf('Bulirsch: r = %f, n = %d, Fehler = %f\n', r_b, N_b, real - r_b);
  printf('\n');
end
