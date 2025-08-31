import 'package:flutter/material.dart';

class KhotmilQuranPage extends StatelessWidget {
  const KhotmilQuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0D4035,
      ), // Hijau tua sebagai latar belakang
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0D4035),
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Khotmil Quran',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/logo.png',
                    ), // Ganti dengan asset Anda
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color(0x88155640), // Overlay hijau tua
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.menu_book, size: 64, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFF0D4035)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Apa itu Khotmil Quran?'),
                  const SizedBox(height: 12),
                  _buildParagraph(
                    'Khotmil Quran (juga dieja Khatam Quran) adalah istilah untuk kegiatan menyelesaikan pembacaan Al-Qur\'an dari awal hingga akhir, yakni dari Surah Al-Fatihah sampai Surah An-Nas, secara berurutan. Kegiatan ini dilakukan untuk memperkuat hubungan dengan Al-Qur\'an, menumbuhkan kecintaan kepada Al-Qur\'an, dan juga sebagai bentuk ibadah dan doa bersama.',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tujuan Khotmil Quran'),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    'Meningkatkan kecintaan pada Al-Qur\'an:',
                    'Kegiatan ini bertujuan untuk menumbuhkan rasa cinta dan keinginan untuk terus membaca, memahami, dan mengamalkan nilai-nilai Al-Qur\'an.',
                  ),
                  const SizedBox(height: 16),
                  _buildBulletPoint(
                    'Mempererat kebersamaan:',
                    'Khotmil Quran seringkali dilakukan bersama-sama oleh sebuah komunitas, sehingga dapat menjaga dan memupuk rasa kekeluargaan dan kebersamaan.',
                  ),
                  const SizedBox(height: 16),
                  _buildBulletPoint(
                    'Mendapatkan keberkahan dan pahala:',
                    'Menyelesaikan pembacaan Al-Qur\'an merupakan salah satu amalan yang sangat dicintai Allah dan memberikan banyak keutamaan bagi yang melaksanakannya.',
                  ),
                  const SizedBox(height: 16),
                  _buildBulletPoint(
                    'Menjadi bekal spiritual:',
                    'Khotmil Quran juga berfungsi sebagai bekal spiritual bagi umat Muslim, terutama dalam menyambut bulan suci Ramadan.',
                  ),
                  const SizedBox(height: 16),
                  _buildBulletPoint(
                    'Pembacaan bersama:',
                    'Kegiatan ini bisa dilakukan secara mandiri, berjamaah (tatap muka), atau daring, dengan tujuan menyempurnakan pembacaan Al-Quran dari awal hingga akhir. ',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Proses dan Pelaksanaan'),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    '1. Pendaftaran (jika acara terpusat):',
                    'Jika mengikuti acara yang terpusat, daftar melalui platform yang disediakan, buat akun, dan daftarkan grup peserta Anda. ',
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    '2. Pembagian Bacaan:',
                    'Al-Quran dibagi menjadi 30 juz, dan setiap peserta mendapatkan bagian juznya masing-masing untuk dibaca. ',
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    '3. Pelaksanaan Mandiri/Berjamaah:',
                    'Peserta membaca bagian Al-Quran yang telah dibagi, baik secara mandiri di rumah maupun secara berjamaah di suatu tempat pada waktu yang ditentukan. ',
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    '4. Konfirmasi Penyelesaian:',
                    'Setelah selesai membaca bagiannya, peserta mengonfirmasi penyelesaiannya kepada panitia atau koordinator. ',
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    '5. Acara Puncak/Khataman:',
                    '- Tawasul: Membaca tawasul untuk menghormati Nabi Muhammad SAW, keluarganya, dan para sahabatnya. '
                        '- Pembacaan Surat Terakhir: Membaca 22 surat terakhir Al-Quran, dimulai dari Surat Ad-Duha hingga An-Naas, secara berurutan. ',
                  ),
                  _buildBulletPoint2(
                    '',
                    '- Doa Khatam Al-Quran: Melafalkan doa khusus setelah selesai membaca Al-Quran seluruhnya. ',
                  ),
                  _buildBulletPoint2(
                    '',
                    '- Pembacaan Surat Terakhir: Membaca 22 surat terakhir Al-Quran, dimulai dari Surat Ad-Duha hingga An-Naas, secara berurutan. ',
                  ),
                  _buildBulletPoint2(
                    '',
                    '- Doa Khatam Al-Quran: Melafalkan doa khusus setelah selesai membaca Al-Quran seluruhnya. ',
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    '6. Tasyakuran (Opsional):',
                    'Kegiatan ini dapat ditutup dengan tasyakuran atau syukuran, yang merupakan ungkapan rasa syukur kepada Allah SWT atas selesainya pembacaan Al-Quran. ',
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Aksi ketika tombol ditekan
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1A7D63,
                        ), // Hijau sedang
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Ikuti Khotmil Quran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildBulletPoint(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4, right: 8),
              child: Icon(Icons.circle, size: 8, color: Color(0xFF1A7D63)),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint2(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
