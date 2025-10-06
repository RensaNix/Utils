{inputs, ...}: let
  inherit (inputs) pkgs utils doclib;

  optionsDoc = doclib.mkOptionDocs {
    inherit (utils) module;
    roots = [
      {
        url = "https://gitlab.com/rensa-nix/utils/-/blob/main/lib";
        path = "${inputs.self}/lib";
      }
    ];
  };
  optionsDocs = pkgs.runCommand "options-docs" {} ''
    mkdir -p $out
    ln -s ${optionsDoc} $out/options.md
  '';
in
  (doclib.mkDocs {
    docs."default" = {
      base = "${inputs.self}";
      path = "${inputs.self}/docs";
      material = {
        enable = true;
        colors = {
          primary = "red";
          accent = "red";
        };
        umami = {
          enable = true;
          src = "https://analytics.tf/umami";
          siteId = "1e063417-931a-4fb7-81a1-fc506372ebcc";
          domains = ["utils.rensa.projects.tf"];
        };
      };
      macros = {
        enable = true;
        includeDir = toString optionsDocs;
      };
      config = {
        site_name = "Utils";
        site_url = "https://utils.rensa.projects.tf";
        repo_name = "rensa-nix/utils";
        repo_url = "https://gitlab.com/rensa-nix/utils";
        extra_css = ["style.css"];
        theme = {
          logo = "images/logo.svg";
          icon.repo = "simple/gitlab";
          favicon = "images/logo.svg";
        };
        nav = [
          {"Introduction" = "index.md";}
          {"Utility Functions" = "utils.md";}
          {"Options" = "options.md";}
        ];
        markdown_extensions = [
          {
            "pymdownx.highlight".pygments_lang_class = true;
          }
          "pymdownx.inlinehilite"
          "pymdownx.snippets"
          "pymdownx.superfences"
          "pymdownx.escapeall"
          "fenced_code"
          "attr_list"
          {
            "toc".permalink = "#";
          }
        ];
      };
    };
  }).packages
  // {
    inherit optionsDocs;
  }
