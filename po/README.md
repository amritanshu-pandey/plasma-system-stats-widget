# Translations

`plasma_applet_in.amritanshu.systemstats.pot` is the template with all
user-visible strings. Each translation is a `<language>.po` file in this
folder, for example `de.po`.

Start a new translation:

```sh
msginit --locale=de --input=plasma_applet_in.amritanshu.systemstats.pot --output-file=de.po
```

Update all translations after strings change:

```sh
make update-po
```

`make install` and `make plasmoid` compile the `.po` files into the package.
