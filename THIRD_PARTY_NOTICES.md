# Third-party notices

mirascope is licensed under the MIT License. It also uses third-party software
that remains subject to its own license terms.

The Windows release bundle contains `THIRD_PARTY_LICENSES.txt`, generated from
the exact Flutter build inputs. That file is the authoritative collection of
copyright notices and license texts for the Dart, Flutter, plugin, font, icon,
and native packages included in that bundle.

The main runtime dependencies use permissive licenses compatible with
mirascope's MIT License:

| Component group | Examples | License family |
|---|---|---|
| Flutter and official plugins | Flutter, file_selector, go_router, path_provider | BSD-3-Clause |
| Dart libraries | crypto, logging, jni | BSD-3-Clause |
| Application libraries | drift, drift_flutter, flutter_riverpod, sqlite3 | MIT |
| Assets | cupertino_icons | MIT |

The Windows portable bundle also contains the retail Microsoft Visual C++
runtime libraries required by the application. Those files are redistributed
from Visual Studio's `Microsoft.VC143.CRT` directory under Microsoft's
applicable Visual Studio license terms. They are not relicensed under MIT.
Microsoft's deployment guidance is available at:

https://learn.microsoft.com/cpp/windows/choosing-a-deployment-method

When dependencies change, regenerate and review the release bundle rather than
copying an older third-party notice file.
