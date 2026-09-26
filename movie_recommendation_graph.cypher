CREATE CONSTRAINT movie_title_released_unique IF NOT EXISTS
FOR (movie:Movie)
REQUIRE (movie.title, movie.released) IS UNIQUE;

CREATE CONSTRAINT person_name_unique IF NOT EXISTS
FOR (person:Person)
REQUIRE person.name IS UNIQUE;

CREATE CONSTRAINT genre_name_unique IF NOT EXISTS
FOR (genre:Genre)
REQUIRE genre.name IS UNIQUE;

UNWIND [
  {title: 'The Matrix', released: 1999},
  {title: 'Inception', released: 2010},
  {title: 'Interstellar', released: 2014},
  {title: 'The Dark Knight', released: 2008},
  {title: 'Speed', released: 1994},
  {title: 'Arrival', released: 2016},
  {title: 'Dune: Part Two', released: 2024}
] AS row
MERGE (movie:Movie {title: row.title, released: row.released});

UNWIND [
  {title: 'The Matrix', released: 1999, genres: ['Action', 'Science Fiction']},
  {title: 'Inception', released: 2010, genres: ['Action', 'Science Fiction', 'Thriller']},
  {title: 'Interstellar', released: 2014, genres: ['Adventure', 'Drama', 'Science Fiction']},
  {title: 'The Dark Knight', released: 2008, genres: ['Action', 'Crime', 'Drama']},
  {title: 'Speed', released: 1994, genres: ['Action', 'Thriller']},
  {title: 'Arrival', released: 2016, genres: ['Drama', 'Mystery', 'Science Fiction']},
  {title: 'Dune: Part Two', released: 2024, genres: ['Action', 'Adventure', 'Drama', 'Science Fiction']}
] AS row
MATCH (movie:Movie {title: row.title, released: row.released})
UNWIND row.genres AS genreName
MERGE (genre:Genre {name: genreName})
MERGE (movie)-[:IN_GENRE]->(genre);

UNWIND [
  {title: 'The Matrix', released: 1999, actors: ['Keanu Reeves', 'Laurence Fishburne', 'Carrie-Anne Moss']},
  {title: 'Inception', released: 2010, actors: ['Leonardo DiCaprio', 'Joseph Gordon-Levitt', 'Elliot Page']},
  {title: 'Interstellar', released: 2014, actors: ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain']},
  {title: 'The Dark Knight', released: 2008, actors: ['Christian Bale', 'Heath Ledger', 'Aaron Eckhart']},
  {title: 'Speed', released: 1994, actors: ['Keanu Reeves', 'Sandra Bullock', 'Dennis Hopper']},
  {title: 'Arrival', released: 2016, actors: ['Amy Adams', 'Jeremy Renner', 'Forest Whitaker']},
  {title: 'Dune: Part Two', released: 2024, actors: ['Timothee Chalamet', 'Zendaya', 'Rebecca Ferguson']}
] AS row
MATCH (movie:Movie {title: row.title, released: row.released})
UNWIND row.actors AS actorName
MERGE (person:Person {name: actorName})
SET person:Actor
MERGE (person)-[:ACTED_IN]->(movie);

UNWIND [
  {title: 'The Matrix', released: 1999, directors: ['Lana Wachowski', 'Lilly Wachowski']},
  {title: 'Inception', released: 2010, directors: ['Christopher Nolan']},
  {title: 'Interstellar', released: 2014, directors: ['Christopher Nolan']},
  {title: 'The Dark Knight', released: 2008, directors: ['Christopher Nolan']},
  {title: 'Speed', released: 1994, directors: ['Jan de Bont']},
  {title: 'Arrival', released: 2016, directors: ['Denis Villeneuve']},
  {title: 'Dune: Part Two', released: 2024, directors: ['Denis Villeneuve']}
] AS row
MATCH (movie:Movie {title: row.title, released: row.released})
UNWIND row.directors AS directorName
MERGE (person:Person {name: directorName})
SET person:Director
MERGE (person)-[:DIRECTED]->(movie);

MATCH (source:Movie {title: 'The Matrix', released: 1999})
MATCH (candidate:Movie)
WHERE candidate <> source
OPTIONAL MATCH (source)-[:IN_GENRE]->(genre:Genre)<-[:IN_GENRE]-(candidate)
WITH source, candidate, count(DISTINCT genre) AS sharedGenres
OPTIONAL MATCH (source)<-[:ACTED_IN]-(actor:Person)-[:ACTED_IN]->(candidate)
WITH source, candidate, sharedGenres, count(DISTINCT actor) AS sharedActors
OPTIONAL MATCH (source)<-[:DIRECTED]-(director:Person)-[:DIRECTED]->(candidate)
WITH candidate,
     sharedGenres,
     sharedActors,
     count(DISTINCT director) AS sharedDirectors,
     sharedGenres + (2 * sharedActors) + (3 * count(DISTINCT director)) AS score
WHERE score > 0
RETURN candidate.title AS title,
       candidate.released AS released,
       score,
       sharedGenres,
       sharedActors,
       sharedDirectors
ORDER BY score DESC, released DESC
LIMIT 5;