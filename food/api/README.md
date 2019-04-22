See `../README.md`, then:

## Quickstart

```
# Run setup script
./bootstrap.sh

# enable localhost SSL
mkcert -install
(ipaddr=$(ipconfig getifaddr en0) && \
  cd ./config/cert/ && \
  mkcert \
  --cert-file localhost-cert.pem \
  --key-file localhost-key.pem \
  localhost 127.0.0.1 ::1 $ipaddr.xip.io \
  )

# iOS simulator
open "$(mkcert -CAROOT)"
# - drag .cer file onto sim
# - Settings > General > Profiles - install
# - Settings > General > About > Certificate Trust Settings - "Enable full..."
# source: # https://git.io/fj3Dc
open ./config/cert # then drag localhost-cert.pem onto sim
# - Settings > General > Profiles - install

cp .env.dev.example .env
heroku local:run rails db:setup
heroku local
```


## Deployment

```
heroku git:remote -r stag -a lenfestlab-food-stag
(cd ../..; git push stag --force `git subtree split --prefix food/api HEAD`:refs/heads/master)

heroku git:remote -r prod -a lenfestlab-food-prod
(cd ../..; git push prod --force `git subtree split --prefix food/api HEAD`:refs/heads/master)
```

## Replace local db w/ copy of remote database

```
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 heroku local:run -e .env.dev bundle exec rails db:drop && \
  heroku pg:pull DATABASE_URL lenfest_food_development -r prod
```
