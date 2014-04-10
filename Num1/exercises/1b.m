function y = exp_n (x, n)
  y = 0;

  for i = 0:n
    y = y + x^i / factorial(i);
  end
endfunction

function plot_exp (x, color)
  semilogy((0:50), arrayfun(@(n) abs((exp_n(x, n) - exp(x)) / x), (0:50)), [";", num2str(x), ";", color]);
endfunction

plot_exp(1, "k")
hold on
plot_exp(10, "r")
plot_exp(-1, "g")
plot_exp(-10, "b")
hold off
