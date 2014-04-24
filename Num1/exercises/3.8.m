function y = tscheb (n, x)
  if n == 0
     y = ones(1, length(x));
  elseif n == 1
    y = x;
  else
    y = x .* 2 .* tscheb((n - 1), x) - tscheb((n - 2), x);
  endif
endfunction

hold on;

styles = ["y", "m", "c", "r", "g", "b", "y", "k", "m"];

x = -1:0.01:1;
for i = 0:8
  plot(x, tscheb(i, x), strcat(";T=", num2str(i), ";"), "Color", styles(i + 1), "LineWidth", 2);
endfor

hold off
