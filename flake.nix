{
  description = "Build and serve my blog";

  # Ruby 2.7 is available only in NixOS 23.11.
  inputs.nixpkgs.url = "github:nixos/nixpkgs/23.11";
  
  outputs = inputs: with inputs; let

    # List of ruby gems required.
    gem_list = {
      jekyll = "3.9.0";
      kramdown-parser-gfm = "1.1.0";
      logger = "1.5.1";
    };

    # List of plugins to use in Jenkins.
    plugin_list = {
      jekyll-figure = "0.2.0";
      jekyll-scholar = "5.16.0";
    };

    system = "x86_64-linux";

    # Seems like these packages are vulnerable, but since we are only using
    # them once to build, I think it is OK.
    pkgs = (import nixpkgs {
      inherit system;
      config.permittedInsecurePackages = [
        "ruby-2.7.8"
        "openssl-1.1.1w"
      ];
    });

    generate_gemfile = let
      gems = builtins.concatStringsSep "\n" (pkgs.lib.attrsets.mapAttrsToList (name: version:
        "gem \"${name}\", \"~> ${version}\""
      ) gem_list);

      plugins = builtins.concatStringsSep "\n" (pkgs.lib.attrsets.mapAttrsToList (name: version:
        "  gem \"${name}\", \"~> ${version}\""
      ) plugin_list);
    in ''
      source "https://rubygems.org"
      gem "github-pages", "~> 224", group: :jekyll_plugins
      ${gems}
      group :jekyll_plugins do
      ${plugins}
      end
    '';

    env = pkgs.bundlerEnv {
      name = "blog";
      ruby = pkgs.ruby_2_7;
      gemdir = ./.;
    };

    # A wrapper to make the execution of scripts easier.
    run_shell = name: add_deps: text: let
      exec = pkgs.writeShellApplication {
        inherit name text;
        runtimeInputs = with pkgs; [
          #gnumake
          bundler
        ] ++ add_deps;
      };
    in {
      type = "app";
      program = "${exec}/bin/${name}";
    };
  in {
    apps.${system} = {

      # Statically build the blog.
      default = run_shell "build" [] ''
        ${env}/bin/bundler exec -- jekyll build --trace -s blog
      '';

      # Build the blog and serve it locally.
      serve = run_shell "serve" [] ''
        ${env}/bin/bundler exec -- jekyll serve -s blog
      '';

      # [Re]generate the ruby environment.
      generate = run_shell "generate" [ pkgs.bundix ] ''
        set -e

        rm -f gemset.nix Gemfile Gemfile.lock .bundle/config
        cat << EOF > Gemfile
        ${generate_gemfile}
        EOF

        export BUNDLE_PATH=vendor
        export BUNDLE_CACHE_ALL=true
        export BUNDLE_NO_INSTALL=true
        export BUNDLE_FORCE_RUBY_PLATFORM=true

        bundler update
        bundler lock
        bundler package
        bundix --magic
        rm -rf vendor .bundle
      '';
    };
  };
}
