# ============================================================
# Parte 1 - Minimizacion del coste medio
# Modelo MathProg / GLPK
# ============================================================

# -----------------------------
# PARAMETROS Y CONJUNTOS
# -----------------------------

param lado, integer, > 0;

param num_cajas := lado * lado;

set FILAS := 1..lado;
set COLUMNAS := 1..lado;
set CAJAS := 1..num_cajas;

# prioridad[k] = prioridad de la caja k
param prioridad {CAJAS}, integer, > 0;


# -----------------------------
# VARIABLES
# -----------------------------

# colocada[i,j,k] = 1 si la caja k se coloca
# en la fila i y columna j; 0 en otro caso
var colocada {FILAS, COLUMNAS, CAJAS}, binary;

# Prioridad de la caja que queda colocada en (i,j)
var prioridad_posicion {FILAS, COLUMNAS} >= 0;

# Coste de la caja situada en (i,j)
var coste_posicion {FILAS, COLUMNAS} >= 0;


# -----------------------------
# RESTRICCIONES
# -----------------------------

# Cada caja se coloca exactamente una vez
s.t. cada_caja_una_vez {k in CAJAS}:
    sum {i in FILAS, j in COLUMNAS} colocada[i,j,k] = 1;


# Cada posicion del pallet contiene exactamente una caja
s.t. una_caja_por_posicion {i in FILAS, j in COLUMNAS}:
    sum {k in CAJAS} colocada[i,j,k] = 1;


# Prioridad correspondiente a la caja colocada en cada posicion
s.t. definir_prioridad_posicion {i in FILAS, j in COLUMNAS}:
    prioridad_posicion[i,j] =
        sum {k in CAJAS} prioridad[k] * colocada[i,j,k];


# Dentro de una misma columna, una fila con mayor indice
# esta mas cerca del punto de acceso y debe tener un numero
# de prioridad menor o igual.
s.t. ordenar_prioridades
    {i in FILAS, t in FILAS, j in COLUMNAS: i > t}:
    prioridad_posicion[i,j] <= prioridad_posicion[t,j];


# Coste de la caja situada en (i,j):
# suma de las prioridades de las cajas situadas por delante
# de ella en la misma columna.
s.t. definir_coste {i in FILAS, j in COLUMNAS}:
    coste_posicion[i,j] =
        sum {ip in FILAS: ip > i} prioridad_posicion[ip,j];


# -----------------------------
# FUNCION OBJETIVO
# -----------------------------

minimize coste_medio:
    (1 / num_cajas) *
    sum {i in FILAS, j in COLUMNAS} coste_posicion[i,j];


solve;

end;
