import 'package:flutter/material.dart';

import 'library_grid.dart';

class LibraryLoadingGrid extends StatelessWidget {
  const LibraryLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1560),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = libraryGridColumnCount(constraints.maxWidth);
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: 0.5,
              ),
              itemCount: columns * 2,
              itemBuilder: (context, index) {
                return Card(
                  key: const Key('library-loading-card'),
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 7,
                        child: ColoredBox(color: colors.surfaceContainerHigh),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 10),
                              FractionallySizedBox(
                                widthFactor: 0.62,
                                child: Container(
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
