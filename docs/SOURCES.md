# Sumber, atribusi, dan lisensi

Dokumen ini mencatat referensi teknis serta batas cakupan lisensi untuk **Ubuntu Hermes Railway**.

## Dokumentasi upstream

- [Hermes Agent — Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation): instalasi CLI dan opsi installer.
- [Hermes Agent — Messaging](https://hermes-agent.nousresearch.com/docs/user-guide/messaging): konfigurasi Gateway pesan.
- [Hermes Agent — Telegram](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram): pengaturan Telegram.
- [Hermes Agent — Discord](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord): pengaturan Discord.
- [Hermes Agent — Environment variables](https://hermes-agent.nousresearch.com/docs/reference/environment-variables): referensi variabel runtime.
- [Hermes Agent v0.23.1 release](https://github.com/NousResearch/hermes-agent/releases/tag/v0.23.1): pinned stable release; image installs commit `3b421578588243f920886e6fe79a6faa87ea026e`.
- [Pinned Hermes installer](https://github.com/NousResearch/hermes-agent/blob/3b421578588243f920886e6fe79a6faa87ea026e/scripts/install.sh): installer source matching the pinned release.
- [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent): upstream Hermes Agent repository.
- [ttyd](https://github.com/tsl0922/ttyd): terminal berbasis web dan versi binary yang digunakan image.
- [Ubuntu Docker Official Image](https://hub.docker.com/_/ubuntu): image dasar Ubuntu.
- [Docker documentation](https://docs.docker.com/): build dan eksekusi container.
- [Railway documentation](https://docs.railway.com/): deployment, networking, variables, dan volumes.
- [Telegram Bot API](https://core.telegram.org/bots/api) dan [Discord Developer Documentation](https://discord.com/developers/docs/intro): platform bot pihak ketiga.

## Logo resmi dan aset dokumentasi

- **Logo Ubuntu Circle of Friends:** ditautkan langsung dari aset resmi Canonical, `https://assets.ubuntu.com/v1/ce518a18-CoF-2022_solid+O.svg`. Canonical mencantumkan aset ini pada [halaman Design Resources](https://design.ubuntu.com/resources) dan [repository sumber situs desain](https://github.com/canonical/design.ubuntu.com/blob/main/_data/downloads.yaml).
- **Logo Hermes Agent:** ditautkan dari [favicon SVG pada repository upstream NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent/blob/main/website/static/img/favicon.svg).
- `hero.id.svg`, `architecture.id.svg`, dan `architecture.en.svg` adalah ilustrasi dokumentasi orisinal untuk repository ini; bukan screenshot aplikasi atau logo resmi Ubuntu, Hermes Agent, Railway, Telegram, maupun Discord.
- Logo Ubuntu dan Hermes tetap merupakan merek/aset masing-masing pemilik. Logo ditampilkan untuk mengidentifikasi sistem dasar dan agent yang digunakan, bukan menyatakan afiliasi resmi.

## Cakupan lisensi

File [LICENSE](../LICENSE) menerapkan MIT pada materi proyek yang tercakup di repository ini. Lisensi tersebut tidak otomatis mengganti lisensi Hermes Agent, dependensi, Ubuntu, ttyd, atau komponen upstream lainnya. Periksa lisensi dan persyaratan tiap komponen sebelum memodifikasi, menggunakan ulang, atau mendistribusikan image.

- [Trivy Action](https://github.com/aquasecurity/trivy-action): Docker image vulnerability reporting in GitHub Actions.
- [Dependabot version updates](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates): weekly Docker and GitHub Actions update checks.
- [Docker Buildx](https://github.com/docker/buildx) and [QEMU setup](https://github.com/docker/setup-qemu-action): cross-platform image builds and runtime smoke tests.
