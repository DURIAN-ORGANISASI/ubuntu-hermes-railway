# Sumber, atribusi, dan lisensi

Dokumen ini mencatat referensi teknis serta batas cakupan lisensi untuk **Ubuntu Hermes Railway**.

## Dokumentasi upstream

- [Hermes Agent — Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation): instalasi CLI dan opsi installer.
- [Hermes Agent — Messaging](https://hermes-agent.nousresearch.com/docs/user-guide/messaging): konfigurasi Gateway pesan.
- [Hermes Agent — Telegram](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram): pengaturan Telegram.
- [Hermes Agent — Discord](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord): pengaturan Discord.
- [Hermes Agent — Environment variables](https://hermes-agent.nousresearch.com/docs/reference/environment-variables): referensi variabel runtime.
- [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent): repository upstream Hermes Agent.
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
