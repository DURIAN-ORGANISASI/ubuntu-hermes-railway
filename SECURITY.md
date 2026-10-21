# Kebijakan keamanan

## Pelaporan kerentanan

Jangan memublikasikan token, password, API key, atau URL terminal privat dalam issue. Laporkan dugaan kerentanan melalui kanal kontak privat yang disediakan pemilik repository/org GitHub. Sertakan dampak, langkah reproduksi yang aman, versi/commit terkait, dan log yang sudah disensor.

## Area sensitif

- ttyd memberi akses shell melalui web dan container menjalankan shell sebagai root.
- Domain Railway yang publik dapat dicapai dari internet; gunakan password kuat dan access gateway tepercaya bila memungkinkan.
- Token bot dan provider dapat memberikan akses ke percakapan, tools, atau layanan yang terhubung.
- Railway Volume di /opt/data berisi konfigurasi serta data Hermes; lindungi akses ke project dan volume tersebut.
- Jangan jalankan dua Gateway aktif dengan token bot yang sama.

## Jika rahasia terpapar

1. Cabut atau rotasi password, API key, dan token yang terdampak.
2. Periksa log deployment dan akses yang tidak dikenal.
3. Hapus rahasia dari lokasi publik; menghapus commit terbaru saja tidak selalu menghapusnya dari seluruh riwayat Git.
4. Redeploy setelah kredensial diganti dan verifikasi allowlist serta akses terminal.
