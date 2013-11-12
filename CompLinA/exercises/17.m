n = 30

  B = repmat([1/6], 1, n - 1)
  A = diag(repmat([2/3], 1, n)) + diag(B, 1) + diag(B, -1)

  A(1, n) = 1/6
  A(n, 1) = 1/6

A
