CREATE TABLE IF NOT EXISTS messages (
  id          SERIAL PRIMARY KEY,
  pseudo      TEXT   NOT NULL,
  text        TEXT   NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO messages (pseudo, text) VALUES
  ('Marine',  'Ça fonctionne parfaitement');

--docker exec -i forum-anonyme-db-1 psql -U postgres -d forum < script.sql