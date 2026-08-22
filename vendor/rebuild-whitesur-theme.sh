#!/bin/sh
# Rebuild the WhiteSur GTK/Kvantum/Firefox theme from the vendored submodules
# (vendor/WhiteSur-gtk-theme, vendor/WhiteSur-kde) into the chezmoi source tree, so the result
# is a normal chezmoi-managed dotfile tree -- reviewable with `jj diff` / `chezmoi diff`, applied
# declaratively, no build tools needed on machines that just run `chezmoi apply`.
#
# Run this by hand after bumping either submodule, then `chezmoi apply` and commit.
#
# Hand-rolled from vendor/WhiteSur-gtk-theme's libs/lib-install.sh (install_theemy) and
# vendor/WhiteSur-kde's/other/firefox's own layout, instead of calling their install.sh/tweaks.sh:
# those also carry distro detection, sudo dependency-install fallbacks, and Plasma/GNOME/Monterey
# assets this Hyprland + qt6ct + Kvantum + Firefox setup never uses.

set -e

src="$(chezmoi source-path)"
vendor="$src/vendor"
gtk_src="$vendor/WhiteSur-gtk-theme/src"
firefox_src="$vendor/WhiteSur-gtk-theme/other/firefox"
kvantum_src="$vendor/WhiteSur-kde/Kvantum/WhiteSur"
sassc_opt="-t expanded"

###############################################################################
#                                   PATCHES                                   #
###############################################################################
# Our own tweaks on top of the vendored submodules, kept as patches (paths relative to vendor/)
# instead of hand-edited so a submodule bump doesn't silently drop them. -N/--forward skips a
# patch that's already applied, so re-running this script is idempotent.

