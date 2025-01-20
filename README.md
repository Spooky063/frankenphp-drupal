# FrankenPHP Drupal

This is a Docker image for [FrankenPHP](https://github.com/frankenphp/frankenphp) with [Drupal 11](https://www.drupal.org/project/drupal) installed.

## Testing

I added the library `xdebug` to the image with the `xdebug.mode=coverage` configuration for testing.  

The testing will be done with the database `sqlite` and the `SIMPLETEST_DB` environment variable. Only the Unit and Kernel tests are executed.

[!NOTE]  
> If you only want to execute tests from your custom module, it's not necessary to keep the installation of Drupal from the `Dockerfile`.

## Usage

### Build
```bash
make build
```

### Run
```bash
make run
```

The website will be available at http://localhost

### Shell
```bash
make ssh
```