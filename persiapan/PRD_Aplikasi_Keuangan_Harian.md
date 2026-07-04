# PRODUCT REQUIREMENT DOCUMENT (PRD)
## Nama Proyek: Aplikasi Manajemen Keuangan Harian (Personal Finance Tracker)

---

### 1. Informasi Dokumen & Riwayat Versi
* **Nama Proyek:** Aplikasi Keuangan Harian v1.0
* **Tanggal Pembuatan:** 15 Juni 2026
* **Status:** Draft - Siap Ditinjau (Ready for Review)
* **Target Rilis:** Kuartal 3, 2026

---

### 2. Ringkasan Eksekutif & Visi Produk
Aplikasi Manajemen Keuangan Harian adalah platform *mobile-first* yang dirancang untuk membantu pengguna mengelola finansial pribadi secara cerdas, otomatis, dan minim usaha (*low-friction*). 

Masalah utama yang diselesaikan adalah kurangnya kedisiplinan dalam mencatat transaksi harian, sulitnya memantau utang-piutang, serta keterlambatan pembayaran tagihan rutin bulanan. Dengan fitur otomatisasi cerdas seperti klasifikasi pengeluaran, pemindaian struk berbasis OCR, dan integrasi pengingat langsung ke WhatsApp, aplikasi ini memposisikan diri sebagai asisten finansial pribadi yang proaktif.

---

### 3. Matriks Prioritas Fitur (MVP)
Fitur-fitur di bawah ini diklasifikasikan menggunakan kerangka kerja prioritas MoSCoW (*Must Have, Should Have, Could Have*) untuk menentukan cakupan *Minimum Viable Product* (MVP):

| Nama Fitur | Kategori (di Gambar) | Prioritas | Deskripsi Singkat |
| :--- | :--- | :--- | :--- |
| **Kategori Pengeluaran** | Inti (*Main*) | P0 - Must Have | Otomatis menyortir pengeluaran ke Kategori (Makan, Transport, Belanja, Tagihan). |
| **Budget Bulanan** | Inti (*Main*) | P0 - Must Have | Set batas budget per kategori dan berikan notifikasi limit jika hampir habis. |
| **Cek Keuangan Harian** | Baru (*New*) | P0 - Must Have | Ringkasan pemasukan & pengeluaran hari ini serta perbandingan vs rata-rata harian. |
| **Lacak Piutang** | Baru (*New*) | P1 - Should Have | Pencatatan utang orang ke kita, nominal, dan tanggal jatuh tempo. |
| **Pengingat Tagihan** | Berguna (*Useful*) | P1 - Should Have | Notifikasi otomatis preventif sebelum tagihan bulanan jatuh tempo. |
| **Laporan & Grafik** | Berguna (*Useful*) | P1 - Should Have | Visualisasi tren mingguan/bulanan dalam bentuk grafik yang mudah dibaca. |
| **Kirim Pengingat Hutang**| Tambahan Oke | P1 - Should Have | Integrasi aksi cepat untuk mengingatkan orang via WhatsApp/Chat langsung. |
| **Foto Struk** | Tambahan Oke | P2 - Could Have | Mengambil foto struk belanjaan dan otomatis mencatat nominal via OCR. |
| **Pengeluaran Rutin** | Tambahan Oke | P2 - Could Have | Otomatis mencatat tagihan/transaksi bulanan yang berulang secara berkala. |
| **Target Tabungan** | Tambahan Oke | P2 - Could Have | Menetapkan target spesifik (misal: HP Baru) dan melacak progres persentase. |

---

### 4. Spesifikasi Fungsional Detail Fitur

#### 4.1 Modul Fitur Utama (Berdasarkan `image_860d61.png`)

##### 4.1.1 Cek Keuangan Harian (Daily Financial Dashboard)
* **Alur Pengguna:** Pengguna membuka aplikasi dan langsung melihat ringkasan keuangan hari ini di bagian atas dashboard utama.
* **Aturan Bisnis:** Sistem menghitung akumulasi seluruh pengeluaran hari ini (00:00 - waktu saat ini) dan membandingkannya dengan rata-rata bergerak (*moving average*) pengeluaran harian pengguna selama 30 hari terakhir.
* **Elemen UI:** Teks berwarna hijau jika di bawah rata-rata (hemat), teks berwarna merah dengan ikon peringatan jika di atas rata-rata (boros).

