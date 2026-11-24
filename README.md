# PHP Apache Base Image for SeedDMS

This Docker image is specially customized to meet the installation needs of SeedDMS (Seed Document Management System). It provides the baseline for the image built in the [seeddms](https://github.com/andkrause/seeddms) repository.

## Overview

This image is based on the [php-apache](https://hub.docker.com/_/php#phpversion-apache) image and includes dependencies, PHP extensions, and Composer-installed PHP libraries for SeedDMS. WebDAV support is not included.

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
- **Development Libraries**: `zlib1g-dev`, `libpng-dev`, `libzip-dev`, `libxslt-dev`, `libonig-dev` for various PHP extensions

### PHP Extensions
- **Database**: `mysqli`, `pdo`, `pdo_mysql`, `pdo_pgsql` for MySQL and PostgreSQL support
- **Image Processing**: `gd` for image manipulation (`imagick` temporarily disabled, see Maintenance)
- **File Handling**: `zip` for archive operations
- **Data Processing**: `xsl` for XML/XSLT transformations, `intl` for internationalization, `mbstring` for multibyte string handling

### PHP Libraries (managed with Composer)
- `Log` - Logging functionality
- `Mail` - Email handling
- `Net_SMTP` - SMTP email transport

## Maintenance

- The PHP version is controlled by the `FROM` line and updated by Dependabot (`docker`).
- PHP libraries are declared in `composer.json` / `composer.lock` and updated by Dependabot (`composer`).
- Third-party extensions are installed with [PIE](https://github.com/php/pie); bundled extensions use `docker-php-ext-install`. PIE and Composer are only used at build time and are not part of the final image.
- Imagick is currently disabled: release 3.8.1 does not compile on PHP 8.6 (fixed upstream, [release pending](https://github.com/Imagick/imagick/issues/804)). The install step is commented out in the `Dockerfile` and can be re-enabled once a release is available.

## Usage

This image serves as a base image for SeedDMS installations. Build and use it as part of your SeedDMS deployment stack.

## Notes

The image is optimized for SeedDMS's document management requirements, including support for various document formats, image processing, and database backends (MySQL and PostgreSQL).
