See `../README.md`, then:

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
