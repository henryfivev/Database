CREATE ROLE SalesToBRole;
CREATE ROLE SalesToCRole;
CREATE ROLE ItemManagerRole;
CREATE ROLE ManagerRole;

GRANT SELECT, INSERT ON customer TO SalesToCRole;
GRANT SELECT, INSERT ON orders TO SalesToCRole;
GRANT SELECT ON item TO SalesToCRole;
GRANT SELECT ON `user` TO SalesToCRole;

GRANT SELECT, INSERT ON supplier TO SalesToBRole;
GRANT SELECT, INSERT ON supply TO SalesToBRole;
GRANT SELECT ON item TO SalesToBRole;
GRANT SELECT ON `user` TO SalesToBRole;

GRANT SELECT, INSERT ON item TO ItemManagerRole;
GRANT SELECT ON orders TO ItemManagerRole;
GRANT SELECT ON supply TO ItemManagerRole;
GRANT SELECT ON `user` TO ItemManagerRole;

GRANT ALL PRIVILEGES ON exp.* TO ManagerRole;