/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb3 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE OR REPLACE DATABASE `db_Secure` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci */;
USE `db_Secure`;

CREATE TABLE IF NOT EXISTS `tb_Attachment` (
  `idAttachment` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `base64` longtext NOT NULL,
  `hash` char(32) GENERATED ALWAYS AS (md5(`base64`)) STORED,
  `size` int(10) unsigned GENERATED ALWAYS AS (octet_length(`base64`)) STORED,
  `name` varchar(255) DEFAULT NULL,
  `mime` varchar(100) DEFAULT NULL,
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idAttachment`),
  UNIQUE KEY `hash_len` (`hash`,`size`),
  KEY `mime` (`mime`),
  KEY `name` (`name`)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Attachment_File` (
  `idAttachment` int(10) unsigned NOT NULL,
  `idFile` int(10) unsigned NOT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1),
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `UK` (`idAttachment`,`idFile`,`DtGer`),
  KEY `DtGer` (`DtGer`),
  KEY `idUserUpd` (`idUserUpd`),
  KEY `idFile` (`idFile`),
  CONSTRAINT `FK_tb_Attachment_File_tb_Attachment` FOREIGN KEY (`idAttachment`) REFERENCES `tb_Attachment` (`idAttachment`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_File_tb_Files` FOREIGN KEY (`idFile`) REFERENCES `tb_Files` (`idFile`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_File_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Attachment_GrpFile` (
  `idAttachment` int(10) unsigned NOT NULL,
  `idGrpFile` smallint(5) unsigned NOT NULL DEFAULT 0,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1),
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `UK` (`idAttachment`,`idGrpFile`,`DtGer`),
  KEY `DtGer` (`DtGer`),
  KEY `idUserUpd` (`idUserUpd`),
  KEY `idGrpFile` (`idGrpFile`),
  CONSTRAINT `FK_tb_Attachment_GrpFile_tb_Attachment` FOREIGN KEY (`idAttachment`) REFERENCES `tb_Attachment` (`idAttachment`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_GrpFile_tb_GrpFile` FOREIGN KEY (`idGrpFile`) REFERENCES `tb_GrpFile` (`idGrpFile`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_GrpFile_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Attachment_GrpUsr` (
  `idAttachment` int(10) unsigned NOT NULL,
  `idGrpUsr` smallint(5) unsigned NOT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1),
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `UK` (`idAttachment`,`idGrpUsr`,`DtGer`),
  KEY `DtGer` (`DtGer`),
  KEY `idUserUpd` (`idUserUpd`),
  KEY `idGrpUsr` (`idGrpUsr`),
  CONSTRAINT `FK_tb_Attachment_GrpUsr_tb_Attachment` FOREIGN KEY (`idAttachment`) REFERENCES `tb_Attachment` (`idAttachment`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_GrpUsr_tb_GrpUsr` FOREIGN KEY (`idGrpUsr`) REFERENCES `tb_GrpUsr` (`idGrpUsr`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_GrpUsr_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Attachment_Permitions` (
  `idAttachment` int(10) unsigned NOT NULL,
  `idPermition` int(10) unsigned NOT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1),
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `UK` (`idAttachment`,`idPermition`,`DtGer`),
  KEY `idPermition` (`idPermition`),
  KEY `DtGer` (`DtGer`),
  KEY `idUserUpd` (`idUserUpd`),
  CONSTRAINT `FK_tb_Attachment_Permitions_tb_Attachment` FOREIGN KEY (`idAttachment`) REFERENCES `tb_Attachment` (`idAttachment`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_Permitions_tb_Permitions` FOREIGN KEY (`idPermition`) REFERENCES `tb_Permitions` (`idPermition`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_Permitions_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Attachment_User` (
  `idAttachment` int(10) unsigned NOT NULL,
  `idUser` int(10) unsigned NOT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1),
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `UK` (`idAttachment`,`idUser`,`DtGer`),
  KEY `DtGer` (`DtGer`),
  KEY `idUserUpd` (`idUserUpd`),
  KEY `idUser` (`idUser`),
  CONSTRAINT `FK_tb_Attachment_User_tb_Attachment` FOREIGN KEY (`idAttachment`) REFERENCES `tb_Attachment` (`idAttachment`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_User_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Attachment_User_tb_Users_2` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Document_types` (
  `id_document_type` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `document_type` varchar(50) NOT NULL,
  PRIMARY KEY (`id_document_type`),
  UNIQUE KEY `document_type` (`document_type`)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Domain` (
  `idDomain` tinyint(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id da tabela',
  `Domain` varchar(50) NOT NULL DEFAULT '' COMMENT 'Nome do dominio. Vazio=Web',
  `Obs` text DEFAULT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idDomain`),
  UNIQUE KEY `Domain` (`Domain`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `idUserUpd` (`idUserUpd`),
  CONSTRAINT `FK_tb_Domain_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Lista de Domínios utilizados';


CREATE TABLE IF NOT EXISTS `tb_Files` (
  `idFile` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id da tabela',
  `File` varchar(255) NOT NULL COMMENT 'Nome do arquivo com caminho completo protocolo://domain/path/file',
  `C` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Create]Permissao Criar',
  `R` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT '[Read]Permissao Ler',
  `U` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Update]Permissao Escrever',
  `D` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Delete]Permissao Exclusao',
  `S` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Special]Permissao Executar',
  `L` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT '[Level]Nivel de Compara\r\n<?\r\n$this->element="ElementCombo";\r\n$this->source=array("Free","Secured","Paranoic");\r\n?>',
  `CRUDS` tinyint(2) unsigned DEFAULT NULL COMMENT '<?$this->edit=false;?>',
  `Obs` text DEFAULT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=>false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '[Geracao]<?$this->edit=>false;?>',
  PRIMARY KEY (`idFile`),
  UNIQUE KEY `File` (`File`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `L` (`L`),
  KEY `idUserUpd` (`idUserUpd`),
  CONSTRAINT `FK_tb_Files_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Arquivos controlados pelo Secure Class.\r\nCRUDS aqui é usado como funções do Arquivo e L o nível de segurança que se espera do arquivo';


CREATE TABLE IF NOT EXISTS `tb_Files_x_tb_GrpFile` (
  `idFile` int(10) unsigned NOT NULL COMMENT 'Id do arquivo',
  `idGrpFile` smallint(5) unsigned NOT NULL COMMENT 'Id do grupo de arquivos',
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idFile`,`idGrpFile`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `idGrpFile` (`idGrpFile`),
  KEY `idUserUpd` (`idUserUpd`),
  CONSTRAINT `FK_tb_Files_x_tb_GrpFile_tb_Files` FOREIGN KEY (`idFile`) REFERENCES `tb_Files` (`idFile`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Files_x_tb_GrpFile_tb_GrpFile` FOREIGN KEY (`idGrpFile`) REFERENCES `tb_GrpFile` (`idGrpFile`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Files_x_tb_GrpFile_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Relação de Files com Grupo de Files';


CREATE TABLE IF NOT EXISTS `tb_GrpFile` (
  `idGrpFile` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id da tabela',
  `GrpFile` varchar(64) NOT NULL COMMENT 'Nome do grupo de arquivos',
  `Obs` text DEFAULT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idGrpFile`),
  UNIQUE KEY `GrpFile` (`GrpFile`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `idUserUpd` (`idUserUpd`),
  CONSTRAINT `FK_tb_GrpFile_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Grupo de Arquivos';


CREATE TABLE IF NOT EXISTS `tb_GrpUsr` (
  `idGrpUsr` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id da tabela',
  `GrpUsr` varchar(64) NOT NULL COMMENT 'Nome do grupo de usuarios',
  `EMail` varchar(255) DEFAULT NULL COMMENT 'DL do Grupo',
  `Obs` text DEFAULT NULL,
  `isLdap` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idGrpUsr`),
  UNIQUE KEY `GrpUsr` (`GrpUsr`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `idUserUpd` (`idUserUpd`),
  KEY `isLdap` (`isLdap`),
  CONSTRAINT `FK_tb_GrpUsr_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Grupo de Usuários';


CREATE TABLE IF NOT EXISTS `tb_Import_Users` (
  `Matricula` varchar(64) NOT NULL,
  `idUser` int(10) unsigned DEFAULT NULL,
  `User` varchar(64) DEFAULT NULL,
  `Nome` varchar(64) DEFAULT NULL,
  `Email` varchar(64) DEFAULT NULL,
  `Sexo` char(1) NOT NULL DEFAULT '',
  `GSM` varchar(20) DEFAULT NULL,
  `Telefone` varchar(20) DEFAULT NULL,
  `Site` varchar(5) DEFAULT NULL,
  `Position` varchar(55) DEFAULT NULL,
  PRIMARY KEY (`Matricula`),
  KEY `idUser` (`idUser`),
  CONSTRAINT `FK_tb_Import_Users_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Penalty` (
  `IP` varchar(64) NOT NULL,
  `DtUpdate` timestamp(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`IP`),
  KEY `DtUpdate` (`DtUpdate`)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_Permitions` (
  `idPermition` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idGrpUsr` smallint(5) unsigned NOT NULL COMMENT '[Grp.Users]Id de Grupo de Usuarios<?\r\n$this->element="ElementCombo";\r\n$this->sql="tb_GrpUsr";\r\n$this->order="GrpUsr";\r\n$this->fields="GrpUsr";\r\n$this->class=''selectpicker'';\r\n$this->attr=array(''data-live-search''=>''true'',''data-size''=>8);\r\n?>',
  `idGrpFile` smallint(5) unsigned NOT NULL COMMENT '[Grp.Files]Id de Grupo de Arquivos<?\r\n$this->element="ElementCombo";\r\n$this->sql="tb_GrpFile";\r\n$this->order=''GrpFile'';\r\n$this->fields=''GrpFile'';\r\n$this->class=''selectpicker'';\r\n$this->attr=array(''data-live-search''=>''true'',''data-size''=>8);\r\n?>',
  `C` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Create]Permissao Criar',
  `R` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT '[Read]Permissao Ler',
  `U` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Update]Permissao Escrever',
  `D` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Delete]Permissao Exclusao',
  `S` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Special]Permissoo Especial',
  `CRUDS` tinyint(2) unsigned DEFAULT NULL COMMENT '<?$this->edit=false;?>',
  `Obs` text DEFAULT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idPermition`),
  UNIQUE KEY `idGrpUsr` (`idGrpUsr`,`idGrpFile`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `idGrpFile` (`idGrpFile`),
  KEY `idUserUpd` (`idUserUpd`),
  CONSTRAINT `FK_tb_Permitions_tb_GrpFile` FOREIGN KEY (`idGrpFile`) REFERENCES `tb_GrpFile` (`idGrpFile`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Permitions_tb_GrpUsr` FOREIGN KEY (`idGrpUsr`) REFERENCES `tb_GrpUsr` (`idGrpUsr`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Permitions_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Permissões de Grupo de Usuários para Grupo de Arquivos';


CREATE TABLE IF NOT EXISTS `tb_Positions` (
  `idPosition` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Position` varchar(64) NOT NULL,
  `Obs` text DEFAULT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idPosition`),
  UNIQUE KEY `Position` (`Position`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `idUserUpd` (`idUserUpd`),
  CONSTRAINT `FK_tb_Positions_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Lista de Cargos';


CREATE TABLE IF NOT EXISTS `tb_Sites` (
  `idSite` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Site` varchar(32) NOT NULL,
  `Logradouro` varchar(255) DEFAULT NULL,
  `Numero` varchar(20) DEFAULT NULL,
  `Bairro` varchar(100) DEFAULT NULL,
  `Cidade` varchar(100) DEFAULT NULL,
  `UF` char(2) DEFAULT NULL,
  `CEP` char(9) DEFAULT NULL,
  PRIMARY KEY (`idSite`),
  UNIQUE KEY `Site` (`Site`)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS `tb_URLs` (
  `idURL` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `lnk` varchar(8) DEFAULT NULL,
  `URL` varchar(500) DEFAULT NULL COMMENT '<?$this->width=''50%'';?>',
  `QString` text DEFAULT NULL COMMENT '<?\r\n$this->rows=15;\r\n$this->height=''15em'';\r\n?>',
  `hash` varchar(45) DEFAULT NULL,
  `Descr` varchar(150) DEFAULT NULL,
  `isTemporary` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp(),
  `DtLastVisit` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `idUser` int(10) unsigned DEFAULT NULL COMMENT '[User]<?$this->element=''ElementIdUser'';\r\n$this->default=Secure::$idUser;\r\n?>',
  PRIMARY KEY (`idURL`),
  UNIQUE KEY `lnk` (`lnk`),
  UNIQUE KEY `hash` (`hash`),
  KEY `DtGer` (`DtGer`),
  KEY `isTemporary` (`isTemporary`),
  KEY `DtLastVisit` (`DtLastVisit`),
  KEY `idUser` (`idUser`),
  CONSTRAINT `FK_tb_URLs_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Links armazenados para serme usados como resumido';


CREATE TABLE IF NOT EXISTS `tb_Users` (
  `idUser` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id da tabela\r\n<?$this->hidden=false;?>',
  `idDomain` tinyint(4) unsigned NOT NULL DEFAULT 3 COMMENT '[Domain]Id do Dominio\r\n<?\r\n$this->element="ElementCombo";\r\n$this->sql="tb_Domain";\r\n$this->Order="Domain";\r\n$this->fields="Domain";\r\n?>',
  `User` varchar(64) NOT NULL COMMENT 'Nome de usuario\r\n',
  `Ativo` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT 'Funcionario',
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`),
  UNIQUE KEY `idDomain` (`idDomain`,`User`),
  KEY `Ativo` (`Ativo`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `User` (`User`),
  KEY `idUserUpd` (`idUserUpd`),
  CONSTRAINT `FK_tb_Users_tb_Users` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Todos os logins com seus respectivos domínios';


CREATE TABLE IF NOT EXISTS `tb_Users_Confirm` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=false;?>',
  `Confirm` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '[Confirmado] Cadastro confirmado',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Data de atualizacao <?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`),
  KEY `Confirm` (`Confirm`),
  KEY `DtUpdate` (`DtUpdate`),
  CONSTRAINT `FK_tb_Users_Confirm_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Se o Login está confirmado por algum meio de entrada AD/LDAP, SMS, e-mail';


CREATE TABLE IF NOT EXISTS `tb_Users_Detail` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=false;?>',
  `Nome` varchar(64) DEFAULT NULL COMMENT '<?$this->width=''20em'';?>',
  `Sexo` enum('','Male','Female') DEFAULT NULL,
  `idGestor` int(10) unsigned DEFAULT NULL COMMENT '[Gestor]<?\r\n$this->element="ElementCombo";\r\n$this->sql="tb_Users_Detail";\r\n$this->order=''Nome'';\r\n$this->fields=''Nome'';\r\n$this->class=''selectpicker'';\r\n$this->attr=array(''data-live-search''=>''true'',''data-size''=>8);\r\n?>',
  `idPosition` int(10) unsigned DEFAULT NULL COMMENT '[Position]<?\r\n$this->element="ElementCombo";\r\n$this->sql="tb_Positions";\r\n$this->order=''Position'';\r\n$this->fields=''Position'';\r\n$this->class=''selectpicker'';\r\n$this->attr=array(''data-live-search''=>''true'',''data-size''=>8);\r\n?>',
  `Matricula` varchar(20) DEFAULT NULL COMMENT '<?$this->width=''9em'';?>',
  `Niver` date DEFAULT NULL,
  `DtContrato` date DEFAULT NULL COMMENT '[Contratação]Início do período aquisitivo do funcionário',
  `CentroCusto` varchar(10) NOT NULL,
  `idSite_Lotado` int(10) unsigned DEFAULT NULL COMMENT '[Lotado em]Local de gerencia do RH',
  `idSite_Locado` int(10) unsigned DEFAULT NULL COMMENT '[Locado em]Local de trabalho atual',
  `Obs` text DEFAULT NULL,
  `idUserUpd` int(10) unsigned DEFAULT ifnull(@`Secure_idUser`,1) COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `idPosition` (`idPosition`),
  KEY `idGestor` (`idGestor`),
  KEY `Matricula` (`Matricula`),
  KEY `Niver` (`Niver`),
  KEY `Nome` (`Nome`),
  KEY `FK_tb_Users_Detail_tb_Sites` (`idSite_Lotado`),
  KEY `FK_tb_Users_Detail_tb_Sites_2` (`idSite_Locado`),
  KEY `FK_tb_Users_Detail_tb_Users_2` (`idUserUpd`),
  CONSTRAINT `FK_tb_Users_Detail_db_Secure.tb_Users` FOREIGN KEY (`idGestor`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Users_Detail_tb_Positions` FOREIGN KEY (`idPosition`) REFERENCES `tb_Positions` (`idPosition`) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Users_Detail_tb_Sites` FOREIGN KEY (`idSite_Lotado`) REFERENCES `tb_Sites` (`idSite`) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Users_Detail_tb_Sites_2` FOREIGN KEY (`idSite_Locado`) REFERENCES `tb_Sites` (`idSite`) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Users_Detail_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Users_Detail_tb_Users_2` FOREIGN KEY (`idUserUpd`) REFERENCES `tb_Users` (`idUser`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Detalhes do Usuário';


CREATE TABLE IF NOT EXISTS `tb_Users_Documents` (
  `idUser` int(10) unsigned NOT NULL COMMENT '<?$this->hidden=true;?>',
  `id_document_type` tinyint(3) unsigned NOT NULL COMMENT '[Type]Type of Document',
  `Document` varchar(255) NOT NULL COMMENT '[Doc]Document',
  `Obs` text DEFAULT NULL,
  PRIMARY KEY (`idUser`,`id_document_type`),
  UNIQUE KEY `Documento` (`Document`,`id_document_type`,`idUser`),
  KEY `TipoDocumento` (`id_document_type`),
  CONSTRAINT `FK_tb_Users_Documents_tb_Document_types` FOREIGN KEY (`id_document_type`) REFERENCES `tb_Document_types` (`id_document_type`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Users_Documents_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Documentos do Usuário';


CREATE TABLE IF NOT EXISTS `tb_Users_Emails` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=true;?>',
  `Email` varchar(64) NOT NULL COMMENT '<?$this->element=''ElementEmail'';$this->fn=''Links::mailto'';?>',
  `EmailType` enum('Business','Home','Other') NOT NULL DEFAULT 'Business' COMMENT '[Tipo]Tipo do Email',
  `Confirm` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `KeyConfirm` varchar(10) DEFAULT NULL,
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`,`Email`),
  UNIQUE KEY `Email` (`Email`,`idUser`),
  KEY `Confirm` (`Confirm`),
  KEY `DtUpdate` (`DtUpdate`),
  CONSTRAINT `FK_tb_Users_Emails_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='E-mails do Usuário';


CREATE TABLE IF NOT EXISTS `tb_Users_Enderecos` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=true;?>',
  `Pop` varchar(16) NOT NULL DEFAULT 'Principal' COMMENT '[Local]Tipo do Local',
  `EndType` enum('Business','Home','Other') NOT NULL DEFAULT 'Business' COMMENT '[Tipo]',
  `Logradouro` varchar(255) DEFAULT NULL COMMENT '[Logr]Logradouro',
  `Num` varchar(16) DEFAULT NULL,
  `Complemento` varchar(64) DEFAULT NULL COMMENT '[Comp]Comnplemento',
  `Bairro` varchar(64) DEFAULT NULL,
  `Cidade` varchar(64) DEFAULT NULL,
  `Uf` char(2) DEFAULT NULL,
  `Pais` varchar(32) NOT NULL DEFAULT 'Brasil',
  `Obs` text DEFAULT NULL,
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`,`Pop`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `Pop` (`Pop`),
  CONSTRAINT `FK_tb_Users_Enderecos_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Endereços do Usuário';


CREATE TABLE IF NOT EXISTS `tb_Users_Ip` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=false;?>',
  `Ip` varchar(39) DEFAULT NULL COMMENT '<?$this->edit=false;?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Data de atualizacao <?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `Ip` (`Ip`),
  CONSTRAINT `FK_tb_Users_Ip_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='IP em qual o usuário está usando';


CREATE TABLE IF NOT EXISTS `tb_Users_Passwd` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=false;?>',
  `Passwd` varbinary(64) NOT NULL COMMENT '<?$this->element="ElementPasswd"; $this->width=''200px'';?>',
  `DtExpires` datetime DEFAULT NULL,
  `DtUpdate` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`idUser`),
  KEY `DtExpires` (`DtExpires`),
  KEY `DtUpdate` (`DtUpdate`),
  CONSTRAINT `FK_tb_Users_Passwd_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Senha do usuário caso seja por web';


CREATE TABLE IF NOT EXISTS `tb_Users_Telefones` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=true;?>',
  `Telefone` varchar(20) NOT NULL COMMENT '[Tel]<?$this->element=''ElementTelefone'';?>',
  `TipoContato` enum('Mobile','Home','Business','Fax','Ramal') NOT NULL DEFAULT 'Mobile' COMMENT '[Tipo]Tipo do contato',
  `Obs` text DEFAULT NULL,
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`,`Telefone`),
  UNIQUE KEY `Telefone` (`Telefone`,`idUser`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `TipoContato` (`TipoContato`),
  CONSTRAINT `FK_tb_Users_Telefones_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Telefones do Usuário';


CREATE TABLE IF NOT EXISTS `tb_Users_Token` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=false;?>',
  `Token` char(32) NOT NULL DEFAULT '',
  `JWT` longtext NOT NULL,
  `Limit` int(10) unsigned NOT NULL DEFAULT 900 COMMENT 'Expires n SECONDS',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`,`Token`),
  KEY `DtGer` (`DtGer`),
  KEY `DtUpdate` (`DtUpdate`),
  CONSTRAINT `FK_tb_Users_Token_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Token que o Usuário está usando no momento';


CREATE TABLE IF NOT EXISTS `tb_Users_TryLogin` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id da tabela<?$this->hidden=false;?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Data de atualizacao <?$this->edit=false;?>',
  PRIMARY KEY (`idUser`),
  KEY `DtUpdate` (`DtUpdate`),
  CONSTRAINT `FK_tb_Users_TryLogin_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Data de tentativa de Login';


CREATE TABLE IF NOT EXISTS `tb_Users_x_tb_GrpUsr` (
  `idUser` int(10) unsigned NOT NULL COMMENT 'Id do usuario',
  `idGrpUsr` smallint(5) unsigned NOT NULL COMMENT '[Grp.Users]Id de Grupo de Usuario <?\r\n$this->element="ElementCombo";\r\n$this->sql="tb_GrpUsr";\r\n$this->order="GrpUsr";\r\n$this->fields="GrpUsr";\r\n?>',
  `isMain` tinyint(1) unsigned DEFAULT NULL,
  `Seq` int(10) unsigned NOT NULL DEFAULT 255,
  `Obs` text DEFAULT NULL,
  `idUserUpd` int(10) unsigned DEFAULT NULL COMMENT '[UserUpd]<?$this->element=''ElementIdUserUpd'';?>',
  `DtUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '<?$this->edit=false;?>',
  `DtGer` timestamp NOT NULL DEFAULT current_timestamp() COMMENT '<?$this->edit=false;?>',
  PRIMARY KEY (`idUser`,`idGrpUsr`),
  UNIQUE KEY `isMain` (`isMain`,`idUser`),
  KEY `DtUpdate` (`DtUpdate`),
  KEY `idGrpUsr` (`idGrpUsr`),
  KEY `Seq` (`Seq`),
  KEY `FK_tb_Users_x_tb_GrpUsr_tb_Users_2` (`idUserUpd`),
  CONSTRAINT `FK_tb_Users_x_tb_GrpUsr_tb_GrpUsr` FOREIGN KEY (`idGrpUsr`) REFERENCES `tb_GrpUsr` (`idGrpUsr`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_tb_Users_x_tb_GrpUsr_tb_Users` FOREIGN KEY (`idUser`) REFERENCES `tb_Users` (`idUser`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Relação de Users com Grupo de Users';





DELIMITER //
CREATE PROCEDURE `fail`(
	IN `in_text` varchar(255)
)
    COMMENT 'Executa uma exceção gerando erro'
CALL signErro(31001,in_text)//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pctr_Files_before`(
	INOUT `NEW_C` TYPE OF db_Secure.tb_Files.C,
	INOUT `NEW_R` TYPE OF db_Secure.tb_Files.R,
	INOUT `NEW_U` TYPE OF db_Secure.tb_Files.U,
	INOUT `NEW_D` TYPE OF db_Secure.tb_Files.D,
	INOUT `NEW_S` TYPE OF db_Secure.tb_Files.S,
	IN `NEW_CRUDS` TYPE OF db_Secure.tb_Files.CRUDS,
	IN `NEW_idUserUpd` TYPE OF db_Secure.tb_Files.idUserUpd
)
BEGIN
	SET NEW_idUserUpd=fn_get_idUser();
	SET NEW_CRUDS=fn_Permition_BuildCRUD(NEW_C,NEW_R,NEW_U,NEW_D,NEW_S);
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pctr_Users_Detail_before`(
	INOUT `NEW_Matricula` TYPE OF db_Secure.tb_Users_Detail.Matricula,
	INOUT `NEW_Nome` TYPE OF db_Secure.tb_Users_Detail.Nome,
	INOUT `NEW_idUserUpd` TYPE OF db_Secure.tb_Users_Detail.idUserUpd
)
BEGIN
	SET NEW_idUserUpd=fn_get_idUser();
	IF(TRIM(IFNULL(NEW_Nome,''))='')THEN SET NEW_Nome=NEW_Matricula; END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pctr_Users_Passwd_before`(
	INOUT `NEW_Passwd` TYPE OF db_secure.tb_Users_Passwd.Passwd,
	INOUT `NEW_DtExpires` TYPE OF db_secure.tb_Users_Passwd.DtExpires,
	IN `OLD_Passwd` TYPE OF db_secure.tb_Users_Passwd.Passwd
)
BEGIN
	DECLARE expiresPasswd INT UNSIGNED DEFAULT IFNULL(@expiresPassword,120);

   IF NEW_Passwd IS NULL THEN SET NEW_Passwd=''; END IF;
	IF NEW_Passwd='' THEN 
		SET NEW_Passwd=fn_encode(fn_user_getRandPasswd(12));
		SET NEW_DtExpires=NOW();
	ELSEIF NOT(NEW_Passwd<=>OLD_Passwd) THEN 
		SET NEW_Passwd=fn_encode(NEW_Passwd);
		SET NEW_DtExpires=IF(expiresPasswd=0,NULL,DATE_ADD(NOW(), INTERVAL expiresPasswd DAY));
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_CleanToken`()
DELETE t
FROM tb_Users_Token t
WHERE t.DtUpdate<NOW() - INTERVAL t.Limit SECOND//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_Import_Users`()
BEGIN
  INSERT IGNORE tb_Users (`User`)
  SELECT IFNULL(i.User,i.Matricula) FROM tb_Import_Users i;

  UPDATE tb_Import_Users i
  JOIN tb_Users u ON IFNULL(i.User,i.Matricula)=u.`User`
  SET i.idUser=u.idUser;

  UPDATE tb_Import_Users i
  JOIN tb_Users_Confirm c ON c.idUser=i.idUser
  SET c.Confirm=1;

  UPDATE tb_Import_Users i
  JOIN tb_Users_Detail d ON d.idUser=i.idUser
  LEFT JOIN db_System.tb_Cnl s ON s.Cnl=i.Site
  SET 
    d.Nome=IF(IFNULL(i.Nome,'')='',d.Nome,i.Nome),
    d.Sexo=IF(i.Sexo='M','Male',IF(i.Sexo='F','Female','')),
    d.Matricula=i.Matricula,
    d.idSite_Lotado=IFNULL(s.idCnl,d.idSite_Lotado),
    d.idSite_Locado=IFNULL(s.idCnl,d.idSite_Locado),
    d.idPosition=fn_User_GetIdCargo(i.Position);

  INSERT IGNORE tb_Users_Emails (idUser,Email,EmailType,Confirm)
  SELECT i.idUser,i.Email, 'Business' TipoContato, 1 Confirm
  FROM tb_Import_Users i
  WHERE IFNULL(i.Email,'')!='';

  INSERT IGNORE tb_Users_Telefones (idUser,Telefone,TipoContato)
  SELECT i.idUser,i.GSM, 'Mobile' TipoContato
  FROM tb_Import_Users i
  WHERE IFNULL(i.GSM,'')!='';

  INSERT IGNORE tb_Users_Telefones (idUser,Telefone,TipoContato)
  SELECT i.idUser,i.Telefone, 'Business' TipoContato
  FROM tb_Import_Users i
  WHERE IFNULL(i.Telefone,'')!='';

  TRUNCATE TABLE tb_Import_Users;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_ManagerLocate`(
	IN `in_idUser` INT(10) UNSIGNED,
	INOUT `in_idUserLocate` INT(10) UNSIGNED
)
BEGIN
	DECLARE o_idGestor INT(11) UNSIGNED DEFAULT (SELECT idGestor FROM tb_Users_Detail WHERE idUser=in_idUser);
	SET @@max_sp_recursion_depth = 20;

	IF(o_idGestor IS NULL OR o_idGestor=in_idUser)THEN
		SET in_idUserLocate=NULL;
	ELSEIF(in_idUserLocate!=o_idGestor)THEN
		CALL pc_ManagerLocate(o_idGestor,in_idUserLocate);
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_ManagerPath`(
	IN `in_idUser` INT(10) UNSIGNED,
	INOUT `io_Path` TEXT
)
BEGIN
	DECLARE o_idGestor INT(11) UNSIGNED DEFAULT (SELECT idGestor FROM tb_Users_Detail WHERE idUser=in_idUser);
	SET @@max_sp_recursion_depth = 20;

	IF(o_idGestor IS NOT NULL AND o_idGestor!=in_idUser)THEN
		SET io_Path=CONCAT_WS(',',io_Path,o_idGestor);
		CALL pc_ManagerPath(o_idGestor,io_Path);
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_Permition_Files_by_idUser`(
	IN `in_idUser` INT(10) UNSIGNED
)
    COMMENT 'Mostra todos os arquivos com permissões para um usuário'
BEGIN
	SELECT 
		t.*,
		fn_Permition_CRUDS(t.Nivel,t.fCRUDS,t.pCRUDS) CRUDS
	FROM (
  	SELECT 
			f.idFile, f.File, f.L Nivel,f.CRUDS fCRUDS,
			BIT_OR(IFNULL(p.CRUDS,0)) pCRUDS
		FROM tb_Users u
		LEFT JOIN tb_Users_x_tb_GrpUsr gu USING(idUser)
		LEFT JOIN tb_Permitions p ON p.idGrpUsr IN (IFNULL(gu.idGrpUsr,0),1,IF(u.idUser IS NULL,0,3)) 
		LEFT JOIN tb_Files_x_tb_GrpFile gf USING(idGrpFile)
		LEFT JOIN tb_Files f USING(idFile)
		WHERE u.idUser=in_idUser AND u.Ativo
    GROUP BY f.idFile
  ) t;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_Permition_File_by_idFile_idUser`(
	IN `in_idFile` INT UNSIGNED,
	IN `in_idUser` INT UNSIGNED
)
BEGIN
	SELECT 
		t.*,
		fn_Permition_CRUDS(t.Nivel,t.fCRUDS,t.pCRUDS) CRUDS
	FROM (
		SELECT 
			f.File, f.L Nivel,f.CRUDS fCRUDS,
			u.User, u.Ativo,
			BIT_OR(IFNULL(p.CRUDS,0)) pCRUDS
		FROM tb_Files f
		LEFT JOIN tb_Users u ON u.idUser=in_idUser AND u.Ativo
		LEFT JOIN tb_Files_x_tb_GrpFile gf USING(idFile)
		LEFT JOIN tb_Users_x_tb_GrpUsr gu USING(idUser)
		LEFT JOIN tb_Permitions p ON p.idGrpFile=gf.idGrpFile AND p.idGrpUsr IN (IFNULL(gu.idGrpUsr,0),1,IF(u.idUser IS NULL,0,3)) 
		WHERE f.idFile=in_idFile 
	) t;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_Permition_GrpUsr_by_idFile_CRUDS`(
	IN `in_idFile` INT(10) UNSIGNED,
	IN `in_CRUDS` tinyint(2) UNSIGNED
)
    COMMENT 'Mostra permissões de um arquivo para seus respectivos Grupos de'
BEGIN
	SET in_CRUDS=IFNULL(in_CRUDS, 31);
	SET in_CRUDS=IF(in_CRUDS=0,31,in_CRUDS);
	SELECT
		f.idFile,
		f.File,
		f.Nivel,
		f.CRUDS fCRUDS,
		p.CRUDS pCRUDS,
		fn_Permition_CRUDS(f.Nivel, f.CRUDS, p.CRUDS) CRUDS,
		gu.idGrpUsr,
		gu.GrpUsr
	FROM tb_Files f
	JOIN tb_Files_x_tb_GrpFile gf ON f.idFile = gf.idFile
	JOIN tb_Permitions p ON gf.idGrpFile = p.idGrpFile AND p.CRUDS & in_CRUDS
	JOIN tb_GrpUsr gu ON p.idGrpUsr = gu.idGrpUsr
	WHERE f.idFile = in_idFile;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_Permition_List_File_by_idFile_idUser`(
	IN `in_idFile` INT(10) UNSIGNED,
	IN `in_idUser` INT(10) UNSIGNED
)
BEGIN
	SELECT *, LPAD(CONV(t.CRUDS, 10,2),5,0) CRUDS_Bin
	FROM (
		SELECT 
			gu.idGrpUsr,guu.GrpUsr, 
			gf.idGrpFile,gff.GrpFile, 
			u.idUser, u.User, u.Ativo,
			f.idFile, f.File, f.L Nivel,f.CRUDS fCRUDS,
     		IFNULL(p.CRUDS,0) pCRUDS,
	      fn_Permition_CRUDS(f.L,f.CRUDS,IFNULL(p.CRUDS,0)) CRUDS
		FROM tb_Files f
		LEFT JOIN tb_Users u ON u.idUser=in_idUser AND u.Ativo 
		LEFT JOIN tb_Files_x_tb_GrpFile gf USING(idFile)
		LEFT JOIN tb_Users_x_tb_GrpUsr gu USING(idUser)
		LEFT JOIN tb_GrpUsr guu USING(idGrpUsr)
		LEFT JOIN tb_GrpFile gff USING(idGrpFile)
		LEFT JOIN tb_Permitions p ON p.idGrpFile=gf.idGrpFile AND p.idGrpUsr IN (IFNULL(gu.idGrpUsr,0),1,IF(u.idUser IS NULL,0,3)) 
		WHERE f.idFile=in_idFile
	) t
	WHERE t.CRUDS;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_rebuild_GrpUsr_Main`()
SELECT 
	u.idUser, u.`User`,
	fn_User_SetMainGroup(u.idUser) idGrpUserMain
FROM tb_Users u
WHERE u.Ativo//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_SplitObjName`(OUT out_ObjName VARCHAR(255), INOUT oi_ObjFullName VARCHAR(255))
    COMMENT 'Divide um nome de objeto em duas partes primeira[.restante]'
BEGIN
	
	DECLARE p TINYINT(4) DEFAULT 0;

	IF(oi_ObjFullName IS NULL)THEN
		SET out_ObjName=NULL;
	ELSE
		IF(LEFT(oi_ObjFullName,1)='`')THEN 
			SET oi_ObjFullName=SUBSTRING(oi_ObjFullName,2);
			SET p=INSTR(oi_ObjFullName,'`');
			IF(p=0)THEN CALL db_System.fail('Parametro in_Obj incorreto'); END IF;
			SET out_ObjName=LEFT(oi_ObjFullName,p-1);
			SET oi_ObjFullName=SUBSTRING(oi_ObjFullName,p+1);
		ELSE
			SET p=INSTR(oi_ObjFullName,'.');
			IF(p=0)THEN 
				SET out_ObjName=oi_ObjFullName;
				SET oi_ObjFullName=NULL;
			ELSE
				SET out_ObjName=LEFT(oi_ObjFullName,p-1);
				SET oi_ObjFullName=SUBSTRING(oi_ObjFullName,p);
			END IF;
		END IF;
		IF(LEFT(oi_ObjFullName,1)='.')THEN
			SET oi_ObjFullName=SUBSTRING(oi_ObjFullName,2);
		END IF;
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_URL_create`(
	IN `in_URL` TEXT,
	IN `in_QString` TEXT,
	IN `in_idUser` INT(10) UNSIGNED
)
BEGIN
	INSERT IGNORE tb_URLs (URL,QString,idUser) VALUES(in_URL,in_QString,in_idUser);
	
	SELECT lnk FROM tb_URLs u WHERE u.hash=fn_URL_hash(REGEXP_REPLACE(in_URL,'#$',''),in_QString);
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_URL_create_trigger`(
	IN `in_idURL` INT(10) UNSIGNED,
	INOUT `io_lnk` VARCHAR(8),
	INOUT `io_URL` TEXT,
	INOUT `io_QString` TEXT,
	INOUT `io_hash` VARCHAR(45),
	INOUT `io_Descr` TEXT,
	INOUT `io_idUser` INT(10) UNSIGNED
)
BEGIN
	IF(in_idURL IS NULL OR in_idURL=0)THEN 
		SET in_idURL=(
				SELECT `AUTO_INCREMENT` 
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_SCHEMA = 'db_Secure' 
				AND TABLE_NAME = 'tb_URLs'
			); 
	END IF;
	SET io_lnk=conv(in_idURL,10,36);
	
	IF(IFNULL(io_Descr,'')='')THEN SET io_Descr=REGEXP_REPLACE(io_URL,'.*#',''); END IF;
	IF(io_Descr='')THEN SET io_Descr=NULL; END IF;
	SET io_URL=REGEXP_REPLACE(io_URL,'#$','');
	
	SET io_hash=fn_URL_hash(io_URL,io_QString);
	IF(io_idUser IS NULL)THEN SET io_idUser=fn_get_idUser(); END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_Details`(
	IN `in_idUser` INT(10) UNSIGNED
)
SELECT
	u.User,
	u.Ativo,
	u.idDomain,
	dm.Domain,
	c.Confirm,
	c.DtUpdate AS DtConfirm,
	d.Matricula,
	d.Nome,
	d.Sexo,
	d.idGestor,
	g.User AS Gestor_User,
	gd.Nome AS Gestor,
	gd.Sexo AS Gestor_Sexo,
	gd.idPosition AS Gestor_idCargo,
	cgg.Position AS Gestor_Cargo,
	d.idPosition,
	cgu.Position,
	i.Ip,
	i.DtUpdate AS DtIp,
	p.DtExpires,
	p.DtUpdate AS DtPasswd
FROM tb_Users u
LEFT JOIN  tb_Domain dm ON u.idDomain = dm.idDomain
LEFT JOIN  tb_Users_Confirm c ON u.idUser = c.idUser
LEFT JOIN tb_Users_Detail d ON u.idUser = d.idUser
LEFT JOIN tb_Users g ON d.idGestor = g.idUser
LEFT JOIN tb_Users_Detail gd ON g.idUser = gd.idUser
LEFT JOIN tb_Positions cgg ON gd.idPosition = cgg.idPosition
LEFT JOIN tb_Positions cgu ON d.idPosition = cgu.idPosition
LEFT JOIN tb_Users_Ip i ON u.idUser = i.idUser
LEFT JOIN tb_Users_Passwd p ON c.idUser = p.idUser
WHERE c.idUser=in_idUser//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_Details_Addresses`(
	IN `in_idUser` INT(10) UNSIGNED
)
SELECT * 
FROM tb_Users_Enderecos 
WHERE idUser=in_idUser//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_Details_Emails`(
	IN `in_idUser` INT(10) UNSIGNED
)
SELECT * 
FROM tb_Users_Emails 
WHERE idUser=in_idUser//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_Details_Phones`(
	IN `in_idUser` INT(10) UNSIGNED
)
SELECT * 
FROM tb_Users_Telefones 
WHERE idUser=in_idUser//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_Details_Workers`(
	IN `in_idUser` INT(10) UNSIGNED
)
SELECT 
	u.User,
	d.*,
	g.idGrpUsr,
	g.GrpUsr
FROM tb_Users_Detail d
JOIN tb_Users u ON d.idUser=u.idUser AND u.Ativo
LEFT JOIN tb_Users_x_tb_GrpUsr ug ON ug.idUser=u.idUser AND ug.isMain
LEFT JOIN tb_GrpUsr g ON ug.idGrpUsr=g.idGrpUsr
WHERE d.idGestor=in_idUser//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_Detais_Groups`(
	IN `in_idUser` INT(10) UNSIGNED
)
SELECT g.*
FROM tb_Users_x_tb_GrpUsr u
JOIN tb_GrpUsr g USING(idGrpUsr)
WHERE u.idUser=in_idUser//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_Detais_Staff`(
	IN `in_idUser` INT(10) UNSIGNED
)
SELECT *
FROM tb_Users_x_tb_GrpUsr u
JOIN tb_GrpUsr g USING(idGrpUsr)
WHERE u.idUser=in_idUser
ORDER BY 
	u.isMain DESC, 
	IF(g.GrpUsr LIKE 'DEP_%',0,IF(g.GrpUsr LIKE 'DL_%',1,10)),
	IF(g.GrpUsr REGEXP '(todos|_rh_|_hr_|Colaboradores)',1,0)
LIMIT 1//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_Info`(
	IN `in_idUser` INT(10) UNSIGNED,
	IN `in_Token` char(32)
)
BEGIN
	SELECT
		u.idUser,
		u.idDomain,
		d.`Domain`,
		u.`User`,
		u.Ativo,
		p.DtExpires,
		n.Confirm,
		i.Ip,
		t.Token,
		d.Obs ObsDomain
	FROM tb_Users u 
	LEFT JOIN tb_Domain d ON u.idDomain=d.idDomain 
	LEFT JOIN tb_Users_Passwd p ON u.idUser=p.idUser 
	LEFT JOIN tb_Users_Ip i ON u.idUser=i.idUser 
	LEFT JOIN tb_Users_Token t ON u.idUser=t.idUser 
	LEFT JOIN tb_Users_Confirm n ON u.idUser=n.idUser 
	WHERE u.idUser=in_idUser
	ORDER BY IF(Token=in_Token,0,1)
	LIMIT 1;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_ListGrp`(
	IN `in_idGrpUsr` INT(10) UNSIGNED
)
BEGIN
	SELECT 
		u.idUser,
		u.idDomain, d.`Domain`,
		u.`User`, dd.Nome,
		dd.Sexo,
		dd.idPosition
	FROM tb_Users_x_tb_GrpUsr g 
	JOIN tb_Users u ON g.idUser=u.idUser AND u.Ativo
	LEFT JOIN tb_Domain d ON u.idDomain=d.idDomain 
	LEFT JOIN tb_Users_Detail dd ON c.idUser = dd.idUser
	WHERE g.idGrpUsr=in_idGrpUsr;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_LogOn`(
	IN in_Domain VARCHAR(50), 
	IN in_User VARCHAR(64), 
	IN in_Password VARCHAR(64), 
	IN in_ForceLogin TINYINT(1) UNSIGNED, 
	IN in_Token CHAR(32)
)
    COMMENT 'Verifica usuário e senha'
BEGIN
	DECLARE o_idUser INT(11) UNSIGNED DEFAULT fn_User_GetId(in_Domain,in_User);
	SET in_Token=fn_User_Check(o_idUser,in_Password,in_ForceLogin,in_Token);
	IF(LENGTH(in_Token)=1)THEN
		SELECT o_idUser idUser, null Token,null FisrtLogOn, null LastLogOn, e.*
		FROM vw_User_LogonErros e
		WHERE e.logonError=in_Token;
	ELSE
		SELECT t.idUser, t.Token,t.DtGer FisrtLogOn, t.DtUpdate LastLogOn, e.*
		FROM tb_Users_Token t, vw_User_LogonErros e
		WHERE t.idUser=o_idUser AND t.Token=in_Token AND e.logonError=0;
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `pc_User_LogOnTrErrors`(IN in_Error TINYINT)
BEGIN
  SELECT * FROM vw_User_LogonErros WHERE logonError=in_Error;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `signErro`(
	IN `in_errno` INT UNSIGNED,
	IN `in_erro` TEXT
)
SIGNAL SQLSTATE '45000' SET
MYSQL_ERRNO = in_errno,
MESSAGE_TEXT = in_erro//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_CRUDS2Bin`(`in_CRUDS` TINYINT(3) UNSIGNED
) RETURNS char(5) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN LPAD(CONV(in_CRUDS,10,2),5,0)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_decode`(`val` LONGBLOB
) RETURNS longtext CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN IF(val IS NULL,NULL,decode(val,fn_KeyPhrase()))//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_encode`(`val` LONGTEXT 
) RETURNS longblob
    DETERMINISTIC
RETURN IF(val IS NULL,NULL,encode(val,fn_KeyPhrase()))//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_File_Create`(`in_File` VARCHAR(255)
) RETURNS int(10) unsigned
    NO SQL
BEGIN
	INSERT tb_Files (`File`) VALUES (in_File);
	RETURN LAST_INSERT_ID();
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_File_GetId`(`in_File` VARCHAR(255)
) RETURNS int(10) unsigned
    NO SQL
RETURN (SELECT idFile FROM tb_Files WHERE File=in_File)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_get_idFile`() RETURNS int(10) unsigned
RETURN IFNULL(@Secure_idFile,0)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_get_idStaff`(`in_idUser` INT UNSIGNED
) RETURNS int(10) unsigned
    DETERMINISTIC
RETURN (
	SELECT g.idGrpUsr
	FROM db_Secure.tb_Users_x_tb_GrpUsr g
	WHERE g.idUser=in_idUser AND g.isMain
	LIMIT 1
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_get_idUser`() RETURNS int(11) unsigned
RETURN IFNULL(@Secure_idUser,1)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_get_NameUser`(`in_idUser` INT UNSIGNED
) RETURNS varchar(255) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN (
	SELECT IFNULL(`ud`.`Nome`, `u`.`User`) 
	FROM db_Secure.tb_Users u 
	LEFT JOIN db_Secure.tb_Users_Detail ud ON ud.idUser=u.idUser 
	WHERE u.idUser=in_idUser
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_isAdmin`(`in_idUser` INT UNSIGNED
) RETURNS tinyint(1) unsigned
RETURN (
	SELECT COUNT(1) q 
	FROM tb_Users_x_tb_GrpUsr g 
	WHERE g. iduser=in_idUser AND g.idgrpusr=2 AND g.iduser > 1
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_KeyPhrase`() RETURNS varchar(255) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN 'hçoasdr@#$]jbnaasd56upa[sdfjç%aertbdklçzjsdfbvgp349q28'//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_L2Level`(in_L TINYINT(1) UNSIGNED) RETURNS enum('Free','Secured','Paranoic') CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
BEGIN
  IF(in_L=0)THEN RETURN 'Free'; END IF;
  IF(in_L=1)THEN RETURN 'Secured'; END IF;
  RETURN 'Paranoic';
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_Permition_BuildCRUD`(`in_C` tinyint(1) UNSIGNED,
	`in_R` tinyint(1) UNSIGNED,
	`in_U` tinyint(1) UNSIGNED,
	`in_D` tinyint(1) UNSIGNED,
	`in_S` tinyint(1) UNSIGNED
) RETURNS tinyint(2) unsigned
    DETERMINISTIC
RETURN in_C<<4 | in_R<<3 | in_U<<2 | in_D<<1 | in_S//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_Permition_CRUDS`(`in_Level` tinyint(1) UNSIGNED,
	`in_fCRUDS` tinyint(2) UNSIGNED,
	`in_pCRUDS` tinyint(2) UNSIGNED
) RETURNS tinyint(2) unsigned
    NO SQL
    DETERMINISTIC
BEGIN
	DECLARE o_CRUDS tinyint(2) UNSIGNED;
	
	IF (in_Level=0)        THEN RETURN 31 & in_fCRUDS; END IF;
	SET o_CRUDS = in_pCRUDS & in_fCRUDS;
	IF (in_Level=1)        THEN RETURN o_CRUDS; END IF;
	IF (o_CRUDS=in_fCRUDS) THEN RETURN o_CRUDS; END IF;
	RETURN 0;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_Permition_File_by_File_idUser`(`in_File` VARCHAR(255),
	`in_idUser` INT UNSIGNED
) RETURNS tinyint(2) unsigned
    NO SQL
RETURN (
	SELECT fn_Permition_CRUDS(f.Nivel,f.CRUDS,BIT_OR(p.CRUDS)) CRUDS
	FROM tb_Files f
	JOIN tb_Files_x_tb_GrpFile gf ON f.idFile=gf.idFile
	JOIN tb_Permitions p ON gf.idGrpFile=p.idGrpFile
	LEFT JOIN tb_Users_x_tb_GrpUsr gu ON p.idGrpUsr=gu.idGrpUsr 
	LEFT JOIN tb_Users u ON gu.idUser=u.idUser
	WHERE f.File=in_File
	AND (
		p.idGrpUsr=1 OR 
		(gu.idUser=in_idUser AND u.Ativo) OR 
		(p.idGrpUsr=3 AND in_idUser!=0 AND (SELECT Ativo FROM tb_Users WHERE idUser=in_idUser)) 
	) 
	GROUP BY f.idFile
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_Permition_File_by_idFile_idUser`(`in_idFile` INT UNSIGNED,
	`in_idUser` INT UNSIGNED
) RETURNS tinyint(2) unsigned
    NO SQL
RETURN (
	SELECT fn_Permition_CRUDS(f.Nivel,f.CRUDS,BIT_OR(p.CRUDS)) CRUDS
	FROM tb_Files f
	JOIN tb_Files_x_tb_GrpFile gf ON f.idFile=gf.idFile
	JOIN tb_Permitions p ON gf.idGrpFile=p.idGrpFile
	LEFT JOIN tb_Users_x_tb_GrpUsr gu ON p.idGrpUsr=gu.idGrpUsr 
	LEFT JOIN tb_Users u ON gu.idUser=u.idUser
	WHERE f.idFile=in_idFile
	AND (
		p.idGrpUsr=1 OR 
		(gu.idUser=in_idUser AND u.Ativo) OR 
		(p.idGrpUsr=3 AND in_idUser!=0 AND (SELECT Ativo FROM tb_Users WHERE idUser=in_idUser)) 
	) 
	GROUP BY f.idFile
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_URL_hash`(`in_URL` TEXT
,
	`in_QString` TEXT
) RETURNS varchar(45) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
BEGIN
	DECLARE o_Txt TEXT;
	SET o_Txt=CONCAT_WS('?',in_URL,in_QString);
	RETURN CONCAT(md5(o_Txt),'#',length(o_Txt));
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_BuildToken`(`in_idUser` INT UNSIGNED
) RETURNS char(32) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
BEGIN
	DECLARE o_Token CHAR(32) DEFAULT REPLACE(UUID(),'-','');
	INSERT IGNORE tb_Users_Token (idUser,Token) VALUES (in_idUser,o_Token);

	RETURN o_Token;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_ChangePasswd`(`in_idUser` INT UNSIGNED,
	`in_oldPasswd` VARCHAR(64),
	`in_newPasswd` VARCHAR(64)
) RETURNS char(32) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    NO SQL
    COMMENT 'Muda senha de um usuário'
BEGIN
	UPDATE tb_Users_Passwd 
	SET Passwd=db_System.fn_Sys_encode(in_newPasswd)
	WHERE idUser=in_idUser AND in_oldPasswd=db_System.fn_Sys_decode(Passwd);
	
	RETURN fn_User_Check(in_idUser,in_newPasswd,1,'');
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_Check`(`in_idUser` INT UNSIGNED,
	`in_passwd` VARCHAR(64),
	`in_ForceLogin` TINYINT(1) UNSIGNED,
	`in_Token` CHAR(32)
) RETURNS char(32) CHARSET latin1 COLLATE latin1_swedish_ci
    NO SQL
    COMMENT 'Check if password is correct'
BEGIN
	DECLARE o_Active tinyint unsigned default (SELECT Ativo FROM tb_Users u WHERE u.idUser=in_idUser);

	
	IF(IFNULL(in_passwd,'')='') THEN 
		RETURN 1; 
	ELSEIF(IFNULL(in_idUser,0)=0 OR o_Active IS NULL) THEN 
		RETURN 2; 
	ELSEIF(o_Active!=1) THEN
		RETURN 3; 
	ELSEIF(fn_User_CheckTryLogin(in_idUser)) THEN 
		RETURN 5; 
	ELSEIF(ifnull((SELECT idUser FROM tb_Users_Passwd p JOIN tb_Users u USING(idUser) WHERE p.idUser=in_idUser AND db_System.fn_Sys_decode(p.Passwd)=in_passwd AND u.Ativo),0)=0) THEN
		RETURN 4; 
	ELSE
		DELETE FROM tb_Users_TryLogin WHERE idUser=in_idUser;
    IF(IFNULL((SELECT DtExpires FROM tb_Users_Passwd WHERE idUser=in_idUser),NOW())<NOW())THEN
      RETURN 6; 
    END IF;
		IF(NOT(fn_User_CheckToken(in_idUser,in_Token)))THEN 
			IF(fn_User_IsLoged(in_idUser))THEN 
				IF(@multiSession) THEN 
					IF(IFNULL(in_Token,'')='')THEN SET in_Token=fn_User_BuildToken(in_idUser); END IF;
				ELSE 
					IF(in_ForceLogin)THEN 
						DELETE FROM tb_Users_TryLogin WHERE idUser=in_idUser;
						SET in_Token=fn_User_LogoutAll(in_idUser);
						SET in_Token=fn_User_BuildToken(in_idUser);
					ELSE 
						RETURN 8; 
					END IF; 
				END IF;
			ELSE 
				SET in_Token=fn_User_BuildToken(in_idUser); 
			END IF;
		END IF;
	END IF;
	RETURN in_Token; 
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_CheckToken`(`in_idUser` INT UNSIGNED,
	`in_Token` CHAR(32)
) RETURNS tinyint(1) unsigned
    NO SQL
BEGIN
	DECLARE o_ExpireSession INT(11) UNSIGNED DEFAULT IFNULL(@expiresSession,15); 
	DECLARE o_DtUpdate DATETIME;  

	IF(IFNULL(in_Token,'')='')THEN RETURN FALSE; END IF;
	SET o_DtUpdate=(SELECT DtUpdate FROM tb_Users_Token WHERE idUser=in_idUser AND Token=in_Token);
	IF(o_DtUpdate IS NULL)THEN RETURN FALSE; END IF;
	IF(o_ExpireSession=0 OR o_DtUpdate>DATE_SUB(NOW(),INTERVAL o_ExpireSession MINUTE)) THEN
		UPDATE tb_Users_Token SET DtUpdate=NOW() WHERE idUser=in_idUser AND Token=in_Token;
		RETURN TRUE;
	ELSE
		DELETE FROM tb_Users_Token WHERE idUser=in_idUser AND Token=in_Token;
		RETURN FALSE;
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_CheckTryLogin`(`in_idUser` INT UNSIGNED
) RETURNS tinyint(1) unsigned
    NO SQL
    COMMENT 'Retorna se pode tentar login novamente'
BEGIN
	DECLARE o_tryWait INT(11) UNSIGNED DEFAULT IFNULL(@tryWait,10); 
	DECLARE o_DtLastTry TINYINT(1) UNSIGNED DEFAULT IFNULL((SELECT DtUpdate FROM tb_Users_TryLogin WHERE idUser=in_idUser),'1970-01-01 00:00:00');
	DECLARE o_out TINYINT(1) UNSIGNED DEFAULT o_DtLastTry>DATE_SUB(NOW(),INTERVAL o_tryWait SECOND);

	REPLACE tb_Users_TryLogin (idUser) VALUES (in_idUser);
	RETURN o_out;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_Create`(`in_Domain` VARCHAR(50),
	`in_User` VARCHAR(64),
	`in_Passwd` VARCHAR(64),
	`in_Email` VARCHAR(64)
) RETURNS int(10) unsigned
    COMMENT 'Cria um usuário'
BEGIN
	DECLARE o_idUser INT(10) UNSIGNED DEFAULT 0;
	
	IF(IFNULL(in_User,'')='')THEN CALL db_System.fail('Username vazio'); END IF;
	IF(IFNULL(in_Passwd,'')='' AND IFNULL(in_Email,'')='')THEN CALL db_System.fail('Senha E-mail vazios'); END IF;
	INSERT tb_Users (idDomain,`User`) VALUES(fn_User_GetIdDomain(in_Domain,true),in_User);
	SET o_idUser=LAST_INSERT_ID();
	IF(o_idUser)THEN
		IF(IFNULL(in_Passwd,'')!='')THEN
			UPDATE tb_Users_Passwd SET Passwd=db_System.fn_Sys_encode(in_Passwd) WHERE idUser=o_idUser;
		END IF;
		IF(IFNULL(in_Email,'')!='')THEN
			INSERT IGNORE tb_Users_Emails SET idUser=o_idUser,Email=in_Email;
		END IF;
	END IF;
	
	RETURN o_idUser;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetEmails`(`in_idUser` INT UNSIGNED
) RETURNS text CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN (
	SELECT GROUP_CONCAT(s.Email)
	FROM tb_Users_Emails s
	WHERE s.idUser=in_idUser
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetId`(`in_Domain` VARCHAR(50),
	`in_User` VARCHAR(64)
) RETURNS int(10) unsigned
    DETERMINISTIC
RETURN (
	SELECT idUser
	FROM tb_Users u 
	JOIN tb_Domain d ON u.idDomain=d.idDomain AND d.Domain=IFNULL(in_Domain,'') 
	WHERE u.User=in_User
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetIdCargo`(`in_Cargo` varchar(64)
) RETURNS int(11) unsigned
BEGIN
	DECLARE oCargoShort VARCHAR(64) DEFAULT SUBSTRING_INDEX(in_Cargo, ' ', 1);
	DECLARE oIdCargo INT(11) UNSIGNED DEFAULT (SELECT c.idPosition FROM tb_Positions c WHERE c.Position=in_Cargo);
	IF(oIdCargo IS NULL)THEN
		SET oIdCargo=(SELECT c.idPosition FROM tb_Positions c WHERE SOUNDEX(c.Position)=SOUNDEX(in_Cargo));
		IF(oIdCargo IS NULL)THEN
			SET oIdCargo=(SELECT c.idPosition FROM tb_Positions c WHERE c.Position=oCargoShort);
			IF(oIdCargo IS NULL)THEN
				SET oIdCargo=(SELECT c.idPosition FROM tb_Positions c WHERE SOUNDEX(c.Position)=SOUNDEX(oCargoShort));
				IF(oIdCargo IS NULL)THEN
					INSERT IGNORE tb_Positions (Position) VALUES (in_Cargo);
					SET oIdCargo=LAST_INSERT_ID();
				END IF;
			END IF;
		END IF;
	END IF;
	RETURN oIdCargo;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetIdDomain`(`in_domain` VARCHAR(50),
	`in_create_if_not_exists` TINYINT
) RETURNS int(10) unsigned
    DETERMINISTIC
BEGIN
	DECLARE o_idDomain int(10) unsigned;
	SET in_domain=IFNULL(in_domain,'');
	SET o_idDomain=(SELECT idDomain FROM tb_Domain WHERE Domain=in_domain);
	IF(o_idDomain IS NULL AND in_create_if_not_exists)THEN
		INSERT IGNORE tb_Domain SET Domain=in_domain;
		SET o_idDomain=LAST_INSERT_ID();
	END IF;
	RETURN o_idDomain;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetPassword`(`in_idUser` INT UNSIGNED
) RETURNS varchar(64) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN (
	SELECT db_System.fn_Sys_decode(p.Passwd)
	FROM tb_Users_Passwd p
	WHERE p.idUser=in_idUser
	LIMIT 1
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetPhones`(`in_idUser` INT UNSIGNED
) RETURNS text CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN (
	SELECT GROUP_CONCAT(s.Telefone)
	FROM tb_Users_Telefones s
	WHERE s.idUser=in_idUser
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetRandNumber`(`in_tam` TINYINT UNSIGNED
) RETURNS varchar(64) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    NO SQL
    DETERMINISTIC
BEGIN
  DECLARE universoChar VARCHAR(255) DEFAULT '0123456789';
  DECLARE m            INT UNSIGNED DEFAULT LENGTH(universoChar);
  DECLARE i            INT UNSIGNED DEFAULT 0;
  DECLARE retorno      VARCHAR(64)  DEFAULT '';
  
  SET in_tam=GREATEST(IFNULL(in_tam,10),1);
  WHILE i<in_tam DO
    SET i=i+1;
    SET retorno=CONCAT(retorno,MID(universoChar,FLOOR(RAND()*m)+1,1));
  END WHILE;    
  RETURN retorno;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetRandPasswd`(`in_tam` TINYINT UNSIGNED
) RETURNS varchar(64) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    NO SQL
    DETERMINISTIC
BEGIN
  DECLARE universoChar VARCHAR(255) DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVXWYZabcdefghijklmnopqrstuvxwyz_-+=!@#$%&*()[]{}';
  DECLARE passwd VARCHAR(64) DEFAULT '';
  DECLARE i INT DEFAULT 0;
  DECLARE m INT;
  
  SET in_tam=GREATEST(IFNULL(in_tam,10),3);
  SET m=LENGTH(universoChar);
  WHILE i<in_tam DO
    SET i=i+1;
    SET passwd=CONCAT(passwd,MID(universoChar,FLOOR(RAND()*m)+1,1));
  END WHILE;    
  RETURN passwd;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetTkbin`() RETURNS varchar(64) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN (
	SELECT db_System.fn_Sys_decode(s.tk)
	FROM tb_Users_Search s
	WHERE s.i=1
)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_GetToken`(`in_idUser` INT UNSIGNED
) RETURNS char(32) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
RETURN (SELECT Token FROM tb_Users_Token WHERE idUser=in_idUser LIMIT 1)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_IsActive`(`in_idUser` INT UNSIGNED
) RETURNS tinyint(1) unsigned
    DETERMINISTIC
RETURN (SELECT Ativo FROM tb_Users WHERE idUserin_idUser)//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_IsGestor`(`in_idUser` INT UNSIGNED,
	`in_idGestor` INT UNSIGNED
) RETURNS tinyint(1) unsigned
BEGIN
	CALL pc_ManagerLocate(in_idUser,in_idGestor);
	RETURN IF(in_idGestor IS NULL,0,1);
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_IsLoged`(`in_idUser` INT UNSIGNED
) RETURNS tinyint(1) unsigned
    DETERMINISTIC
BEGIN
	DECLARE o_ExpireSession INT(11) UNSIGNED DEFAULT IFNULL(@expiresSession,15);
	IF(o_ExpireSession!=0)THEN
		DELETE FROM tb_Users_Token 
		WHERE idUser=in_idUser 
		AND DtUpdate<=DATE_SUB(NOW(),INTERVAL o_ExpireSession MINUTE);
	END IF;
	RETURN (SELECT COUNT(1) FROM tb_Users_Token WHERE idUser=in_idUser);
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_Logout`(`in_idUser` INT UNSIGNED,
	`in_Token` CHAR(32)
) RETURNS int(10) unsigned
    DETERMINISTIC
BEGIN
	IF(IFNULL(in_Token,'')='')THEN
		DELETE FROM tb_Users_Token 
		WHERE idUser=in_idUser;
	ELSE
		DELETE FROM tb_Users_Token 
		WHERE idUser=in_idUser AND Token=in_Token;
	END IF;
	RETURN ROW_COUNT();
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_LogoutAll`(`in_idUser` INT UNSIGNED
) RETURNS int(10) unsigned
    DETERMINISTIC
BEGIN
	DELETE FROM tb_Users_Token WHERE idUser=in_idUser;
	RETURN ROW_COUNT();
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_SetMainGroup`(`in_idUser` INT UNSIGNED
) RETURNS int(10) unsigned
    COMMENT 'return idGrpUsr main'
BEGIN
	DECLARE v_id INT UNSIGNED DEFAULT(
		SELECT g.idGrpUsr
		FROM tb_Users_x_tb_GrpUsr gu
		JOIN tb_GrpUsr g ON g.idGrpUsr=gu.idGrpUsr
		WHERE gu.idUser=in_idUser
		ORDER BY IF(g.GrpUsr LIKE 'DEP%',0,
			IF(g.GrpUsr LIKE 'DL_%',LENGTH(g.GrpUsr),1000)
		)
		LIMIT 1
	);
	UPDATE tb_Users_x_tb_GrpUsr g 
	SET g.isMain=null
	WHERE g.idUser=in_idUser AND g.idGrpUsr!=v_id;
	UPDATE tb_Users_x_tb_GrpUsr g 
	SET g.isMain=1
	WHERE g.idUser=in_idUser AND g.idGrpUsr=v_id;
	
	RETURN v_id;
END//
DELIMITER ;

DELIMITER //
CREATE FUNCTION `fn_User_SetPasswd`(`in_idUser` INT UNSIGNED,
	`in_Passwd` VARCHAR(64)
) RETURNS char(32) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    NO SQL
    COMMENT 'Muda senha de um usuário'
BEGIN
	UPDATE tb_Users_Passwd SET Passwd=in_Passwd WHERE idUser=in_idUser;
	UPDATE tb_Users SET Ativo=1 WHERE idUser=in_idUser;

	RETURN fn_User_Check(in_idUser,in_Passwd,1,'');
END//
DELIMITER ;

DELIMITER //
CREATE EVENT `ev_CleanToken` ON SCHEDULE EVERY 1 MINUTE STARTS '2024-10-15 04:55:00' ON COMPLETION PRESERVE ENABLE DO CALL pc_CleanToken//
DELIMITER ;

DELIMITER //
CREATE EVENT `ev_rebuild_GrpUsr_Main` ON SCHEDULE EVERY 1 DAY STARTS '2022-07-22 19:00:00' ON COMPLETION PRESERVE ENABLE DO CALL pc_rebuild_GrpUsr_Main//
DELIMITER ;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Attachment_before_del` BEFORE DELETE ON `tb_Attachment` FOR EACH ROW CALL fail('Unsupport Delete')//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Attachment_before_ins` BEFORE INSERT ON `tb_Attachment` FOR EACH ROW IF IFNULL(NEW.base64,'')='' THEN
	CALL fail('Content is empty');
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Attachment_before_upd` BEFORE UPDATE ON `tb_Attachment` FOR EACH ROW CALL fail('Unsupport Update')//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Domain_before_ins` BEFORE INSERT ON `tb_Domain` FOR EACH ROW SET NEW.idUserUpd=fn_get_idUser()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Domain_before_upd` BEFORE UPDATE ON `tb_Domain` FOR EACH ROW SET NEW.idUserUpd=fn_get_idUser()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Files_after_ins` AFTER INSERT ON `tb_Files` FOR EACH ROW INSERT IGNORE db_Secure.tb_Files_x_tb_GrpFile SET idFile=NEW.idFile, idGrpFile=1//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Files_before_ins` BEFORE INSERT ON `tb_Files` FOR EACH ROW CALL pctr_Files_before(NEW.C,NEW.R,NEW.U,NEW.D,NEW.S,NEW.CRUDS,NEW.idUserUpd)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Files_before_upd` BEFORE UPDATE ON `tb_Files` FOR EACH ROW CALL pctr_Files_before(NEW.C,NEW.R,NEW.U,NEW.D,NEW.S,NEW.CRUDS,NEW.idUserUpd)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Files_x_tb_GrpFile_before_ins` BEFORE INSERT ON `tb_Files_x_tb_GrpFile` FOR EACH ROW SET NEW.idUserUpd=fn_get_idUser()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Files_x_tb_GrpFile_before_upd` BEFORE UPDATE ON `tb_Files_x_tb_GrpFile` FOR EACH ROW SET NEW.idUserUpd=fn_get_idUser()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_GrpFile_before_del` BEFORE DELETE ON `tb_GrpFile` FOR EACH ROW IF(OLD.idGrpFile<4)THEN
	CALL db_System.fail('Não pode ser Apagado');
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_GrpFile_before_ins` BEFORE INSERT ON `tb_GrpFile` FOR EACH ROW BEGIN
  SET NEW.idUserUpd=fn_get_idUser();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_GrpFile_before_upd` BEFORE UPDATE ON `tb_GrpFile` FOR EACH ROW BEGIN
  SET NEW.idUserUpd=fn_get_idUser();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_GrpUsr_before_del` BEFORE DELETE ON `tb_GrpUsr` FOR EACH ROW IF(OLD.idGrpUsr<5)THEN
	CALL db_System.fail('Não pode ser apagado');
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_GrpUsr_before_ins` BEFORE INSERT ON `tb_GrpUsr` FOR EACH ROW BEGIN
  SET NEW.idUserUpd=fn_get_idUser();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_GrpUsr_before_upd` BEFORE UPDATE ON `tb_GrpUsr` FOR EACH ROW BEGIN
  SET NEW.idUserUpd=fn_get_idUser();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_Permitions_before_ins` BEFORE INSERT ON `tb_Permitions` FOR EACH ROW BEGIN
  SET NEW.idUserUpd=fn_get_idUser();
	SET NEW.CRUDS=fn_Permition_BuildCRUD(NEW.C,NEW.R,NEW.U,NEW.D,NEW.S);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_Permitions_before_upd` BEFORE UPDATE ON `tb_Permitions` FOR EACH ROW BEGIN
  SET NEW.idUserUpd=fn_get_idUser();
	SET NEW.CRUDS=fn_Permition_BuildCRUD(NEW.C,NEW.R,NEW.U,NEW.D,NEW.S);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Positions_before_ins` BEFORE INSERT ON `tb_Positions` FOR EACH ROW BEGIN
  SET NEW.idUserUpd=fn_get_idUser();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Positions_before_upd` BEFORE UPDATE ON `tb_Positions` FOR EACH ROW BEGIN
  SET NEW.idUserUpd=fn_get_idUser();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_URLs_before_ins` BEFORE INSERT ON `tb_URLs` FOR EACH ROW BEGIN
	CALL pc_URL_create_trigger(NEW.idURL, NEW.lnk, NEW.URL, NEW.QString, NEW.hash, NEW.Descr, NEW.idUser);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_URLs_before_upd` BEFORE UPDATE ON `tb_URLs` FOR EACH ROW BEGIN
	CALL pc_URL_create_trigger(NEW.idURL, NEW.lnk, NEW.URL, NEW.QString, NEW.hash, NEW.Descr, NEW.idUser);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_Users_after_ins` AFTER INSERT ON `tb_Users` FOR EACH ROW BEGIN
	INSERT IGNORE tb_Users_Passwd   SET idUser=NEW.idUser;
	INSERT IGNORE tb_Users_Confirm  SET idUser=NEW.idUser;
	INSERT IGNORE tb_Users_Detail   SET idUser=NEW.idUser, Matricula=NEW.User, Nome=NEW.User;
	IF(NEW.idDomain=2)THEN
		INSERT IGNORE tb_Users_x_tb_GrpUsr (idUser,idGrpUsr) VALUES (NEW.idUser, 4);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_Users_before_ins` BEFORE INSERT ON `tb_Users` FOR EACH ROW SET NEW.idUserUpd=fn_get_idUser()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_Users_before_upd` BEFORE UPDATE ON `tb_Users` FOR EACH ROW SET NEW.idUserUpd=fn_get_idUser()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Users_Detail_before_ins` BEFORE INSERT ON `tb_Users_Detail` FOR EACH ROW CALL pctr_Users_Detail_before(NEW.Matricula, NEW.Nome, NEW.idUserUpd)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Users_Detail_before_upd` BEFORE UPDATE ON `tb_Users_Detail` FOR EACH ROW CALL pctr_Users_Detail_before(NEW.Matricula, NEW.Nome, NEW.idUserUpd)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Users_Emails_before_upd` BEFORE UPDATE ON `tb_Users_Emails` FOR EACH ROW IF(NEW.Email!=OLD.Email)THEN
	SET NEW.Confirm=0;
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Users_Passwd_before_ins` BEFORE INSERT ON `tb_Users_Passwd` FOR EACH ROW CALL pctr_Users_Passwd_before(NEW.Passwd, NEW.DtExpires, NULL)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Users_Passwd_before_upd` BEFORE UPDATE ON `tb_Users_Passwd` FOR EACH ROW CALL pctr_Users_Passwd_before(NEW.Passwd, NEW.DtExpires, OLD.Passwd)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_Users_x_tb_GrpUsr_before_ins` BEFORE INSERT ON `tb_Users_x_tb_GrpUsr` FOR EACH ROW IF(NEW.Seq IS NULL)THEN
	SET NEW.Seq=IFNULL((SELECT MAX(Seq)+1 FROM tb_Users_x_tb_GrpUsr WHERE idUser=NEW.idUser),0);
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_Users_x_tb_GrpUsr_before_upd` BEFORE UPDATE ON `tb_Users_x_tb_GrpUsr` FOR EACH ROW SET NEW.idUserUpd=fn_get_idUser()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

DROP TABLE IF EXISTS `vw_cbo_Users`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_cbo_Users` AS select `d`.`idUser` AS `idUser`,concat(if(`u`.`Ativo`,'','*'),`d`.`Nome`) AS `Nome` from (`tb_Users` `u` join `tb_Users_Detail` `d` on(`d`.`idUser` = `u`.`idUser`)) order by `u`.`Ativo` desc,`d`.`Nome`
;

DROP TABLE IF EXISTS `vw_UserDomains`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_UserDomains` AS select `d`.`idDomain` AS `idDomain`,`d`.`Domain` AS `Domain`,`d`.`Obs` AS `Obs`,`d`.`DtUpdate` AS `DtUpdate` from `tb_Domain` `d` where `d`.`idDomain` <> 2
;

DROP TABLE IF EXISTS `vw_Users`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_Users` AS select `u`.`idUser` AS `idUser`,`u`.`idDomain` AS `idDomain`,`d`.`Domain` AS `Domain`,`u`.`User` AS `User`,`ud`.`Matricula` AS `Matricula`,`ud`.`Nome` AS `Nome`,`g`.`idGrpUsr` AS `idGrpUsr`,`g`.`GrpUsr` AS `Staff`,`u`.`Ativo` AS `Ativo`,`uc`.`Confirm` AS `Confirm`,`ud`.`Sexo` AS `Sexo`,`ui`.`Ip` AS `Ip`,`ud`.`idGestor` AS `idGestor`,`ge`.`Nome` AS `Gestor`,`ud`.`idPosition` AS `idPosition`,`c`.`Position` AS `Position`,`ud`.`Niver` AS `Niver`,`ud`.`CentroCusto` AS `CentroCusto`,`ud`.`Obs` AS `Obs`,`ui`.`DtUpdate` AS `LastAccess`,`u`.`DtUpdate` AS `DtUpdate`,`u`.`DtGer` AS `DtGer` from ((((((((`tb_Users` `u` left join `tb_Domain` `d` on(`u`.`idDomain` = `d`.`idDomain`)) left join `tb_Users_Ip` `ui` on(`u`.`idUser` = `ui`.`idUser`)) left join `tb_Users_Detail` `ud` on(`u`.`idUser` = `ud`.`idUser`)) left join `tb_Users_Confirm` `uc` on(`u`.`idUser` = `uc`.`idUser`)) left join `tb_Users_x_tb_GrpUsr` `ug` on(`u`.`idUser` = `ug`.`idUser` and `ug`.`isMain` <> 0)) left join `tb_GrpUsr` `g` on(`g`.`idGrpUsr` = `ug`.`idGrpUsr`)) left join `tb_Positions` `c` on(`c`.`idPosition` = `ud`.`idPosition`)) left join `tb_Users_Detail` `ge` on(`ge`.`idUser` = `ud`.`idGestor`))
;

DROP TABLE IF EXISTS `vw_Users_GrpUsers`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_Users_GrpUsers` AS select `u`.`idUser` AS `idUser`,`d`.`idDomain` AS `idDomain`,`d`.`Domain` AS `Domain`,`u`.`User` AS `User`,`u`.`Ativo` AS `Ativo`,`e`.`Nome` AS `Nome`,`e`.`Sexo` AS `Sexo`,`e`.`Matricula` AS `Matricula`,`e`.`Obs` AS `ObsUser`,`u`.`DtUpdate` AS `DtUpdateUser`,`u`.`DtGer` AS `DtGerUser`,`g`.`idGrpUsr` AS `idGrpUsr`,`g`.`GrpUsr` AS `GrpUsr`,`g`.`EMail` AS `DL`,`g`.`Obs` AS `ObsGrpUser`,`g`.`isLdap` AS `isLdapGrpUser`,`g`.`DtUpdate` AS `DtUpdateGrpUser`,`g`.`DtGer` AS `DtGerGrpUser` from ((((`tb_Users` `u` join `tb_Domain` `d` on(`d`.`idDomain` = `u`.`idDomain`)) join `tb_Users_Detail` `e` on(`e`.`idUser` = `u`.`idUser`)) join `tb_Users_x_tb_GrpUsr` `gu` on(`gu`.`idUser` = `u`.`idUser`)) join `tb_GrpUsr` `g` on(`g`.`idGrpUsr` = `gu`.`idGrpUsr`))
;

DROP TABLE IF EXISTS `vw_Users_Rel`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_Users_Rel` AS select `u`.`idUser` AS `idUser`,`u`.`idDomain` AS `idDomain`,`u`.`User` AS `User`,`d`.`Nome` AS `Nome`,`d`.`Sexo` AS `Sexo`,`d`.`idGestor` AS `idGestor`,`d`.`idPosition` AS `idPosition`,`d`.`Matricula` AS `Matricula`,`d`.`Niver` AS `Niver`,`d`.`DtContrato` AS `DtContrato`,`d`.`CentroCusto` AS `CentroCusto`,`d`.`idSite_Lotado` AS `idSite_Lotado`,`d`.`idSite_Locado` AS `idSite_Locado`,`d`.`Obs` AS `Obs`,`u`.`Ativo` AS `Ativo`,`d`.`idUserUpd` AS `idUserUpd`,`d`.`DtUpdate` AS `DtUpdate`,`d`.`DtGer` AS `DtGer`,if(`d`.`idUser` = `du`.`idGestor`,0,if(`d`.`idUser` = `du`.`idUser`,1,if(`d`.`idGestor` = `du`.`idUser`,3,2))) AS `TipoRel` from ((`tb_Users_Detail` `du` join `tb_Users_Detail` `d` on(`d`.`idUser` = `du`.`idGestor` or `d`.`idGestor` = `du`.`idGestor` or `d`.`idGestor` = `du`.`idUser`)) join `tb_Users` `u` on(`u`.`idUser` = `d`.`idUser`)) where `du`.`idUser` = `fn_get_idUser`()
;

DROP TABLE IF EXISTS `vw_User_LogonErros`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_User_LogonErros` AS select 0 AS `logonError`,'OK' AS `messageError`,'Logon OK' AS `userMessageError`,1 AS `logonAction` union all select 1 AS `logonError`,'Empty Password' AS `messageError`,'Empty Password' AS `userMessageError`,0 AS `logonAction` union all select 2 AS `logonError`,'Unknown user' AS `messageError`,'Invalid user or password' AS `userMessageError`,0 AS `logonAction` union all select 3 AS `logonError`,'Inactive User' AS `messageError`,'Invalid user or password' AS `userMessageError`,0 AS `logonAction` union all select 4 AS `logonError`,'Invalid Password' AS `messageError`,'Invalid user or password' AS `userMessageError`,0 AS `logonAction` union all select 5 AS `logonError`,'Over try Login' AS `messageError`,'Over try Login, wait some seconds to try again' AS `userMessageError`,1 AS `logonAction` union all select 6 AS `logonError`,'Expired Password' AS `messageError`,'Expired Password. Change it' AS `userMessageError`,0 AS `logonAction` union all select 7 AS `logonError`,'Error Change Password' AS `messageError`,'Error Change Password ' AS `userMessageError`,1 AS `logonAction` union all select 8 AS `logonError`,'User already Loged' AS `messageError`,'User already Loged' AS `userMessageError`,1 AS `logonAction` union all select 9 AS `logonError`,'Unknown error' AS `messageError`,'Unknown error' AS `userMessageError`,0 AS `logonAction`
;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
