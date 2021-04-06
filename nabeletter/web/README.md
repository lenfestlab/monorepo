## Setup

```
# Run setup script
bash ./scripts/bootstrap.sh

# enable localhost SSL
mkcert -install
(ipaddr=$(ipconfig getifaddr en1) && \
  cd ./config/cert/ && \
  mkcert \
  --cert-file localhost-cert.pem \
  --key-file localhost-key.pem \
  localhost 127.0.0.1 ::1 $ipaddr.xip.io \
  )

# copy/edit local env vars
cp .env.dev.example .env.dev

# run locally
heroku local -e .env.dev web=1,webpacker=1,log=1
open https://localhost:3443
```


## Deployment

```
heroku git:remote -r prod -a lenfestlab-nabeletter-prod
(cd ../..; git push prod --force `git subtree split --prefix nabeletter/web HEAD`:refs/heads/master)

heroku git:remote -r stag -a lenfestlab-nabeletter-stag
(cd ../..; git push stag --force `git subtree split --prefix nabeletter/web HEAD`:refs/heads/master)
```

## Replace local db w/ copy of remote database

```
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 heroku local:run -e .env.dev bundle exec rails db:drop && \
  heroku pg:pull DATABASE_URL nabeletter_development -r prod
```

## Replace stag db w/ a copy of your local db

```
heroku pg:reset -r stag
heroku pg:push nabeletter_development DATABASE_URL -r stag
```
