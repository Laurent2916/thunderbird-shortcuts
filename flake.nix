{
  description = "Thunderbird shortcut extensions";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    systems = {
      url = "github:nix-systems/default";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs
      (import inputs.systems)
      (system: function nixpkgs.legacyPackages.${system});
  in rec {
    lib = {
      getSlug = string: sep:
        inputs.nixpkgs.lib.toLower (
          inputs.nixpkgs.lib.strings.concatStringsSep sep (
            inputs.nixpkgs.lib.strings.splitString " " string
          )
        );

      genShortcut = {
        pkgs,
        name,
        url,
        logo,
        ...
      }: let
        slug_hyphen = lib.getSlug name "-";
        slug_underscore = lib.getSlug name "_";
        id = "${slug_hyphen}.thunderbird.shortcut";
      in
        pkgs.stdenvNoCC.mkDerivation {
          name = id;
          dontUnpack = true;

          # https://webextension-api.thunderbird.net/en/128-esr-mv2/spaces.html#create-name-defaulturl-buttonproperties
          script_file = pkgs.writeText "script.js" ''
            browser.spaces.create(
              "${slug_underscore}",
              "${url}",
              {
                title: "${name}",
                defaultIcons: "logo.svg"
              }
            )
          '';

          # https://developer.thunderbird.net/add-ons/mailextensions/supported-manifest-keys
          manifest_file = pkgs.writeText "manifest.json" ''
            {
              "manifest_version": 2,
              "name": "Shortcut - ${name}",
              "description": "Shortcut to ${name}.",
              "version": "1.0.0",
              "author": "Laureηt",
              "browser_specific_settings": {
                "gecko": {
                  "id": "@${id}",
                  "strict_min_version": "106.0"
                }
              },
              "icons": {
                "32": "logo.svg"
              },
              "background": {
                "scripts": [
                  "script.js"
                ]
              }
            }
          '';

          buildInputs = [
            pkgs.minify
            pkgs.zip
          ];

          installPhase = ''
            cp ${logo} logo.svg
            cp $script_file script.js
            cp $manifest_file manifest.json
            minify logo.svg -o logo.svg
            minify script.js -o script.js
            minify manifest.json -o manifest.json

            zip -j @${id}.xpi logo.svg manifest.json script.js

            dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
            mkdir -p "$dst"
            install -v -m644 @${id}.xpi $dst/@${id}.xpi
          '';
        };
    };

    packages = forAllSystems (pkgs: {
      youtube-music = lib.genShortcut {
        inherit pkgs;
        name = "Youtube Music";
        url = "https://music.youtube.com/";
        logo = pkgs.fetchurl {
          url = "https://upload.wikimedia.org/wikipedia/commons/6/6a/Youtube_Music_icon.svg";
          sha256 = "sha256-K/up+bdoIXa5ltb1H4XKO1EnLggr/Z+H9jzukfX8jQs=";
        };
      };
      finegrain-slack = lib.genShortcut {
        inherit pkgs;
        name = "Finegrain Slack";
        url = "https://finegrain-ai.slack.com/";
        logo = pkgs.fetchurl {
          url = "https://upload.wikimedia.org/wikipedia/commons/d/d5/Slack_icon_2019.svg";
          sha256 = "sha256-FxYEd6R1FmrQVW4AKOOwvQY01wwC57kgwEpEKeoYSrM";
        };
      };
      discord = lib.genShortcut {
        inherit pkgs;
        name = "Discord";
        url = "https://discord.com/channels/@me";
        logo = pkgs.fetchurl {
          url = "https://upload.wikimedia.org/wikipedia/fr/4/4f/Discord_Logo_sans_texte.svg";
          sha256 = "sha256-fyh2K4xqb/xx1G9CocFagRLLtSu/x7jze5wITjEiTvk=";
        };
      };
      element = lib.genShortcut {
        inherit pkgs;
        name = "Element";
        url = "https://app.element.io/";
        logo = pkgs.fetchurl {
          url = "https://upload.wikimedia.org/wikipedia/commons/c/cb/Element_%28software%29_logo.svg";
          sha256 = "sha256-xj/SnGWfsaBbEJVi1fBM7HgIcNI1xH6b/OWtqXIzjq8=";
        };
      };
    });
  };
}
