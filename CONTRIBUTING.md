# Panduan kontribusi

Terima kasih telah membantu meningkatkan Ubuntu Hermes Railway.

## Sebelum membuka Pull Request

1. Jelaskan masalah yang ingin diperbaiki dan perubahan yang diusulkan.
2. Jalankan pemeriksaan sintaks:
   ~~~bash
   bash -n entrypoint.sh
   bash -n start-hermes
   bash -n system-banner.sh
   ~~~
3. Jika memungkinkan, bangun image:
   ~~~bash
   docker build --tag ubuntu-hermes-railway .
   ~~~
4. Perbarui dokumentasi terkait jika perilaku variabel, penyimpanan, port, keamanan, atau setup berubah.
5. Pastikan README Indonesia dan Inggris tetap konsisten, serta seluruh link lokal menuju file yang tersedia.

## Aturan kontribusi

- Jangan commit password, API key, token Telegram/Discord, file konfigurasi pribadi, atau log yang memuat rahasia.
- Jangan mengklaim tes integrasi Railway atau provider berhasil bila hanya menjalankan pemeriksaan lokal.
- Pertahankan batas tanggung jawab repository ini sebagai image terminal Ubuntu untuk Hermes Agent; perubahan tidak boleh diam-diam mengubah kredensial atau menghapus data persisten.
- Jelaskan langkah reproduksi yang aman untuk setiap bug.
