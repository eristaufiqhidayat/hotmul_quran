**BUSINESS REQUIREMENT DOCUMENT (BRD)**

**Judul Proyek**: Aplikasi Mobile Monitoring & Scheduling Hafalan Quran
(QuranTracker)\
**Versi**: 1.0\
**Tanggal**: \[31/07/2025\]

**1. Latar Belakang**

Kelompok penghafal Quran membutuhkan sistem untuk:

-   Memantau progres hafalan 1 juz per 2 minggu per anggota.

-   Mengelola jadwal bergulir (rolling schedule) dari Juz 1--30 untuk 30
    anggota.

-   Memastikan laporan harian dan notifikasi tenggat waktu.

**2. Tujuan**

-   Memudahkan tracking hafalan dengan batas waktu 2 minggu.

-   Mengotomatisasi penjadwalan bergulir setiap 2 pekan.

-   Meningkatkan akuntabilitas anggota melalui laporan real-time.

**3. Stakeholder**

-   **Admin Kelompok**: Membuat grup, mengundang anggota, memantau
    progres.

-   **Anggota**: Melaporkan hafalan harian, melihat jadwal, menerima
    notifikasi.

**4. Fitur Utama**

**4.1 Manajemen Grup**

-   Admin dapat membuat grup dengan 30 anggota (1 anggota = 1 juz).

-   Setiap grup memiliki jadwal bergulir otomatis (Juz 1--30, ulang
    setiap 30×2 minggu).

**4.2 Penjadwalan Otomatis**

-   Sistem menetapkan juz baru untuk setiap anggota setiap 2 minggu.

-   Jadwal bergulir: Anggota A dapat Juz 1 (pekan 1--2), Juz 2 (pekan
    3--4), dst.

**4.3 Pelaporan Harian**

-   Anggota melaporkan progres harian (misal: halaman yang dihafal) via
    input teks/audio.

-   Progress bar menunjukkan target 1 juz dalam 2 minggu.

**4.4 Notifikasi**

-   Pengingat harian untuk melaporkan hafalan.

-   Notifikasi tenggat waktu (H-1, H-3 sebelum 2 minggu berakhir).

**4.5 Dashboard & Analytics**

-   Admin melihat ringkasan: anggota yang on-track/terlambat.

-   Grafik progres per anggota dan grup.

**4.6 Integrasi**

-   Kalender Islam (Hijriah) untuk penjadwalan.

-   Ekspor laporan ke PDF/Excel.

**4.7 Fitur Penggantian Anggota & Reward**

-   Jika anggota tidak melaporkan hafalan selama 2 pekan, sistem
    mengizinkan anggota lain mengambil alih juz tersebut.

-   Anggota pengganti mendapat badge **\"Pengganti Aktif\"** di profil
    dan notifikasi penghargaan ke grup.

-   Admin dapat manual assign pengganti atau sistem otomatis menawarkan
    ke anggota teraktif.

**4.8 Manajemen Khotaman**

-   Setiap akhir periode 2 pekan, grup dapat:

    -   Upload dokumentasi khotaman (foto/audio/video) ke **repository
        grup**.

    -   Kategorikan berdasarkan tanggal/juz.

-   Notifikasi otomatis mengingatkan deadline upload khotaman.

**4.9 Manajemen Keuangan**

-   Fitur **\"Kas Grup\"** untuk sumbangan sukarela:

    -   Anggota dapat transfer via integrasi **DANA/OVO/QRIS** atau
        input manual.

    -   Sistem catat: nominal, tanggal, nama penyumbang.

-   Laporan keuangan otomatis:

    -   Total dana terkumpul per periode.

    -   Daftar penyumbang + riwayat pengeluaran (contoh: konsumsi
        khotaman).

-   Admin bisa ekspor laporan ke **PDF/Excel**.

**5. Non-Functional Requirements**

-   **Platform**: Android & iOS (hybrid app, e.g., Flutter/React
    Native).

-   **Security**: Login dengan email/OTP, data dienkripsi.

-   **Offline Mode**: Bisa input laporan tanpa internet (sync saat
    online).

