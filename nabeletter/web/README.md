```
## Setup

# Run setup script
bash ./scripts/bootstrap.sh

# enable localhost SSL
mkcert -install
(ipaddr=$(ipconfig getifaddr en0) && \
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


## Deployment

```
heroku git:remote -r prod -a lenfestlab-nabeletter-prod
(cd ../..; git push prod --force `git subtree split --prefix nabeletter/web HEAD`:refs/heads/master)

heroku git:remote -r stag -a lenfestlab-nabeletter-stag
(cd ../..; git push stag --force `git subtree split --prefix nabeletter/web HEAD`:refs/heads/master)
```
