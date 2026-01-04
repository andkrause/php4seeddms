# PHP Apache Base Image for SeedDMS

This Docker image is specially customized to meet the installation needs of SeedDMS (Seed Document Management System). It provides the baseline for the image built in the [seeddms](https://github.com/andkrause/seeddms) repository.

## Overview

This image is based on the lastest available [php-apache](https://hub.docker.com/_/php#phpversion-apache) version and includes all the necessary dependencies, PHP extensions, and PEAR packages required for a complete SeedDMS installation.

## Included Components

### System Packages
- **Database Support**: `libpq-dev` for PostgreSQL database connectivity
- **Image Processing**: `libmagickwand-dev` and `imagemagick` for image manipulation
- **Document Processing**: 
  - `poppler-utils` for PDF processing
  - `catdoc` for Microsoft Word document conversion
  - `xpdf` for PDF text extraction
  - `html2text` for HTML to text conversion
  - `docx2txt` for DOCX file processing
  - `id3` for audio file metadata
- **Development Libraries**: `zlib1g-dev`, `libpng-dev`, `libzip-dev`, `libxslt-dev` for various PHP extensions

### PHP Extensions
- **Database**: `mysqli`, `pdo`, `pdo_mysql`, `pdo_pgsql` for MySQL and PostgreSQL support
- **Image Processing**: `gd` and `imagick` for image manipulation
- **File Handling**: `zip` for archive operations
- **Data Processing**: `xsl` for XML/XSLT transformations, `intl` for internationalization

### PEAR Packages
- `Log` - Logging functionality
- `Mail` - Email handling
- `Net_SMTP` - SMTP email transport
- `HTTP_WebDAV_Server-1.0.0RC8` - WebDAV server capabilities

## Usage

This image serves as a base image for SeedDMS installations. Build and use it as part of your SeedDMS deployment stack.

## Notes

The image is optimized for SeedDMS's document management requirements, including support for various document formats, image processing, and database backends (MySQL and PostgreSQL).

