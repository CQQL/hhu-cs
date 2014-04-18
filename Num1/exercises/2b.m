function y = eval_p (a, x)
  y = zeros(1, length(x));

  for i = a
      y = i + x .* y;
  endfor
endfunction

a = [1, -7, 21, -35, 35, -21, 7, -1];
x = 0.988:0.0001:1.012;

plot(x, eval_p(a, x));
