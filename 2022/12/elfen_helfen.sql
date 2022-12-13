-- definitions for puzzle input
DROP TABLE IF EXISTS heightmap;
DROP TABLE IF EXISTS input;
CREATE TABLE heightmap (i int, j int, height char(1));
CREATE TABLE input (idx SERIAL, row text);

COPY input(row) FROM '/Users/louisalambrecht/git/Advent_of_Code/2022/12/example_input.txt' DELIMITER ',' CSV;

-- todo: better with unnest rather than substring
INSERT INTO heightmap
SELECT idx AS i, col AS j, substring(row from col for 1) AS height
FROM input, generate_series(1, (SELECT length(row) FROM input LIMIT 1)) AS col;

DROP TABLE input;


-- Finding shortest path from 'S' to 'E' by moving up max. 1 level