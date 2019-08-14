{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, adjunctions, base, bifunctors, bytestring
      , Cabal, cabal-doctest, containers, doctest, filepath
      , kan-extensions, lens, lens-process, optparse-applicative, process
      , profunctors, stdenv, tasty, tasty-hunit, text
      , unordered-containers
      }:
      mkDerivation {
        pname = "julip";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = true;
        isExecutable = true;
        setupHaskellDepends = [ base Cabal cabal-doctest ];
        libraryHaskellDepends = [
          adjunctions base bifunctors bytestring containers filepath
          kan-extensions lens lens-process process profunctors text
          unordered-containers
        ];
        executableHaskellDepends = [ base optparse-applicative ];
        testHaskellDepends = [
          base doctest filepath lens lens-process process tasty tasty-hunit
        ];
        doHaddock = false;
        description = "An implementation of Pijul in Haskell";
        license = stdenv.lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
