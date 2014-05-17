for n = 4:7
  A = zeros(n + 1, n + 1);
  b = zeros(n + 1, 1);

  for i = 1:(n + 1)
    for j = 1:(n + 1)
      A(i, j) = 1 / (i - 1 + j);
    end
  end

  for i = 1:(n + 1)
    b(i) = 2 / (1 + 2 * i);
  end

  coeffs = A \ b;

  x = 0:0.01:1;
  y = zeros(1, length(x));

  % Polynom auswerten
  for i = 1:(n + 1)
    y = y + coeffs(i) * (x .^ (i - 1));
  end

  figure;
  hold on;
  plot(x, sqrt(x), 'c', 'LineWidth', 3, 'DisplayName', 'sqrt(x)');
  plot(x, y, 'r', 'LineWidth', 3, 'DisplayName', strcat("f aus P_", num2str(n)));
  legend('show');
  hold off;
end
