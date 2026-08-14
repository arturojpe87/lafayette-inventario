-- Reparto interno por área + separación de salidas
-- Aplicado 14 Ago 2026

-- Las salidas a ÁREAS no salen de la fábrica: son el consumo de fábrica,
-- subdividido. Restarlas del consumo (como se hace con los locales) sería
-- restar el consumo de sí mismo.
alter table salidas_insumos
  add column if not exists tipo text not null default 'LOCAL'
  check (tipo in ('LOCAL','AREA'));

-- Consumo de fábrica: solo resta lo que salió a locales
-- (definición completa en supabase-schema.sql, aquí solo el filtro tipo='LOCAL')

-- v_consumo_areas — Gourmet NO se declara, se calcula como residuo.
--
-- El almacenista también opera el área Gourmet: es juez y parte. Si declarara
-- su propio consumo podría ajustarlo a conveniencia. Calculándolo como
-- residuo (consumo_fabrica − pan_dulce − pastelería), cualquier faltante
-- aterriza visible en gourmet_residual. Para taparlo tendría que inflar el
-- material de otras dos personas, que sí lo reciben en mano.
--
-- No previene el desvío; lo vuelve visible. Eso es lo que puede hacer el
-- software — el arreglo de fondo es separar los roles.
