param lado, integer, > 0;
param niveles, integer, > 0;
param num_cajas, integer, > 0;

set FILAS := 1..lado;
set COLUMNAS := 1..lado;
set NIVELES := 1..niveles;
set CAJAS := 1..num_cajas;

param prioridad {CAJAS}, integer, > 0;
param peso {CAJAS} >= 0;
param capacidad {CAJAS} >= 0;


# M para representar la prioridad infinita de una posicion vacia
param M_prioridad := 1 + max {k in CAJAS} prioridad[k];

# M suficientemente grande para relajar el coste
param M_coste := sum {k in CAJAS} prioridad[k];

# M suficientemente grande para la restriccion de capacidad
param M_peso := sum {k in CAJAS} peso[k];


# X[i,j,z,k] = 1 si la caja k esta en (i,j,z)
var X {FILAS, COLUMNAS, NIVELES, CAJAS}, binary;

# Coste de la posicion (i,j,z)
var C {FILAS, COLUMNAS, NIVELES} >= 0;



# RESTRICCION 1:Cada caja se coloca exactamente una vez

s.t. cada_caja_una_vez {k in CAJAS}:

    sum {i in FILAS, j in COLUMNAS, z in NIVELES}
        X[i,j,z,k] = 1;



# RESTRICCION 2:En cada posicion puede haber como maximo una caja

s.t. como_maximo_una_caja
    {i in FILAS, j in COLUMNAS, z in NIVELES}:

    sum {k in CAJAS}
        X[i,j,z,k] <= 1;



# RESTRICCION 3: No puede haber una caja encima de una posicion vacia

s.t. no_caja_sobre_hueco
    {i in FILAS, j in COLUMNAS, z in NIVELES: z < niveles}:

    sum {k in CAJAS}
        X[i,j,z+1,k]

    <=

    sum {k in CAJAS}
        X[i,j,z,k];



# RESTRICCION 4: Orden de prioridades

s.t. ordenar_prioridades
    {i in FILAS, t in FILAS,
     j in COLUMNAS, z in NIVELES: i > t}:

    sum {k in CAJAS}
        prioridad[k] * X[i,j,z,k]

    + M_prioridad *
        (1 - sum {k in CAJAS} X[i,j,z,k])

    <=

    sum {k in CAJAS}
        prioridad[k] * X[t,j,z,k]

    + M_prioridad *
        (1 - sum {k in CAJAS} X[t,j,z,k]);



# RESTRICCION 5 : Capacidad de carga de cada caja
s.t. restriccion_capacidad
    {i in FILAS, j in COLUMNAS,
     z in NIVELES, k in CAJAS}:

    sum {z2 in NIVELES, k2 in CAJAS: z2 > z}
        peso[k2] * X[i,j,z2,k2]

    <=

    capacidad[k]
    + M_peso * (1 - X[i,j,z,k]);


# RESTRICCION 6: Coste de la posicion
# Si esta ocupada: sum X = 1 -> desaparece -M
# Si esta vacia: sum X = 0 -> aparece -M entonces C = 0

s.t. definir_coste
    {i in FILAS, j in COLUMNAS, z in NIVELES}:

    C[i,j,z]

    >=

    sum {ip in FILAS, k in CAJAS: ip > i}
        prioridad[k] * X[ip,j,z,k]

    - M_coste *
        (1 - sum {k in CAJAS} X[i,j,z,k]);



# FUNCION OBJETIVO
minimize coste_medio:
    (1 / num_cajas) * sum {i in FILAS, j in COLUMNAS, z in NIVELES}
        C[i,j,z];



solve;

end;