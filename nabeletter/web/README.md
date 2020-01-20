```

## Setup

# Run setup script
bash ./scripts/bootstrap.sh

# copy/edit local env vars
cp .env.dev.example .env.dev

# run locally
herokou local -f Procfile.dev


## Deployment

```
heroku git:remote -r prod -a lenfestlab-nabeletter-prod
(cd ../..; git push prod --force `git subtree split --prefix nabeletter/web HEAD`:refs/heads/master)
```
