# Deployment Guide

This guide provides instructions for deploying the Social Media Scheduler application to a production environment.

## Prerequisites

Before deploying, ensure you have the following:

- A server running Linux (Ubuntu 20.04+ recommended)
- Ruby 3.1.0+ installed
- PostgreSQL 12+ installed
- Redis server installed
- Nginx or Apache web server
- SSL certificate for secure HTTPS connections

## Production Environment Setup

### 1. System Dependencies

Install system dependencies:

```bash
sudo apt-get update
sudo apt-get install -y build-essential libpq-dev nodejs npm git curl
sudo apt-get install -y redis-server
```

### 2. Ruby Installation

Install Ruby using rbenv or RVM:

```bash
# Using rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 3.1.0
rbenv global 3.1.0
```

### 3. PostgreSQL Setup

Install and configure PostgreSQL:

```bash
sudo apt-get install -y postgresql postgresql-contrib
sudo -u postgres createuser -s deploy
sudo -u postgres createdb social_media_scheduler_production
```

### 4. Application Deployment

#### Clone the Repository

```bash
git clone <repository-url> /var/www/social_media_scheduler
cd /var/www/social_media_scheduler
```

#### Install Dependencies

```bash
gem install bundler
bundle install --without development test
```

#### Configure Environment Variables

Create a `.env` file in the application root directory:

```
RAILS_ENV=production
DATABASE_URL=postgres://deploy:password@localhost/social_media_scheduler_production
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
SECRET_KEY_BASE=your_secret_key_base
```

Generate a secure `SECRET_KEY_BASE`:

```bash
bundle exec rails secret
```

#### Database Setup

```bash
bundle exec rails db:migrate RAILS_ENV=production
```

#### Precompile Assets

```bash
bundle exec rails assets:precompile RAILS_ENV=production
```

### 5. Web Server Configuration

#### Nginx Configuration

Create an Nginx configuration file:

```bash
sudo nano /etc/nginx/sites-available/social_media_scheduler
```

Add the following configuration:

```nginx
upstream puma {
  server unix:///var/www/social_media_scheduler/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name your-domain.com;
  
  # Redirect HTTP to HTTPS
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;
  server_name your-domain.com;
  
  ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
  
  root /var/www/social_media_scheduler/public;
  
  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }
  
  location / {
    proxy_pass http://puma;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_redirect off;
  }
  
  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

Enable the configuration:

```bash
sudo ln -s /etc/nginx/sites-available/social_media_scheduler /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 6. Application Server Setup

#### Puma Configuration

Create a Puma configuration file:

```bash
nano /var/www/social_media_scheduler/config/puma.rb
```

Add the following configuration:

```ruby
environment ENV.fetch("RAILS_ENV") { "production" }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

app_dir = File.expand_path("../..", __FILE__)
directory app_dir
bind "unix://#{app_dir}/tmp/sockets/puma.sock"
pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"
stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true

workers ENV.fetch("WEB_CONCURRENCY") { 2 }
preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

plugin :tmp_restart
```

Create necessary directories:

```bash
mkdir -p /var/www/social_media_scheduler/tmp/sockets
mkdir -p /var/www/social_media_scheduler/tmp/pids
```

### 7. Background Job Processing

#### Sidekiq Configuration

Create a Systemd service file for Sidekiq:

```bash
sudo nano /etc/systemd/system/sidekiq.service
```

Add the following configuration:

```
[Unit]
Description=sidekiq
After=syslog.target network.target

[Service]
Type=simple
WorkingDirectory=/var/www/social_media_scheduler
Environment=RAILS_ENV=production
ExecStart=/home/deploy/.rbenv/shims/bundle exec sidekiq -e production
User=deploy
Group=deploy
UMask=0002
RestartSec=1
Restart=on-failure
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=sidekiq

[Install]
WantedBy=multi-user.target
```

Enable and start the Sidekiq service:

```bash
sudo systemctl enable sidekiq
sudo systemctl start sidekiq
```

### 8. Puma Service Setup

Create a Systemd service file for Puma:

```bash
sudo nano /etc/systemd/system/puma.service
```

Add the following configuration:

```
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=deploy
Group=deploy
WorkingDirectory=/var/www/social_media_scheduler
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
ExecReload=/bin/kill -s USR1 $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start the Puma service:

```bash
sudo systemctl enable puma
sudo systemctl start puma
```

## LinkedIn OAuth Configuration

For the LinkedIn OAuth integration to work in production:

1. Go to the [LinkedIn Developer Portal](https://developer.linkedin.com/).
2. Update your application's Authorized Redirect URLs to include your production domain:
   ```
   https://your-domain.com/auth/linkedin/callback
   ```

## Maintenance

### Updating the Application

To update the application with new changes:

```bash
cd /var/www/social_media_scheduler
git pull origin main
bundle install --without development test
bundle exec rails db:migrate RAILS_ENV=production
bundle exec rails assets:precompile RAILS_ENV=production
sudo systemctl restart puma
sudo systemctl restart sidekiq
```

### Monitoring

Monitor the application logs:

```bash
tail -f /var/www/social_media_scheduler/log/production.log
tail -f /var/www/social_media_scheduler/log/puma.stdout.log
tail -f /var/www/social_media_scheduler/log/sidekiq.log
```

### Backup

Regularly backup your database:

```bash
pg_dump -U deploy social_media_scheduler_production > backup_$(date +%Y%m%d).sql
```

## Troubleshooting

### Application Not Starting

Check the Puma logs:

```bash
cat /var/www/social_media_scheduler/log/puma.stderr.log
```

### Background Jobs Not Processing

Check the Sidekiq logs:

```bash
cat /var/www/social_media_scheduler/log/sidekiq.log
```

Verify Redis is running:

```bash
sudo systemctl status redis-server
```

### Database Connection Issues

Check the database configuration:

```bash
cat /var/www/social_media_scheduler/config/database.yml
```

Verify PostgreSQL is running:

```bash
sudo systemctl status postgresql
```