**6. Asumsi & Ketergantungan**

-   Setiap anggota memiliki smartphone.

-   Jadwal tidak berubah selama siklus 2 minggu.

**TAHAPAN PENGEMBANGAN**

**1. Fase Persiapan (2 Minggu)**

-   **Kick-off meeting** dengan stakeholder.

-   **Analisis kompetitor** (apps seperti \"Hafiz Planner\").

-   **Penyusunan dokumen teknis** (SRS, Wireframe).

**2. Fase Desain (3 Minggu)**

-   **UI/UX Design**:

    -   Mockup halaman: Login, Dashboard, Laporan, Jadwal.

    -   Prototyping (Figma/Adobe XD).

-   **Database Design**: Struktur data grup, anggota, laporan.

**3. Fase Pengembangan (8 Minggu)**

-   **Backend**:

    -   API untuk manajemen grup, jadwal, dan laporan.

    -   Sistem notifikasi (Firebase/Pusher).

-   **Frontend**:

    -   Implementasi UI + integrasi API.

    -   Fitur offline mode.

**4. Fase Testing (3 Minggu)**

-   **Unit Testing**: Validasi input, logika penjadwalan.

-   **User Acceptance Test (UAT)**: Demo ke stakeholder.

-   **Perbaikan bug**.

**5. Deployment & Maintenance**

-   **Roll-out** bertahap ke Google Play Store & App Store.

-   **Monitoring** penggunaan + hotfix jika diperlukan.

-   **Update** berkala (e.g., tambah fitur laporan audio).

**SOFTWARE REQUIREMENTS SPECIFICATION (SRS)**

**Nama Proyek**: QuranTracker\
**Versi**: 1.0

**1. Pendahuluan**

**1.1 Tujuan**

Mendefinisikan kebutuhan teknis untuk aplikasi mobile yang
memfasilitasi:

-   Penjadwalan otomatis hafalan per juz (30 anggota × 2 minggu/juz).

-   Pelacakan progres harian dengan notifikasi.

**1.2 Lingkup**

-   Platform: Android & iOS (Hybrid, Flutter/React Native).

-   Target Pengguna: Admin kelompok & anggota penghafal Quran.

**1.3 Definisi & Singkatan**

-   **Juz**: 1/30 bagian Al-Quran (20-25 halaman).

-   **Rolling Schedule**: Jadwal bergulir setiap 2 minggu.

**2. Deskripsi Umum**

**2.1 Fitur Utama**

  -----------------------------------------------------------------------
  **Fitur**       **Deskripsi**
  --------------- -------------------------------------------------------
  Manajemen Grup  Admin buat grup, undang anggota via link/email. Maks 30
                  anggota.

  Rolling         Sistem otomatis assign juz baru tiap 2 minggu (Juz
  Schedule        1→30→ulang).

  Laporan Harian  Input progres harian (teks: halaman/hafalan) + upload
                  audio (opsional).

  Notifikasi      Pengingat harian & tenggat waktu (H-1, H-3 sebelum
                  deadline).

  Dashboard       Visualisasi progres anggota (progress bar, status
                  \"On-Track/Terlambat\").
  -----------------------------------------------------------------------

**2.2 Arsitektur Sistem**

![A diagram of a server AI-generated content may be
incorrect.](./image1.png){width="2.2539654418197723in"
height="3.160119203849519in"}

**3. Requirements Detail**

3.1 Functional Requirements

  -----------------------------------------------------------------------
  ID          Requirement
  ----------- -----------------------------------------------------------
  FR-01       Admin dapat membuat grup dengan kapasitas 30 anggota.

  FR-02       Sistem assign 1 juz/anggota secara otomatis setiap 2
              minggu.

  FR-03       Anggota dapat input laporan harian (teks + audio).

  FR-04       Notifikasi muncul pukul 08.00 waktu lokal untuk pengingat
              laporan.

  FR-05       Dashboard menampilkan ringkasan progres per anggota (warna:
              hijau/kuning/merah).

  FR-06       Sistem mengizinkan anggota lain mengambil alih juz jika
              anggota asli tidak aktif dalam 14 hari.

  FR-07       Badge \"Pengganti Aktif\" muncul di profil anggota yang
              menggantikan.

  FR-08       Fitur upload dokumentasi khotaman (foto/audio) dengan
              kapasitas maks. 50MB/file.

  FR-09       Manajemen kas grup: input sumbangan, riwayat transaksi, dan
              ekspor laporan.

  FR-10       Notifikasi ke admin jika ada anggota yang tidak aktif 2
              pekan berturut-turut.
  -----------------------------------------------------------------------

3.2 Non-Functional Requirements

  -----------------------------------------------------------------------
  ID          Requirement
  ----------- -----------------------------------------------------------
  NFR-01      Responsivitas: Load data \<2 detik di jaringan 3G.

  NFR-02      Kompatibilitas: Android 10+ & iOS 13+.

  NFR-03      Security: Enkripsi data laporan & autentikasi 2 faktor
              untuk admin.

  NFR-04      Penyimpanan dokumentasi khotaman di cloud (AWS S3/Google
              Drive) dengan enkripsi

  NFR-05      Integrasi pembayaran: DANA/OVO/QRIS (hanya untuk versi
              Indonesia).
  -----------------------------------------------------------------------

**3.3 Use Case Diagram**

usecaseDiagram

actor Admin

actor Anggota

Admin \--\> (Buat Grup)

Admin \--\> (Lihat Dashboard)

Anggota \--\> (Input Laporan)

Anggota \--\> (Lihat Jadwal)

**WIREFRAME (Sketsa UI/UX)**

Tools: Figma (Link mockup: contoh link)

1\. Halaman Login

-   Input email + password.

-   Opsi \"Login sebagai Admin/Anggota\".

2\. Dashboard Admin

-   Komponen:

    -   Daftar anggota (nama, juz saat ini, progres).

    -   Tombol \"Buat Grup Baru\".

    -   Grafik pie: Persentase anggota on-track vs terlambat.

3\. Halaman Input Laporan (Anggota)

-   Komponen:

    -   Input teks: \"Halaman yang dihafal hari ini (contoh: Juz 1, hlm.
        1-2)\".

    -   Tombol rekaman audio (opsional).

    -   Progress bar: \"14 hari tersisa (75% tercapai)\".

4\. Halaman Jadwal Bergulir

-   Komponen:

    -   Kalender 2 minggu dengan highlight juz aktif.

    -   List history: \"Pekan lalu: Juz 1 \| Pekan ini: Juz 2\".

5\. Halaman Penggantian Anggota

-   **Komponen**:

    -   List anggota yang tidak aktif (highlight merah).

    -   Tombol **\"Ambil Alih Juz Ini\"** + konfirmasi pop-up.

    -   Badge **\"Pengganti Aktif\"** di profil pengganti.

**6. Halaman Upload Khotaman**

-   **Komponen**:

    -   Pilih file (foto/audio) atau rekam langsung.

    -   Kolom deskripsi: \"Catatan acara khotaman Juz 5\".

    -   Tombol **\"Simpan ke Repository\"**.

**7. Halaman Kas Grup**

-   **Komponen**:

    -   Saldo terkini: \"Total Rp 1.500.000\".

    -   Tombol **\"Tambah Sumbangan\"** (input manual/pilih metode
        pembayaran).

    -   Riwayat transaksi: \"Ali (Rp 100.000) \| 12 Mei 2024\".

