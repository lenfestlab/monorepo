## Deployment

```
heroku git:remote -r screenie-prod -a lenfestlab-screenie-prod
(cd ../..; git push screenie-prod --force `git subtree split --prefix nabeletter/screenie HEAD`:refs/heads/master)
```
