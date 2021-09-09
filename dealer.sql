CREATE TABLE IF NOT EXISTS `dealers` (
  `identifier` varchar(255) CHARACTER SET utf8 NOT NULL,
  `timeleft` INT(5) DEFAULT '0',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;