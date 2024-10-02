reset session
set terminal pngcairo enhanced size 800,600
set output "histograma_test_aleatorio.png"
set style data histograms
set style fill solid 0.5 border -1
set boxwidth 0.9 relative
set title "Histograma de los retardos de la prueba aleatoria"
set xlabel "Retardo"
set ylabel "Frecuencia"
binwidth = 1
set boxwidth binwidth relative
set style fill solid
plot "Aleatorio.csv" every ::7 using (floor($8/binwidth)*binwidth):1 smooth freq with boxes title "Frecuencia"