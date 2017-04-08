CREATE TABLE boards (
  board_id  INT NOT NULL AUTO_INCREMENT,
  name      VARCHAR(255),
  PRIMARY KEY (board_id)
);

INSERT INTO boards (name) VALUES ('Oddyscape-World');

CREATE TABLE locations (
  location_id  INT NOT NULL AUTO_INCREMENT,
  board_id     INT NOT NULL,
  name         VARCHAR(255),
  PRIMARY KEY (location_id),
  FOREIGN KEY (board_id) REFERENCES boards(board_id)
);

INSERT INTO locations (board_id, name) VALUES (1, 'The Beach');

/* Think of this table as a "state" that a location may have */
CREATE TABLE spaces (
  space_id     INT          NOT NULL AUTO_INCREMENT,
  post_id      VARCHAR(255) NULL,
  location_id  INT          NOT NULL,
  dir          VARCHAR(255),
  PRIMARY KEY (space_id),
  FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

INSERT INTO spaces (post_id, location_id, dir) VALUES (302, 1, '{"explore":2}');

INSERT INTO spaces (post_id, location_id) VALUES (363, 1);

CREATE TABLE pieces (
  piece_id  INT NOT NULL AUTO_INCREMENT,
  space_id  INT NULL,
  PRIMARY KEY (piece_id),
  FOREIGN KEY (space_id) REFERENCES spaces(space_id)
);

INSERT INTO pieces (space_id) VALUES (1);

CREATE TABLE characters (
  character_id  INT NOT NULL AUTO_INCREMENT,
  user_id       INT,
  name          VARCHAR(255),
  piece_id      INT NOT NULL,
  PRIMARY KEY (character_id),
  FOREIGN KEY (piece_id) REFERENCES pieces(piece_id)
);

INSERT INTO characters (user_id, name, piece_id) VALUES (1, 'Arian', 1);

/* This is should be in Artemis::Symposium */
CREATE TABLE symposium (
  symposium_id INT          NOT NULL AUTO_INCREMENT,
  type         VARCHAR(255) NULL,
  PRIMARY KEY (symposium_id)
);

/* This is should be in Artemis::Symposium */
CREATE TABLE symposium_participant (
  symposium_participant_id INT          NOT NULL AUTO_INCREMENT,
  symposium_id             INT,
  type         VARCHAR(255) NULL,
  PRIMARY KEY (symposium_participant_id),
  FOREIGN KEY (symposium_id) REFERENCES pieces(piece_id)
);
