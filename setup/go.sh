#!/usr/bin/env bash
set -e;

if ! docker info > /dev/null 2>&1; then
    echo -e "Docker is not running!" >&2;
    exit 1;
fi

echo '';
echo '🚀 [1mInitializer for Rubin Red Backend[0m';
echo 'This script will intialize Rubin Red and Docker into your computer.';
echo '';
if [ -t 1 ];
then
    echo '';
    read -n 1 -s -r -p "Press any key to continue";
    echo '';
else
    echo '';
fi

echo '';
echo '🚧 [1mDownload Setup files from remote[0m';
if [ -f "auth.json.dist" ]; then
unlink auth.json.dist
fi
curl -O https://raw.githubusercontent.com/workupsrl/rubinred-utilities-and-assets/main/setup/auth.json.dist
if [ -f "composer.json" ]; then
unlink composer.json
fi
curl -O https://raw.githubusercontent.com/workupsrl/rubinred-utilities-and-assets/5004c806c78da10a51f0ad70391d5db630bdd526/setup/composer.json
if [ -f "composer.lock" ]; then
unlink composer.lock
fi
curl -O https://raw.githubusercontent.com/workupsrl/rubinred-utilities-and-assets/6b4a0f96f8ea458ffb2c545455757af666603109/setup/composer.lock

if [ ! -f "auth.json" ]; then
echo '';
echo '🚧 [1mGithub Authentication Token[0m';
echo 'Insert your Github username:';
read -p ""
awk -v VAR=$REPLY "{sub(/YOUR-USERNAME/,VAR)}1" auth.json.dist > auth.json.temp
echo 'Insert your token (To get a token: https://github.com/settings/tokens/new - repo and admin:org permissions):';
read -p ""
awk -v VAR=$REPLY "{sub(/TOKEN-XYZ/,VAR)}1" auth.json.temp > auth.json
echo '';
unlink auth.json.temp
else
echo '';
echo '⚠️  [1mUsing Security Token Provided[0m';
echo '';
fi

echo '';
echo '🚧 [1mInstall dependencies and set up Laravel Sail[0m';
echo '';
docker run --rm \
    -v "$(pwd)":/opt \
    -w /opt \
    laravelsail/php81-composer:latest \
    bash -c "composer install --ignore-platform-reqs && php -r \"file_exists('.env') || copy('.env.devs', '.env');\" && php -r \"file_exists('phpstan.neon') || copy('phpstan.neon.dist', 'phpstan.neon');\" && php artisan key:generate --ansi && php artisan sail:install --devcontainer --with=mysql,redis,mailhog";

echo '';
echo '🚧 [1mAdjust Permissions[0m';
echo '';
    if sudo -n true 2>/dev/null; then
        sudo chown -R $USER: .
    else
        echo "Please provide your computer password so we can make some final adjustments to your application's permissions."
        echo ""
        sudo chown -R $USER: .
    fi;

echo '';
echo '🚧 [1mStart Laravel Sail[0m';
echo '';
./vendor/bin/sail up -d;

# echo '';
# echo '🚧 [1mPublishing Larastub Migrations[0m';
# ./vendor/bin/sail artisan vendor:publish --provider="Workup\Larastub\LarastubServiceProvider" --tag="migrations";

echo '';
echo '🚧 [1mRubin Red Setup[0m';
./vendor/bin/sail composer setup;

# echo "Finished setup...";
# rm "./init-devs";
# # Remove TODO in readme
# perl -0777 -pi -e 's/<!-- Rubin Red Installation START  -->.*<!-- Rubin Red Installation END  -->//gs' README.md

echo '';
echo '🍺 [1m Done![0m';
echo 'Rubin Red Backend application is ready! Run "./vendor/bin/sail composer demo" to try it!';
echo '';

unlink go.sh
