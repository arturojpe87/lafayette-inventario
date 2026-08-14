-- Catálogo de insumos — reconstruido desde la hoja de papel real (Ago 2026)
-- Correr DESPUÉS de supabase-schema.sql
-- El `orden` respeta el orden de la hoja, para que capturar sea leer de arriba a abajo.
-- `solo_fabrica = true` → no aparece en la tabla de reparto a locales.

insert into insumos (nombre, unidad, solo_fabrica, orden) values
  ('ACEITE',         'LT',     false,  1),
  ('AZUCAR',         'KG',     false,  2),
  ('AZUCAR GLASS',   'KG',     true,   3),
  ('CAFÉ',           'KG',     true,   4),
  ('CHOCOLATE',      'KG',     false,  5),
  ('CHANTILLY',      'CUBETA', false,  6),
  ('HARINA BLANCA',  'KG',     false,  7),
  ('MIX VAINILLA',   'KG',     false,  8),
  ('MIX BIZCOCHO',   'KG',     false,  9),
  ('MIX BROWNIE',    'KG',     true,  10),
  ('MIX CROISSANT',  'KG',     true,  11),
  ('MIX 3 LECHES',   'KG',     true,  12),
  ('MIX CHOCO',      'KG',     true,  13),
  ('MIX MUERTO',     'KG',     true,  14),
  ('MIX ROSCA',      'KG',     true,  15),
  ('MIX DANÉS',      'KG',     false, 16),
  ('HUEVO',          'CAJA',   false, 17),
  ('LECHE PROD',     'LT',     true,  18),
  ('LECHE CAFÉ',     'LT',     true,  19),
  ('LEVADURA',       'PZA',    false, 20),
  ('MANTECA',        'KG',     true,  21),
  ('DANÉS',          'KG',     false, 22),
  ('UNTARELLA',      'KG',     true,  23),
  ('NONNA',          'KG',     true,  24),
  ('FEITÉ',          'KG',     true,  25),
  ('QUESO',          'KG',     false, 26),
  ('LECHERA',        'LT',     true,  27),
  ('VASO 12 OZ',     'PZA',    true,  28),
  ('TAPAS CAFÉ',     'PZA',    true,  29),
  ('TOPPING',        'PZA',    true,  30),
  ('ELOTE',          'KG',     true,  31),
  ('QUESO CREMA',    'KG',     true,  32),
  ('MAICENA',        'KG',     true,  33),
  ('DURAZNO',        'LATA',   true,  34)
on conflict (nombre) do update
  set unidad       = excluded.unidad,
      solo_fabrica = excluded.solo_fabrica,
      orden        = excluded.orden;
