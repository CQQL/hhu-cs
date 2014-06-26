function x = qr_solve (A, b)
  [Q, R] = mqr(A);

  x = R \ (Q' * b);
end
