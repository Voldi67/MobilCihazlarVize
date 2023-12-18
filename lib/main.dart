import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
void firebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitap Listesi Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GirisSayfasi(),
    );
  }
}

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final TextEditingController _isimController = TextEditingController();
  late String kullaniciIsim;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Sayfası'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _isimController,
              decoration: InputDecoration(labelText: 'İsim Soyisim'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  kullaniciIsim = _isimController.text;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KitapListesiSayfasi(kullaniciIsim: kullaniciIsim),
                  ),
                );
              },
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}

class KitapListesiSayfasi extends StatelessWidget {
  final String kullaniciIsim;

  KitapListesiSayfasi({required this.kullaniciIsim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kitap Listesi'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('kitaplar').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Hata: ${snapshot.error}');
          }

          var kitaplar = snapshot.data?.docs;

          return ListView.builder(
            itemCount: kitaplar?.length ?? 0,
            itemBuilder: (context, index) {
              var kitap = kitaplar![index].data() as Map<String, dynamic>;

              return KitapTile(
                kitapId: kitaplar[index].id,
                kitapAdi: kitap['kitapAdi'],
                yazar: kitap['yazar'],
                sayfaSayisi: kitap['sayfaSayisi'].toString(),
                kategori: kitap['kategori'],
                onUpdate: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KitapEklemeSayfasi(
                        kitapId: kitaplar[index].id,
                        kitapAdi: kitap['kitapAdi'],
                        yazar: kitap['yazar'],
                        sayfaSayisi: kitap['sayfaSayisi'].toString(),
                        kategori: kitap['kategori'],
                        onUpdate: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KitapEklemeSayfasi(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
class KitapEklemeSayfasi extends StatefulWidget {
  final String? kitapId;
  final String? kitapAdi;
  final String? yazar;
  final String? sayfaSayisi;
  final String? kategori;
  final VoidCallback? onUpdate;

  KitapEklemeSayfasi({this.kitapId, this.kitapAdi, this.yazar, this.sayfaSayisi, this.kategori, this.onUpdate});

  @override
  _KitapEklemeSayfasiState createState() => _KitapEklemeSayfasiState();
}

class _KitapEklemeSayfasiState extends State<KitapEklemeSayfasi> {
  TextEditingController kitapAdiController = TextEditingController();
  TextEditingController yazarController = TextEditingController();
  TextEditingController sayfaSayisiController = TextEditingController();
  TextEditingController yayineviController = TextEditingController();
  TextEditingController kategoriController = TextEditingController();
  TextEditingController basimYiliController = TextEditingController();
  bool listeyeYayinla = false;

  @override
  void initState() {
    super.initState();
    if (widget.kitapAdi != null) {
      kitapAdiController.text = widget.kitapAdi!;
      yazarController.text = widget.yazar!;
      sayfaSayisiController.text = widget.sayfaSayisi!;
      kategoriController.text = widget.kategori!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kitap Ekleme Sayfası'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: kitapAdiController,
              decoration: InputDecoration(labelText: 'Kitap Adı'),
            ),
            TextField(
              controller: yazarController,
              decoration: InputDecoration(labelText: 'Yazarlar'),
            ),
            TextField(
              controller: yayineviController,
              decoration: InputDecoration(labelText: 'Yayınevi'),
            ),
            TextField(
              controller: kategoriController,
              decoration: InputDecoration(labelText: 'Kategori'),
            ),
            TextField(
              controller: sayfaSayisiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Sayfa Sayısı'),
            ),
            TextField(
              controller: basimYiliController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Basım Yılı'),
            ),
            Row(
              children: [
                Text('Listede Yayınla'),
                Checkbox(
                  value: listeyeYayinla,
                  onChanged: (value) {
                    setState(() {
                      listeyeYayinla = value ?? false;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                int? sayfaSayisi;
                int? basimYili;

                try {
                  sayfaSayisi = int.parse(sayfaSayisiController.text);
                  basimYili = int.parse(basimYiliController.text);
                } catch (e) {
                  print('Hata: Sayfa sayısı ve basım yılı yalnızca sayı olmalıdır.');
                  return;
                }

                // Eğer kitapId varsa, güncelleme işlemi yap
                if (widget.kitapId != null) {
                  await FirebaseFirestore.instance.collection('kitaplar').doc(widget.kitapId).update({
                    'kitapAdi': kitapAdiController.text,
                    'yazar': yazarController.text,
                    'yayinevi': yayineviController.text,
                    'kategori': kategoriController.text,
                    'sayfaSayisi': sayfaSayisi,
                    'basimYili': basimYili,
                    'listeyeYayinla': listeyeYayinla,
                  });

                  // Eğer onUpdate fonksiyonu belirtilmişse çağır
                  if (widget.onUpdate != null) {
                    widget.onUpdate!();
                  }
                } else {
                  // Yeni kitap ekleme işlemi
                  await FirebaseFirestore.instance.collection('kitaplar').add({
                    'kitapAdi': kitapAdiController.text,
                    'yazar': yazarController.text,
                    'yayinevi': yayineviController.text,
                    'kategori': kategoriController.text,
                    'sayfaSayisi': sayfaSayisi,
                    'basimYili': basimYili,
                    'listeyeYayinla': listeyeYayinla,
                  });
                }

                // Güncelleme işlemi tamamlandıktan sonra bir önceki sayfaya dön
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
class KitapTile extends StatelessWidget {
  final String kitapId;
  final String kitapAdi;
  final String yazar;
  final String sayfaSayisi;
  final String kategori;
  final VoidCallback onUpdate;

  KitapTile({
    required this.kitapId,
    required this.kitapAdi,
    required this.yazar,
    required this.sayfaSayisi,
    required this.kategori,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      child: ListTile(
        title: Text(
          kitapAdi,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$yazar\nKategori: $kategori\nSayfa Sayısı: $sayfaSayisi'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onUpdate,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Emin misiniz?'),
                    content: Text('Bu kitabı silmek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Vazgeç'),
                      ),
                      TextButton(
                        onPressed: () {
                          FirebaseFirestore.instance.collection('kitaplar').doc(kitapId).delete();
                          Navigator.pop(context);
                        },
                        child: Text('Evet, Sil'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}