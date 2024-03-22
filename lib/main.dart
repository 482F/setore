// TODO:
//   p2p sync
//   rsa encrypt drift:
//     https://drift.simonbinder.eu/docs/platforms/encryption/
//     https://pub.dev/packages/sqlcipher_flutter_libs
//     上記 package は flutter sdk が必要なので、dart のみでは使用できない
//     secret なフィールドのみ個別で暗号化するとか？あまり好ましくない・・・
//     Isar v4 であれば暗号化できるかも？
//     でも、どうせ基本的には flutter で使うものなのに
//     flutter test では使えそうだが、そもそも sqlcipher_flutter_libs を使うこと自体が難しい
//       sqlcipher.dll のビルドが必要 -> https://zenn.dev/shiena/articles/unity-sqlcipher
//   user defined field -> like relation table (id, entry_id, field_id, value)

void main() async {}
