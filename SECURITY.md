# Kebijakan keamanan

## Pelaporan kerentanan

Jangan memublikasikan token, password, API key, atau URL terminal privat dalam issue. Laporkan dugaan kerentanan melalui kanal kontak privat yang disediakan pemilik repository/org GitHub. Sertakan dampak, langkah reproduksi yang aman, versi/commit terkait, dan log yang sudah disensor.

## Area sensitif

- ttyd memberi akses shell melalui web; sesi terminal dan Hermes Gateway berjalan sebagai user non-root UID 10001 di dalam container.
- Domain Railway yang publik dapat dicapai dari internet; gunakan password kuat dan access gateway tepercaya bila memungkinkan.
- Token bot dan provider dapat memberikan akses ke percakapan, tools, atau layanan yang terhubung.
- Entrypoint menggunakan root hanya saat startup untuk memigrasikan kepemilikan file lama pada `/opt/data`, kemudian menurunkan hak akses ke UID 10001.
- Startup pertama setelah upgrade melakukan `chown` rekursif pada `/opt/data`; Volume besar dapat memerlukan waktu lebih lama. Proses ini mempertahankan isi file, tetapi mengubah pemiliknya ke UID/GID 10001.
- Railway Volume di /opt/data berisi konfigurasi serta data Hermes; lindungi akses ke project dan volume tersebut.
- Supervisor mengelola satu Gateway per container dan menghentikan child process saat container menerima SIGTERM/SIGINT.
- Jangan jalankan dua Gateway aktif dengan token bot yang sama.
- Hermes Agent CLI pada image dipatok ke versi v0.23.1; pembaruan versi dilakukan dengan mengubah versi dan commit pin pada Dockerfile.

## Jika rahasia terpapar

1. Cabut atau rotasi password, API key, dan token yang terdampak.
2. Periksa log deployment dan akses yang tidak dikenal.
3. Hapus rahasia dari lokasi publik; menghapus commit terbaru saja tidak selalu menghapusnya dari seluruh riwayat Git.
4. Redeploy setelah kredensial diganti dan verifikasi allowlist serta akses terminal.
