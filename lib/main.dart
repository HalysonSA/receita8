import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

enum DataStatus { loading, loaded, error }

final ValueNotifier<bool> isLoading = ValueNotifier(false);
final ValueNotifier<int> itemsQuantity = ValueNotifier(5);
final ValueNotifier<int> currentData = ValueNotifier(0);
final ValueNotifier<Map<String, dynamic>> data =
    ValueNotifier({"status": DataStatus.loading, "data": []});

List<VoidCallback> dataValues = [
  carregarCafes,
  carregarCervejas,
  carregarPaises,
  carregarProdutos
];

Future<void> carregarProdutos() async {
  var productsUri = Uri(
      scheme: 'https',
      host: 'fakestoreapi.com',
      path: 'products',
      queryParameters: {'limit': "${itemsQuantity.value}"});

  currentData.value = 3;

  try {
    final response = await http.get(productsUri);

    response.statusCode == 200
        ? data.value = {
            "status": DataStatus.loaded,
            "data": jsonDecode(response.body)
          }
        : data.value = {"status": DataStatus.error, "data": []};
  } catch (error) {
    data.value = {"status": DataStatus.error, "data": []};
  }
}

Future<void> carregarCervejas() async {
  var beersUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/beer/random_beer',
      queryParameters: {'size': "${itemsQuantity.value} "});

  currentData.value = 1;

  try {
    final response = await http.get(beersUri);
    response.statusCode == 200
        ? data.value = {
            "status": DataStatus.loaded,
            "data": jsonDecode(response.body)
          }
        : data.value = {"status": DataStatus.error, "data": []};
  } catch (error) {
    data.value = {"status": DataStatus.error, "data": []};
  }
}

Future<void> carregarPaises() async {
  var nationsUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/nation/random_nation',
      queryParameters: {'size': "${itemsQuantity.value} "});

  currentData.value = 2;

  try {
    final response = await http.get(nationsUri);

    response.statusCode == 200
        ? data.value = {
            "status": DataStatus.loaded,
            "data": jsonDecode(response.body)
          }
        : data.value = {"status": DataStatus.error, "data": []};
  } catch (error) {
    data.value = {"status": DataStatus.error, "data": []};
  }
}

Future<void> carregarCafes() async {
  var coffesUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/coffee/random_coffee',
      queryParameters: {'size': "${itemsQuantity.value} "});

  currentData.value = 0;

  try {
    await http.get(coffesUri).then((value) => value.statusCode == 200
        ? data.value = {
            "status": DataStatus.loaded,
            "data": jsonDecode(value.body)
          }
        : data.value = {"status": DataStatus.error, "data": []});
  } catch (error) {
    data.value = {"status": DataStatus.error, "data": []};
  }
}

enum SampleItem { itemOne, itemTwo, itemThree }

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    data.value = {"status": DataStatus.loading, "data": []};
    dataValues[currentData.value]();

    return Scaffold(
      appBar: AppBar(
        title: Text("App"),
        actions: [
          PopupMenuButton(
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      child: Text('5 itens'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: Text('10 itens'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemThree,
                      child: Text('15 itens'),
                    ),
                  ],
              onSelected: (e) {
                switch (e) {
                  case SampleItem.itemOne:
                    itemsQuantity.value = 5;
                    dataValues[currentData.value]();
                    break;
                  case SampleItem.itemTwo:
                    itemsQuantity.value = 10;
                    dataValues[currentData.value]();
                    break;
                  case SampleItem.itemThree:
                    itemsQuantity.value = 15;
                    dataValues[currentData.value]();
                    break;
                }
              }),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: data,
          builder: (_, value, __) {
            switch (value["status"]) {
              case DataStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case DataStatus.loaded:
                return GenericItem(objects: [
                  ...value["data"],
                ]);

              case DataStatus.error:
                return const Center(
                    child: Text(
                  "Erro ao carregar dados",
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ));
              default:
                return const Center(
                    child: Text(
                  "Erro ao carregar dados",
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ));
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Aqui está faltando a lógica para ordenar os itens
        },
        child: Icon(Icons.sort),
      ),
      bottomNavigationBar: NavbarCustom(),
    );
  }
}

class NavbarCustom extends HookWidget {
  NavbarCustom();

  @override
  Widget build(BuildContext context) {
    final buttontapped = useState(0);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          label: "Cafés",
          icon: Icon(Icons.coffee_outlined),
        ),
        BottomNavigationBarItem(
            label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
        BottomNavigationBarItem(
            label: "Nações", icon: Icon(Icons.flag_outlined)),
        BottomNavigationBarItem(label: "Produtos", icon: Icon(Icons.pallet))
      ],
      onTap: (index) {
        data.value = {"status": DataStatus.loading, "data": []};
        buttontapped.value = index;
        dataValues[index]();
      },
      currentIndex: buttontapped.value,
    );
  }
}

class GenericItem extends StatelessWidget {
  List<Map<String, dynamic>> objects;

  GenericItem({this.objects = const []});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(30),
      itemCount: objects.length,
      itemBuilder: (context, index) {
        final titles = objects[index].keys.toList();
        final values = objects[index].values.toList();

        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: titles
                .map((e) => Text(
                      "$e: ${values[titles.indexOf(e)]}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18),
                    ))
                .toList(),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
