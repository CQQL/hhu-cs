function plot_spline (f)
  colors = ['m', 'y', 'b'];
  min = -5;
  max = 5;
  X = min:0.01:max;

  figure;
  hold on;

  plot(X, (X.^2 + 1).^(-1), 'c', 'LineWidth', 4);

  for n = [5, 10, 20]
    h = (max - min) / (n - 1);

    x = min:h:max;
    y = (x.^2 + 1).^(-1);

    spline = f(x, y);

    plot(X, spline_eval(x, y, spline, X), colors(n / 5 - (n == 20)), 'LineWidth', 2, 'DisplayName', strcat('n = ', num2str(n)));
  end

  legend('show');

  hold off;
end
