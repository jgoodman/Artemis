CREATE TABLE boards (
  board_id              INT          NOT NULL AUTO_INCREMENT,
  name                  VARCHAR(255) NULL,
  PRIMARY KEY (board_id)
);

INSERT INTO boards (name) VALUES ('Oddyscape-World');

CREATE TABLE locations (
  location_id           INT          NOT NULL AUTO_INCREMENT,
  board_id              INT          NOT NULL,
  name                  VARCHAR(255) NULL,
  PRIMARY KEY (location_id),
  FOREIGN KEY (board_id) REFERENCES boards(board_id)
);

INSERT INTO locations (board_id, name) VALUES (1, 'The Beach');

/* Think of this table as a "state" that a location may have */
CREATE TABLE spaces (
  space_id             INT          NOT NULL AUTO_INCREMENT,
  post_id              VARCHAR(255) NULL,
  location_id          INT          NOT NULL,
  dir                  VARCHAR(255),
  PRIMARY KEY (space_id),
  FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

INSERT INTO spaces (post_id, location_id, dir) VALUES (302, 1, '{"explore":2}');

INSERT INTO spaces (post_id, location_id) VALUES (363, 1);

CREATE TABLE pieces (
  piece_id            INT          NOT NULL AUTO_INCREMENT,
  space_id            INT          NULL,
  PRIMARY KEY (piece_id),
  FOREIGN KEY (space_id) REFERENCES spaces(space_id)
);

INSERT INTO pieces (space_id) VALUES (1);

CREATE TABLE characters (
  character_id        INT          NOT NULL AUTO_INCREMENT,
  user_id             INT          NULL,
  name                VARCHAR(255) NULL,
  piece_id            INT          NOT NULL,
  PRIMARY KEY (character_id),
  FOREIGN KEY (piece_id) REFERENCES pieces(piece_id)
);

INSERT INTO characters (user_id, name, piece_id) VALUES (1, 'Arian', 1);

CREATE TABLE entities (
  entity_id           INT          NOT NULL AUTO_INCREMENT,
  class               VARCHAR(255) NOT NULL,
  name                VARCHAR(255) NULL,
  piece_id            INT          NULL,
  PRIMARY KEY (entity_id),
  FOREIGN KEY (piece_id) REFERENCES pieces(piece_id)
);

INSERT INTO entities (class, name, piece_id) VALUES ('character', 'Arian', 1);

CREATE TABLE entity_options (
  entity_option_id    INT          NOT NULL AUTO_INCREMENT,
  entity_id           VARCHAR(255) NULL,
  name                VARCHAR(255) NOT NULL,
  value               VARCHAR(255) NULL,
  PRIMARY KEY (entity_option_id),
  FOREIGN KEY (entity_id)    REFERENCES entities(entity_id),
  CONSTRAINT unique_entity_id_name UNIQUE (entity_id, name)
);

INSERT INTO entity_options (entity_id, name, value) VALUES (1, 'user_id', 1);

CREATE TABLE symposiums (
  symposium_id        INT          NOT NULL AUTO_INCREMENT,
  class               VARCHAR(255) NULL,
  PRIMARY KEY (symposium_id)
);

CREATE TABLE symposium_entities (
  symposium_entity_id INT          NOT NULL AUTO_INCREMENT,
  symposium_id        INT          NOT NULL,
  entity_id           INT          NOT NULL,
  class               VARCHAR(255) NULL,
  PRIMARY KEY (symposium_entity_id),
  FOREIGN KEY (symposium_id) REFERENCES symposiums(symposium_id),
  FOREIGN KEY (entity_id)    REFERENCES entities(entity_id)
);
