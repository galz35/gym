import 'package:flutter/material.dart';

class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Usuarios')),
    body: const Center(child: Text('Gestión de Usuarios (Admin)')),
  );
}

class SucursalesScreen extends StatelessWidget {
  const SucursalesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sucursales')),
    body: const Center(child: Text('Gestión de Sucursales (Admin)')),
  );
}

class ProductosScreen extends StatelessWidget {
  const ProductosScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Catálogo de Productos')),
    body: const Center(child: Text('Gestión Global de Productos')),
  );
}
