See `../README.md`, then:

## Quickstart

```
# Run setup script
./bootstrap.sh

# Use XcodeGen to generate xcode project from ./project.yml
# https://github.com/yonaskolb/XcodeGen
# First edit secrets variables with your private/local values
cp project-secrets.example.yml project-secrets.yml
mint run xcodegen

# Open the project in Xcode, hit build
open *.xcodeproj
```

## Deployment

```
cp .env.example .env # edit .env with correct values
bundle exec fastlane ios beta
```
