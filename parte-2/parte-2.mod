# ============================================================
# Parte 2 - Montaje volumetrico
# Modelo MathProg / GLPK
# Incluye salida visual por niveles
# ============================================================

param lado, integer, > 0;
param niveles, integer, > 0;

param num_cajas := niveles * lado * lado;

set FILAS := 1..lado;
set COLUMNAS := 1..lado;
set NIVELES := 1..niveles;
set CAJAS := 1..num_cajas;

param prioridad {CAJAS}, integer, > 0;
param peso {CAJAS} >= 0;
param capacidad {CAJAS} >= 0;

param M := sum {k in CAJAS} peso[k];

var colocada {FILAS, COLUMNAS, CAJAS, NIVELES}, binary;
var prioridad_posicion {FILAS, COLUMNAS, NIVELES} >= 0;
var coste_posicion {FILAS, COLUMNAS, NIVELES} >= 0;

s.t. cada_caja_una_vez {k in CAJAS}:
    sum {i in FILAS, j in COLUMNAS, r in NIVELES}
        colocada[i,j,k,r] = 1;

s.t. una_caja_por_posicion {i in FILAS, j in COLUMNAS, r in NIVELES}:
    sum {k in CAJAS}
        colocada[i,j,k,r] = 1;

s.t. definir_prioridad_posicion {i in FILAS, j in COLUMNAS, r in NIVELES}:
    prioridad_posicion[i,j,r] =
        sum {k in CAJAS}
            prioridad[k] * colocada[i,j,k,r];

s.t. ordenar_prioridades
    {i in FILAS, t in FILAS, j in COLUMNAS, r in NIVELES: i > t}:
    prioridad_posicion[i,j,r] <= prioridad_posicion[t,j,r];

s.t. restriccion_capacidad
    {i in FILAS, j in COLUMNAS, k in CAJAS, r in NIVELES}:
    sum {k2 in CAJAS, r2 in NIVELES: k2 <> k and r2 > r}
        peso[k2] * colocada[i,j,k2,r2]
    <= capacidad[k] + M * (1 - colocada[i,j,k,r]);

s.t. definir_coste {i in FILAS, j in COLUMNAS, r in NIVELES}:
    coste_posicion[i,j,r] =
        sum {ip in FILAS: ip > i}
            prioridad_posicion[ip,j,r];

minimize coste_medio:
    (1 / num_cajas) *
    sum {i in FILAS, j in COLUMNAS, r in NIVELES}
        coste_posicion[i,j,r];

solve;

printf "\n";
printf "============================================================\n";
printf "              DISPOSICION DE LAS CAJAS\n";
printf "============================================================\n";
printf "Cada casilla muestra: caja / prioridad / peso / capacidad\n";
printf "Nivel 1 = inferior; Nivel %d = superior\n\n", niveles;

for {r in NIVELES} {
    printf "------------------------- NIVEL %d -------------------------\n", r;

    for {i in lado..1 by -1} {
        for {j in COLUMNAS} {
            printf "+----------------------";
        }
        printf "+\n";

        for {j in COLUMNAS} {
            printf "| Caja:%2g  P:%3g       ",
                sum {k in CAJAS} k * colocada[i,j,k,r],
                prioridad_posicion[i,j,r];
        }
        printf "|\n";

        for {j in COLUMNAS} {
            printf "| W:%4g   Cap:%4g      ",
                sum {k in CAJAS} peso[k] * colocada[i,j,k,r],
                sum {k in CAJAS} capacidad[k] * colocada[i,j,k,r];
        }
        printf "|\n";
    }

    for {j in COLUMNAS} {
        printf "+----------------------";
    }
    printf "+\n\n";
}

printf "Coste medio: %g\n\n", coste_medio;

end;