for patch_file in "$vendor"/patches/*.patch; do
  [ -e "$patch_file" ] || continue
  # A reverse dry-run succeeding means the patched state is already there (checkout left over
  # from a previous run of this script) -- skip it, applying again would just fail/no-op noisily.
  # Otherwise actually apply it (not dry-run): if the submodule has drifted enough upstream that
  # the patch no longer applies cleanly, this must fail loudly (via set -e) instead of being
  # silently skipped like a forward --dry-run check would do (can't tell "already applied" apart
  # from "no longer applies").
  if patch -p1 -R --dry-run -s -d "$vendor" < "$patch_file" >/dev/null 2>&1; then
    continue
  fi
  echo "Applying $patch_file ..." >&2
  patch -p1 -N -d "$vendor" < "$patch_file"
done

###############################################################################
#                                  GTK THEME                                  #
###############################################################################
# Only the GTK 2.0/3.0/4.0 pieces are built (all that dot_gtkrc-2.0, gtk-3.0/settings.ini and
# gtk-4.0/settings.ini need) -- Cinnamon, xfwm4, metacity, labwc and plank assets are skipped.

name="WhiteSur-Dark"
gtk_target="$src/dot_themes/exact_$name"

rm -rf "$gtk_target"
mkdir -p "$gtk_target"

cat > "$gtk_target/index.theme" <<EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=$name
Comment=A MacOS BigSur like Gtk+ theme based on Elegant Design
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=$name
MetacityTheme=$name
IconTheme=WhiteSur-Dark
CursorTheme=WhiteSur-cursors
ButtonLayout=close,minimize,maximize:menu
EOF

## GTK 2.0 (legacy, used by .gtkrc-2.0)
mkdir -p "$gtk_target/gtk-2.0"
cp "$gtk_src/main/gtk-2.0/gtkrc-Dark" "$gtk_target/gtk-2.0/gtkrc"
cp "$gtk_src/main/gtk-2.0/menubar-toolbar-Dark.rc" "$gtk_target/gtk-2.0/menubar-toolbar.rc"
cp "$gtk_src"/main/gtk-2.0/common/*.rc "$gtk_target/gtk-2.0/"
cp -r "$gtk_src/assets/gtk-2.0/assets-common-Dark" "$gtk_target/gtk-2.0/assets"
cp "$gtk_src"/assets/gtk-2.0/assets-Dark/*.png "$gtk_target/gtk-2.0/assets/"

build_gtk() {
  gtk_version="$1"
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT

  cp -r "$gtk_src/assets/gtk/common-assets/assets" "$tmp"
  cp "$gtk_src"/assets/gtk/common-assets/sidebar-assets/*.png "$tmp/assets/"
  cp -r "$gtk_src/assets/gtk/scalable" "$tmp/assets"
  cp -r "$gtk_src/assets/gtk/windows-assets/titlebutton" "$tmp/windows-assets"

  sassc $sassc_opt "$gtk_src/main/$gtk_version/gtk-Dark.scss" "$tmp/gtk.css"
  sassc $sassc_opt "$gtk_src/main/$gtk_version/gtk-Dark.scss" "$tmp/gtk-dark.css"

  mkdir -p "$gtk_target/$gtk_version"
  cp "$gtk_src/assets/gtk/thumbnails/thumbnail-Dark.png" "$gtk_target/$gtk_version/thumbnail.png"
  echo '@import url("resource:///org/gnome/theme/gtk.css");' > "$gtk_target/$gtk_version/gtk.css"
  echo '@import url("resource:///org/gnome/theme/gtk-dark.css");' > "$gtk_target/$gtk_version/gtk-dark.css"
  glib-compile-resources --sourcedir="$tmp" --target="$gtk_target/$gtk_version/gtk.gresource" "$gtk_src/main/$gtk_version/gtk.gresource.xml"

  rm -rf "$tmp"
  trap - EXIT
}

build_gtk gtk-3.0
build_gtk gtk-4.0

###############################################################################
#                                KVANTUM THEME                                #
###############################################################################
# Just the Kvantum SVG theme, not the rest of WhiteSur-kde's Plasma-specific assets
# (desktoptheme, look-and-feel, sddm, latte-dock), which don't apply to this Hyprland setup.

kvantum_target="$src/dot_config/Kvantum/exact_WhiteSur"
rm -rf "$kvantum_target"
cp -r "$kvantum_src" "$kvantum_target"

###############################################################################
#                               FIREFOX THEME                                 #
###############################################################################
# Default WhiteSur variant ("./tweaks.sh -f" in upstream terms). Lives at
# ~/.mozilla/firefox/firefox-themes, symlinked into each profile by
# run_onchange_symlink-whitesur-firefox-theme.sh.tmpl (profile dirs have random names chezmoi
# can't target directly, so that last hop stays a plain symlink instead of a managed dotfile).

firefox_target="$src/private_dot_mozilla/private_firefox/exact_firefox-themes"
rm -rf "$firefox_target"
mkdir -p "$firefox_target"

cp -r "$firefox_src/WhiteSur" "$firefox_target/"
cp -r "$firefox_src/common/icons" "$firefox_src/common/pages" "$firefox_target/WhiteSur/"
cp -r "$firefox_src/common/titlebuttons" "$firefox_target/WhiteSur/"
cp "$firefox_src"/common/*.css "$firefox_target/WhiteSur/"
cp "$firefox_src"/common/parts/*.css "$firefox_target/WhiteSur/parts/"
cp "$firefox_src/userChrome-WhiteSur.css" "$firefox_target/userChrome.css"
cp "$firefox_src/userContent-WhiteSur.css" "$firefox_target/userContent.css"

# Prefs the theme needs (CSD, rounded corners, etc). This file is symlinked in as a profile's
# user.js, which Firefox force-applies every startup, overriding prefs.js/about:config.
cat > "$firefox_target/user.js" <<'EOF'
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.tabs.drawInTitlebar", true);
user_pref("browser.uidensity", 0);
user_pref("layers.acceleration.force-enabled", true);
user_pref("mozilla.widget.use-argb-visuals", true);
user_pref("widget.gtk.rounded-bottom-corners.enabled", true);
user_pref("svg.context-properties.content.enabled", true);
EOF

echo "Rebuilt into $gtk_target, $kvantum_target and $firefox_target." >&2
echo "Run 'chezmoi apply' to place them, then commit with jj." >&2
