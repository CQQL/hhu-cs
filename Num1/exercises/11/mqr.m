function [Q, R] = mqr (A)
  [m, n] = size(A);
  Q = eye(m);
  R = A;

  for i = (1:n)
    e = zeros(m, 1);
    e(i) = 1;
    c = R(:, i);
    s = norm(c);
    v = c - s * e;
    v(1:(i - 1)) = 0;

    H = eye(m, m) - (2 / norm(v)) * (v * v');
    Q = Q * H;
    R = H * R;
  end
end
