-- AoC 2022, Day 15 (Part 1)

WITH
  input(row, line) AS (
    SELECT ROW_NUMBER() OVER () AS row
         , c.line
      FROM read_csv_auto('input.txt', SEP=false) AS c(line)
  ),

  sensors(sensor, beacon, distance) AS (
    SELECT { 'x': parts[1] :: int
           , 'y': parts[2] :: int
           } AS sensor
         , { 'x': parts[3] :: int
           , 'y': parts[4] :: int
           } AS beacon
         , ABS(sensor['x'] - beacon['x'])
         + ABS(sensor['y'] - beacon['y']) AS distance
      FROM input AS i
         , ( SELECT string_split_regex(i.line, 'Sensor at x=|, y=|: closest beacon is at x=')[2:] ) AS _(parts)
  ),

  mask(x) AS (
    SELECT sensor.x FROM sensors WHERE sensor.y = 2000000
      UNION
    SELECT beacon.x FROM sensors WHERE beacon.y = 2000000
  ),

  line(x) AS (
    SELECT DISTINCT unnest(generate_series("start", "end"))
      FROM sensors AS s
         , (SELECT ABS(s.sensor."y" - 2000000) AS diff)
         , (SELECT s.sensor."x" - (s.distance - diff) AS "start")
         , (SELECT s.sensor."x" + (s.distance - diff) AS "end")
     WHERE diff <= s.distance
    EXCEPT (TABLE mask)
  )

SELECT COUNT(*)
  FROM line;
