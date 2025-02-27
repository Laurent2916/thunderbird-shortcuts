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
      linear = lib.genShortcut {
        inherit pkgs;
        name = "Linear";
        url = "https://linear.app/";
        logo = pkgs.writeText "logo.svg" ''
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" width="200" height="200" viewBox="0 0 100 100"><path fill="#fff" d="M1.22541 61.5228c-.2225-.9485.90748-1.5459 1.59638-.857L39.3342 97.1782c.6889.6889.0915 1.8189-.857 1.5964C20.0515 94.4522 5.54779 79.9485 1.22541 61.5228ZM.00189135 46.8891c-.01764375.2833.08887215.5599.28957165.7606L52.3503 99.7085c.2007.2007.4773.3075.7606.2896 2.3692-.1476 4.6938-.46 6.9624-.9259.7645-.157 1.0301-1.0963.4782-1.6481L2.57595 39.4485c-.55186-.5519-1.49117-.2863-1.648174.4782-.465915 2.2686-.77832 4.5932-.92588465 6.9624ZM4.21093 29.7054c-.16649.3738-.08169.8106.20765 1.1l64.77602 64.776c.2894.2894.7262.3742 1.1.2077 1.7861-.7956 3.5171-1.6927 5.1855-2.684.5521-.328.6373-1.0867.1832-1.5407L8.43566 24.3367c-.45409-.4541-1.21271-.3689-1.54074.1832-.99132 1.6684-1.88843 3.3994-2.68399 5.1855ZM12.6587 18.074c-.3701-.3701-.393-.9637-.0443-1.3541C21.7795 6.45931 35.1114 0 49.9519 0 77.5927 0 100 22.4073 100 50.0481c0 14.8405-6.4593 28.1724-16.7199 37.3375-.3903.3487-.984.3258-1.3542-.0443L12.6587 18.074Z"/></svg>
        '';
      };
    });
  };
}
