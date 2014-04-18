# Ich denke mal, dass "beschriebene Auswertungsmoeglichkeiten" die aus
# Aufgabenteilen a und b meint.

function y = eval_p_a (a, x)
  y = zeros(1, length(x));

  for i = 1:length(a)
      y = y .+ (a(i) * x.^(i - 1));
  endfor
endfunction

function y = eval_p_b (a, x)
  y = zeros(1, length(x));

  for i = a
      y = i + x .* y;
  endfor
endfunction

a = [8118, -11482, 1, 5741, -2030];

# Methode a ergibt eine Gerade ~= 1500 und b eine Gerade ~= 0
x = 0.7071067:0.0000000001:0.7071068;
plot(x, eval_p_a(a, x), "r;a;", x, eval_p_b(a, x), "c;b;");

# Methode a ergibt eine leicht fallende Kurve von ~2500->1000 und b ergibt in
# etwa eine Gerade = 0.
#x = 0.6:0.0001:0.8;
#plot(x, eval_p_a(a, x), "r;a;", x, eval_p_b(a, x), "c;b;");
