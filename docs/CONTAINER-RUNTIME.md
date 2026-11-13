# Container runtime policy

Cham Linux uses the native Docker Engine for long-running local services and
Podman/Distrobox for isolated development environments. Do not run Docker
Desktop's QEMU VM at the same time as the native Docker Engine unless the
native engine and its containers are deliberately stopped first.

Docker Desktop for Linux starts a separate virtual machine. On the LOQ profile
it was configured to reserve almost 4 GiB of memory and conflicted with the
native engine context while the LMS stack was running. Keep the Docker CLI on
the native context:

```bash
docker context use default
docker ps
```

Docker Desktop remains installed but is disabled from automatic startup. It can
be re-enabled only for an isolated test after stopping the native engine and
recording a backup/rollback plan.

Use `cham doctor` to identify an accidental `desktop-linux` context while the
native engine is active.
