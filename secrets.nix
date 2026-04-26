let
  phip = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgCqkVI/LR3FFI9z1JLnQylOsteuCg3fP2UXAf/Bnzu";
  nuc  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdwE7xHYwdbM2IETm3fIH+rxrVeY24Ofnc49Qb/siZb";
in {
  "secrets/restic-repository.age".publicKeys = [ phip nuc ];
  "secrets/restic-password.age".publicKeys = [ phip nuc ];
}
