x = 0.988:0.0001:1.012;
p = x.^7 - 7 * x.^6 + 21 * x.^5 - 35 * x.^4 + 35 * x.^3 - 21 * x.^2 + 7 * x - 1;
#p = (x - 1).^7;

plot(x, p);

# Meine Erklaerung ist Ausloeschung. Bei der zweiten Version wird zuerst eine
# schlecht konditionierte Operation (-) angewandt, aber dann nur noch gut
# konditionierte Operationen (^). Bei der Originalformel hingegen ist es
# andersherum. Hier werden dann mehrmals Zahlen unterschiedlichen Vorzeichens
# addiert.
