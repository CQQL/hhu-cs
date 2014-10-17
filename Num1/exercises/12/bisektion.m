function x = bisektion (f, a, b, epsilon)
  if abs(a - b) < epsilon
    x = a;
  else
    m = (a + b) / 2;

    if f(a) * f(m) < 0
      x = bisektion(f, a, m, epsilon);
    else
      x = bisektion(f, m, b, epsilon);
    end
  end
end
