See `../README.md`, then:

## Quickstart

```
# Run setup script
./bootstrap.sh


# Use XcodeGen to generate xcode project from ./project.yml
# https://github.com/yonaskolb/XcodeGen
# First, edit secrets variables with your private/local values
cp project-secrets.example.yml project-secrets.yml

# and copy/symlink firebase environment files
ln -s /keybase/team/lenfest.lab/food/developer/ios/firebase

mint run xcodegen

# Open the project in Xcode, hit build
open *.xcodeproj
```

