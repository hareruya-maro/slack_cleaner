# slack_cleaner
A Powershell script that deletes messages on a specified channel before a specified date.

指定したチャンネルの指定した日付以前のメッセージを削除するPowershellスクリプトです。

## How to use
Set the following environment variables and execute.

If proxy authentication is not required, please change it appropriately.

* USER: User for proxy authentication
* PASSWORD: Password for proxy authentication
* PROXYHOST: Proxy authentication host & port number (http:// is not required)
* TOKEN:Slack API token
* DATECOUNT: how many days old messages should be deleted
* CHANNEL LIST: Target channel ID list (comma separated)

## 使い方
以下の環境変数を設定して実行します。

proxy認証が不要な場合は適宜変更して使用して下さい。

* USER:プロクシ認証用ユーザ
* PASSWORD:プロクシ認証用パスワード
* PROXYHOST:プロクシ認証ホスト＆ポート番号（http://は不要）
* TOKEN:Slack API token
* DATECOUNT:何日以上前のメッセージを削除するか
* CHANNELLIST:対象チャンネルIDリスト（カンマ区切り）
