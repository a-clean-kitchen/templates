{
  description = "My relevant templates";

  outputs = { self }: {
    templates = {
      next-js = {
        path = ./nextjs;
        description = "A NextJS template for use with Nix";
        welcomeText = ''
          # Getting started
          - Run `nix develop`
          
          # Don't forget to change the name of your project in the package.json
          # And update the dependency hash in the flake.nix
          # And ofc `git init`
        '';
      };
    };
  };
}
