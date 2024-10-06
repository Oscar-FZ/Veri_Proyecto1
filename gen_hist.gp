reset session
set terminal pngcairo enhanced size 800,600
set output "histograma.png"

filename = ARG1

binwidth = 20
bin(x,width) = width*floor(x/width)

stats filename using 8 nooutput

set tics out nomirror
set style fill transparent solid 0.5 border lt -1
set xrange [0:STATS_max+10]
set xtics binwidth
set boxwidth binwidth
set xlabel "Tiempo de retardo"

set yrange [0:*]
set ylabel "Frecuencia"

set title "Tiempos de retardo de los paquetes recibidos"

plot filename every ::7 using (bin($8,binwidth)):(1.0) smooth frequency with boxes title "Frecuencia"