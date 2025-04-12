/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb3 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Database: Secure
-- Description: Database for secure applications.
CREATE OR REPLACE DATABASE db_secure
/*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci */;

USE db_secure;

-- Table: Attachments
-- Description: Stores file attachments.
CREATE TABLE IF NOT EXISTS tb_attachments (
  id_attachment INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  base64 LONGTEXT NOT NULL COMMENT 'Base64 encoded file content',
  hash CHAR(32) GENERATED ALWAYS AS (md5(base64)) STORED COMMENT 'MD5 hash of the file content',
  size INT(10) UNSIGNED GENERATED ALWAYS AS (octet_length(base64)) STORED COMMENT 'Size of the file in bytes',
  name VARCHAR(255) DEFAULT NULL COMMENT 'Original file name',
  mime VARCHAR(100) DEFAULT NULL COMMENT 'MIME type of the file',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_attachment),
  UNIQUE KEY uk_attachments_hash_size (hash, size),
  INDEX idx_attachments_mime (mime),
  INDEX idx_attachments_name (name)
) ENGINE=InnoDB COMMENT='Stores file attachments.';

-- Table: Attachment Files
-- Description: Junction table for attachments and files.
CREATE TABLE IF NOT EXISTS tb_attachment_files (
  id_attachment INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_attachments',
  id_file INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_files',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  UNIQUE KEY uk_attachment_files_attachment_file_created_at (id_attachment, id_file, created_at),
  INDEX idx_attachment_files_created_at (created_at),
  INDEX idx_attachment_files_updated_by_user_id (updated_by_user_id),
  INDEX idx_attachment_files_file_id (id_file),
  CONSTRAINT fk_attachment_files_attachment_id FOREIGN KEY (id_attachment) REFERENCES tb_attachments (id_attachment) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_files_file_id FOREIGN KEY (id_file) REFERENCES tb_files (id_file) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_files_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Junction table for attachments and files.';

-- Table: Attachment Group Files
-- Description: Junction table for attachments and file groups.
CREATE TABLE IF NOT EXISTS tb_attachment_group_files (
  id_attachment INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_attachments',
  id_group_file SMALLINT(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Foreign Key referencing tb_group_files',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  UNIQUE KEY uk_attachment_group_files_attachment_group_file_created_at (id_attachment, id_group_file, created_at),
  INDEX idx_attachment_group_files_created_at (created_at),
  INDEX idx_attachment_group_files_updated_by_user_id (updated_by_user_id),
  INDEX idx_attachment_group_files_group_file_id (id_group_file),
  CONSTRAINT fk_attachment_group_files_attachment_id FOREIGN KEY (id_attachment) REFERENCES tb_attachments (id_attachment) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_group_files_group_file_id FOREIGN KEY (id_group_file) REFERENCES tb_group_files (id_group_file) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_group_files_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Junction table for attachments and file groups.';

-- Table: Attachment Group Users
-- Description: Junction table for attachments and user groups.
CREATE TABLE IF NOT EXISTS tb_attachment_group_users (
  id_attachment INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_attachments',
  id_group_user SMALLINT(5) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_group_users',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  UNIQUE KEY uk_attachment_group_users_attachment_group_user_created_at (id_attachment, id_group_user, created_at),
  INDEX idx_attachment_group_users_created_at (created_at),
  INDEX idx_attachment_group_users_updated_by_user_id (updated_by_user_id),
  INDEX idx_attachment_group_users_group_user_id (id_group_user),
  CONSTRAINT fk_attachment_group_users_attachment_id FOREIGN KEY (id_attachment) REFERENCES tb_attachments (id_attachment) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_group_users_group_user_id FOREIGN KEY (id_group_user) REFERENCES tb_group_users (id_group_user) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_group_users_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Junction table for attachments and user groups.';

-- Table: Attachment Permissions
-- Description: Junction table for attachments and permissions.
CREATE TABLE IF NOT EXISTS tb_attachment_permissions (
  id_attachment INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_attachments',
  ican_delete INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_permissions',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  UNIQUE KEY uk_attachment_permissions_attachment_permission_created_at (id_attachment, ican_delete, created_at),
  INDEX idx_attachment_permissioncan_special_id (ican_delete),
  INDEX idx_attachment_permissions_created_at (created_at),
  INDEX idx_attachment_permissions_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_attachment_permissions_attachment_id FOREIGN KEY (id_attachment) REFERENCES tb_attachments (id_attachment) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_permissioncan_special_id FOREIGN KEY (ican_delete) REFERENCES tb_permissions (ican_delete) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_permissions_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Junction table for attachments and permissions.';

-- Table: Attachment Users
-- Description: Junction table for attachments and users.
CREATE TABLE IF NOT EXISTS tb_attachment_users (
  id_attachment INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_attachments',
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  UNIQUE KEY uk_attachment_users_attachment_user_created_at (id_attachment, id_user, created_at),
  INDEX idx_attachment_users_created_at (created_at),
  INDEX idx_attachment_users_updated_by_user_id (updated_by_user_id),
  INDEX idx_attachment_users_user_id (id_user),
  CONSTRAINT fk_attachment_users_attachment_id FOREIGN KEY (id_attachment) REFERENCES tb_attachments (id_attachment) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_users_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_attachment_users_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Junction table for attachments and users.';

-- Table: Document Types
-- Description: Stores different types of documents.
CREATE TABLE IF NOT EXISTS tb_document_types (
  id_document_type TINYINT(3) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  document_type VARCHAR(50) NOT NULL COMMENT 'Name of the document type',
  PRIMARY KEY (id_document_type),
  UNIQUE KEY uk_document_types_document_type (document_type)
) ENGINE=InnoDB COMMENT='Stores different types of documents.';

-- Table: Domains
-- Description: List of domains used. Empty=Web.
CREATE TABLE IF NOT EXISTS tb_domains (
  id_domain TINYINT(4) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  domain_name VARCHAR(50) NOT NULL DEFAULT '' COMMENT 'Name of the domain. Empty=Web',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  PRIMARY KEY (id_domain),
  UNIQUE KEY uk_domains_domain_name (domain_name),
  INDEX idx_domains_updated_at (updated_at),
  INDEX idx_domains_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_domains_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='List of domains used. Empty=Web.';

-- Table: Files
-- Description: Files controlled by the Secure Class. CRUDS here is used as file functions and L the security level expected for the file.
CREATE TABLE IF NOT EXISTS tb_files (
  id_file INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  file_path VARCHAR(255) NOT NULL COMMENT 'File name with complete path protocol://domain/path/file',
  can_create TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '[Create]Create permission',
  can_read TINYINT(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT '[Read]Read permission',
  can_update TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '[Update]Write permission',
  can_delete TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '[Delete]Delete permission',
  can_special TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '[Special]Execute permission',
  security_level ENUM('Free', 'Secured', 'Paranoic') NOT NULL DEFAULT 'Free' COMMENT '[Level]Comparison Level',
  cruds TINYINT(2) UNSIGNED DEFAULT NULL COMMENT 'CRUD permissions flag',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_file),
  UNIQUE KEY uk_files_file_path (file_path),
  INDEX idx_files_updated_at (updated_at),
  INDEX idx_files_security_level (security_level),
  INDEX idx_files_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_files_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Files controlled by the Secure Class. CRUDS here is used as file functions and L the security level expected for the file.';

-- Table: Files x Group Files
-- Description: Relationship of Files with File Group.
CREATE TABLE IF NOT EXISTS tb_files_x_group_files (
  id_file INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_files',
  id_group_file SMALLINT(5) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_group_files',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_file, id_group_file),
  INDEX idx_files_x_group_files_updated_at (updated_at),
  INDEX idx_files_x_group_files_group_file_id (id_group_file),
  INDEX idx_files_x_group_files_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_files_x_group_files_file_id FOREIGN KEY (id_file) REFERENCES tb_files (id_file) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_files_x_group_files_group_file_id FOREIGN KEY (id_group_file) REFERENCES tb_group_files (id_group_file) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_files_x_group_files_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Relationship of Files with File Group.';

-- Table: Group Files
-- Description: Group of Files.
CREATE TABLE IF NOT EXISTS tb_group_files (
  id_group_file SMALLINT(5) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  group_file_name VARCHAR(64) NOT NULL COMMENT 'Name of the file group',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_group_file),
  UNIQUE KEY uk_group_files_group_file_name (group_file_name),
  INDEX idx_group_files_updated_at (updated_at),
  INDEX idx_group_files_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_group_files_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Group of Files.';

-- Table: Group Users
-- Description: Group of Users.
CREATE TABLE IF NOT EXISTS tb_group_users (
  id_group_user SMALLINT(5) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  group_user_name VARCHAR(64) NOT NULL COMMENT 'Name of the user group',
  email_dl VARCHAR(255) DEFAULT NULL COMMENT 'Group DL email',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  is_ldap TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Is this group from LDAP?',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_group_user),
  UNIQUE KEY uk_group_users_group_user_name (group_user_name),
  INDEX idx_group_users_updated_at (updated_at),
  INDEX idx_group_users_updated_by_user_id (updated_by_user_id),
  INDEX idx_group_users_is_ldap (is_ldap),
  CONSTRAINT fk_group_users_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Group of Users.';


-- Table: Import Users
-- Description: Temporary table for importing users.
CREATE TABLE IF NOT EXISTS tb_import_users (
  matricula VARCHAR(64) NOT NULL COMMENT 'User registration number',
  id_user INT(10) UNSIGNED DEFAULT NULL COMMENT 'Foreign Key referencing tb_users',
  user_name VARCHAR(64) DEFAULT NULL COMMENT 'User login name',
  full_name VARCHAR(64) DEFAULT NULL COMMENT 'Full name of the user',
  email VARCHAR(64) DEFAULT NULL COMMENT 'User email address',
  gender CHAR(1) NOT NULL DEFAULT '' COMMENT 'User gender (M/F)',
  mobile_phone VARCHAR(20) DEFAULT NULL COMMENT 'User mobile phone number',
  phone VARCHAR(20) DEFAULT NULL COMMENT 'User phone number',
  site_code VARCHAR(5) DEFAULT NULL COMMENT 'User site code',
  position_name VARCHAR(55) DEFAULT NULL COMMENT 'User position name',
  PRIMARY KEY (matricula),
  INDEX idx_import_users_user_id (id_user),
  CONSTRAINT fk_import_users_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Temporary table for importing users.';

-- Table: Penalty
-- Description: Stores IP addresses that have been penalized.
CREATE TABLE IF NOT EXISTS tb_penalty (
  ip_address VARCHAR(64) NOT NULL COMMENT 'IP Address',
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT 'Last update timestamp',
  PRIMARY KEY (ip_address),
  INDEX idx_penalty_updated_at (updated_at)
) ENGINE=InnoDB COMMENT='Stores IP addresses that have been penalized.';

-- Table: Permissions
-- Description: Permissions of User Group for File Group.
CREATE TABLE IF NOT EXISTS tb_permissions (
  ican_delete INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  id_group_user SMALLINT(5) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_group_users',
  id_group_file SMALLINT(5) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_group_files',
  can_create TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '[Create]Create permission',
  can_read TINYINT(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT '[Read]Read permission',
  can_update TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '[Update]Write permission',
  can_delete TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '[Delete]Delete permission',
  can_special TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '[Special]Special permission',
  cruds TINYINT(2) UNSIGNED DEFAULT NULL COMMENT 'CRUD permissions flag',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (ican_delete),
  UNIQUE KEY uk_permissions_group_user_id_group_file_id (id_group_user, id_group_file),
  INDEX idx_permissions_updated_at (updated_at),
  INDEX idx_permissions_group_file_id (id_group_file),
  INDEX idx_permissions_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_permissions_group_file_id FOREIGN KEY (id_group_file) REFERENCES tb_group_files (id_group_file) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_permissions_group_user_id FOREIGN KEY (id_group_user) REFERENCES tb_group_users (id_group_user) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_permissions_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Permissions of User Group for File Group.';

-- Table: Positions
-- Description: List of Job Positions.
CREATE TABLE IF NOT EXISTS tb_positions (
  id_position INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  position_name VARCHAR(64) NOT NULL COMMENT 'Name of the position',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  PRIMARY KEY (id_position),
  UNIQUE KEY uk_positions_position_name (position_name),
  INDEX idx_positions_updated_at (updated_at),
  INDEX idx_positions_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_positions_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='List of Job Positions.';

-- Table: Sites
-- Description: List of Sites.
CREATE TABLE IF NOT EXISTS tb_sites (
  id_site INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  site_name VARCHAR(32) NOT NULL COMMENT 'Name of the site',
  street_address VARCHAR(255) DEFAULT NULL COMMENT 'Street address',
  address_number VARCHAR(20) DEFAULT NULL COMMENT 'Address number',
  neighborhood VARCHAR(100) DEFAULT NULL COMMENT 'Neighborhood',
  city VARCHAR(100) DEFAULT NULL COMMENT 'City',
  state_code CHAR(2) DEFAULT NULL COMMENT 'State code',
  zip_code CHAR(9) DEFAULT NULL COMMENT 'Zip code',
  PRIMARY KEY (id_site),
  UNIQUE KEY uk_sites_site_name (site_name)
) ENGINE=InnoDB COMMENT='List of Sites.';

-- Table: URLs
-- Description: Stored links to be used as shortened URLs.
CREATE TABLE IF NOT EXISTS tb_urls (
  id_url INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  short_link VARCHAR(8) DEFAULT NULL COMMENT 'Shortened link identifier',
  full_url VARCHAR(500) DEFAULT NULL COMMENT 'Full URL',
  query_string TEXT DEFAULT NULL COMMENT 'Query string parameters',
  hash VARCHAR(45) DEFAULT NULL COMMENT 'Hash of the URL',
  description VARCHAR(150) DEFAULT NULL COMMENT 'Description of the URL',
  is_temporary TINYINT(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Is this a temporary link?',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  last_visit_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last visit timestamp',
  id_user INT(10) UNSIGNED DEFAULT NULL COMMENT 'Foreign Key referencing tb_users for the creator',
  PRIMARY KEY (id_url),
  UNIQUE KEY uk_urls_short_link (short_link),
  UNIQUE KEY uk_urls_hash (hash),
  INDEX idx_urls_created_at (created_at),
  INDEX idx_urls_is_temporary (is_temporary),
  INDEX idx_urls_last_visit_at (last_visit_at),
  INDEX idx_urls_user_id (id_user),
  CONSTRAINT fk_urls_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Stored links to be used as shortened URLs.';

-- Table: Users
-- Description: All logins with their respective domains.
CREATE TABLE IF NOT EXISTS tb_users (
  id_user INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  id_domain TINYINT(4) UNSIGNED NOT NULL DEFAULT 3 COMMENT 'Foreign Key referencing tb_domains',
  user_login VARCHAR(64) NOT NULL COMMENT 'User login name',
  is_active TINYINT(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Is the user active?',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user),
  UNIQUE KEY uk_users_domain_id_user_login (id_domain, user_login),
  INDEX idx_users_is_active (is_active),
  INDEX idx_users_updated_at (updated_at),
  INDEX idx_users_user_login (user_login),
  INDEX idx_users_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_users_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='All logins with their respective domains.';

-- Table: User Confirmation
-- Description: If the Login is confirmed by some input method AD/LDAP, SMS, e-mail.
CREATE TABLE IF NOT EXISTS tb_user_confirmations (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  is_confirmed TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Is the registration confirmed?',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user),
  INDEX idx_user_confirmations_is_confirmed (is_confirmed),
  INDEX idx_user_confirmations_updated_at (updated_at),
  CONSTRAINT fk_user_confirmations_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='If the Login is confirmed by some input method AD/LDAP, SMS, e-mail.';

-- Table: User Details
-- Description: User Details.
CREATE TABLE IF NOT EXISTS tb_user_details (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  full_name VARCHAR(64) DEFAULT NULL COMMENT 'User full name',
  gender ENUM('', 'Male', 'Female') DEFAULT NULL COMMENT 'User gender',
  manager_id INT(10) UNSIGNED DEFAULT NULL COMMENT 'Foreign Key referencing tb_user_details for the manager',
  id_position INT(10) UNSIGNED DEFAULT NULL COMMENT 'Foreign Key referencing tb_positions',
  registration_number VARCHAR(20) DEFAULT NULL COMMENT 'User registration number',
  birth_date DATE DEFAULT NULL COMMENT 'User birth date',
  contract_start_date DATE DEFAULT NULL COMMENT 'Employee acquisition period start date',
  cost_center VARCHAR(10) NOT NULL COMMENT 'Cost center',
  assigned_site_id INT(10) UNSIGNED DEFAULT NULL COMMENT 'Foreign Key referencing tb_sites for the RH management location',
  located_site_id INT(10) UNSIGNED DEFAULT NULL COMMENT 'Foreign Key referencing tb_sites for the current work location',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_by_user_id INT(10) UNSIGNED DEFAULT (IFNULL(@Secure_idUser, 1)) COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user),
  INDEX idx_user_details_updated_at (updated_at),
  INDEX idx_user_details_position_id (id_position),
  INDEX idx_user_details_manager_id (manager_id),
  INDEX idx_user_details_registration_number (registration_number),
  INDEX idx_user_details_birth_date (birth_date),
  INDEX idx_user_details_full_name (full_name),
  INDEX idx_user_details_assigned_site_id (assigned_site_id),
  INDEX idx_user_details_located_site_id (located_site_id),
  INDEX idx_user_details_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_user_details_manager_id FOREIGN KEY (manager_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT fk_user_details_position_id FOREIGN KEY (id_position) REFERENCES tb_positions (id_position) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT fk_user_details_assigned_site_id FOREIGN KEY (assigned_site_id) REFERENCES tb_sites (id_site) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT fk_user_details_located_site_id FOREIGN KEY (located_site_id) REFERENCES tb_sites (id_site) ON DELETE SET NULL ON UPDATE NO ACTION,
  CONSTRAINT fk_user_details_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_user_details_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='User Details.';

-- Table: User Documents
-- Description: User Documents.
CREATE TABLE IF NOT EXISTS tb_user_documents (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  id_document_type TINYINT(3) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_document_types',
  document_name VARCHAR(255) NOT NULL COMMENT 'Document name',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  PRIMARY KEY (id_user, id_document_type),
  UNIQUE KEY uk_user_documents_document_name_document_type_user_id (document_name, id_document_type, id_user),
  INDEX idx_user_documents_document_type_id (id_document_type),
  CONSTRAINT fk_user_documents_document_type_id FOREIGN KEY (id_document_type) REFERENCES tb_document_types (id_document_type) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_user_documents_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='User Documents.';

-- Table: User Emails
-- Description: User E-mails.
CREATE TABLE IF NOT EXISTS tb_user_emails (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  email VARCHAR(64) NOT NULL COMMENT 'User email address',
  email_type ENUM('Business', 'Home', 'Other') NOT NULL DEFAULT 'Business' COMMENT 'Type of email',
  is_confirmed TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Is the email confirmed?',
  confirmation_key VARCHAR(10) DEFAULT NULL COMMENT 'Confirmation key',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user, email),
  UNIQUE KEY uk_user_emails_email_user_id (email, id_user),
  INDEX idx_user_emails_is_confirmed (is_confirmed),
  INDEX idx_user_emails_updated_at (updated_at),
  CONSTRAINT fk_user_emails_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='User E-mails.';

-- Table: User Addresses
-- Description: User Addresses.
CREATE TABLE IF NOT EXISTS tb_user_addresses (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  address_label VARCHAR(16) NOT NULL DEFAULT 'Principal' COMMENT 'Type of address location',
  address_type ENUM('Business', 'Home', 'Other') NOT NULL DEFAULT 'Business' COMMENT 'Address type',
  street_address VARCHAR(255) DEFAULT NULL COMMENT 'Street address',
  address_number VARCHAR(16) DEFAULT NULL COMMENT 'Address number',
  complement VARCHAR(64) DEFAULT NULL COMMENT 'Address complement',
  neighborhood VARCHAR(64) DEFAULT NULL COMMENT 'Neighborhood',
  city VARCHAR(64) DEFAULT NULL COMMENT 'City',
  state_code CHAR(2) DEFAULT NULL COMMENT 'State code',
  country VARCHAR(32) NOT NULL DEFAULT 'Brasil' COMMENT 'Country',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user, address_label),
  INDEX idx_user_addresses_updated_at (updated_at),
  INDEX idx_user_addresses_address_label (address_label),
  CONSTRAINT fk_user_addresses_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='User Addresses.';

-- Table: User IPs
-- Description: IP address the user is currently using.
CREATE TABLE IF NOT EXISTS tb_user_ips (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  ip_address VARCHAR(39) DEFAULT NULL COMMENT 'User IP Address',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user),
  INDEX idx_user_ips_updated_at (updated_at),
  INDEX idx_user_ips_ip_address (ip_address),
  CONSTRAINT fk_user_ips_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='IP address the user is currently using.';

-- Table: User Passwords
-- Description: User password if it is via web.
CREATE TABLE IF NOT EXISTS tb_user_passwords (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  password VARBINARY(64) NOT NULL COMMENT 'User password',
  expiration_date DATETIME DEFAULT NULL COMMENT 'Password expiration date',
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  PRIMARY KEY (id_user),
  INDEX idx_user_passwords_expiration_date (expiration_date),
  INDEX idx_user_passwords_updated_at (updated_at),
  CONSTRAINT fk_user_passwords_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='User password if it is via web.';

-- Table: User Phone Numbers
-- Description: User Phone Numbers.
CREATE TABLE IF NOT EXISTS tb_user_phone_numbers (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  phone_number VARCHAR(20) NOT NULL COMMENT 'User phone number',
  contact_type ENUM('Mobile', 'Home', 'Business', 'Fax', 'Ramal') NOT NULL DEFAULT 'Mobile' COMMENT 'Type of contact',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user, phone_number),
  UNIQUE KEY uk_user_phone_numbers_phone_number_user_id (phone_number, id_user),
  INDEX idx_user_phone_numbers_updated_at (updated_at),
  INDEX idx_user_phone_numbers_contact_type (contact_type),
  CONSTRAINT fk_user_phone_numbers_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='User Phone Numbers.';

-- Table: User Tokens
-- Description: Token that the User is currently using.
CREATE TABLE IF NOT EXISTS tb_user_tokens (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  token CHAR(32) NOT NULL DEFAULT '' COMMENT 'User token',
  jwt LONGTEXT NOT NULL COMMENT 'JSON Web Token',
  expiration_limit INT(10) UNSIGNED NOT NULL DEFAULT 900 COMMENT 'Token expiration time in seconds',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user, token),
  INDEX idx_user_tokens_created_at (created_at),
  INDEX idx_user_tokens_updated_at (updated_at),
  CONSTRAINT fk_user_tokens_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Token that the User is currently using.';

-- Table: User Login Attempts
-- Description: Date of Login attempt.
CREATE TABLE IF NOT EXISTS tb_user_login_attempts (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  PRIMARY KEY (id_user),
  INDEX idx_user_login_attempts_updated_at (updated_at),
  CONSTRAINT fk_user_login_attempts_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Date of Login attempt.';

-- Table: Users x Group Users
-- Description: Relationship of Users with Group of Users.
CREATE TABLE IF NOT EXISTS tb_users_x_group_users (
  id_user INT(10) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_users',
  id_group_user SMALLINT(5) UNSIGNED NOT NULL COMMENT 'Foreign Key referencing tb_group_users',
  is_main TINYINT(1) UNSIGNED DEFAULT NULL COMMENT 'Is this the main group for the user?',
  sequence INT(10) UNSIGNED NOT NULL DEFAULT 255 COMMENT 'Sequence order',
  obs TEXT DEFAULT NULL COMMENT 'Observations',
  updated_by_user_id INT(10) UNSIGNED DEFAULT NULL COMMENT 'Foreign Key referencing tb_users for the last update',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
  PRIMARY KEY (id_user, id_group_user),
  UNIQUE KEY uk_users_x_group_users_is_main_user_id (is_main, id_user),
  INDEX idx_users_x_group_users_updated_at (updated_at),
  INDEX idx_users_x_group_users_group_user_id (id_group_user),
  INDEX idx_users_x_group_users_sequence (sequence),
  INDEX idx_users_x_group_users_updated_by_user_id (updated_by_user_id),
  CONSTRAINT fk_users_x_group_users_group_user_id FOREIGN KEY (id_group_user) REFERENCES tb_group_users (id_group_user) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_users_x_group_users_user_id FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_users_x_group_users_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES tb_users (id_user) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Relationship of Users with Group of Users.';


DELIMITER //

-- Stored Procedure: fail
-- Description: Executes an exception, generating an error.
CREATE PROCEDURE sp_fail (
  IN in_text VARCHAR(255)
)
COMMENT 'Executes an exception, generating an error'
CALL sp_sign_error(31001, in_text)//

DELIMITER ;

DELIMITER //

-- Stored Procedure: pctr_Files_before
-- Description: Before insert or update trigger procedure for the tb_files table.
--              Sets the updated_by_user_id and builds the CRUDS flag.
CREATE PROCEDURE sptr_files_before (
  INOUT NEW_can_create TINYINT(1),
  INOUT NEW_can_read TINYINT(1),
  INOUT NEW_can_update TINYINT(1),
  INOUT NEW_can_delete TINYINT(1),
  INOUT NEW_can_special TINYINT(1),
  IN NEW_cruds TINYINT(2),
  INOUT NEW_updated_by_user_id INT(10) UNSIGNED
)
BEGIN
  -- Set the updated_by_user_id using the function fn_get_idUser().
  SET NEW_updated_by_user_id = fn_get_id_user();
  -- Build the CRUDS flag based on individual permissions.
  SET NEW_cruds = fn_permission_build_crud(NEW_can_create, NEW_can_read, NEW_can_update, NEW_can_delete, NEW_can_special);
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: pctr_Users_Detail_before
-- Description: Before insert or update trigger procedure for the tb_user_details table.
--              Sets the updated_by_user_id and defaults the full_name to registration_number if empty.
CREATE PROCEDURE sptr_user_details_before (
  INOUT NEW_registration_number VARCHAR(20),
  INOUT NEW_full_name VARCHAR(64),
  INOUT NEW_updated_by_user_id INT(10) UNSIGNED
)
BEGIN
  -- Set the updated_by_user_id using the function fn_get_idUser().
  SET NEW_updated_by_user_id = fn_get_id_user();
  -- If the full_name is empty, set it to the registration_number.
  IF (TRIM(IFNULL(NEW_full_name, '')) = '') THEN
    SET NEW_full_name = NEW_registration_number;
  END IF;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: pctr_Users_Passwd_before
-- Description: Before insert or update trigger procedure for the tb_user_passwords table.
--              Handles password encoding and expiration date.
CREATE PROCEDURE sptr_user_passwords_before (
  INOUT NEW_password VARBINARY(64),
  INOUT NEW_expiration_date DATETIME,
  IN OLD_password VARBINARY(64)
)
BEGIN
  -- Declare a variable for password expiration in days, defaulting to the session variable or 120 days.
  DECLARE expires_password INT UNSIGNED DEFAULT IFNULL(@expiresPassword, 120);

  -- If the new password is NULL, set it to an empty string.
  IF NEW_password IS NULL THEN
    SET NEW_password = '';
  END IF;

  -- If the new password is empty, generate a random password and set the expiration date to now.
  IF NEW_password = '' THEN
    SET NEW_password = fn_encode(fn_user_get_random_password(12));
    SET NEW_expiration_date = NOW();
  -- If the new password is different from the old password, encode the new password and set the expiration date.
  ELSEIF NOT (NEW_password <=> OLD_password) THEN
    SET NEW_password = fn_encode(NEW_password);
    SET NEW_expiration_date = IF(expires_password = 0, NULL, DATE_ADD(NOW(), INTERVAL expires_password DAY));
  END IF;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_CleanToken
-- Description: Deletes expired tokens from the tb_user_tokens table.
CREATE PROCEDURE sp_clean_token ()
DELETE t
FROM tb_user_tokens t
WHERE t.updated_at < NOW() - INTERVAL t.expiration_limit SECOND//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_Import_Users
-- Description: Imports users from the tb_import_users table to the tb_users, tb_user_confirmations,
--              tb_user_details, tb_user_emails, and tb_user_phone_numbers tables.
--              Finally, it truncates the tb_import_users table.
CREATE PROCEDURE sp_import_users ()
BEGIN
  -- Insert new users into tb_users, ignoring duplicates based on username or registration number.
  INSERT IGNORE tb_users (`user_login`)
  SELECT IFNULL(i.user_name, i.registration_number)
  FROM tb_import_users i;

  -- Update tb_import_users with the corresponding id_user from tb_users.
  UPDATE tb_import_users i
  JOIN tb_users u ON IFNULL(i.user_name, i.registration_number) = u.user_login
  SET i.id_user = u.id_user;

  -- Confirm imported users in tb_user_confirmations if they exist.
  UPDATE tb_import_users i
  JOIN tb_user_confirmations c ON c.id_user = i.id_user
  SET c.is_confirmed = 1;

  -- Update user details in tb_user_details with data from tb_import_users.
  UPDATE tb_import_users i
  JOIN tb_user_details d ON d.id_user = i.id_user
  SET
    d.full_name = IF(IFNULL(i.full_name, '') = '', d.full_name, i.full_name),
    d.gender = IF(i.gender = 'M', 'Male', IF(i.gender = 'F', 'Female', '')),
    d.registration_number = i.registration_number,
    d.id_position = fn_user_get_id_position(i.position_name);

  -- Insert new business emails into tb_user_emails, ignoring duplicates.
  INSERT IGNORE tb_user_emails (id_user, email, email_type, is_confirmed)
  SELECT i.id_user, i.email, 'Business', 1
  FROM tb_import_users i
  WHERE IFNULL(i.email, '') != '';

  -- Insert new mobile phone numbers into tb_user_phone_numbers, ignoring duplicates.
  INSERT IGNORE tb_user_phone_numbers (id_user, phone_number, contact_type)
  SELECT i.id_user, i.mobile_phone, 'Mobile'
  FROM tb_import_users i
  WHERE IFNULL(i.mobile_phone, '') != '';

  -- Insert new business phone numbers into tb_user_phone_numbers, ignoring duplicates.
  INSERT IGNORE tb_user_phone_numbers (id_user, phone_number, contact_type)
  SELECT i.id_user, i.phone, 'Business'
  FROM tb_import_users i
  WHERE IFNULL(i.phone, '') != '';

  -- Remove all data from the tb_import_users table.
  TRUNCATE TABLE tb_import_users;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_ManagerLocate
-- Description: Recursively finds the top-level manager ID for a given user.
CREATE PROCEDURE sp_manager_locate (
  IN in_id_user INT(10) UNSIGNED,
  INOUT inout_located_manager_id INT(10) UNSIGNED
)
BEGIN
  -- Declare a variable to store the manager ID of the current user.
  DECLARE current_manager_id INT(11) UNSIGNED DEFAULT (SELECT manager_id FROM tb_user_details WHERE id_user = in_id_user);
  -- Set the maximum recursion depth to prevent infinite loops.
  SET @@max_sp_recursion_depth = 20;

  -- If the current user has no manager or the manager is the user itself, set the located manager ID to NULL.
  IF (current_manager_id IS NULL OR current_manager_id = in_id_user) THEN
    SET inout_located_manager_id = NULL;
  -- If the located manager ID is different from the current manager ID, recursively call the procedure.
  ELSEIF (inout_located_manager_id != current_manager_id) THEN
    CALL sp_manager_locate(current_manager_id, inout_located_manager_id);
  END IF;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_ManagerPath
-- Description: Recursively builds a comma-separated path of manager IDs up to the top-level manager for a given user.
CREATE PROCEDURE sp_manager_path (
  IN in_id_user INT(10) UNSIGNED,
  INOUT io_path TEXT
)
BEGIN
  -- Declare a variable to store the manager ID of the current user.
  DECLARE current_manager_id INT(11) UNSIGNED DEFAULT (SELECT manager_id FROM tb_user_details WHERE id_user = in_id_user);
  -- Set the maximum recursion depth to prevent infinite loops.
  SET @@max_sp_recursion_depth = 20;

  -- If the current user has a manager and the manager is not the user itself,
  -- concatenate the manager ID to the path and recursively call the procedure.
  IF (current_manager_id IS NOT NULL AND current_manager_id != in_id_user) THEN
    SET io_path = CONCAT_WS(',', io_path, current_manager_id);
    CALL sp_manager_path(current_manager_id, io_path);
  END IF;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_Permition_Files_by_idUser
-- Description: Shows all files with permissions for a given user.
CREATE PROCEDURE sp_permission_files_by_id_user (
  IN in_id_user INT(10) UNSIGNED
)
COMMENT 'Shows all files with permissions for a user'
BEGIN
  -- Select file information and calculate the combined CRUDS permissions.
  SELECT
    t.*,
    -- Calculate the effective CRUDS permissions based on file level, file CRUDS, and group permissions.
    fn_permission_cruds(t.security_level, t.file_cruds, t.permission_cruds) AS cruds
  FROM (
    -- Subquery to retrieve file information and aggregated group permissions.
    SELECT
      f.id_file,
      f.file_path,
      f.security_level,
      f.cruds AS file_cruds,
      -- Aggregate the CRUDS permissions for the user's groups.
      BIT_OR(IFNULL(p.cruds, 0)) AS permission_cruds
    FROM tb_users u
    LEFT JOIN tb_users_x_group_users gu USING (id_user)
    LEFT JOIN tb_permissions p
      ON p.id_group_user IN (IFNULL(gu.id_group_user, 0), 1, IF(u.id_user IS NULL, 0, 3))
    LEFT JOIN tb_files_x_group_files gf USING (id_group_file)
    LEFT JOIN tb_files f USING (id_file)
    WHERE u.id_user = in_id_user
      AND u.is_active -- Consider only active users
    GROUP BY f.id_file
  ) t;
END//

DELIMITER ;


DELIMITER //

-- Stored Procedure: sp_Permition_File_by_idFile_idUser
-- Description: Retrieves the permissions for a specific file for a given user.
CREATE PROCEDURE sp_permission_file_by_id_file_id_user (
  IN in_id_file INT UNSIGNED,
  IN in_id_user INT UNSIGNED
)
BEGIN
  -- Select file information, user information, and calculate combined CRUDS permissions.
  SELECT
    t.*,
    -- Calculate the effective CRUDS permissions.
    fn_permission_cruds(t.security_level, t.file_cruds, t.permission_cruds) AS cruds
  FROM (
    -- Subquery to join file, user, and permission information.
    SELECT
      f.file_path,
      f.security_level,
      f.cruds AS file_cruds,
      u.user_login,
      u.is_active,
      -- Aggregate the CRUDS permissions for the user's groups on this file.
      BIT_OR(IFNULL(p.cruds, 0)) AS permission_cruds
    FROM tb_files f
    LEFT JOIN tb_users u ON u.id_user = in_id_user AND u.is_active
    LEFT JOIN tb_files_x_group_files gf USING (id_file)
    LEFT JOIN tb_users_x_group_users gu USING (id_user)
    LEFT JOIN tb_permissions p
      ON p.id_group_file = gf.id_group_file
      AND p.id_group_user IN (IFNULL(gu.id_group_user, 0), 1, IF(u.id_user IS NULL, 0, 3))
    WHERE f.id_file = in_id_file
  ) t;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_Permition_GrpUsr_by_idFile_CRUDS
-- Description: Shows the permissions of a file for its respective User Groups based on a CRUDS filter.
CREATE PROCEDURE sp_permission_group_user_by_id_file_cruds (
  IN in_id_file INT(10) UNSIGNED,
  IN in_cruds TINYINT(2) UNSIGNED
)
COMMENT 'Shows permissions of a file for its respective User Groups'
BEGIN
  -- Set the CRUDS filter to the input value or default to 31 (all permissions).
  SET in_cruds = IFNULL(in_cruds, 31);
  SET in_cruds = IF(in_cruds = 0, 31, in_cruds);

  -- Select file information, group user information, and calculate combined CRUDS permissions.
  SELECT
    f.id_file,
    f.file_path,
    f.security_level,
    f.cruds AS file_cruds,
    p.cruds AS permission_cruds,
    -- Calculate the effective CRUDS permissions.
    fn_permission_cruds(f.security_level, f.cruds, p.cruds) AS cruds,
    gu.id_group_user,
    gu.group_user_name
  FROM tb_files f
  JOIN tb_files_x_group_files gf ON f.id_file = gf.id_file
  JOIN tb_permissions p ON gf.id_group_file = p.id_group_file AND (p.cruds & in_cruds) > 0
  JOIN tb_group_users gu ON p.id_group_user = gu.id_group_user
  WHERE f.id_file = in_id_file;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_Permition_List_File_by_idFile_idUser
-- Description: Lists the permissions for a specific file for a given user, including group user and group file information.
CREATE PROCEDURE sp_permission_list_file_by_id_file_id_user (
  IN in_id_file INT(10) UNSIGNED,
  IN in_id_user INT(10) UNSIGNED
)
BEGIN
  -- Select detailed permission information, including binary representation of CRUDS.
  SELECT
    *,
    LPAD(CONV(t.cruds, 10, 2), 5, '0') AS cruds_bin
  FROM (
    -- Subquery to join file, user, group user, group file, and permission information.
    SELECT
      gu.id_group_user,
      guu.group_user_name,
      gf.id_group_file,
      gff.group_file_name,
      u.id_user,
      u.user_login,
      u.is_active,
      f.id_file,
      f.file_path,
      f.security_level,
      f.cruds AS file_cruds,
      -- Retrieve the CRUDS permissions for the group, defaulting to 0 if no permission is set.
      IFNULL(p.cruds, 0) AS permission_cruds,
      -- Calculate the effective CRUDS permissions.
      fn_permission_cruds(f.security_level, f.cruds, IFNULL(p.cruds, 0)) AS cruds
    FROM tb_files f
    LEFT JOIN tb_users u ON u.id_user = in_id_user AND u.is_active
    LEFT JOIN tb_files_x_group_files gf USING (id_file)
    LEFT JOIN tb_users_x_group_users gu USING (id_user)
    LEFT JOIN tb_group_users guu USING (id_group_user)
    LEFT JOIN tb_group_files gff USING (id_group_file)
    LEFT JOIN tb_permissions p
      ON p.id_group_file = gf.id_group_file
      AND p.id_group_user IN (IFNULL(gu.id_group_user, 0), 1, IF(u.id_user IS NULL, 0, 3))
    WHERE f.id_file = in_id_file
  ) t
  WHERE t.cruds > 0; -- Filter results to show only where there is at least one permission granted
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_rebuild_GrpUsr_Main
-- Description: Selects all active users and attempts to set their main group using the fn_User_SetMainGroup function.
CREATE PROCEDURE sp_rebuild_group_user_main ()
SELECT
  u.id_user,
  u.user_login,
  -- Calls the function to set the main group for each user.
  fn_user_set_main_group(u.id_user) AS id_group_user_main
FROM tb_users u
WHERE u.is_active//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_SplitObjName
-- Description: Splits an object full name into two parts: the first part and the rest.
--              Handles quoted identifiers (using backticks).
CREATE PROCEDURE sp_split_obj_name (
  OUT out_obj_name VARCHAR(255),
  INOUT oi_obj_full_name VARCHAR(255)
)
COMMENT 'Divides an object name into two parts: first_part[.rest]'
BEGIN
  -- Declare a variable to store the position of the delimiter.
  DECLARE p TINYINT(4) DEFAULT 0;

  -- If the input full name is NULL, set the output name to NULL.
  IF (oi_obj_full_name IS NULL) THEN
    SET out_obj_name = NULL;
  ELSE
    -- Handle quoted identifiers (names enclosed in backticks).
    IF (LEFT(oi_obj_full_name, 1) = '`') THEN
      -- Remove the opening backtick.
      SET oi_obj_full_name = SUBSTRING(oi_obj_full_name, 2);
      -- Find the position of the closing backtick.
      SET p = INSTR(oi_obj_full_name, '`');
      -- If no closing backtick is found, raise an error.
      IF (p = 0) THEN
        CALL sp_fail('Incorrect in_Obj parameter');
      END IF;
      -- Extract the object name (part before the closing backtick).
      SET out_obj_name = LEFT(oi_obj_full_name, p - 1);
      -- Update the input full name to the part after the closing backtick.
      SET oi_obj_full_name = SUBSTRING(oi_obj_full_name, p + 1);
    ELSE
      -- Handle unquoted identifiers (names separated by a dot).
      SET p = INSTR(oi_obj_full_name, '.');
      -- If no dot is found, the entire full name is the object name.
      IF (p = 0) THEN
        SET out_obj_name = oi_obj_full_name;
        SET oi_obj_full_name = NULL;
      -- If a dot is found, the part before the dot is the object name.
      ELSE
        SET out_obj_name = LEFT(oi_obj_full_name, p - 1);
        -- Update the input full name to the part starting from the dot.
        SET oi_obj_full_name = SUBSTRING(oi_obj_full_name, p);
      END IF;
    END IF;
    -- Remove a leading dot if present in the remaining part of the full name.
    IF (LEFT(oi_obj_full_name, 1) = '.') THEN
      SET oi_obj_full_name = SUBSTRING(oi_obj_full_name, 2);
    END IF;
  END IF;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_URL_create
-- Description: Creates a new URL record if it doesn't exist and returns the shortened link.
CREATE PROCEDURE sp_url_create (
  IN in_url TEXT,
  IN in_query_string TEXT,
  IN in_id_user INT(10) UNSIGNED
)
BEGIN
  -- Insert the URL, query string, and user ID into the tb_urls table, ignoring duplicates.
  INSERT IGNORE tb_urls (full_url, query_string, id_user)
  VALUES (in_url, in_query_string, in_id_user);

  -- Select the shortened link (lnk) for the created or existing URL based on its hash.
  SELECT short_link
  FROM tb_urls u
  WHERE u.hash = fn_url_hash(REGEXP_REPLACE(in_url, '#$', ''), in_query_string);
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_URL_create_trigger
-- Description: Procedure called before inserting or updating the tb_urls table to generate the shortened link, hash, and description.
CREATE PROCEDURE sp_url_create_trigger (
  IN in_id_url INT(10) UNSIGNED,
  INOUT io_short_link VARCHAR(8),
  INOUT io_full_url TEXT,
  INOUT io_query_string TEXT,
  INOUT io_hash VARCHAR(45),
  INOUT io_description TEXT,
  INOUT io_id_user INT(10) UNSIGNED
)
BEGIN
  -- If the URL ID is NULL or 0, get the next auto-increment value for the tb_urls table.
  IF (in_id_url IS NULL OR in_id_url = 0) THEN
    SET in_id_url = (
      SELECT `AUTO_INCREMENT`
      FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_SCHEMA = 'db_Secure'
        AND TABLE_NAME = 'tb_urls'
    );
  END IF;
  -- Generate the shortened link by converting the URL ID to base-36.
  SET io_short_link = conv(in_id_url, 10, 36);

  -- If the description is empty, try to extract it from the URL fragment.
  IF (IFNULL(io_description, '') = '') THEN
    SET io_description = REGEXP_REPLACE(io_full_url, '.*#', '');
  END IF;
  -- If the description is still empty, set it to NULL.
  IF (io_description = '') THEN
    SET io_description = NULL;
  END IF;
  -- Remove any trailing '#' from the URL.
  SET io_full_url = REGEXP_REPLACE(io_full_url, '#$', '');

  -- Generate the hash for the URL and query string.
  SET io_hash = fn_url_hash(io_full_url, io_query_string);
  -- If the user ID is NULL, set it to the ID of the current logged-in user.
  IF (io_id_user IS NULL) THEN
    SET io_id_user = fn_get_id_user();
  END IF;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_Details
-- Description: Retrieves detailed information about a specific user.
CREATE PROCEDURE sp_user_details (
  IN in_id_user INT(10) UNSIGNED
)
SELECT
  u.user_login,
  u.is_active,
  u.id_domain,
  dm.domain_name AS domain,
  c.is_confirmed AS confirmation_status,
  c.updated_at AS confirmation_updated_at,
  d.registration_number,
  d.full_name,
  d.gender,
  d.manager_id,
  gm.user_login AS manager_user_login,
  gd.full_name AS manager_full_name,
  gd.gender AS manager_gender,
  gd.id_position AS manager_position_id,
  cp_manager.position_name AS manager_position_name,
  d.id_position AS position_id,
  cp_user.position_name AS position_name,
  i.ip_address,
  i.updated_at AS ip_updated_at,
  p.expiration_date AS password_expiration_date,
  p.updated_at AS password_updated_at
FROM tb_users u
LEFT JOIN tb_domains dm ON u.id_domain = dm.id_domain
LEFT JOIN tb_user_confirmations c ON u.id_user = c.id_user
LEFT JOIN tb_user_details d ON u.id_user = d.id_user
LEFT JOIN tb_users gm ON d.manager_id = gm.id_user
LEFT JOIN tb_user_details gd ON gm.id_user = gd.id_user
LEFT JOIN tb_positions cp_manager ON gd.id_position = cp_manager.id_position
LEFT JOIN tb_positions cp_user ON d.id_position = cp_user.id_position
LEFT JOIN tb_user_ips i ON u.id_user = i.id_user
LEFT JOIN tb_user_passwords p ON c.id_user = p.id_user
WHERE c.id_user = in_id_user//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_Details_Addresses
-- Description: Retrieves all addresses for a specific user.
CREATE PROCEDURE sp_user_details_addresses (
  IN in_id_user INT(10) UNSIGNED
)
SELECT *
FROM tb_user_addresses
WHERE id_user = in_id_user//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_Details_Emails
-- Description: Retrieves all email addresses for a specific user.
CREATE PROCEDURE sp_user_details_emails (
  IN in_id_user INT(10) UNSIGNED
)
SELECT *
FROM tb_user_emails
WHERE id_user = in_id_user//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_Details_Phones
-- Description: Retrieves all phone numbers for a specific user.
CREATE PROCEDURE sp_user_details_phones (
  IN in_id_user INT(10) UNSIGNED
)
SELECT *
FROM tb_user_phone_numbers
WHERE id_user = in_id_user//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_Details_Workers
-- Description: Retrieves all active users who report to a specific manager.
CREATE PROCEDURE sp_user_details_workers (
  IN in_id_user INT(10) UNSIGNED
)
SELECT
  u.user_login,
  d.*,
  g.id_group_user,
  g.group_user_name
FROM tb_user_details d
JOIN tb_users u ON d.id_user = u.id_user AND u.is_active
LEFT JOIN tb_users_x_group_users ug ON ug.id_user = u.id_user AND ug.is_main
LEFT JOIN tb_group_users g ON ug.id_group_user = g.id_group_user
WHERE d.manager_id = in_id_user//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_Detais_Groups
-- Description: Retrieves all groups that a specific user belongs to.
CREATE PROCEDURE sp_user_details_groups (
  IN in_id_user INT(10) UNSIGNED
)
SELECT g.*
FROM tb_users_x_group_users u
JOIN tb_group_users g USING (id_group_user)
WHERE u.id_user = in_id_user//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_Detais_Staff
-- Description: Retrieves the main group for a specific user, prioritizing certain group name patterns.
CREATE PROCEDURE sp_user_details_staff (
  IN in_id_user INT(10) UNSIGNED
)
SELECT *
FROM tb_users_x_group_users u
JOIN tb_group_users g USING (id_group_user)
WHERE u.id_user = in_id_user
ORDER BY
  u.is_main DESC,
  IF(g.group_user_name LIKE 'DEP_%', 0, IF(g.group_user_name LIKE 'DL_%', 1, 10)),
  IF(g.group_user_name REGEXP '(todos|_rh_|_hr_|Colaboradores)', 1, 0)
LIMIT 1//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_Info
-- Description: Retrieves basic information about a user, including domain, password expiration, confirmation status, IP, and token.
CREATE PROCEDURE sp_user_info (
  IN in_id_user INT(10) UNSIGNED,
  IN in_token CHAR(32)
)
BEGIN
  SELECT
    u.id_user,
    u.id_domain,
    d.domain_name AS domain,
    u.user_login,
    u.is_active,
    p.expiration_date,
    n.is_confirmed AS confirmation_status,
    i.ip_address,
    t.token,
    d.obs AS domain_obs
  FROM tb_users u
  LEFT JOIN tb_domains d ON u.id_domain = d.id_domain
  LEFT JOIN tb_user_passwords p ON u.id_user = p.id_user
  LEFT JOIN tb_user_ips i ON u.id_user = i.id_user
  LEFT JOIN tb_user_tokens t ON u.id_user = t.id_user
  LEFT JOIN tb_user_confirmations n ON u.id_user = n.id_user
  WHERE u.id_user = in_id_user
  ORDER BY IF(token = in_token, 0, 1)
  LIMIT 1;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_ListGrp
-- Description: Lists all active users belonging to a specific group.
CREATE PROCEDURE sp_user_list_group (
  IN in_id_group_user INT(10) UNSIGNED
)
BEGIN
  SELECT
    u.id_user,
    u.id_domain,
    d.domain_name AS domain,
    u.user_login,
    dd.full_name,
    dd.gender,
    dd.id_position
  FROM tb_users_x_group_users g
  JOIN tb_users u ON g.id_user = u.id_user AND u.is_active
  LEFT JOIN tb_domains d ON u.id_domain = d.id_domain
  LEFT JOIN tb_user_details dd ON u.id_user = dd.id_user
  WHERE g.id_group_user = in_id_group_user;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_LogOn
-- Description: Verifies the user's credentials and returns a token upon successful login.
CREATE PROCEDURE sp_user_log_on (
  IN in_domain VARCHAR(50),
  IN in_user VARCHAR(64),
  IN in_password VARCHAR(64),
  IN in_force_login TINYINT(1) UNSIGNED,
  IN in_token CHAR(32)
)
COMMENT 'Verifies user and password'
BEGIN
  -- Get the user ID based on the domain and username.
  DECLARE o_id_user INT(11) UNSIGNED DEFAULT fn_user_get_id(in_domain, in_user);
  -- Check the user's credentials and retrieve or generate a token.
  SET in_token = fn_user_check(o_id_user, in_password, in_force_login, in_token);

  -- If the token length is 1, it indicates an error.
  IF (LENGTH(in_token) = 1) THEN
    -- Select the user ID and error information.
    SELECT o_id_user AS id_user, NULL AS token, NULL AS first_logon, NULL AS last_logon, e.*
    FROM vw_user_logon_errors e
    WHERE e.logon_error = in_token;
  -- If the token length is greater than 1, login is successful.
  ELSE
    -- Select the user ID, token, and logon timestamps.
    SELECT t.id_user, t.token, t.created_at AS first_logon, t.updated_at AS last_logon, e.*
    FROM tb_user_tokens t, vw_user_logon_errors e
    WHERE t.id_user = o_id_user
      AND t.token = in_token
      AND e.logon_error = 0;
  END IF;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_User_LogOnTrErrors
-- Description: Retrieves logon error information based on the error code.
CREATE PROCEDURE sp_user_logon_trigger_errors (IN in_error TINYINT)
BEGIN
  -- Select all columns from the vw_user_logon_errors view for the given error code.
  SELECT *
  FROM vw_user_logon_errors
  WHERE logon_error = in_error;
END//

DELIMITER ;

DELIMITER //

-- Stored Procedure: sp_sign_error
-- Description: Generates a SQLSTATE signal to raise an error with a custom error number and message.
CREATE PROCEDURE sp_sign_error (
  IN in_errno INT UNSIGNED,
  IN in_error TEXT
)
SIGNAL SQLSTATE '45000'
SET MYSQL_ERRNO = in_errno,
MESSAGE_TEXT = in_error//

DELIMITER ;

DELIMITER //

-- Function: fn_CRUDS2Bin
-- Description: Converts a CRUDS integer value to a 5-character binary string.
CREATE FUNCTION fn_cruds_to_binary (in_cruds TINYINT(3) UNSIGNED)
RETURNS CHAR(5) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN LPAD(CONV(in_cruds, 10, 2), 5, '0')//

DELIMITER ;

DELIMITER //

-- Function: fn_decode
-- Description: Decodes a LONGBLOB value using the key phrase.
CREATE FUNCTION fn_decode (val LONGBLOB)
RETURNS LONGTEXT CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN IF(val IS NULL, NULL, decode(val, fn_key_phrase()))//

DELIMITER ;

DELIMITER //

-- Function: fn_encode
-- Description: Encodes a LONGTEXT value using the key phrase.
CREATE FUNCTION fn_encode (val LONGTEXT)
RETURNS LONGBLOB
DETERMINISTIC
RETURN IF(val IS NULL, NULL, encode(val, fn_key_phrase()))//

DELIMITER ;

DELIMITER //

-- Function: fn_File_Create
-- Description: Creates a new file record and returns its ID.
CREATE FUNCTION fn_file_create (in_file VARCHAR(255))
RETURNS INT(10) UNSIGNED
NO SQL
BEGIN
  -- Insert the file path into the tb_files table.
  INSERT tb_files (file_path)
  VALUES (in_file);
  -- Return the ID of the last inserted row.
  RETURN LAST_INSERT_ID();
END//

DELIMITER ;

DELIMITER //

-- Function: fn_File_GetId
-- Description: Retrieves the ID of a file based on its path.
CREATE FUNCTION fn_file_get_id (in_file VARCHAR(255))
RETURNS INT(10) UNSIGNED
NO SQL
RETURN (
  SELECT id_file
  FROM tb_files
  WHERE file_path = in_file
)//

DELIMITER ;

DELIMITER //

-- Function: fn_get_idFile
-- Description: Returns the currently set file ID from the session variable.
CREATE FUNCTION fn_get_id_file ()
RETURNS INT(10) UNSIGNED
RETURN IFNULL(@Secure_idFile, 0)//

DELIMITER ;

DELIMITER //

-- Function: fn_get_idStaff
-- Description: Retrieves the ID of the main group for a given user.
CREATE FUNCTION fn_get_id_staff (in_id_user INT UNSIGNED)
RETURNS INT(10) UNSIGNED
DETERMINISTIC
RETURN (
  SELECT g.id_group_user
  FROM db_secure.tb_users_x_group_users g
  WHERE g.id_user = in_id_user
    AND g.is_main
  LIMIT 1
)//

DELIMITER ;

DELIMITER //

-- Function: fn_get_idUser
-- Description: Returns the currently set user ID from the session variable.
CREATE FUNCTION fn_get_id_user ()
RETURNS INT(11) UNSIGNED
RETURN IFNULL(@Secure_idUser, 1)//

DELIMITER ;

DELIMITER //

-- Function: fn_get_NameUser
-- Description: Retrieves the name of a user, prioritizing the full name from tb_user_details.
CREATE FUNCTION fn_get_user_name (in_id_user INT UNSIGNED)
RETURNS VARCHAR(255) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN (
  SELECT IFNULL(ud.full_name, u.user_login)
  FROM db_secure.tb_users u
  LEFT JOIN db_secure.tb_user_details ud ON ud.id_user = u.id_user
  WHERE u.id_user = in_id_user
)//

DELIMITER ;

DELIMITER //

-- Function: fn_isAdmin
-- Description: Checks if a user belongs to the administrator group (group ID 2) and is not the default user (ID 1).
CREATE FUNCTION fn_is_admin (in_id_user INT UNSIGNED)
RETURNS TINYINT(1) UNSIGNED
RETURN (
  SELECT COUNT(1) q
  FROM tb_users_x_group_users g
  WHERE g.id_user = in_id_user
    AND g.id_group_user = 2
    AND g.id_user > 1
)//

DELIMITER ;

DELIMITER //

-- Function: fn_KeyPhrase
-- Description: Returns the secret key phrase used for encoding and decoding.
CREATE FUNCTION fn_key_phrase ()
RETURNS VARCHAR(255) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN 'hçoasdr@#$]jbnaasd56upa[sdfjç%aertbdklçzjsdfbvgp349q28'//

DELIMITER ;

DELIMITER //

-- Function: fn_L2Level
-- Description: Converts a tinyint representing a security level to an ENUM value.
CREATE FUNCTION fn_l2_level (in_l TINYINT(1) UNSIGNED)
RETURNS ENUM('Free', 'Secured', 'Paranoic') CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
BEGIN
  IF (in_l = 0) THEN
    RETURN 'Free';
  END IF;
  IF (in_l = 1) THEN
    RETURN 'Secured';
  END IF;
  RETURN 'Paranoic';
END//

DELIMITER ;

DELIMITER //

-- Function: fn_Permition_BuildCRUD
-- Description: Builds a CRUDS tinyint value from individual boolean permissions.
CREATE FUNCTION fn_permission_build_crud (
  in_c TINYINT(1) UNSIGNED,
  in_r TINYINT(1) UNSIGNED,
  in_u TINYINT(1) UNSIGNED,
  in_d TINYINT(1) UNSIGNED,
  in_s TINYINT(1) UNSIGNED
)
RETURNS TINYINT(2) UNSIGNED
DETERMINISTIC
RETURN in_c << 4 | in_r << 3 | in_u << 2 | in_d << 1 | in_s//

DELIMITER ;

DELIMITER //

-- Function: fn_Permition_CRUDS
-- Description: Determines the effective CRUDS permissions based on file level, file CRUDS, and group CRUDS.
CREATE FUNCTION fn_permission_cruds (
  in_level TINYINT(1) UNSIGNED,
  in_fcruds TINYINT(2) UNSIGNED,
  in_pcruds TINYINT(2) UNSIGNED
)
RETURNS TINYINT(2) UNSIGNED
NO SQL
DETERMINISTIC
BEGIN
  DECLARE o_cruds TINYINT(2) UNSIGNED;

  IF (in_level = 0) THEN
    RETURN 31 & in_fcruds;
  END IF;
  SET o_cruds = in_pcruds & in_fcruds;
  IF (in_level = 1) THEN
    RETURN o_cruds;
  END IF;
  IF (o_cruds = in_fcruds) THEN
    RETURN o_cruds;
  END IF;
  RETURN 0;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_Permition_File_by_File_idUser
-- Description: Retrieves the effective CRUDS permissions for a file for a given user based on the file path.
CREATE FUNCTION fn_permission_file_by_file_id_user (
  in_file VARCHAR(255),
  in_id_user INT UNSIGNED
)
RETURNS TINYINT(2) UNSIGNED
NO SQL
RETURN (
  SELECT fn_permission_cruds(f.security_level, f.cruds, BIT_OR(p.cruds)) AS cruds
  FROM tb_files f
  JOIN tb_files_x_group_files gf ON f.id_file = gf.id_file
  JOIN tb_permissions p ON gf.id_group_file = p.id_group_file
  LEFT JOIN tb_users_x_group_users gu ON p.id_group_user = gu.id_group_user
  LEFT JOIN tb_users u ON gu.id_user = u.id_user
  WHERE f.file_path = in_file
    AND (
      p.id_group_user = 1 OR
      (gu.id_user = in_id_user AND u.is_active) OR
      (p.id_group_user = 3 AND in_id_user != 0 AND (SELECT is_active FROM tb_users WHERE id_user = in_id_user))
    )
  GROUP BY f.id_file
)//

DELIMITER ;

DELIMITER //

-- Function: fn_Permition_File_by_idFile_idUser
-- Description: Retrieves the effective CRUDS permissions for a file for a given user based on the file ID.
CREATE FUNCTION fn_permission_file_by_id_file_id_user (
  in_id_file INT UNSIGNED,
  in_id_user INT UNSIGNED
)
RETURNS TINYINT(2) UNSIGNED
NO SQL
RETURN (
  SELECT fn_permission_cruds(f.security_level, f.cruds, BIT_OR(p.cruds)) AS cruds
  FROM tb_files f
  JOIN tb_files_x_group_files gf ON f.id_file = gf.id_file
  JOIN tb_permissions p ON gf.id_group_file = p.id_group_file
  LEFT JOIN tb_users_x_group_users gu ON p.id_group_user = gu.id_group_user
  LEFT JOIN tb_users u ON gu.id_user = u.id_user
  WHERE f.id_file = in_id_file
    AND (
      p.id_group_user = 1 OR
      (gu.id_user = in_id_user AND u.is_active) OR
      (p.id_group_user = 3 AND in_id_user != 0 AND (SELECT is_active FROM tb_users WHERE id_user = in_id_user))
    )
  GROUP BY f.id_file
)//

DELIMITER ;

DELIMITER //

-- Function: fn_URL_hash
-- Description: Generates a hash for a given URL and query string.
CREATE FUNCTION fn_url_hash (
  in_url TEXT,
  in_query_string TEXT
)
RETURNS VARCHAR(45) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
BEGIN
  DECLARE o_txt TEXT;
  SET o_txt = CONCAT_WS('?', in_url, in_query_string);
  RETURN CONCAT(md5(o_txt), '#', LENGTH(o_txt));
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_BuildToken
-- Description: Generates a unique token for a user and stores it in the tb_user_tokens table.
CREATE FUNCTION fn_user_build_token (in_id_user INT UNSIGNED)
RETURNS CHAR(32) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
BEGIN
  DECLARE o_token CHAR(32) DEFAULT REPLACE(UUID(), '-', '');
  INSERT IGNORE tb_user_tokens (id_user, token)
  VALUES (in_id_user, o_token);
  RETURN o_token;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_ChangePasswd
-- Description: Changes a user's password if the old password matches and returns a new token.
CREATE FUNCTION fn_user_change_passwd (
  in_id_user INT UNSIGNED,
  in_old_passwd VARCHAR(64),
  in_new_passwd VARCHAR(64)
)
RETURNS CHAR(32) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
NO SQL
COMMENT 'Changes the password of a user'
BEGIN
  UPDATE tb_user_passwords
  SET password = fn_encode(in_new_passwd)
  WHERE id_user = in_id_user
    AND in_old_passwd = fn_decode(password);

  RETURN fn_user_check(in_id_user, in_new_passwd, 1, '');
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_Check
-- Description: Checks if the provided password is correct for a user and manages the user's token.
CREATE FUNCTION fn_user_check (
  in_id_user INT UNSIGNED,
  in_passwd VARCHAR(64),
  in_force_login TINYINT(1) UNSIGNED,
  in_token CHAR(32)
)
RETURNS CHAR(32) CHARSET latin1 COLLATE latin1_swedish_ci
NO SQL
COMMENT 'Check if password is correct'
BEGIN
  -- Get the active status of the user.
  DECLARE o_active TINYINT UNSIGNED DEFAULT (SELECT is_active FROM tb_users u WHERE u.id_user = in_id_user);

  -- If the password is empty, return error code 1.
  IF (IFNULL(in_passwd, '') = '') THEN
    RETURN '1';
  -- If the user ID is NULL or 0, or the user is not found, return error code 2.
  ELSEIF (IFNULL(in_id_user, 0) = 0 OR o_active IS NULL) THEN
    RETURN '2';
  -- If the user is not active, return error code 3.
  ELSEIF (o_active != 1) THEN
    RETURN '3';
  -- If the user has exceeded login attempts, return error code 5.
  ELSEIF (fn_user_check_try_login(in_id_user)) THEN
    RETURN '5';
  -- If the provided password does not match the stored password, return error code 4.
  ELSEIF (IFNULL((
    SELECT id_user
    FROM tb_user_passwords p
    JOIN tb_users u USING (id_user)
    WHERE p.id_user = in_id_user
      AND fn_decode(p.password) = in_passwd
      AND u.is_active
  ), 0) = 0) THEN
    RETURN '4';
  ELSE
    -- Delete the user's record from the login attempts table upon successful login.
    DELETE FROM tb_user_login_attempts
    WHERE id_user = in_id_user;
    -- Check if the password has expired.
    IF (IFNULL((SELECT expiration_date FROM tb_user_passwords WHERE id_user = in_id_user), NOW()) < NOW()) THEN
      RETURN '6';
    END IF;
    -- Check the user's token.
    IF (NOT (fn_user_check_token(in_id_user, in_token))) THEN
      -- If the user is already logged in.
      IF (fn_user_is_logged(in_id_user)) THEN
        -- If multi-session is allowed.
        IF (@multiSession) THEN
          -- If no token is provided, generate a new one.
          IF (IFNULL(in_token, '') = '') THEN
            SET in_token = fn_user_build_token(in_id_user);
          END IF;
        -- If multi-session is not allowed.
        ELSE
          -- If forced login is enabled.
          IF (in_force_login) THEN
            -- Clear login attempts and logout all previous sessions.
            DELETE FROM tb_user_login_attempts
            WHERE id_user = in_id_user;
            SET in_token = fn_user_logout_all(in_id_user);
            -- Generate a new token.
            SET in_token = fn_user_build_token(in_id_user);
          -- If forced login is not enabled, return error code 8.
          ELSE
            RETURN '8';
          END IF;
        END IF;
      -- If the user is not logged in, generate a new token.
      ELSE
        SET in_token = fn_user_build_token(in_id_user);
      END IF;
    END IF;
  END IF;
  RETURN in_token;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_CheckToken
-- Description: Checks if a given token is valid for a user and updates its last used timestamp.
CREATE FUNCTION fn_user_check_token (
  in_id_user INT UNSIGNED,
  in_token CHAR(32)
)
RETURNS TINYINT(1) UNSIGNED
NO SQL
BEGIN
  -- Get the session expiration time in minutes.
  DECLARE o_expire_session INT(11) UNSIGNED DEFAULT IFNULL(@expiresSession, 15);
  DECLARE o_dt_update DATETIME;

  -- If the token is empty, return FALSE.
  IF (IFNULL(in_token, '') = '') THEN
    RETURN FALSE;
  END IF;
  -- Get the last update timestamp for the token.
  SET o_dt_update = (SELECT updated_at FROM tb_user_tokens WHERE id_user = in_id_user AND token = in_token);
  -- If the token is not found, return FALSE.
  IF (o_dt_update IS NULL) THEN
    RETURN FALSE;
  END IF;
  -- If the session expiration is 0 or the token is still within the valid time frame.
  IF (o_expire_session = 0 OR o_dt_update > DATE_SUB(NOW(), INTERVAL o_expire_session MINUTE)) THEN
    -- Update the last used timestamp of the token.
    UPDATE tb_user_tokens
    SET updated_at = NOW()
    WHERE id_user = in_id_user
      AND token = in_token;
    RETURN TRUE;
  -- If the token has expired, delete it and return FALSE.
  ELSE
    DELETE FROM tb_user_tokens
    WHERE id_user = in_id_user
      AND token = in_token;
    RETURN FALSE;
  END IF;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_CheckTryLogin
-- Description: Checks if a user can attempt to log in again based on the last failed attempt timestamp.
CREATE FUNCTION fn_user_check_try_login (in_id_user INT UNSIGNED)
RETURNS TINYINT(1) UNSIGNED
NO SQL
COMMENT 'Returns if the user can try to login again'
BEGIN
  -- Get the waiting time after a failed login attempt in seconds.
  DECLARE o_try_wait INT(11) UNSIGNED DEFAULT IFNULL(@tryWait, 10);
  -- Get the timestamp of the last login attempt.
  DECLARE o_dt_last_try TIMESTAMP DEFAULT IFNULL((SELECT updated_at FROM tb_user_login_attempts WHERE id_user = in_id_user), '1970-01-01 00:00:00');
  -- Check if the last attempt was within the waiting period.
  DECLARE o_out TINYINT(1) UNSIGNED DEFAULT o_dt_last_try > DATE_SUB(NOW(), INTERVAL o_try_wait SECOND);

  -- Update the last login attempt timestamp.
  REPLACE tb_user_login_attempts (id_user)
  VALUES (in_id_user);
  RETURN o_out;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_Create
-- Description: Creates a new user with the given domain, username, password, and email.
CREATE FUNCTION fn_user_create (
  in_domain VARCHAR(50),
  in_user VARCHAR(64),
  in_passwd VARCHAR(64),
  in_email VARCHAR(64)
)
RETURNS INT(10) UNSIGNED
COMMENT 'Creates a user'
BEGIN
  DECLARE o_id_user INT(10) UNSIGNED DEFAULT 0;

  -- If the username is empty, raise an error.
  IF (IFNULL(in_user, '') = '') THEN
    CALL sp_fail('Username empty');
  END IF;
  -- If both password and email are empty, raise an error.
  IF (IFNULL(in_passwd, '') = '' AND IFNULL(in_email, '') = '') THEN
    CALL sp_fail('Password and Email empty');
  END IF;
  -- Insert the new user into the tb_users table.
  INSERT tb_users (id_domain, user_login)
  VALUES (fn_user_get_id_domain(in_domain, TRUE), in_user);
  -- Get the ID of the newly inserted user.
  SET o_id_user = LAST_INSERT_ID();
  -- If the user was successfully inserted.
  IF (o_id_user) THEN
    -- If a password is provided, store it in tb_user_passwords.
    IF (IFNULL(in_passwd, '') != '') THEN
      INSERT IGNORE tb_user_passwords (id_user, password)
      VALUES (o_id_user, fn_encode(in_passwd));
    END IF;
    -- If an email is provided, store it in tb_user_emails.
    IF (IFNULL(in_email, '') != '') THEN
      INSERT IGNORE tb_user_emails (id_user, email)
      VALUES (o_id_user, in_email);
    END IF;
  END IF;

  RETURN o_id_user;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetEmails
-- Description: Retrieves a comma-separated list of email addresses for a given user.
CREATE FUNCTION fn_user_get_emails (in_id_user INT UNSIGNED)
RETURNS TEXT CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN (
  SELECT GROUP_CONCAT(s.email)
  FROM tb_user_emails s
  WHERE s.id_user = in_id_user
)//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetId
-- Description: Retrieves the ID of a user based on their domain and username.
CREATE FUNCTION fn_user_get_id (
  in_domain VARCHAR(50),
  in_user VARCHAR(64)
)
RETURNS INT(10) UNSIGNED
DETERMINISTIC
RETURN (
  SELECT u.id_user
  FROM tb_users u
  JOIN tb_domains d ON u.id_domain = d.id_domain AND d.domain_name = IFNULL(in_domain, '')
  WHERE u.user_login = in_user
)//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetIdCargo
-- Description: Retrieves the ID of a position (cargo) based on its name, attempting fuzzy matching if necessary.
CREATE FUNCTION fn_user_get_id_position (in_position VARCHAR(64))
RETURNS INT(11) UNSIGNED
BEGIN
  DECLARE o_position_short VARCHAR(64) DEFAULT SUBSTRING_INDEX(in_position, ' ', 1);
  DECLARE o_id_position INT(11) UNSIGNED DEFAULT (SELECT c.id_position FROM tb_positions c WHERE c.position_name = in_position);

  IF (o_id_position IS NULL) THEN
    SET o_id_position = (SELECT c.id_position FROM tb_positions c WHERE SOUNDEX(c.position_name) = SOUNDEX(in_position));
    IF (o_id_position IS NULL) THEN
      SET o_id_position = (SELECT c.id_position FROM tb_positions c WHERE c.position_name = o_position_short);
      IF (o_id_position IS NULL) THEN
        SET o_id_position = (SELECT c.id_position FROM tb_positions c WHERE SOUNDEX(c.position_name) = SOUNDEX(o_position_short));
        IF (o_id_position IS NULL) THEN
          INSERT IGNORE tb_positions (position_name)
          VALUES (in_position);
          SET o_id_position = LAST_INSERT_ID();
        END IF;
      END IF;
    END IF;
  END IF;
  RETURN o_id_position;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetIdDomain
-- Description: Retrieves the ID of a domain, creating it if it doesn't exist and the flag is set.
CREATE FUNCTION fn_user_get_id_domain (
  in_domain VARCHAR(50),
  in_create_if_not_exists TINYINT
)
RETURNS INT(10) UNSIGNED
DETERMINISTIC
BEGIN
  DECLARE o_id_domain INT(10) UNSIGNED;
  SET in_domain = IFNULL(in_domain, '');
  SET o_id_domain = (SELECT id_domain FROM tb_domains WHERE domain_name = in_domain);
  IF (o_id_domain IS NULL AND in_create_if_not_exists) THEN
    INSERT IGNORE tb_domains
    SET domain_name = in_domain;
    SET o_id_domain = LAST_INSERT_ID();
  END IF;
  RETURN o_id_domain;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetPassword
-- Description: Retrieves the decoded password for a given user.
CREATE FUNCTION fn_user_get_password (in_id_user INT UNSIGNED)
RETURNS VARCHAR(64) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN (
  SELECT fn_decode(p.password)
  FROM tb_user_passwords p
  WHERE p.id_user = in_id_user
  LIMIT 1
)//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetPhones
-- Description: Retrieves a comma-separated list of phone numbers for a given user.
CREATE FUNCTION fn_user_get_phones (in_id_user INT UNSIGNED)
RETURNS TEXT CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN (
  SELECT GROUP_CONCAT(s.phone_number)
  FROM tb_user_phone_numbers s
  WHERE s.id_user = in_id_user
)//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetRandNumber
-- Description: Generates a random numeric string of a specified length.
CREATE FUNCTION fn_user_get_rand_number (in_tam TINYINT UNSIGNED)
RETURNS VARCHAR(64) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
NO SQL
DETERMINISTIC
BEGIN
  DECLARE universe_char VARCHAR(255) DEFAULT '0123456789';
  DECLARE m INT UNSIGNED DEFAULT LENGTH(universe_char);
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE return_value VARCHAR(64) DEFAULT '';

  SET in_tam = GREATEST(IFNULL(in_tam, 10), 1);
  WHILE i < in_tam DO
    SET i = i + 1;
    SET return_value = CONCAT(return_value, SUBSTR(universe_char, FLOOR(RAND() * m) + 1, 1));
  END WHILE;
  RETURN return_value;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetRandPasswd
-- Description: Generates a random password string of a specified length with a mix of characters.
CREATE FUNCTION fn_user_get_random_password (in_tam TINYINT UNSIGNED)
RETURNS VARCHAR(64) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
NO SQL
DETERMINISTIC
BEGIN
  DECLARE universe_char VARCHAR(255) DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-+=!@#$%&*()[]{}';
  DECLARE passwd VARCHAR(64) DEFAULT '';
  DECLARE i INT DEFAULT 0;
  DECLARE m INT;

  SET in_tam = GREATEST(IFNULL(in_tam, 10), 3);
  SET m = LENGTH(universe_char);
  WHILE i < in_tam DO
    SET i = i + 1;
    SET passwd = CONCAT(passwd, SUBSTR(universe_char, FLOOR(RAND() * m) + 1, 1));
  END WHILE;
  RETURN passwd;
END//
DELIMITER ;

DELIMITER //

-- Function: fn_User_GetTkbin
-- Description: Retrieves a decoded token from the tb_user_search table (assuming a specific row).
CREATE FUNCTION fn_user_get_tkbin ()
RETURNS VARCHAR(64) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN (
  SELECT fn_decode(s.tk)
  FROM tb_user_search s
  WHERE s.i = 1
)//

DELIMITER ;

DELIMITER //

-- Function: fn_User_GetToken
-- Description: Retrieves the current token for a given user.
CREATE FUNCTION fn_user_get_token (in_id_user INT UNSIGNED)
RETURNS CHAR(32) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
DETERMINISTIC
RETURN (
  SELECT token
  FROM tb_user_tokens
  WHERE id_user = in_id_user
  LIMIT 1
)//

DELIMITER ;

DELIMITER //

-- Function: fn_User_IsActive
-- Description: Checks if a user is currently active.
CREATE FUNCTION fn_user_is_active (in_id_user INT UNSIGNED)
RETURNS TINYINT(1) UNSIGNED
DETERMINISTIC
RETURN (
  SELECT is_active
  FROM tb_users
  WHERE id_user = in_id_user
)//

DELIMITER ;

DELIMITER //

-- Function: fn_User_IsGestor
-- Description: Checks if a given user reports to a specific manager.
CREATE FUNCTION fn_user_is_manager (
  in_id_user INT UNSIGNED,
  in_id_manager INT UNSIGNED
)
RETURNS TINYINT(1) UNSIGNED
BEGIN
  -- Call the stored procedure to locate the top-level manager of the user.
  CALL sp_manager_locate(in_id_user, in_id_manager);
  -- Return 1 if a manager was found (in_idGestor is not NULL), 0 otherwise.
  RETURN IF(in_id_manager IS NULL, 0, 1);
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_IsLoged
-- Description: Checks if a user is currently logged in by verifying the existence of a non-expired token.
CREATE FUNCTION fn_user_is_logged (in_id_user INT UNSIGNED)
RETURNS TINYINT(1) UNSIGNED
DETERMINISTIC
BEGIN
  -- Get the session expiration time in minutes.
  DECLARE o_expire_session INT(11) UNSIGNED DEFAULT IFNULL(@expiresSession, 15);
  -- If the session expiration is not 0, delete expired tokens for the user.
  IF (o_expire_session != 0) THEN
    DELETE FROM tb_user_tokens
    WHERE id_user = in_id_user
      AND updated_at <= DATE_SUB(NOW(), INTERVAL o_expire_session MINUTE);
  END IF;
  -- Return the count of active tokens for the user. If greater than 0, the user is logged in.
  RETURN (SELECT COUNT(1) FROM tb_user_tokens WHERE id_user = in_id_user);
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_Logout
-- Description: Logs out a user by deleting their token(s).
CREATE FUNCTION fn_user_logout (
  in_id_user INT UNSIGNED,
  in_token CHAR(32)
)
RETURNS INT(10) UNSIGNED
DETERMINISTIC
BEGIN
  -- If no token is provided, delete all tokens for the user.
  IF (IFNULL(in_token, '') = '') THEN
    DELETE FROM tb_user_tokens
    WHERE id_user = in_id_user;
  -- If a token is provided, delete only that specific token for the user.
  ELSE
    DELETE FROM tb_user_tokens
    WHERE id_user = in_id_user
      AND token = in_token;
  END IF;
  -- Return the number of rows affected (deleted).
  RETURN ROW_COUNT();
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_LogoutAll
-- Description: Logs out a user from all sessions by deleting all their tokens.
CREATE FUNCTION fn_user_logout_all (in_id_user INT UNSIGNED)
RETURNS INT(10) UNSIGNED
DETERMINISTIC
BEGIN
  -- Delete all tokens associated with the given user ID.
  DELETE FROM tb_user_tokens
  WHERE id_user = in_id_user;
  -- Return the number of rows affected (deleted).
  RETURN ROW_COUNT();
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_SetMainGroup
-- Description: Sets the main group for a user based on a specific ordering logic.
CREATE FUNCTION fn_user_set_main_group (in_id_user INT UNSIGNED)
RETURNS INT(10) UNSIGNED
COMMENT 'return idGrpUsr main'
BEGIN
  DECLARE v_id INT UNSIGNED DEFAULT (
    SELECT g.id_group_user
    FROM tb_users_x_group_users gu
    JOIN tb_group_users g ON g.id_group_user = gu.id_group_user
    WHERE gu.id_user = in_id_user
    ORDER BY IF(g.group_user_name LIKE 'DEP%', 0,
               IF(g.group_user_name LIKE 'DL_%', LENGTH(g.group_user_name), 1000))
    LIMIT 1
  );
  -- Clear the is_main flag for all groups of the user except the selected one.
  UPDATE tb_users_x_group_users g
  SET g.is_main = NULL
  WHERE g.id_user = in_id_user
    AND g.id_group_user != v_id;
  -- Set the is_main flag to 1 for the selected main group.
  UPDATE tb_users_x_group_users g
  SET g.is_main = 1
  WHERE g.id_user = in_id_user
    AND g.id_group_user = v_id;

  RETURN v_id;
END//

DELIMITER ;

DELIMITER //

-- Function: fn_User_SetPasswd
-- Description: Sets a new password for a user and activates their account.
CREATE FUNCTION fn_user_set_passwd (
  in_id_user INT UNSIGNED,
  in_passwd VARCHAR(64)
)
RETURNS CHAR(32) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
NO SQL
COMMENT 'Changes the password of a user'
BEGIN
  -- Update the user's password.
  UPDATE tb_user_passwords
  SET password = in_passwd
  WHERE id_user = in_id_user;
  -- Activate the user account.
  UPDATE tb_users
  SET is_active = 1
  WHERE id_user = in_id_user;

  -- Return a new token for the user.
  RETURN fn_user_check(in_id_user, in_passwd, 1, '');
END//

DELIMITER ;

DELIMITER //

-- Event: ev_CleanToken
-- Description: Calls the pc_CleanToken stored procedure every minute.
CREATE EVENT `ev_cleantoken`
ON SCHEDULE EVERY 1 MINUTE
STARTS '2024-10-15 04:55:00'
ON COMPLETION PRESERVE
ENABLE
DO CALL sp_clean_token//

DELIMITER ;

DELIMITER //

-- Event: ev_rebuild_GrpUsr_Main
-- Description: Calls the pc_rebuild_GrpUsr_Main stored procedure every day at 19:00:00.
CREATE EVENT `ev_rebuild_grpusr_main`
ON SCHEDULE EVERY 1 DAY
STARTS '2022-07-22 19:00:00'
ON COMPLETION PRESERVE
ENABLE
DO CALL sp_rebuild_group_user_main//

DELIMITER ;

-- Trigger: tr_Attachment_before_del
-- Description: Prevents deletion of records from the tb_attachments table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_attachment_before_del` BEFORE DELETE ON `tb_attachments` FOR EACH ROW
CALL sp_sign_error(45000, 'Unsupported Delete')//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Attachment_before_ins
-- Description: Prevents insertion into the tb_attachments table if the base64 content is empty.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_attachment_before_ins` BEFORE INSERT ON `tb_attachments` FOR EACH ROW
IF IFNULL(NEW.base64, '') = '' THEN
  CALL sp_sign_error(45000, 'Content is empty');
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Attachment_before_upd
-- Description: Prevents updates to records in the tb_attachments table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_attachment_before_upd` BEFORE UPDATE ON `tb_attachments` FOR EACH ROW
CALL sp_sign_error(45000, 'Unsupported Update')//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Domain_before_ins
-- Description: Sets the updated_by_user_id field to the ID of the user performing the insert on the tb_domains table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_domain_before_ins` BEFORE INSERT ON `tb_domains` FOR EACH ROW
SET NEW.updated_by_user_id = fn_get_id_user()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Domain_before_upd
-- Description: Sets the updated_by_user_id field to the ID of the user performing the update on the tb_domains table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_domain_before_upd` BEFORE UPDATE ON `tb_domains` FOR EACH ROW
SET NEW.updated_by_user_id = fn_get_id_user()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Files_after_ins
-- Description: After inserting a new record into tb_Files, it inserts a corresponding record into tb_files_x_group_files with idGrpFile=1 if it doesn't exist.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_files_after_ins` AFTER INSERT ON `tb_files` FOR EACH ROW
INSERT IGNORE db_secure.tb_files_x_group_files
SET id_file = NEW.id_file,
    id_group_file = 1//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Files_before_ins
-- Description: Before inserting into tb_Files, it calls the pctr_Files_before stored procedure.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_files_before_ins` BEFORE INSERT ON `tb_files` FOR EACH ROW
CALL pctr_files_before(NEW.can_create, NEW.can_read, NEW.can_update, NEW.can_delete, NEW.can_special, NEW.cruds, NEW.updated_by_user_id)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Files_before_upd
-- Description: Before updating tb_Files, it calls the pctr_Files_before stored procedure.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_files_before_upd` BEFORE UPDATE ON `tb_files` FOR EACH ROW
CALL pctr_files_before(NEW.can_create, NEW.can_read, NEW.can_update, NEW.can_delete, NEW.can_special, NEW.cruds, NEW.updated_by_user_id)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Files_x_tb_group_files_before_ins
-- Description: Sets the updated_by_user_id field to the ID of the user performing the insert on the tb_files_x_group_files table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_files_x_tb_group_files_before_ins` BEFORE INSERT ON `tb_files_x_group_files` FOR EACH ROW
SET NEW.updated_by_user_id = fn_get_id_user()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Files_x_tb_group_files_before_upd
-- Description: Sets the updated_by_user_id field to the ID of the user performing the update on the tb_files_x_group_files table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_files_x_tb_group_files_before_upd` BEFORE UPDATE ON `tb_files_x_group_files` FOR EACH ROW
SET NEW.updated_by_user_id = fn_get_id_user()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_GrpFile_before_del
-- Description: Prevents deletion of records from the tb_group_files table if their ID is less than 4.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_grpfile_before_del` BEFORE DELETE ON `tb_group_files` FOR EACH ROW
IF (OLD.id_group_file < 4) THEN
  CALL sp_fail('Cannot be Deleted');
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_GrpFile_before_ins
-- Description: Sets the updated_by_user_id field to the ID of the user performing the insert on the tb_group_files table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_grpfile_before_ins` BEFORE INSERT ON `tb_group_files` FOR EACH ROW
BEGIN
  SET NEW.updated_by_user_id = fn_get_id_user();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_GrpFile_before_upd
-- Description: Sets the updated_by_user_id field to the ID of the user performing the update on the tb_group_files table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_grpfile_before_upd` BEFORE UPDATE ON `tb_group_files` FOR EACH ROW
BEGIN
  SET NEW.updated_by_user_id = fn_get_id_user();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_GrpUsr_before_del
-- Description: Prevents deletion of records from the tb_group_users table if their ID is less than 5.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_grpusr_before_del` BEFORE DELETE ON `tb_group_users` FOR EACH ROW
IF (OLD.id_group_user < 5) THEN
  CALL sp_fail('Cannot be deleted');
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_GrpUsr_before_ins
-- Description: Sets the updated_by_user_id field to the ID of the user performing the insert on the tb_group_users table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_grpusr_before_ins` BEFORE INSERT ON `tb_group_users` FOR EACH ROW
BEGIN
  SET NEW.updated_by_user_id = fn_get_id_user();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_GrpUsr_before_upd
-- Description: Sets the updated_by_user_id field to the ID of the user performing the update on the tb_group_users table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_grpusr_before_upd` BEFORE UPDATE ON `tb_group_users` FOR EACH ROW
BEGIN
  SET NEW.updated_by_user_id = fn_get_id_user();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Permitions_before_ins
-- Description: Sets the updated_by_user_id field and calculates the CRUDS value before inserting into the tb_Permissions table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_permitions_before_ins` BEFORE INSERT ON `tb_permissions` FOR EACH ROW
BEGIN
  SET NEW.updated_by_user_id = fn_get_id_user();
  SET NEW.cruds = fn_permission_build_crud(NEW.can_create, NEW.can_read, NEW.can_update, NEW.can_delete, NEW.can_special);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Permitions_before_upd
-- Description: Sets the updated_by_user_id field and calculates the CRUDS value before updating the tb_Permissions table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_permitions_before_upd` BEFORE UPDATE ON `tb_permissions` FOR EACH ROW
BEGIN
  SET NEW.updated_by_user_id = fn_get_id_user();
  SET NEW.cruds = fn_permission_build_crud(NEW.can_create, NEW.can_read, NEW.can_update, NEW.can_delete, NEW.can_special);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Positions_before_ins
-- Description: Sets the updated_by_user_id field to the ID of the user performing the insert on the tb_Positions table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_positions_before_ins` BEFORE INSERT ON `tb_positions` FOR EACH ROW
BEGIN
  SET NEW.updated_by_user_id = fn_get_id_user();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Positions_before_upd
-- Description: Sets the updated_by_user_id field to the ID of the user performing the update on the tb_Positions table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_positions_before_upd` BEFORE UPDATE ON `tb_positions` FOR EACH ROW
BEGIN
  SET NEW.updated_by_user_id = fn_get_id_user();
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_URLs_before_ins
-- Description: Calls the pc_URL_create_trigger stored procedure before inserting into the tb_URLs table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_urls_before_ins` BEFORE INSERT ON `tb_urls` FOR EACH ROW
BEGIN
  CALL sp_url_create_trigger(NEW.id_url, NEW.short_link, NEW.full_url, NEW.query_string, NEW.hash, NEW.description, NEW.id_user);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_URLs_before_upd
-- Description: Calls the pc_URL_create_trigger stored procedure before updating the tb_URLs table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_urls_before_upd` BEFORE UPDATE ON `tb_urls` FOR EACH ROW
BEGIN
  CALL sp_url_create_trigger(NEW.id_url, NEW.short_link, NEW.full_url, NEW.query_string, NEW.hash, NEW.description, NEW.id_user);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Users_after_ins
-- Description: After inserting a new user, it inserts default records into tb_user_passwords, tb_Users_Confirm, and tb_user_details, and adds domain-specific group for domain ID 2.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_users_after_ins` AFTER INSERT ON `tb_users` FOR EACH ROW
BEGIN
  INSERT IGNORE tb_user_passwords (id_user)
  VALUES (NEW.id_user);
  INSERT IGNORE tb_user_confirmations (id_user)
  VALUES (NEW.id_user);
  INSERT IGNORE tb_user_details (id_user, registration_number, full_name)
  VALUES (NEW.id_user, NEW.user_login, NEW.user_login);
  IF (NEW.id_domain = 2) THEN
    INSERT IGNORE tb_users_x_group_users (id_user, id_group_user)
    VALUES (NEW.id_user, 4);
  END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Users_before_ins
-- Description: Sets the updated_by_user_id field to the ID of the user performing the insert on the tb_Users table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_users_before_ins` BEFORE INSERT ON `tb_users` FOR EACH ROW
SET NEW.updated_by_user_id = fn_get_id_user()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Trigger: tr_Users_before_upd
-- Description: Sets the updated_by_user_id field to the ID of the user performing the update on the tb_Users table.
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_users_before_upd` BEFORE UPDATE ON `tb_users` FOR EACH ROW
SET NEW.updated_by_user_id = fn_get_id_user()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_users_detail_before_ins` BEFORE INSERT ON `tb_user_details` FOR EACH ROW CALL sptr_users_detail_before(NEW.registration_number, NEW.full_name, NEW.updated_by_user_id)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_users_detail_before_upd` BEFORE UPDATE ON `tb_user_details` FOR EACH ROW CALL sptr_users_detail_before(NEW.registration_number, NEW.full_name, NEW.updated_by_user_id)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_users_emails_before_upd` BEFORE UPDATE ON `tb_user_emails` FOR EACH ROW IF(NEW.email!=OLD.email)THEN
	SET NEW.is_confirmed=0;
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_users_passwd_before_ins` BEFORE INSERT ON `tb_user_passwords` FOR EACH ROW CALL sptr_users_passwd_before(NEW.password, NEW.expiration_date, NULL)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_users_passwd_before_upd` BEFORE UPDATE ON `tb_user_passwords` FOR EACH ROW CALL sptr_users_passwd_before(NEW.password, NEW.expiration_date, OLD.password)//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tr_users_x_tb_group_users_before_ins` BEFORE INSERT ON `tb_users_x_group_users` FOR EACH ROW IF(NEW.sequence IS NULL) THEN
  SET NEW.sequence = IFNULL((SELECT MAX(g.sequence) + 1 FROM tb_users_x_group_users g WHERE g.id_User = NEW.id_User), 0);
END IF//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `tr_users_x_tb_group_users_before_upd` BEFORE UPDATE ON `tb_users_x_group_users` FOR EACH ROW SET NEW.updated_by_user_id = fn_get_id_user()//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `vw_cbo_users` AS
SELECT
  d.id_user AS idUser,
  CONCAT(IF(u.is_active, '', '*'), d.full_name) AS Nome
FROM tb_users AS u
JOIN tb_user_details AS d
  ON d.id_user = u.id_user
ORDER BY
  u.is_active DESC,
  d.full_name;

CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `vw_userdomains` AS
SELECT
  d.id_domain AS idDomain,
  d.domain_name AS Domain,
  d.obs AS Obs,
  d.updated_at AS DtUpdate
FROM tb_domains AS d
WHERE
  d.id_domain <> 2;

CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `vw_users` AS
SELECT
  u.id_user AS idUser,
  u.id_domain AS idDomain,
  d.domain_name AS Domain,
  u.user_login AS User,
  ud.registration_number AS Matricula,
  ud.full_name AS Nome,
  g.id_group_user AS idGrpUsr,
  g.group_user_name AS Staff,
  u.is_active AS Ativo,
  uc.is_confirmed AS Confirm,
  ud.gender AS Sexo,
  ui.ip_address AS Ip,
  ud.manager_id AS idGestor,
  ge.full_name AS Gestor,
  ud.id_position AS idPosition,
  c.position_name AS Position,
  ud.birth_date AS Niver,
  ud.cost_center AS CentroCusto,
  ud.obs AS Obs,
  ui.updated_at AS LastAccess,
  u.updated_at AS DtUpdate,
  u.created_at AS DtGer
FROM tb_users AS u
LEFT JOIN tb_domains AS d
  ON u.id_domain = d.id_domain
LEFT JOIN tb_user_ips AS ui
  ON u.id_user = ui.id_user
LEFT JOIN tb_user_details AS ud
  ON u.id_user = ud.id_user
LEFT JOIN tb_user_confirmations AS uc
  ON u.id_user = uc.id_user
LEFT JOIN tb_users_x_group_users AS ug
  ON u.id_user = ug.id_user
  AND ug.is_main <> 0
LEFT JOIN tb_group_users AS g
  ON g.id_group_user = ug.id_group_user
LEFT JOIN tb_positions AS c
  ON c.id_position = ud.id_position
LEFT JOIN tb_user_details AS ge
  ON ge.id_user = ud.manager_id;

CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `vw_users_group_users` AS
SELECT
  u.id_user AS idUser,
  d.id_domain AS idDomain,
  d.domain_name AS Domain,
  u.user_login AS User,
  u.is_active AS Ativo,
  e.full_name AS Nome,
  e.gender AS Sexo,
  e.registration_number AS Matricula,
  e.obs AS ObsUser,
  u.updated_at AS DtUpdateUser,
  u.created_at AS DtGerUser,
  g.id_group_user AS idGrpUsr,
  g.group_user_name AS GrpUsr,
  g.email_dl AS DL,
  g.obs AS ObsGrpUser,
  g.is_ldap AS isLdapGrpUser,
  g.updated_at AS DtUpdateGrpUser,
  g.created_at AS DtGerGrpUser
FROM tb_users AS u
JOIN tb_domains AS d
  ON d.id_domain = u.id_domain
JOIN tb_user_details AS e
  ON e.id_user = u.id_user
JOIN tb_users_x_group_users AS gu
  ON gu.id_user = u.id_user
JOIN tb_group_users AS g
  ON g.id_group_user = gu.id_group_user;

CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `vw_users_rel` AS
SELECT
  u.id_user AS idUser,
  u.id_domain AS idDomain,
  u.user_login AS User,
  d.full_name AS Nome,
  d.gender AS Sexo,
  d.manager_id AS idGestor,
  d.id_position AS idPosition,
  d.registration_number AS Matricula,
  d.birth_date AS Niver,
  d.contract_start_date AS DtContrato,
  d.cost_center AS CentroCusto,
  d.assigned_site_id AS idSite_Lotado,
  d.located_site_id AS idSite_Locado,
  d.obs AS Obs,
  u.is_active AS Ativo,
  d.updated_by_user_id AS updated_by_user_id,
  d.updated_at AS DtUpdate,
  d.created_at AS DtGer,
  IF(d.id_user = du.manager_id, 0, IF(d.id_user = du.id_user, 1, IF(d.manager_id = du.id_user, 3, 2))) AS TipoRel
FROM tb_user_details AS du
JOIN tb_user_details AS d
  ON d.id_user = du.manager_id
  OR d.manager_id = du.manager_id
  OR d.manager_id = du.id_user
JOIN tb_users AS u
  ON u.id_user = d.id_user
WHERE
  du.id_user = fn_get_id_user();

CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `vw_user_logonerros` AS
SELECT 0 AS logonError, 'OK' AS messageError, 'Logon OK' AS userMessageError, 1 AS logonAction
UNION ALL
SELECT 1 AS logonError, 'Empty Password' AS messageError, 'Empty Password' AS userMessageError, 0 AS logonAction
UNION ALL
SELECT 2 AS logonError, 'Unknown user' AS messageError, 'Invalid user or password' AS userMessageError, 0 AS logonAction
UNION ALL
SELECT 3 AS logonError, 'Inactive User' AS messageError, 'Invalid user or password' AS userMessageError, 0 AS logonAction
UNION ALL
SELECT 4 AS logonError, 'Invalid Password' AS messageError, 'Invalid user or password' AS userMessageError, 0 AS logonAction
UNION ALL
SELECT 5 AS logonError, 'Over try Login' AS messageError, 'Over try Login, wait some seconds to try again' AS userMessageError, 1 AS logonAction
UNION ALL
SELECT 6 AS logonError, 'Expired Password' AS messageError, 'Expired Password. Change it' AS userMessageError, 0 AS logonAction
UNION ALL
SELECT 7 AS logonError, 'Error Change Password' AS messageError, 'Error Change Password ' AS userMessageError, 1 AS logonAction
UNION ALL
SELECT 8 AS logonError, 'User already Loged' AS messageError, 'User already Loged' AS userMessageError, 1 AS logonAction
UNION ALL
SELECT 9 AS logonError, 'Unknown error' AS messageError, 'Unknown error' AS userMessageError, 0 AS logonAction;


/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
