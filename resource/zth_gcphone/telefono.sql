-- --------------------------------------------------------
-- Host:                         srv.gamegrabbers.it
-- Versione server:              10.4.10-MariaDB - mariadb.org binary distribution
-- S.O. server:                  Win64
-- HeidiSQL Versione:            10.3.0.5771
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dump della struttura di tabella esfx.cell_towers
CREATE TABLE IF NOT EXISTS `cell_towers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tower_label` varchar(255) DEFAULT NULL,
  `x` double NOT NULL DEFAULT 0,
  `y` double NOT NULL DEFAULT 0,
  `broken` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coordinate` (`x`,`y`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=latin1;

-- Dump dei dati della tabella esfx.cell_towers: ~47 rows (circa)
DELETE FROM `cell_towers`;
/*!40000 ALTER TABLE `cell_towers` DISABLE KEYS */;
INSERT INTO `cell_towers` (`id`, `tower_label`, `x`, `y`, `broken`) VALUES
	(1, 'torre1', -1288.63, -444.78, 0),
	(2, 'torre2', -900.5, -1245.9, 0),
	(3, 'torre3', -65.25, -1282.9, 0),
	(4, 'torre4', 470.5, -1015.85, 0),
	(5, 'torre5', 26.51, 6468.7, 0),
	(6, 'torre6', -143.746, -637.036, 0),
	(7, 'torre7', -429.904, 263.826, 0),
	(8, 'torre8', 1694.717, 3616.178, 0),
	(9, 'torre9', 999.895, 3577.541, 0),
	(10, 'torre10', 2319.618, 2953.879, 0),
	(11, 'torre11', 761.229, 2575.218, 0),
	(12, 'torre12', 1029.065, -3116.018, 0),
	(13, 'torre13', 333.17, 430.42, 0),
	(14, 'torre14', 1555.881, 797.882, 0),
	(15, 'torre15', 1400.267, 2121.764, 0),
	(16, 'torre16', 2972.253, 3489.116, 0),
	(17, 'torre17', -2312.738, 350.847, 0),
	(18, 'torre18', 795.717, -2285.257, 0),
	(19, 'torre19', 38.156, -1836.739, 0),
	(20, 'torre20', 1362.364, -1523.894, 0),
	(21, 'torre21', -2309.044, -370.694, 0),
	(22, 'torre22', 1073.043, 201.276, 0),
	(23, 'torre23', -2062.99, 1984.061, 0),
	(24, 'torre24', -1487.747, -1021.537, 0),
	(25, 'torre25', -2958.35, 474.732, 0),
	(26, 'torre26', -2677.426, 1324.919, 0),
	(27, 'torre27', -914.82, -2519.14, 0),
	(28, 'torre28', -742.06, 5595.33, 0),
	(29, 'torre29', -1579.81, 776.25, 0),
	(30, 'torre30', -637.89, 863.06, 0),
	(31, 'torre31', 2248.84, 5160.42, 0),
	(32, 'torre32', -268.55, 2201.62, 0),
	(33, 'torre33', 2557.87, 395.71, 0),
	(34, 'torre34', 2484.55, 1584.72, 0),
	(35, 'torre35', 1701.67, 6422.1, 0),
	(36, 'torre36', 1032.44, -503.17, 0),
	(37, 'torre37', 3495.63, 4856.12, 0),
	(38, 'torre38', -1521.47, 134.61, 0),
	(39, 'torre39', 5265.45, -5427.24, 0),
	(40, 'torre40', -1714.13, 5050.15, 0),
	(41, 'torre41', -1118.66, 2695.86, 0),
	(42, 'torre42', 1304.26, 4365.69, 0),
	(43, 'torre43', 109.35, 3581.54, 0),
	(44, 'torre44', 142.26, -2890.87, 0),
	(45, 'torre45', 415.76, -212.23, 0),
	(46, 'torre46', -1511.35, 1507.06, 0),
	(47, 'torre47', -2191.29, 4276.4, 0);
/*!40000 ALTER TABLE `cell_towers` ENABLE KEYS */;

-- Dump della struttura di tabella esfx.home_wifi_nets
CREATE TABLE IF NOT EXISTS `home_wifi_nets` (
  `steam_id` varchar(50) NOT NULL DEFAULT '',
  `label` varchar(32) NOT NULL DEFAULT '',
  `password` varchar(32) NOT NULL DEFAULT '',
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `due_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `not_expire` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`steam_id`),
  UNIQUE KEY `coordinate` (`x`,`y`,`z`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dump dei dati della tabella esfx.home_wifi_nets: ~7 rows (circa)
DELETE FROM `home_wifi_nets`;
/*!40000 ALTER TABLE `home_wifi_nets` DISABLE KEYS */;
INSERT INTO `home_wifi_nets` (`steam_id`, `label`, `password`, `x`, `y`, `z`, `created`, `due_date`, `not_expire`) VALUES
	('lifeinvader', 'Life Invader', 'llifeinvader', -1075.832, -248.41, 37.763, '2020-12-18 21:11:10', '2020-12-18 21:11:25', 1),
	('polizia', 'Centrale', 'policeenforce', 447.118, -985.24, 30.69, '2020-12-18 21:11:10', '2020-12-18 21:11:25', 1);
/*!40000 ALTER TABLE `home_wifi_nets` ENABLE KEYS */;

-- Dump della struttura di tabella esfx.phone_app_chat
CREATE TABLE IF NOT EXISTS `phone_app_chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel` varchar(20) NOT NULL,
  `message` varchar(255) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_bank_movements
CREATE TABLE IF NOT EXISTS `phone_bank_movements` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `amount` bigint(20) NOT NULL DEFAULT 0,
  `type` varchar(255) DEFAULT NULL,
  `to` varchar(255) DEFAULT NULL,
  `from` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_calls
CREATE TABLE IF NOT EXISTS `phone_calls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(10) NOT NULL COMMENT 'Num tel proprio',
  `num` varchar(10) NOT NULL COMMENT 'Num reférence du contact',
  `incoming` int(11) NOT NULL COMMENT 'Défini si on est à l''origine de l''appels',
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `accepts` int(11) NOT NULL COMMENT 'Appels accepter ou pas',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_darkweb_messages
CREATE TABLE IF NOT EXISTS `phone_darkweb_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(255) DEFAULT NULL,
  `message` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_emails
CREATE TABLE IF NOT EXISTS `phone_emails` (
  `id` int(55) NOT NULL AUTO_INCREMENT,
  `sender` varchar(255) DEFAULT NULL,
  `receiver` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL DEFAULT 'CURRENT_TIMESTAMP',
  `message` mediumtext NOT NULL,
  `pic` varchar(255) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_instagram_accounts
CREATE TABLE IF NOT EXISTS `phone_instagram_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `avatar_url` varchar(255) NOT NULL DEFAULT '/html/static/img/app_instagram/default_profile.png',
  PRIMARY KEY (`id`),
  UNIQUE KEY `Indice 2` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_instagram_likes
CREATE TABLE IF NOT EXISTS `phone_instagram_likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) NOT NULL DEFAULT 0,
  `postId` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `FK_instagram_likes_instagram_accounts` (`authorId`),
  KEY `FK_instagram_likes_instagram_posts` (`postId`),
  CONSTRAINT `FK_instagram_likes_instagram_accounts` FOREIGN KEY (`authorId`) REFERENCES `phone_instagram_accounts` (`id`),
  CONSTRAINT `FK_instagram_likes_instagram_posts` FOREIGN KEY (`postId`) REFERENCES `phone_instagram_posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_instagram_posts
CREATE TABLE IF NOT EXISTS `phone_instagram_posts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `authorId` varchar(255) NOT NULL,
  `image` mediumtext NOT NULL,
  `didascalia` mediumtext NOT NULL,
  `filter` varchar(50) NOT NULL DEFAULT 'Originale',
  `likes` mediumint(9) NOT NULL DEFAULT 0,
  `data` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_messages
CREATE TABLE IF NOT EXISTS `phone_messages` (
  `id` bigint(50) NOT NULL AUTO_INCREMENT,
  `transmitter` varchar(255) NOT NULL,
  `receiver` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL DEFAULT '0',
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `isRead` int(11) NOT NULL DEFAULT 0,
  `owner` int(11) NOT NULL DEFAULT 0,
  `received` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `transmitter` (`transmitter`),
  KEY `receiver` (`receiver`)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_users_contacts
CREATE TABLE IF NOT EXISTS `phone_users_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) CHARACTER SET utf8mb4 DEFAULT NULL,
  `number` varchar(10) CHARACTER SET utf8mb4 DEFAULT NULL,
  `display` varchar(64) CHARACTER SET utf8mb4 DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_users_emails
CREATE TABLE IF NOT EXISTS `phone_users_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_user_covers
CREATE TABLE IF NOT EXISTS `phone_user_covers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL DEFAULT '0',
  `cover` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_whatsapp_groups
CREATE TABLE IF NOT EXISTS `phone_whatsapp_groups` (
  `id` bigint(255) NOT NULL AUTO_INCREMENT,
  `icona` varchar(50) NOT NULL,
  `gruppo` varchar(255) NOT NULL DEFAULT 'Nessun nome',
  `partecipanti` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.phone_whatsapp_messages
CREATE TABLE IF NOT EXISTS `phone_whatsapp_messages` (
  `id` bigint(255) NOT NULL AUTO_INCREMENT,
  `idgruppo` bigint(255) NOT NULL DEFAULT 0,
  `sender` varchar(255) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.sim
CREATE TABLE IF NOT EXISTS `sim` (
  `identifier` varchar(50) NOT NULL,
  `phone_number` varchar(10) DEFAULT NULL,
  `piano_tariffario` varchar(16) DEFAULT NULL,
  `minuti` int(11) DEFAULT NULL,
  `messaggi` int(11) DEFAULT NULL,
  `dati` int(11) DEFAULT NULL,
  `nome_sim` varchar(10) DEFAULT '',
  UNIQUE KEY `phone_number` (`phone_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.twitter_accounts
CREATE TABLE IF NOT EXISTS `twitter_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  `password` varchar(50) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `avatar_url` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.twitter_likes
CREATE TABLE IF NOT EXISTS `twitter_likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) DEFAULT NULL,
  `tweetId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_twitter_likes_twitter_accounts` (`authorId`),
  KEY `FK_twitter_likes_twitter_tweets` (`tweetId`),
  CONSTRAINT `FK_twitter_likes_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`),
  CONSTRAINT `FK_twitter_likes_twitter_tweets` FOREIGN KEY (`tweetId`) REFERENCES `twitter_tweets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- L’esportazione dei dati non era selezionata.

-- Dump della struttura di tabella esfx.twitter_tweets
CREATE TABLE IF NOT EXISTS `twitter_tweets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) NOT NULL,
  `realUser` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `likes` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `FK_twitter_tweets_twitter_accounts` (`authorId`),
  CONSTRAINT `FK_twitter_tweets_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- L’esportazione dei dati non era selezionata.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
