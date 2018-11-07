# system-config
My personal set of scripts to ease up setting up a new system and sync the settings between them.
Beware that the repo is still WIP, especially the readme file.

### Plasma + i3
To use Plasma and i3 together, Plasma's splash screen should be completely removed(the executable itself).
In my case it is

```
# mv /usr/bin/ksplashqml /usr/bin/ksplashqml.bak
```

Everything else required for the integration of Plasma with i3 is in the plasma stow directory and 
the i3 config after the `## Plasma fix` tag
