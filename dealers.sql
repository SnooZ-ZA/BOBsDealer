CREATE TABLE IF NOT EXISTS `dealers` (
  `identifier` varchar(255) NOT NULL,
  `timeleft` int(5) DEFAULT '0',
  `weed` int(5) DEFAULT '0',
  `meth` int(5) DEFAULT '0',
  `coke` int(5) DEFAULT '0',
  `money` int(10) DEFAULT '0',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
