-- phpMyAdmin SQL Dump
-- version 4.0.10.7
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Mar 16, 2015 at 04:56 PM
-- Server version: 5.5.41-cll-lve
-- PHP Version: 5.4.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `xavyxcom_xavyx`
--

-- --------------------------------------------------------

--
-- Table structure for table `deviceTokens`
--

CREATE TABLE IF NOT EXISTS `deviceTokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `IdUser` int(255) NOT NULL,
  `token` varchar(150) CHARACTER SET utf8 NOT NULL,
  `transactionDateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=22 ;

-- --------------------------------------------------------

--
-- Table structure for table `flag`
--

CREATE TABLE IF NOT EXISTS `flag` (
  `id` int(200) NOT NULL AUTO_INCREMENT,
  `IdPhoto` varchar(200) NOT NULL,
  `IdUser` int(200) NOT NULL,
  `type` varchar(200) NOT NULL,
  `IdUserFlag` int(200) NOT NULL,
  `transactionDateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `flagged` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=13 ;

-- --------------------------------------------------------

--
-- Table structure for table `flagDeletedPhotos`
--

CREATE TABLE IF NOT EXISTS `flagDeletedPhotos` (
  `id` int(200) NOT NULL AUTO_INCREMENT,
  `IdPhoto` varchar(200) NOT NULL,
  `IdUser` int(200) NOT NULL,
  `title` varchar(200) DEFAULT NULL,
  `award` int(11) DEFAULT '0',
  `life` datetime NOT NULL,
  `transactionDateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `likes` int(11) NOT NULL,
  `flags` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `IdPhoto` (`IdPhoto`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=89 ;

-- --------------------------------------------------------

--
-- Table structure for table `forgotPassword`
--

CREATE TABLE IF NOT EXISTS `forgotPassword` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(50) NOT NULL,
  `email` varchar(200) NOT NULL,
  `attempts` int(11) NOT NULL,
  `transactionDateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=71 ;


-- --------------------------------------------------------

--
-- Table structure for table `likes`
--

CREATE TABLE IF NOT EXISTS `likes` (
  `id` int(200) NOT NULL AUTO_INCREMENT,
  `IdPhoto` varchar(200) NOT NULL,
  `IdUser` int(200) NOT NULL,
  `IdUserLike` int(200) NOT NULL,
  `transactionDateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `liked` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=49 ;

--
-- Dumping data for table `likes`
--

INSERT INTO `likes` (`id`, `IdPhoto`, `IdUser`, `IdUserLike`, `transactionDateTime`, `liked`) VALUES
(48, '1181426059066', 119, 0, '2015-03-13 03:16:07', 1);

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE IF NOT EXISTS `login` (
  `IdUser` int(200) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `pass` varchar(200) NOT NULL,
  `firstName` varchar(200) NOT NULL,
  `lastName` varchar(200) NOT NULL,
  `profileImage` varchar(200) NOT NULL,
  `email` varchar(200) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `activation` varchar(300) NOT NULL,
  `transactionDateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdUser`),
  UNIQUE KEY `eMail` (`email`),
  UNIQUE KEY `activation` (`activation`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=120 ;

-- --------------------------------------------------------

--
-- Table structure for table `photoComments`
--

CREATE TABLE IF NOT EXISTS `photoComments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `IdUser` int(11) NOT NULL,
  `IdPhoto` varchar(200) NOT NULL,
  `comment` varchar(500) NOT NULL,
  `transactionDateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=22 ;

-- --------------------------------------------------------

--
-- Table structure for table `photoCommentsAPNS`
--

CREATE TABLE IF NOT EXISTS `photoCommentsAPNS` (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `IdUser` int(255) NOT NULL,
  `IdPhoto` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Table structure for table `photos`
--

CREATE TABLE IF NOT EXISTS `photos` (
  `id` int(200) NOT NULL AUTO_INCREMENT,
  `IdPhoto` varchar(200) NOT NULL,
  `IdUser` int(200) NOT NULL,
  `title` varchar(200) NOT NULL,
  `award` int(11) DEFAULT '0',
  `life` datetime NOT NULL,
  `transactionDateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` tinyint(1) DEFAULT '1',
  `othersIdUser` int(200) DEFAULT NULL,
  `likes` int(11) NOT NULL,
  `flags` int(11) NOT NULL,
  `sequence` int(2) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `IdPhoto` (`IdPhoto`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=205 ;

-- --------------------------------------------------------