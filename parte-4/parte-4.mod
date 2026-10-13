# Parte 4: pallets incompletos con coste de preparacion.
# X[i,j,z,t,k]: caja k en fila i, columna j, nivel z del pallet t.
# Las filas mayores estan mas cerca del acceso; el suelo es z = 1.

param l, integer, >= 1;
param h, integer, >= 1;
param n, integer, >= 1;
param P, >= 0;

set FILAS := 1..l;
set COLUMNAS := 1..l;
set NIVELES := 1..h;
set CAJAS := 1..n;
# n candidatos bastan: cada pallet utilizado debe contener alguna caja.
set PALLETS := 1..n;

param p{CAJAS}, integer, >= 1;
param peso{CAJAS}, >= 0;
param capacidad{CAJAS}, >= 0;
param p_max := max{k in CAJAS} p[k];
param M_p := p_max + 1;
# El coste suma prioridades reales, sin incluir la prioridad de los huecos.
param M_c := (l - 1) * p_max;

var X{FILAS, COLUMNAS, NIVELES, PALLETS, CAJAS}, binary;
var Y{PALLETS}, binary;
var C{FILAS, COLUMNAS, NIVELES, PALLETS}, >= 0;

# Coste TOTAL: no se divide entre n.
minimize CosteTotal:
    sum{t in PALLETS, i in FILAS, j in COLUMNAS, z in NIVELES}
        C[i,j,z,t]
    + P * sum{t in PALLETS} Y[t];

# 1. Cada caja aparece exactamente una vez entre TODOS los pallets.
s.t. CajaUnaVez{k in CAJAS}:
    sum{t in PALLETS, i in FILAS, j in COLUMNAS, z in NIVELES}
        X[i,j,z,t,k] = 1;

# 2. Como maximo una caja por posicion; si hay una caja, Y[t] debe ser 1.
# Esta restriccion ya incluye sum{k} X[i,j,z,t,k] <= 1.
s.t. PosicionYPallet{i in FILAS, j in COLUMNAS, z in NIVELES, t in PALLETS}:
    sum{k in CAJAS} X[i,j,z,t,k] <= Y[t];

# 3. No se crea una variable de prioridad ni una variable V.
# Prioridad de una posicion = sum{k} p[k]*X + M_p*(1-sum{k} X).
# Ocupada: prioridad de su caja. Vacia: M_p, mayor que todas las reales.

# 4. i > r: la fila i esta delante y debe tener prioridad numerica menor.
s.t. OrdenPrioridades{j in COLUMNAS, z in NIVELES, t in PALLETS,
                      r in FILAS, i in FILAS: r < i}:
    sum{k in CAJAS} p[k] * X[i,j,z,t,k]
      + M_p * (1 - sum{k in CAJAS} X[i,j,z,t,k])
    <=
    sum{k in CAJAS} p[k] * X[r,j,z,t,k]
      + M_p * (1 - sum{k in CAJAS} X[r,j,z,t,k]);

# 5. No hay cajas flotantes, incluso si su peso es cero.
s.t. Apoyo{i in FILAS, j in COLUMNAS, z in NIVELES, t in PALLETS: z < h}:
    sum{k in CAJAS} X[i,j,z+1,t,k]
    <= sum{k in CAJAS} X[i,j,z,t,k];

# 6. C >= 0 se declara en la variable. Al minimizar, esta cota basta:
# ocupada -> C = suma de prioridades delante; vacia -> C = 0.
s.t. CostePosicion{i in FILAS, j in COLUMNAS, z in NIVELES, t in PALLETS}:
    C[i,j,z,t]
    >= sum{ip in FILAS, k in CAJAS: ip > i} p[k] * X[ip,j,z,t,k]
       - M_c * (1 - sum{k in CAJAS} X[i,j,z,t,k]);

# 7. Se cuenta TODO el peso situado encima, no solo el nivel siguiente.
s.t. CapacidadCarga{i in FILAS, j in COLUMNAS, z in NIVELES, t in PALLETS: z < h}:
    sum{zp in NIVELES, k in CAJAS: zp > z} peso[k] * X[i,j,zp,t,k]
    <= sum{k in CAJAS} capacidad[k] * X[i,j,z,t,k];

# 8. Un pallet vacio debe tener Y[t] = 0, tambien cuando P = 0.
s.t. PalletNoVacio{t in PALLETS}:
    Y[t] <= sum{i in FILAS, j in COLUMNAS, z in NIVELES, k in CAJAS}
        X[i,j,z,t,k];

solve;
end;
