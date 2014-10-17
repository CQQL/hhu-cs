epsilon = 10^(-15);
f1 = @(x) x^2 - 3;
f2 = @(x) sin(x);
f3 = @(x) x^3 - 2 * x + 2;

printf('f1: bi -> %f; newt -> %f\n', bisektion(f1, 1, 2, epsilon), newton(f1, 1, 2));
printf('f2: bi -> %f; newt -> %f\n', bisektion(f2, sqrt(2), 3 * sqrt(2), epsilon), newton(f2, sqrt(2), 3 * sqrt(2)));
printf('f3: bi -> %f; newt -> %f\n', bisektion(f3, -2, 0, epsilon), newton(f2, -2, 0));
