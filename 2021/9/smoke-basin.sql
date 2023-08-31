
DROP TABLE IF EXISTS heightmap;
CREATE TABLE heightmap AS
  SELECT ROW_NUMBER() OVER ()                       AS y,
         unnest(generate_series(1, length(c.line))) AS x,
         c.line[x] :: int                           AS height
  FROM   read_csv_auto(input(), SEP=false) AS c(line);


DROP TABLE IF EXISTS lowpoints;
CREATE TABLE lowpoints AS
  SELECT h.y, h.x, h.height
  FROM   heightmap AS h
         LEFT JOIN heightmap AS t ON h.x = t.x     AND h.y = t.y + 1
         LEFT JOIN heightmap AS b ON h.x = b.x     AND h.y = b.y - 1
         LEFT JOIN heightmap AS l ON h.x = l.x + 1 AND h.y = l.y
         LEFT JOIN heightmap AS r ON h.x = r.x - 1 AND h.y = r.y
  WHERE  h.height < LEAST(t.height, b.height, l.height, r.height);
