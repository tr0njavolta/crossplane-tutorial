let
  # Pinned so every reader gets the same tool versions, whatever Nix setup they have.
  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/ca1659429c950a11a565b5764e37a1b704e17ec8.tar.gz";
    sha256 = "1g5rrss5fzvdkfafv94fyxah7q5vsq78aqw746r9mbn952yz1ssf";
  };
in
{ pkgs ? import nixpkgs {
    # The up CLI (upbound) is unfree; allow just that package.
    config.allowUnfreePredicate = pkg: (pkg.pname or "") == "upbound";
  } }:pkgs.mkShell {
  packages = with pkgs; [
    gum
    gh
    kind
    kubectl
    yq-go
    jq
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    awscli2
    azure-cli
    upbound
    teller
    crossplane-cli
    kubernetes-helm
  ];
}
