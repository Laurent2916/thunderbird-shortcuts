# Thunderbird shortcuts

Small addons to add URL shortcuts to Thunderbird.

## Usage

### Build with nix (flakes)

`flake.nix` already contains some examples, you can build them like so:

```shell
nix build .#youtube-music
nix build .#discord
...
```

### Use with nix (flakes)

You can also use the shortcuts directly in your own flakes:

1. Add this flake as an input to your flake:

```nix
# flake.nix
{
  inputs = {
    thunderbird-shortcuts = {
      url = "github:Laurent2916/thunderbird-shortcuts";
      inputs.nixpkgs.follows = "nixpkgs";  # optional
      inputs.systems.follows = "systems";  # optional
    };
  };
}
```

2. You can then use the provided `package` and `lib`, for example with home-manager and thunderbird:

```nix
{system, pkgs, thunderbird-shortcuts, ...}: {
  programs.thunderbird = {
    enable = true;
    profiles = {
      my_profile = {
        extensions = [
          thunderbird-shortcuts.packages."${system}".youtube-music
          thunderbird-shortcuts.packages."${system}".discord
          (
            thunderbird-shortcuts.lib.genShortcut {
              inherit pkgs;
              name = "arXiv";
              url = "https://arxiv.org/";
              logo = pkgs.fetchurl {
                url = "https://upload.wikimedia.org/wikipedia/commons/b/bc/ArXiv_logo_2022.svg";
                sha256 = "sha256-Lc2IQPRoWcXim13yCxX5iqhyVOCeze2ywRoe1QKFBPw=";
              };
            };
          )
        ];
      };
    };
  };
}
```

## FAQ

### Ok but why?

I always have Thunderbird opened (for emails and RSS),
I also always have "persistent" tabs opened in my browser (e.g. Slack, YT Music, etc.),
so why not have them in the same place?

### How to get notifications?

Even though Thunderbird uses the same engine as Firefox, some features are not enabled.
You can auto-accept notifications by setting the following in `about:config`:
```
"permissions.default.desktop-notification" = 1
```

### How can I use the webcam/microphone?

I haven't figured this one yet, if you have any idea, please let me know.

## Acknowledgements

- [github:tdmrhn/Thunderbird-Quick-Access-Buttons](https://github.com/tdmrhn/Thunderbird-Quick-Access-Buttons/)
