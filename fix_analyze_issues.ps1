$ErrorActionPreference = 'Stop'

Write-Host 'Applying Flutter analyzer fixes...' -ForegroundColor Cyan

function Replace-InFile {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Old,
        [Parameter(Mandatory=$true)][string]$New
    )

    $content = Get-Content -Raw -Encoding UTF8 $Path
    if (-not $content.Contains($Old)) {
        throw "Pattern not found in ${Path}:`n$Old"
    }

    $content = $content.Replace($Old, $New)
    Set-Content -Path $Path -Value $content -Encoding UTF8
}

# 1. UserProvider: catchError must return User, so use async/try-catch instead.
Replace-InFile 'lib/providers/user_provider.dart' @'
  void _sendPresenceSafely() {
    updatePresence().catchError((_) {
      // Presence не должна ломать основную сессию пользователя.
    });
  }
'@ @'
  void _sendPresenceSafely() async {
    try {
      await updatePresence();
    } catch (_) {
      // Presence не должна ломать основную сессию пользователя.
    }
  }
'@

# 2. Repository: unused import.
Replace-InFile 'lib/repositories/user_repository.dart' @'
import 'package:mess_prototype/database/database_provider.dart';
'@ ''

# 3. Edit profile: validator should receive the actual String.
#    The formatter remains responsible only for formatting input.
Replace-InFile 'lib/services/is_valid_values.dart' @'
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

'@ ''
Replace-InFile 'lib/services/is_valid_values.dart' @'
  String? phone(MaskTextInputFormatter phoneFormatter) {
    final cleanPhone = phoneFormatter.getUnmaskedText();

    if (cleanPhone.length < 10) return 'Номер телефона слишком короткий';

    return null;
  }
'@ @'
  String? phone(String value) {
    final phone = value.trim().replaceAll(RegExp(r'[\s()-]'), '');

    if (phone.isEmpty) return 'Номер телефона не может быть пустым';
    if (!RegExp(r'^\+[0-9]+$').hasMatch(phone)) {
      return 'Номер телефона должен начинаться с "+" и содержать только цифры';
    }

    final digitCount = phone.length - 1;
    if (digitCount < 10) return 'Номер телефона слишком короткий';
    if (digitCount > 15) return 'Номер телефона слишком длинный';

    return null;
  }
'@

# 4. Auth screen: returned user isn't used.
Replace-InFile 'lib/screens/auth_screen.dart' @'
      final user = await userProvider.login(
'@ @'
      await userProvider.login(
'@

# 5. Register screen: returned user isn't used.
Replace-InFile 'lib/screens/register_screen.dart' @'
      final user = await userProvider.register(
'@ @'
      await userProvider.register(
'@

# 6. Main screen: do not keep a separate UserProvider field in LeftPanel.
#    Logout must resolve the provider from the context of LeftPanelState.
Replace-InFile 'lib/screens/main_screen.dart' @'
              DefaultButton(
                funTap: () async {
                  await userProvider.logout();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
'@ @'
              DefaultButton(
                funTap: () async {
                  await context.read<UserProvider>().logout();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
'@

# 7. Main screen: context.mounted is the correct guard after async gaps.
Replace-InFile 'lib/screens/main_screen.dart' @'
                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
'@ @'
                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
'@

# 8. Profile screen: protect ScaffoldMessenger after await.
Replace-InFile 'lib/screens/profile_screen.dart' @'
      await userProvider.removeAvatar();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Аватар успешно обновлен')));
'@ @'
      await userProvider.removeAvatar();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Аватар успешно обновлен')));
'@

# 9. API service: use debugPrint instead of print.
Replace-InFile 'lib/api/api_service.dart' "    print(response.body);" "    debugPrint(response.body);"
# foundation is already available through Flutter/http imports in this project; ensure explicit import.
$apiContent = Get-Content -Raw -Encoding UTF8 'lib/api/api_service.dart'
if (-not $apiContent.Contains("import 'package:flutter/foundation.dart';")) {
    $apiContent = "import 'package:flutter/foundation.dart';`r`n" + $apiContent
    Set-Content -Path 'lib/api/api_service.dart' -Value $apiContent -Encoding UTF8
}

# 10. Settings: remove unused imports and make the public state type public.
Replace-InFile 'lib/screens/settings_screen.dart' "import 'package:mess_prototype/providers/user_provider.dart';" ''
Replace-InFile 'lib/screens/settings_screen.dart' "import 'package:provider/provider.dart';" ''
Replace-InFile 'lib/screens/settings_screen.dart' 'class _SettingsScreenState extends State<SettingsScreen>' 'class SettingsScreenState extends State<SettingsScreen>'
Replace-InFile 'lib/screens/settings_screen.dart' '_SettingsScreenState createState() => _SettingsScreenState();' 'SettingsScreenState createState() => SettingsScreenState();'

# 11. Chat service: field is never reassigned.
Replace-InFile 'lib/services/chat_service.dart' '  List<Map<String, dynamic>> _messages = [];' '  final List<Map<String, dynamic>> _messages = [];'

# 12. Divider widget: public widget should have a named key.
Replace-InFile 'lib/widgets/divider.dart' 'class CustomDivider extends StatelessWidget {' @'
class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});
'@

# 13. Friend request: make state type public because it appears in the public API.
Replace-InFile 'lib/widgets/friend_request.dart' 'class _FriendRequestState extends State<FriendRequest>' 'class FriendRequestState extends State<FriendRequest>'
Replace-InFile 'lib/widgets/friend_request.dart' '_FriendRequestState createState() => _FriendRequestState();' 'FriendRequestState createState() => FriendRequestState();'

# 15. Replace remaining debug prints with debugPrint.
foreach ($path in @(
    'lib/screens/main_screen.dart',
    'lib/services/chat_service.dart',
    'lib/widgets/switcher_button.dart'
)) {
    $content = Get-Content -Raw -Encoding UTF8 $path
    $content = $content.Replace('print(', 'debugPrint(')
    if ($path -ne 'lib/screens/main_screen.dart' -and -not $content.Contains("import 'package:flutter/foundation.dart';")) {
        $content = "import 'package:flutter/foundation.dart';`r`n" + $content
    }
    Set-Content -Path $path -Value $content -Encoding UTF8
}

# 16. Remove the unused print from the test helper.

if (Test-Path 'lib/test/test.dart') {
    $test = Get-Content -Raw -Encoding UTF8 'lib/test/test.dart'
    $test = $test -replace "\s*print\([^;]*;", ''
    Set-Content -Path 'lib/test/test.dart' -Value $test -Encoding UTF8
}

Write-Host ''
Write-Host 'Done. Run:' -ForegroundColor Green
Write-Host '  flutter analyze' -ForegroundColor Yellow
Write-Host ''