8\. Notifikasi Pop-up

-   Contoh teks:\
    \"📣 Hari ke-13: Deadline besok! Laporkan hafalan Juz 1-mu
    sekarang!\"

**Lampiran**

1.  Database Schema:

    -   Tabel Users (user_id, role, email).

    -   Tabel Groups (group_id, admin_id, start_date).

    -   Tabel Schedule (schedule_id, juz_number, deadline).

2.  Teknologi yang Digunakan:

    -   Backend: Node.js + Express.js.

    -   Database: Firebase Realtime DB / PostgreSQL.

    -   Notification: Firebase Cloud Messaging.

**LAMPIRAN TEKNIS**

**1. Database Schema (Tambahan)**

-   Tabel Replacements:

-   (replacement_id, original_user_id, replacement_user_id, juz_number,
    date)

-   Tabel Khotaman:

-   (event_id, group_id, file_path, notes, date)

-   Tabel Donations:

-   (transaction_id, user_id, amount, payment_method, is_verified)

**2. Alur Penggantian Anggota**

![A screenshot of a computer AI-generated content may be
incorrect.](./image2.png){width="3.8672779965004374in"
height="2.0793153980752406in"}

**3. Prioritas Pengembangan**

1.  Fitur penggantian anggota + reward.

2.  Integrasi pembayaran untuk kas grup.

