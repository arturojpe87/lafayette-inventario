-- Lafayette · Almacén de materia prima
-- Correr una sola vez en Supabase → SQL Editor → New query → Run
-- Proyecto: ivijmnnmbkriewdaujpb (el mismo de los cortes)

-- ══════════ CATÁLOGO DE INSUMOS ══════════
create table if not exists insumos (
  id            bigserial primary key,
  nombre        text not null unique,
  unidad        text not null,              -- KG | LT | PZA | LATA | CUBETA | CAJA
  solo_fabrica  boolean not null default false,
  costo         numeric(10,2),
  minimo        numeric(10,3),              -- para alerta de stock bajo
  orden         int not null default 0,     -- para respetar el orden de la hoja de papel
  activo        boolean not null default true,
  created_at    timestamptz not null default now()
);

-- ══════════ INVENTARIO DIARIO EN FÁBRICA ══════════
-- Un renglón por insumo por día = una celda de la hoja semanal.
create table if not exists inv_insumos (
  id            bigserial primary key,
  fecha         date not null,
  insumo_id     bigint not null references insumos(id) on delete restrict,
  cantidad      numeric(12,3) not null,     -- siempre en la unidad base del insumo
  capturado_por text,
  created_at    timestamptz not null default now(),
  unique (fecha, insumo_id)                 -- recapturar el mismo día actualiza, no duplica
);

-- ══════════ ENTRADAS DE PROVEEDOR ══════════
create table if not exists entradas_insumos (
  id            bigserial primary key,
  fecha         date not null,
  insumo_id     bigint not null references insumos(id) on delete restrict,
  cantidad      numeric(12,3) not null,
  proveedor     text,
  capturado_por text,
  created_at    timestamptz not null default now()
);

-- ══════════ SALIDAS A SUCURSALES ══════════
create table if not exists salidas_insumos (
  id            bigserial primary key,
  fecha         date not null,
  insumo_id     bigint not null references insumos(id) on delete restrict,
  cantidad      numeric(12,3) not null,
  destino       text not null,              -- nombre de la sucursal
  recibido_por  text,                       -- quien firma en el local (va en la hoja de papel)
  capturado_por text,
  created_at    timestamptz not null default now()
);

create index if not exists idx_inv_fecha      on inv_insumos(fecha);
create index if not exists idx_entradas_fecha on entradas_insumos(fecha);
create index if not exists idx_salidas_fecha  on salidas_insumos(fecha);
create index if not exists idx_salidas_destino on salidas_insumos(destino);

-- ══════════ SEGURIDAD ══════════
alter table insumos           enable row level security;
alter table inv_insumos       enable row level security;
alter table entradas_insumos  enable row level security;
alter table salidas_insumos   enable row level security;

-- Todos los usuarios autenticados leen todo (el dashboard lo necesita)
create policy "leer insumos"    on insumos          for select to authenticated using (true);
create policy "leer inv"        on inv_insumos      for select to authenticated using (true);
create policy "leer entradas"   on entradas_insumos for select to authenticated using (true);
create policy "leer salidas"    on salidas_insumos  for select to authenticated using (true);

-- Autenticados capturan movimientos
create policy "escribir inv"      on inv_insumos      for all to authenticated using (true) with check (true);
create policy "escribir entradas" on entradas_insumos for all to authenticated using (true) with check (true);
create policy "escribir salidas"  on salidas_insumos  for all to authenticated using (true) with check (true);

-- El catálogo solo lo toca el admin
create policy "admin edita insumos" on insumos for all to authenticated
  using (auth.jwt() ->> 'email' = 'admin@lafa.mx')
  with check (auth.jwt() ->> 'email' = 'admin@lafa.mx');

-- ══════════ CONSUMO DE FÁBRICA ══════════
-- Consumo = inventario de ayer + entradas de hoy - salidas a locales - inventario de hoy
create or replace view v_consumo_fabrica as
select
  hoy.fecha,
  i.nombre,
  i.unidad,
  ayer.cantidad                        as inv_ayer,
  coalesce(e.total, 0)                 as entradas,
  coalesce(s.total, 0)                 as salidas_locales,
  hoy.cantidad                         as inv_hoy,
  ayer.cantidad + coalesce(e.total,0) - coalesce(s.total,0) - hoy.cantidad as consumo
from inv_insumos hoy
join insumos i on i.id = hoy.insumo_id
join inv_insumos ayer
  on ayer.insumo_id = hoy.insumo_id
 and ayer.fecha = hoy.fecha - 1
left join (
  select fecha, insumo_id, sum(cantidad) total from entradas_insumos group by 1,2
) e on e.insumo_id = hoy.insumo_id and e.fecha = hoy.fecha
left join (
  select fecha, insumo_id, sum(cantidad) total from salidas_insumos group by 1,2
) s on s.insumo_id = hoy.insumo_id and s.fecha = hoy.fecha;

-- ══════════ PROMEDIOS DE CONSUMO ══════════
-- Lo que hoy no tienes: cuánto se consume de cada insumo por día de la semana.
create or replace view v_consumo_promedio as
select
  nombre,
  unidad,
  extract(dow from fecha)::int as dia_semana,   -- 0=domingo … 6=sábado
  round(avg(consumo)::numeric, 3)  as consumo_promedio,
  round(stddev(consumo)::numeric, 3) as desviacion,
  count(*) as dias_medidos
from v_consumo_fabrica
where consumo >= 0
group by nombre, unidad, extract(dow from fecha);

-- ══════════ CONSUMO POR SUCURSAL ══════════
create or replace view v_salidas_promedio as
select
  s.destino,
  i.nombre,
  i.unidad,
  round(avg(s.cantidad)::numeric, 3) as promedio_envio,
  sum(s.cantidad)                    as total_periodo,
  count(*)                           as veces_enviado
from salidas_insumos s
join insumos i on i.id = s.insumo_id
group by s.destino, i.nombre, i.unidad;

revoke all on v_consumo_fabrica, v_consumo_promedio, v_salidas_promedio from anon;
grant select on v_consumo_fabrica, v_consumo_promedio, v_salidas_promedio to authenticated;
