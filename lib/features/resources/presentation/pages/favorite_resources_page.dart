import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_study_plan/features/resources/presentation/bloc/resource_event.dart';

import '../../../../core/bloc/base_state.dart';
import '../../../../core/bloc/view_state.dart';
import '../../domain/entities/file_resource.dart';
import '../bloc/resource_bloc.dart';
import '../widgets/resource_item_card.dart';
import 'resource_viewer_page.dart';

class FavoriteResourcesPage extends StatelessWidget {
  const FavoriteResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF6F7FB),
        automaticallyImplyLeading: false,
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ResourceBloc, BaseState<List<FileResource>>>(
        builder: (context, state) {
          final vs = state.viewState;

          if (vs is ViewLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vs is ViewFailure<List<FileResource>>) {
            return Center(child: Text(vs.message));
          }

          if (vs is ViewSuccess<List<FileResource>>) {
            final favorites = vs.data.where((e) => e.isFavorite).toList();

            if (favorites.isEmpty) {
              return const _EmptyFavorites();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (_, i) {
                final resource = favorites[i];

                return ResourceItemCard(
                  resource: resource,
                  onFavorite: () {
                    context.read<ResourceBloc>().add(
                      ToggleFavoriteResourceEvent(resource),
                    );
                  },
                  onOpen: () {
                    if (resource.url.isEmpty) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResourceViewerPage(resource: resource),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_border_rounded,
              size: 88,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the star on any resource\nto save it here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