3.  Penyimpanan dokumentasi khotaman.

**Catatan**:

-   Untuk fitur keuangan, perlu integrasi dengan **payment
    gateway** (tambahkan biaya di anggaran proyek).

-   Jika dokumentasi khotaman perlu OCR (misal: scan mushaf), tambahkan
    library seperti **Tesseract.js**.

-   Sediakan opsi **\"Laporan Khusus\"** untuk keuangan (contoh: filter
    per periode/juz).

**desain teknis fungsi utama** untuk memenuhi kebutuhan tracking,
penjadwalan otomatis, dan akuntabilitas real-time dalam aplikasi
QuranTracker:

**1. Fungsi Tracking Hafalan (2 Minggu)**

![A diagram of a company AI-generated content may be
incorrect.](./image3.png){width="3.9751367016622923in"
height="2.133784995625547in"}

**Teknologi & Logika:**

-   **Progress Tracking:**

> // Contoh kode hitung progres
>
> function checkProgress(userId, juz) {
>
> const totalPages = getPagesReported(userId, juz); // Ambil data dari
> DB
>
> const targetPages = 20; // Asumsi 1 juz = 20 halaman
>
> const deadline = getDeadline(userId, juz);
>
> const remainingDays = calculateRemainingDays(deadline);
>
> if (totalPages \>= targetPages) {
>
> sendNotification(userId, \"Target tercapai!\");
>
> } else if (remainingDays \<= 2) {
>
> sendNotification(userId, \`Selesaikan \${targetPages - totalPages}
> halaman lagi!\`);
>
> }
>
> }
>
> Progress bar di dashboard dengan warna:

-   **Hijau** jika \>80% halaman terlapor.

-   **Merah** jika \<50% di hari ke-10.

```{=html}
<!-- -->
```
-   **2. Penjadwalan Bergulir Otomatis (2 Pekan)**

-   **Alur Sistem:**

> ![A diagram of a work flow AI-generated content may be
> incorrect.](./image4.png){width="4.760991907261593in"
> height="4.643365048118985in"}
>
> **Teknologi & Logika:**
>
> ![A screenshot of a computer screen AI-generated content may be
> incorrect.](./image5.png){width="6.268055555555556in"
> height="0.8847222222222222in"}
>
> **Algoritma Assign Juz:**
>
> ![A screen shot of a computer code AI-generated content may be
> incorrect.](./image6.png){width="4.804478346456693in"
> height="2.1802734033245845in"}
>
> **3. Akuntabilitas Real-Time**
>
> **Komponen Utama:**

+----------------+------------------------------+----------------------+
| > **Fitur**    | > **Teknik Implementasi**    | > **Contoh Output**  |
+================+==============================+======================+
| > **Laporan    | > Input harian + validasi    | > \"Hari ini: Juz 1  |
| > Harian**     | > (e.g., maks 5              | > hlm. 3-5 (Total:   |
|                | > halaman/hari).             | > 8)\"               |
+----------------+------------------------------+----------------------+
| > *            | > Query ranking anggota      | > Top 3 anggota      |
| *Leaderboard** | > berdasarkan kecepatan      | > dengan progres     |
|                | > hafalan.                   | > tertinggi          |
+----------------+------------------------------+----------------------+
| > **Audit      | > Catat semua aktivitas      | > \"Ali menginput    |
| > Log**        | > (siapa, kapan, apa).       | > laporan Juz 1, 12  |
|                |                              | > Mei\"              |
+----------------+------------------------------+----------------------+

> **Contoh Query Real-Time (Firebase):**
>
> ![](./image7.png){width="4.8369564741907265in"
> height="1.0358770778652668in"}
>
> **Integrasi dengan Notifikasi**

-   **Trigger Notifikasi:**

    -   **Pengingat Harian:** Jam 05.00 waktu lokal (\"Jangan lupa lapor
        hari ini!\").

    -   **Tenggat Waktu:** H-3 dan H-1 sebelum 14 hari berakhir.

-   **Contoh Payload (Firebase Cloud Messaging):**

> ![A screen shot of a computer screen AI-generated content may be
> incorrect.](./image8.png){width="4.73681539807524in"
> height="1.1839413823272091in"}
>
> **Arsitektur Sistem (Simplified)**
>
> ![](./image9.png){width="4.146411854768154in"
> height="1.6460629921259842in"}
>
> **Testing Scenario**

1.  **Tracking:**

    -   Uji input laporan 15 halaman dalam 10 hari → Sistem harus beri
        notifikasi \"On-Track\".

2.  **Penjadwalan:**

    -   Setelah 14 hari, juz semua anggota harus update otomatis.

3.  **Akuntabilitas:**

    -   Anggota yang tidak lapor 3 hari berturut-turut → Sistem tandai
        \"Terlambat\" di dashboard admin

> Dengan implementasi ini, aplikasi akan:\
> ✅ **Memudahkan tracking** via progress bar dan notifikasi.\
> ✅ **Menjamin jadwal bergulir otomatis** tanpa intervensi manual.\
> ✅ **Meningkatkan akuntabilitas** melalui laporan real-time dan
> leaderboard.
>
> Untuk fitur tambahan (seperti penggantian anggota), bisa dikembangkan
> dengan menambahkan **state management** untuk flag anggota tidak
> aktif.
>
> **Desain teknis lengkap untuk fitur penggantian anggota** dengan
> pendekatan *state management*, termasuk alur logika, arsitektur data,
> dan contoh kode implementasi:
>
> **1. State Management untuk Anggota Tidak Aktif**
>
> **Struktur Data (Firebase Example)**
>
> ![](./image10.png){width="4.654213692038495in"
> height="1.6681124234470692in"}

**\
**

> **State Diagram**
>
> ![](./image11.png){width="3.052509842519685in"
> height="3.34421697287839in"}
>
> **2. Alur Penggantian Anggota**
>
> ![](./image12.png){width="4.628721566054243in"
> height="2.734361329833771in"}
>
> **3. Implementasi Kode**
>
> **3.1 Deteksi Anggota Tidak Aktif (Cloud Function)**
>
> // Firebase Cloud Function (Jadwalkan tiap hari)
>
> exports.checkInactiveMembers = functions.pubsub.schedule(\'every 24
> hours\')
>
> .onRun(async (context) =\> {
>
> const groupId = \"group123\";
>
> const members = await getGroupMembers(groupId);
>
> const now = new Date();
>
> members.forEach(async (member) =\> {
>
> const daysInactive = Math.floor((now - member.lastReportDate) / (1000
> \* 60 \* 60 \* 24));
>
> if (daysInactive \>= 14) {
>
> await db.collection(\'users\').doc(member.userId).update({
>
> status: \"inactive\",
>
> flaggedSince: now
>
> });
>
> // Kirim notifikasi ke admin
>
> sendAdminNotification(member.userId);
>
> }
>
> });
>
> });
>
> **3.2 Ambil Alih Juz (Frontend)**
>
> **// Flutter Widget Example**
>
> **ElevatedButton(**
>
> **onPressed: () {**
>
> **if (currentUser.status == \'active\') {**
>
> **showDialog(**
>
> **context: context,**
>
> **builder: (ctx) =\> AlertDialog(**
>
> **title: Text(\"Ambil Alih Juz \${inactiveMember.currentJuz}?\"),**
>
> **actions: \[**
>
> **TextButton(**
>
> **onPressed: () =\> \_takeOverJuz(inactiveMember),**
>
> **child: Text(\"Konfirmasi\"),**
>
> **),**
>
> **\],**
>
> **),**
>
> **);**
>
> **}**
>
> **},**
>
> **child: Text(\"Ambil Alih\"),**
>
> **),**
>
> **// Fungsi takeOverJuz**
>
> **Future\<void\> \_takeOverJuz(User inactiveUser) async {**
>
> **await FirebaseFirestore.instance.runTransaction((tx) async {**
>
> **// 1. Update status pengganti**
>
> **tx.update(**
>
> **FirebaseFirestore.instance.collection(\'users\').doc(currentUser.id),**
>
> **{**
>
> **\'status\': \'replacement\',**
>
> **\'currentJuz\': inactiveUser.currentJuz,**
>
> **\'replacementHistory\': FieldValue.arrayUnion(\[**
>
> **{**
>
> **\'replacedUserId\': inactiveUser.id,**
>
> **\'date\': DateTime.now(),**
>
> **}**
>
> **\]),**
>
> **},**
>
> **);**
>
> **// 2. Reset anggota yang digantikan**
>
> **tx.update(**
>
> **FirebaseFirestore.instance.collection(\'users\').doc(inactiveUser.id),**
>
> **{**
>
> **\'currentJuz\': null,**
>
> **\'status\': \'inactive\',**
>
> **},**
>
> **);**
>
> **});**
>
> **// 3. Update UI**
>
> **setState(() {**
>
> **currentUser.status = \'replacement\';**
>
> **});**
>
> **}**
>
> **4. Reward System untuk Pengganti**
>
> **Struktur Badge**
>
> // Collection \'badges\'
>
> {
>
> badgeId: \"replacer_1\",
>
> userId: \"user123\",
>
> type: \"replacement\",
>
> juz: 5,
>
> awardedAt: \"2024-05-20T10:00:00Z\",
>
> description: \"Telah menggantikan Juz 5 untuk user456\"
>
> }
>
> **Contoh Query Leaderboard**
>
> \-- SQL untuk ranking pengganti aktif
>
> SELECT
>
> u.name,
>
> COUNT(r.replacedUserId) AS total_replacements
>
> FROM
>
> users u
>
> JOIN
>
> replacements r ON u.userId = r.replacementUserId
>
> GROUP BY
>
> u.userId
>
> ORDER BY
>
> total_replacements DESC
>
> LIMIT 3;

**\
**

> **5. Mekanisme Fallback Otomatis**
>
> Jika tidak ada yang mengambil alih dalam 3 hari:
>
> ![](./image13.png){width="2.3458508311461066in"
> height="3.6022725284339456in"}
>
> **6. Testing Scenario**

1.  **Kasus Normal:**

    -   Anggota A tidak lapor 14 hari → status jadi \'inactive\'.

    -   Anggota B mengambil alih → dapat badge, Anggota A kehilangan
        juz.

2.  **Kasus Fallback:**

    -   Tidak ada yang mengambil alih dalam 3 hari → sistem assign ke
        anggota progres terbaik.

3.  **Edge Case:**

    -   Anggota pengganti tidak menyelesaikan juz → tidak bisa ambil juz
        baru sampai selesai.

> **7. Security Rules (Firestore)**
>
> match /users/{userId} {
>
> allow read: if request.auth != null;
>
> allow update: if
>
> // Admin bisa update semua
>
> request.auth.token.isAdmin \|\|
>
> // User bisa update sendiri jika bukan status replacement
>
> (request.auth.uid == userId && resource.data.status !=
> \'replacement\');
>
> }
>
> **Langkah Pengembangan**

1.  **Phase 1:** Implementasi state management dasar (active/inactive).

2.  **Phase 2:** Mekanisme penggantian manual via UI.

3.  **Phase 3:** Sistem reward dan fallback otomatis.

> Dengan pendekatan ini, sistem akan:\
> ✅ **Mengurangi beban admin** dengan automasi deteksi anggota tidak
> aktif.\
> ✅ **Mendorong partisipasi** melalui reward yang terlihat.\
> ✅ **Mempertahankan konsistensi** jadwal rolling 2 minggu.
