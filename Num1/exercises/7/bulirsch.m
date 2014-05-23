function r = bulirsch(f, a, b, n)
  r = zeros(n, n);

  % Konstruktion der Bulirschfolge
  bur = zeros(1, n);
  bur(1) = 1;
  for i = 1:floor(n / 2)
    bur(2 * i) = 2^i;
  end
  for i = 1:floor((n - 1) / 2)
    bur(2 * i + 1) = (3/2) * 2^i;
  end

  h = (b - a) ./ bur;
  r(1, 1) = (b - a) * (f(a) + f(b)) / 2;

  for j = 2:n
    subtotal = (1/2) * (f(a) + f(b));

    for i = 1:(bur(j) - 1)
      subtotal = subtotal + f(a + i * h(j));
    end

    r(j, 1) = h(j) * subtotal;

    for k = 2:j
      r(j, k) = r(j, k - 1) + (r(j, k - 1) - r(j - 1, k - 1)) / ((bur(j) / bur(j - 1))^(2 * (k - 1)) - 1);
    end
  end
end
