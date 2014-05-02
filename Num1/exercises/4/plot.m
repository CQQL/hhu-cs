x = -5:0.01:5;

plot(x, (x.^2 + 1).^(-1), 'c', 'LineWidth', 4,
     x, spline(-5, 5, x, 5), 'r', 'LineWidth', 2,
     x, spline(-5, 5, x, 10), 'y', 'LineWidth', 2,
     x, spline(-5, 5, x, 20), 'b', 'LineWidth', 2);
