See `../README.md`, then:

## Quickstart

```
# Run setup script
./bootstrap.sh

cp .env.dev.example .env
heroku local:run rails db:setup
heroku local
```

## Replace local db w/ copy of remote database

```
heroku local:run rails db:drop
heroku pg:pull DATABASE_URL lenfest_development -r prod
```

## Deployment

```
heroku git:remote -r prod -a lenfest-benji-production

(cd ..; git push prod --force `git subtree split --prefix api HEAD`:refs/heads/master)
```
