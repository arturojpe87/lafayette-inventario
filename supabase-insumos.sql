-- Catálogo de insumos — tomado de la PWA v13 (INSUMOS_DEF + SOLO_FABRICA)
-- Correr DESPUÉS de supabase-schema.sql
--
-- Deliberadamente NO están todos los insumos de la hoja de papel: solo los que
-- concentran el gasto. Medir 27 bien es mejor que 34 a medias — menos captura
-- diaria, más probable que el hábito se sostenga. Se agregan desde Config si
-- alguno empieza a pesar.
--
-- solo_fabrica = true  →  no aparece en la tabla de reparto a locales.

insert into insumos (nombre, unidad, solo_fabrica, orden) values
  ('ACEITE',        'LT',   false,  1),
  ('AZUCAR',        'KG',   false,  2),
  ('AZUCAR GLASS',  'KG',   false,  3),
  ('CHOCOLATE',     'KG',   false,  4),
  ('CHANTILLY',     'KG',   false,  5),
  ('HARINA BLANCA', 'KG',   false,  6),
  ('MIX VAINILLA',  'KG',   false,  7),
  ('MIX BIZCOCHO',  'KG',   false,  8),
  ('MIX BROWNIE',   'KG',   true,   9),
  ('MIX CROISSANT', 'KG',   true,  10),
  ('MIX 3 LECHES',  'KG',   true,  11),
  ('MIX CHOCO',     'KG',   true,  12),
  ('MIX RED V',     'KG',   true,  13),
  ('HUEVO',         'KG',   false, 14),
  ('LECHE FAB',     'LT',   true,  15),
  ('LEVADURA',      'PZA',  false, 16),
  ('MANTECA',       'KG',   false, 17),
  ('DANÉS',         'KG',   false, 18),
  ('UNTARELLA',     'KG',   true,  19),
  ('NONNA',         'KG',   true,  20),
  ('FEITÉ',         'KG',   false, 21),
  ('QUESO',         'KG',   false, 22),
  ('LECHERA',       'LT',   true,  23),
  ('TOPPING',       'PZA',  true,  24),
  ('ELOTE',         'KG',   true,  25),
  ('QUESO CREMA',   'KG',   false, 26),
  ('DURAZNO',       'LATA', true,  27)
on conflict (nombre) do update
  set unidad       = excluded.unidad,
      solo_fabrica = excluded.solo_fabrica,
      orden        = excluded.orden;