##### 4.1.2 Lacak Piutang (Receivables Tracker)
* **Alur Pengguna:** Pengguna masuk ke tab 'Piutang', lalu menekan tombol '+' untuk menambahkan catatan baru.
* **Aturan Bisnis:** Form wajib mengisi Nama Peminjam, Nominal, dan Tanggal Jatuh Tempo. Piutang yang melewati batas jatuh tempo akan otomatis naik ke bagian atas daftar dengan penanda status *Overdue*.

##### 4.1.3 Kategori Pengeluaran Otomatis (Auto-Categorization)
* **Alur Pengguna:** Saat transaksi dimasukkan, sistem langsung mengelompokkannya secara otomatis.
* **Aturan Bisnis:** Kategori utama mencakup Makan, Transport, Belanja, dan Tagihan. Sistem menggunakan pencocokan kata kunci pada deskripsi (misal: "Gojek" -> Transport, "Indomaret" -> Belanja) untuk mengklasifikasikannya secara otomatis tanpa input manual berlebih.

##### 4.1.4 Budget Bulanan & Alert Limit (Monthly Budgeting)
* **Alur Pengguna:** Pengguna menetapkan batas anggaran di awal bulan untuk setiap kategori yang diinginkan.
* **Aturan Bisnis:** Sistem akan memicu *push notification* proaktif ketika pengeluaran suatu kategori menyentuh angka 80% dari total budget, dan notifikasi kritis saat menyentuh 100%.

##### 4.1.5 Pengingat Tagihan & Modul Grafik (Bill Reminders & Analytics)
* **Aturan Bisnis:** Mengirimkan pengingat sistem H-3, H-1, dan hari H jatuh tempo tagihan terdaftar agar tidak terkena denda.
* **Visualisasi Laporan:** Menyediakan visualisasi berbentuk *Pie Chart* untuk distribusi pengeluaran per kategori dan *Line/Bar Chart* untuk tren pengeluaran mingguan/bulanan.

#### 4.2 Modul Fitur Tambahan (Berdasarkan `image_860d79.png`)

##### 4.2.1 Pemindai Foto Struk (OCR Receipt Scanner)
* **Deskripsi:** Pengguna dapat mengambil foto struk belanja fisik menggunakan kamera handphone untuk mempercepat pencatatan.
* **Aturan Bisnis:** Mesin OCR mengekstrak teks, mengidentifikasi nominal total transaksi, dan mengisinya ke draf form transaksi untuk konfirmasi akhir pengguna.

##### 4.2.2 Kirim Pengingat Hutang (WhatsApp Reminders Integration)
* **Deskripsi:** Menyediakan tombol aksi cepat di samping data piutang untuk menagih dengan sopan tanpa rasa sungkan.
* **Aturan Bisnis:** Saat tombol diklik, aplikasi memicu *deep linking* untuk langsung membuka aplikasi WhatsApp kontak tujuan dengan template pesan otomatis (Contoh: *"Halo [Nama], cuma mau mengingatkan kalau pinjaman Rp [Nominal] sudah mendekati jatuh tempo pada [Tanggal]. Terima kasih ya!"*).

##### 4.2.3 Pengeluaran Rutin & Target Tabungan (Recurring Tasks & Savings Goals)
* **Pengeluaran Rutin:** Sistem otomatis melakukan pencatatan transaksi (misal: langganan streaming, biaya kos) pada tanggal yang sama setiap bulannya tanpa perlu input ulang.
* **Target Tabungan:** Membuat target tabungan terisolasi dengan visualisasi *progress bar* (contoh: Target 'Beli HP Baru' Rp 5.000.000, terisi Rp 2.500.000 berarti *progress bar* menampilkan 50%).

---

### 5. Persyaratan Non-Fungsional (Non-Functional Requirements)
* **Keamanan (Security):** Aplikasi harus menyediakan opsi otentikasi biometrik (*Fingerprint/Face ID*) atau PIN 6 digit sebelum membuka aplikasi untuk melindungi privasi data keuangan.
* **Mode Offline (Offline Usability):** Pengguna harus bisa mencatat transaksi kapan saja tanpa koneksi internet. Data disimpan di database lokal (*SQLite/Room*) dan akan disinkronisasikan ke cloud secara otomatis saat koneksi internet kembali aktif.
* **Kinerja & Aksesibilitas:** Waktu muat halaman utama dashboard tidak boleh lebih dari 1.5 detik. Tombol 'Tambah Transaksi (+)' ditempatkan secara ergonomis (*Floating Action Button*) sehingga dapat diakses maksimal dengan 2 ketukan dari layar mana saja.
