<# 
 # Slackメッセージ一括削除スクリプト 
 # 指定したチャンネルの指定日時よりまえのメッセージを一括削除するスクリプト
 # 以下の環境変数を設定してから実行が必要です。
 # 
 # USER:プロクシ認証用ユーザ
 # PASSWORD:プロクシ認証用パスワード
 # PROXYHOST:プロクシ認証ホスト＆ポート番号（http://は不要）
 # TOKEN:Slack API token
 # DATECOUNT:何日以上前のメッセージを削除するか
 # CHANNELLIST:対象チャンネルIDリスト（カンマ区切り）
 #>

$user = $env:USER
$password = $env:PASSWORD
$proxyhost = $env:PROXYHOST
$proxyaddress = "http://$($proxyhost)/"
$proxyaddress_with_authenticattion = "http://$($user):$($password)@$($proxyhost)"
$env:http_proxy = $proxyaddress_with_authenticattion
$env:https_proxy = $proxyaddress_with_authenticattion
$env:ftp_proxy = $proxyaddress_with_authenticattion
$password_secure = ConvertTo-SecureString $password -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential $user, $password_secure
$proxy = New-Object System.Net.WebProxy $proxyaddress
$proxy.Credentials = $creds
[System.Net.WebRequest]::DefaultWebProxy = $proxy

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

function delMsg($t, $c, $ts, $u) {
    # $t  :Slack token
    # $c  :Channel ID
    # $ts :TimeStamp(過去の何日より前のメッセージを対象とするかを示すUNIX seconds)
    # $u  :対象ユーザID（指定しない場合は空文字""を渡す）

    do {
    
        $url = "https://slack.com/api/conversations.history?token=" + $t + "&channel=" + $c + "&inclusive=true&count=200&latest=" + $ts + "";
    
        $test = Invoke-RestMethod -Uri $url;

        $messages = $test.messages

        Write-Host "Get Message Count " $messages.Length 
    
        foreach ($message in $messages) {
    
            $msts = [double] $message.ts
            Write-Host $i ":" $msts " : " $message.is_starred
    
            if (($msts -lt $ts) -And (($u -eq "") -Or ($u -eq $message.user)) -And -Not( $message.is_starred)) {
                $url = "https://slack.com/api/chat.delete?token=" + $t + "&channel=" + $c + "&ts=" + $message.ts + "";
                Invoke-RestMethod -Uri $url;
                Start-Sleep -m 700

                # 返信がある場合、返信も削除する
                if ( $message.reply_count -gt 0) {
                    do {
                        # 返信の取得
                        $r_url = "https://slack.com/api/conversations.replies?token=" + $t + "&channel=" + $c + "&ts=" + $message.ts + "";
                        $replies = Invoke-RestMethod -Uri $r_url;
                        Start-Sleep -m 700

                        # 取得した返信をすべて削除する
                        $r_messages = $replies.messages
                        foreach ($r_message in $r_messages) {
                            $rd_url = "https://slack.com/api/chat.delete?token=" + $t + "&channel=" + $c + "&ts=" + $r_message.ts + "";
                            Invoke-RestMethod -Uri $rd_url;
                            Start-Sleep -m 700
                        }
                    } while ($replies.has_more -eq "True")
                }
            }
            $i = $i + 1
        }
    } while ($test.has_more -eq "True")
}

$token = $env:TOKEN
$dateCount = $env:DATECOUNT
$channelList = $env:CHANNELLIST

# 指定日数以上立ってるメッセージを対象とする
$weekago = (Get-Date).AddDays(-$dateCount)
$origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
$totalsec = ($weekago - $origin).TotalSeconds
$i = 1

$channelArray = $channelList.Split(",")

# 指定されたチャンネル分繰り返し実行
foreach ($channel in $channelArray) {
    Write-Host "Target Channel ID " $channel
    delMsg $token $channel $totalsec ""
}
