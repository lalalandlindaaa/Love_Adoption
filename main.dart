lib/main.dart
  import 'package:flutter/material.dart';

void main() {
  runApp(LoveAdoptionApp());
}

/* ======================
   APP
===================== */
class LoveAdoptionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Love Adoption',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: LoginPage(),
    );
  }
}

/* ======================
   MODELOS
===================== */
class Animal {
  String nome;
  String porte;
  String raca;
  String foto;
  Animal(this.nome, this.porte, this.raca, this.foto);
}

class Solicitacao {
  String animal;
  String adotante;
  String status;
  Solicitacao(this.animal, this.adotante, this.status);
}

/* ======================
   DADOS
===================== */
List<Animal> animais = [
  Animal("Rex", "Médio", "Vira-lata",
      "https://images.unsplash.com/photo-1601758125946-6ec2ef64daf8"),
  Animal("Thor", "Grande", "Pastor Alemão",
      "https://images.unsplash.com/photo-1558788353-f76d92427f16"),
  Animal("Nina", "Pequeno", "Shih Tzu",
      "https://images.unsplash.com/photo-1596492784531-6e6eb5ea9993"),
  Animal("Bob", "Médio", "Beagle",
      "https://images.unsplash.com/photo-1592194996308-7b43878e84a6"),
];

List<Solicitacao> solicitacoes = [];

bool isONG = false;
String usuarioLogado = "";

/* ======================
   LOGIN
===================== */
class LoginPage extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController senha = TextEditingController();

  void login(BuildContext context, bool ong) {
    if (email.text.isEmpty || senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha email e senha")),
      );
      return;
    }

    usuarioLogado = email.text;
    isONG = ong;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  Widget campo(String txt, TextEditingController c, {bool senha = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        obscureText: senha,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: txt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: EdgeInsets.all(30),
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: 70, color: Colors.deepPurple),
                Text("Love Adoption",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                campo("Email", email),
                campo("Senha", senha, senha: true),
                SizedBox(height: 15),
                Text("Entrar como:"),
                ElevatedButton(
                  onPressed: () => login(context, false),
                  child: Text("Adotante"),
                ),
                OutlinedButton(
                  onPressed: () => login(context, true),
                  child: Text("ONG"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ======================
   HOME
===================== */
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void solicitar(String animal) {
    solicitacoes.add(Solicitacao(animal, usuarioLogado, "Pendente"));
    setState(() {});
    mostrarMensagem("Solicitação enviada com sucesso!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isONG ? "Painel da ONG" : "Adotar"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => LoginPage())),
          )
        ],
      ),
      floatingActionButton: isONG
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: cadastrarAnimalDialog,
            )
          : null,
      body: isONG ? painelONG() : painelAdotante(),
    );
  }

/* ======================
   ADOTANTE
===================== */
  Widget painelAdotante() {
    return Column(
      children: [
        Expanded(child: listaAnimais()),
        Divider(),
        Text("Minhas Solicitações",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          height: 200,
          child: ListView(
            children: solicitacoes
                .where((s) => s.adotante == usuarioLogado)
                .map(tileSolic)
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget listaAnimais() {
    return ListView.builder(
      itemCount: animais.length,
      itemBuilder: (_, i) {
        var a = animais[i];
        return Card(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Image.network(a.foto, height: 180, fit: BoxFit.cover),
              ListTile(
                title: Text(a.nome),
                subtitle: Text("${a.raca} • ${a.porte}"),
                trailing: ElevatedButton(
                  child: Text("Adotar"),
                  onPressed: () => solicitar(a.nome),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget tileSolic(Solicitacao s) {
    Color cor = s.status == "Aprovado"
        ? Colors.green
        : s.status == "Recusado"
            ? Colors.red
            : Colors.orange;

    return ListTile(
      title: Text(s.animal),
      trailing: Text(s.status, style: TextStyle(color: cor)),
    );
  }

/* ======================
   ONG
===================== */
  Widget painelONG() {
    return ListView(
      children: [
        ListTile(
          title: Text("Relatórios",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        relatorio("Total de Animais", animais.length),
        relatorio("Solicitações", solicitacoes.length),
        relatorio(
            "Aprovados",
            solicitacoes.where((s) => s.status == "Aprovado").length),
        relatorio(
            "Recusados",
            solicitacoes.where((s) => s.status == "Recusado").length),
        Divider(),
        ...solicitacoes.map((s) => Card(
              child: ListTile(
                title: Text("Animal: ${s.animal}"),
                subtitle: Text("Adotante: ${s.adotante}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          setState(() => s.status = "Aprovado");
                          mostrarMensagem(
                              "Solicitação APROVADA com sucesso!");
                        }),
                    IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() => s.status = "Recusado");
                          mostrarMensagem(
                              "Solicitação RECUSADA com sucesso!");
                        }),
                  ],
                ),
              ),
            ))
      ],
    );
  }

  Widget relatorio(String titulo, int valor) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(Icons.analytics),
        title: Text(titulo),
        trailing:
            Text(valor.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

/* ======================
   CADASTRO ANIMAL
===================== */
  void cadastrarAnimalDialog() {
    final TextEditingController nome = TextEditingController();
    final TextEditingController raca = TextEditingController();
    final TextEditingController foto = TextEditingController();
    String porte = "Pequeno";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Cadastrar Animal"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              campo("Nome", nome),
              campo("Raça", raca),
              DropdownButtonFormField<String>(
                initialValue: porte,
                items: ["Pequeno", "Médio", "Grande"]
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p),
                        ))
                    .toList(),
                onChanged: (String? v) => porte = v!,
                decoration: InputDecoration(labelText: "Porte"),
              ),
              campo("URL da foto", foto),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar")),
          ElevatedButton(
              child: Text("Cadastrar"),
              onPressed: () {
                if (nome.text.isEmpty ||
                    raca.text.isEmpty ||
                    foto.text.isEmpty) {
                  mostrarMensagem("Preencha todos os campos!");
                  return;
                }

                animais.add(Animal(nome.text, porte, raca.text, foto.text));
                setState(() {});
                Navigator.pop(context);
                mostrarMensagem("Animal cadastrado com sucesso!");
              }),
        ],
      ),
    );
  }

  Widget campo(String txt, TextEditingController c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: txt),
      ),
    );
  }
}
