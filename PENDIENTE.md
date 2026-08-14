# Estado del almacén — 14 Ago 2026

## Listo y probado

| Qué | Cómo se comprobó |
|---|---|
| Google Sheets fuera, todo en Supabase | 0 llamadas a `syncToSheet` en el archivo |
| El "Guardado ✓" falso, resuelto | Cada escritura pide de vuelta lo insertado y falla si no cuadra |
| Pantalla **Material a Fábrica** | Tabla 3×2 renderiza; basura no guarda nada |
| Fracciones como en el papel | `2 1/2`, `3/4`, `13.200` → **13/13 casos** |
| Dato de ayer junto a cada casilla | Junto a la unidad en cada tarjeta |
| Alerta gramos-vs-kilos | `29440 KG` → *"Parece que son gramos"* |
| Alerta de salto raro | Más de 3× contra ayer → *"Ayer había X. ¿Seguro?"* |
| Sesión caída se detecta | No muestra pantallas vacías fingiendo normalidad |

**Archivo:** `lafayette_v14.html` — v13 sigue intacto por si hay que volver.

---

## Falta (2 cosas)

### 1. Quitar el login — BLOQUEADO, necesita que tú corras un SQL

Se pidió quitar la pantalla de correo/contraseña. Para que la app lea y
escriba sin sesión hay que abrir los permisos a acceso anónimo, y **el sistema
de seguridad no me deja ejecutar eso solo**. Queda preparado abajo.

⚠️ **Antes de correrlo, entiende qué implica:** el repo `lafayette-inventario`
es **público en GitHub**. Con estos permisos, cualquiera que llegue a la URL de
la app puede leer y escribir tus costos, volúmenes y proveedores.

La alternativa sin ese riesgo: dejar el login como está. Aparece **una sola vez
por tablet** — se entra el día que la instalas y nunca más. Para el almacenista
es exactamente lo mismo: abre y da clic en Encargado.

**Si aun así lo quieres**, pega esto en Supabase → SQL Editor → Run:

```sql
create policy "anon insumos"  on insumos          for select to anon using (true);
create policy "anon inv"      on inv_insumos      for all to anon using (true) with check (true);
create policy "anon entradas" on entradas_insumos for all to anon using (true) with check (true);
create policy "anon salidas"  on salidas_insumos  for all to anon using (true) with check (true);
grant select on v_consumo_fabrica, v_consumo_promedio, v_salidas_promedio, v_consumo_areas to anon;
```

Para revertirlo después: `drop policy "anon insumos" on insumos;` y así con las
otras tres.

**La app no necesita cambios.** Detecta sola si hay acceso abierto: si lo hay,
la pantalla de login deja de aparecer por sí misma.

### 2. Limpiar la configuración vieja de Google Sheets

En Config del dueño quedaron las instrucciones de Apps Script y el campo de la
URL. Es UI muerta — no rompe nada, solo estorba. Ese HTML está enredado y
recortarlo a ciegas puede romper la pantalla; conviene hacerlo con la app
abierta enfrente.

---

## Lo que necesito de ti

1. **Usuario del almacén en Supabase** → Authentication → Users → Add user.
   Sugerido `almacen@lafa.mx`. Sin esto nadie puede entrar (si dejas el login).
2. **Decidir lo del acceso anónimo** — correr el SQL de arriba o quedarte con
   el login de una sola vez.
3. **Probar la app** en `lafayette_v14.html` y decir qué se siente mal al usarla.

## Siguiente paso natural

Cuando el almacén lleve 2-3 semanas capturando, `v_consumo_promedio` ya tendrá
con qué responder lo que hoy no sabes: **cuánto se consume de cada insumo por
día de la semana**. Ahí es donde aparecen las fugas.
