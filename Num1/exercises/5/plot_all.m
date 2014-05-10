plot_spline(@(x, y) spline_fixed(x, y, 0.05, 0.1));
plot_spline(@(x, y) spline_natural(x, y));
plot_spline(@(x, y) spline_periodic(x, y));
plot_spline(@(x, y) spline_not_a_knot(x, y));
