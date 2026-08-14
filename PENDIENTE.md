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

---

## Automatización por WhatsApp (diseño, aún no construido)

Corre sobre la **misma infraestructura de Meta** que los reportes de venta:
un solo chip / un solo número para todo lo interno. Un número puede enviar
cuantas plantillas distintas se quieran, y tener un solo remitente
("Lafayette") se lee mejor que tres números sueltos.

Un segundo número solo se justifica cuando cambie el público — mensajes a
clientes vs. internos — porque la calificación de calidad es por número y
un cliente molesto arrastraría también los reportes internos.

⚠️ **La API oficial no envía a grupos.** Solo 1:1. Se recorre una lista de
números. Ventaja: se puede mandar distinto contenido a cada quien — a Jorge
el detalle, al almacenista solo lo accionable.

### Un mensaje diario, no cinco alertas sueltas

Cinco mensajes separados se ignoran en dos semanas. Uno que llega siempre a
la misma hora, y que *a veces* trae banderas, se lee siempre. Solo lo
urgente de verdad se sale del resumen.

```
📦 ALMACÉN · Jueves 14 Ago
Inventario final capturado ✓ (28 insumos)

🔴 URGENTE
  CHOCOLATE — quedan 1.5 jornadas

🟡 REVISAR
  HARINA: 18kg hoy vs 7kg promedio de jueves
  LEVADURA: sin movimiento en 21 días
```

### Alertas, por orden de valor

1. **No se capturó el inventario hoy** — la más importante. Sin ella el
   sistema se muere en silencio: nadie captura una semana y los promedios
   quedan con hoyos que ya no se pueden reconstruir.
2. **Consumo anómalo vs. el promedio de ese día de la semana** — aquí está
   el dinero. Los faltantes de stock se ven solos; las fugas no se ven nunca.
   `v_consumo_promedio` ya trae la desviación, así que la comparación es gratis.
3. **Consumo negativo o imposible** — alguien contó mal o falta registrar una
   entrada. Avisa el mismo día, cuando todavía se puede reconstruir.
4. **Insumo estancado** (3+ semanas sin moverse) — capital dormido que caduca,
   o no se está contando bien.
5. **Stock por agotarse** — en **jornadas de trabajo**, no días de calendario
   (`v_cobertura`), y considerando lo que tarda el proveedor. No sirve avisar
   con 2 jornadas si el proveedor tarda 3 días.

**Bloqueado por:** el chip y la configuración de producción en Meta.
