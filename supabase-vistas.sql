-- Vistas de consumo — versión final 14 Ago 2026
-- (aplicadas ya en Supabase; este archivo es el respaldo del proyecto)

-- REGLA CLAVE: el consumo NO se divide entre días calendario.
--
-- La panadería no produce domingos ni festivos. El consumo medido entre el
-- conteo del sábado y el del lunes ocurrió TODO el lunes; repartirlo entre
-- 2 días subestimaba el promedio del lunes a la mitad, que es justo el KPI
-- que se quiere.
--
-- Como los conteos ocurren en días laborales, agrupar el consumo por el día
-- de la semana del conteo da el número correcto sin dividir nada.
--
-- `dias_cubiertos` se conserva como ADVERTENCIA, no como divisor: si un
-- conteo abarca más de 2 días, hubo un día laboral sin contar y ese número
-- mezcla dos jornadas. `mediciones_dudosas` los cuenta.

-- v_consumo_fabrica   → consumo por conteo, tolerante a días saltados
-- v_consumo_promedio  → promedio y desviación por día de la semana
-- v_cobertura         → jornadas de existencia al ritmo de las últimas 4 semanas
-- v_consumo_areas     → Pan Dulce y Pastelería capturados, Gourmet como residuo

-- El SQL vive aplicado en la base. Para consultarlo:
--   select definition from pg_views where viewname like 'v_%';
